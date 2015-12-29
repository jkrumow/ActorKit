//
//  TBActorPoolSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/Promises.h>
#import "TestActor.h"


SpecBegin(TBActorPool)

__block TBActorPool *pool;
__block TestActor *actorOne;
__block TestActor *actorTwo;
__block TestActor *otherActor;
__block dispatch_queue_t testQueue;
__block dispatch_queue_t completionQueue;
__block NSMutableArray *addresses;

__block BOOL(^checkDistribution)(NSArray *, NSUInteger, NSUInteger) = ^BOOL(NSArray *data, NSUInteger poolSize, NSUInteger threshold) {
    NSLog(@"| worker | task count |");
    NSCountedSet *set = [NSCountedSet setWithArray:data];
    for (NSUInteger i=0; i < set.count; i++) {
        NSNumber *worker = @(i);
        NSUInteger count = [set countForObject:worker];
        NSLog(@"\t %@ \t\t %lu", worker, (unsigned long)count);
        if (count > threshold) {
            NSLog(@"error: task count of worker %@ exceeds threshold (%lu > %lu)", worker, (unsigned long)count, (unsigned long)threshold);
            return NO;
        }
    }
    return YES;
};

describe(@"TBActorPool", ^{
    
    afterEach(^{
        [pool unsubscribe:@"notification"];
        pool = nil;
        actorOne = nil;
        actorTwo = nil;
        otherActor = nil;
        testQueue = nil;
        completionQueue = nil;
        addresses = nil;
    });
    
    describe(@"initialization", ^{
        
        it(@"creates an empty pool when not initialized using designated initializer.", ^{
            pool = [[TBActorPool alloc] init];
            expect(pool).notTo.beNil;
            expect(pool.actors).to.beNil;
        });
        
        it(@"creates a pool of actors of its own class and a pool configuration block.", ^{
            pool = [TestActor poolWithSize:2 configuration:^(id actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(5);
            }];

            expect(pool.actors.count).to.equal(2);
            expect(pool.size).to.equal(2);

            actorOne = pool.actors.allObjects[0];
            actorTwo = pool.actors.allObjects[1];
            expect(actorOne).to.beInstanceOf([TestActor class]);
            expect(actorTwo).to.beInstanceOf([TestActor class]);
            expect(actorOne.uuid).to.equal(5);
            expect(actorTwo.uuid).to.equal(5);
        });
    });
    
    describe(@"invocations", ^{
        
        beforeEach(^{
            pool = [TestActor poolWithSize:2 configuration:^(NSObject *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(5);
            }];
            actorOne = pool.actors.allObjects[0];
            actorTwo = pool.actors.allObjects[1];
            otherActor = [TestActor new];
        });
        
        describe(@"sync", ^{
            
            it (@"returns a sync proxy", ^{
                expect([pool.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            });
            
            it(@"dispatches invocations synchronously to an idle actor.", ^{
                
                
                [pool.sync blockSomething];
                [pool.sync setSymbol:@123];
                
                if (actorOne.symbol) {
                    expect(actorOne.symbol).to.equal(@123);
                    expect(actorTwo.symbol).to.beNil;
                } else {
                    expect(actorOne.symbol).to.beNil;
                    expect(actorTwo.symbol).to.equal(@123);
                }
            });
        });
        
        describe(@"async", ^{
            
            it (@"returns an async proxy", ^{
                expect([pool.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
            });
            
            it(@"dispatches invocations asynchronously to an idle actor.", ^{
                waitUntil(^(DoneCallback done) {
                    [pool.async blockSomethingWithCompletion:^{
                        done();
                    }];
                    [pool.async setSymbol:@456];
                });
                
                if (actorOne.symbol) {
                    expect(actorOne.symbol).to.equal(456);
                    expect(actorTwo.symbol).to.beNil;
                } else {
                    expect(actorOne.symbol).to.beNil;
                    expect(actorTwo.symbol).to.equal(@456);
                }
            });
        });
        
        describe(@"broadcast", ^{
            
            it (@"returns an broadcast proxy", ^{
                TBActorProxyBroadcast *proxy = pool.broadcast;
                expect([proxy isMemberOfClass:[TBActorProxyBroadcast class]]).to.beTruthy;
            });
            
            it(@"dispatches invocations asynchronously to all actors.", ^{
                __block int count = 0;
                waitUntil(^(DoneCallback done) {
                    [pool.broadcast setSymbol:@456 withCompletion:^(NSNumber *symbol) {
                        count++;
                        if (count == 2) {
                            done();
                        }
                    }];
                });
                
                expect(actorOne.symbol).to.equal(@456);
                expect(actorTwo.symbol).to.equal(@456);
            });
        });
        
        describe(@"promise", ^{
            
            it (@"returns a promise proxy.", ^{
                expect([pool.promise isMemberOfClass:[TBActorProxyPromise class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronously on an idle actor returning a value through a promise.", ^{
                __block AnyPromise *promise;
                __block id blockResult;
                waitUntil(^(DoneCallback done) {
                    promise = (AnyPromise *)[pool.promise returnSomething];
                    promise.then(^(id result) {
                        blockResult = result;
                        done();
                    });
                });
                expect(blockResult).to.equal(@5);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles notifications from other actors.", ^{
                
                [pool subscribe:@"notification" selector:@selector(handler:)];
                
                waitUntil(^(DoneCallback done) {
                    actorOne.monitorBlock = ^{
                        done();
                    };
                    actorTwo.monitorBlock = ^{
                        done();
                    };
                    [pool publish:@"notification" payload:@8];
                });
                
                if (actorOne.symbol) {
                    expect(actorOne.symbol).to.equal(8);
                    expect(actorTwo.symbol).to.beNil;
                } else {
                    expect(actorOne.symbol).to.beNil;
                    expect(actorTwo.symbol).to.equal(8);
                }
            });
            
        });
    });
    
    describe(@"load distribution", ^{
        
        __block size_t poolSize = 10;
        __block size_t taskCount = 100;
        __block NSUInteger threshold = taskCount * 0.5;
        
        beforeEach(^{
            pool = [TestActor poolWithSize:poolSize configuration:nil];
            NSUInteger uuid = 0;
            for (TestActor *actor in pool.actors) {
                actor.uuid = @(uuid);
                uuid++;
            }
            otherActor = [TestActor new];
            testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
            completionQueue = dispatch_queue_create("completionQueue", DISPATCH_QUEUE_SERIAL);
            addresses = [NSMutableArray new];
        });
        
        it(@"seeds long work synchronously onto multiple actors", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSNumber *uuid = [pool.sync returnSomethingBlocking];
                dispatch_sync(completionQueue, ^{
                    [addresses addObject:uuid];
                });
            });
            expect(checkDistribution(addresses, poolSize, taskCount)).to.equal(YES);
        });
        
        it(@"seeds short work synchronously onto multiple actors", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSNumber *uuid = [pool.sync returnSomething];
                dispatch_sync(completionQueue, ^{
                    [addresses addObject:uuid];
                });
            });
            expect(checkDistribution(addresses, poolSize, taskCount)).to.equal(YES);
        });
        
        it(@"seeds long work asynchronously onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [pool.async returnSomethingBlockingWithCompletion:^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [addresses addObject:uuid];
                            if (addresses.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
            expect(checkDistribution(addresses, poolSize, threshold)).to.equal(YES);
        });
        
        it(@"seeds short work asynchronously onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [pool.async returnSomethingWithCompletion:^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [addresses addObject:uuid];
                            if (addresses.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
            expect(checkDistribution(addresses, poolSize, threshold)).to.equal(YES);
        });
        
        it(@"seeds long promised onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    AnyPromise *promise = (AnyPromise *)[pool.promise returnSomethingBlocking];
                    promise.then(^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [addresses addObject:uuid];
                            if (addresses.count == taskCount) {
                                done();
                            }
                        });
                    });
                });
            });
            expect(checkDistribution(addresses, poolSize, threshold)).to.equal(YES);
        });
        
        it(@"seeds short promised onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    AnyPromise *promise = (AnyPromise *)[pool.promise returnSomething];
                    promise.then(^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [addresses addObject:uuid];
                            if (addresses.count == taskCount) {
                                done();
                            }
                        });
                    });
                });
            });
            expect(checkDistribution(addresses, poolSize, threshold)).to.equal(YES);
        });
    });
});

SpecEnd
