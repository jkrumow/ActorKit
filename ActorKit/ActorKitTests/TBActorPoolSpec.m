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
__block TestActor *otherActor;
__block dispatch_queue_t testQueue;
__block dispatch_queue_t completionQueue;
__block NSMutableArray *results;

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
        [pool unsubscribe:@"message"];
        pool = nil;
        otherActor = nil;
        testQueue = nil;
        completionQueue = nil;
        results = nil;
    });
    
    describe(@"initialization", ^{
        
        it(@"creates an empty pool when not initialized using designated initializer.", ^{
            pool = [[TBActorPool alloc] init];
            expect(pool).notTo.beNil;
            expect(pool.actors).to.beNil;
        });
        
        it(@"creates a pool of actors of its own class and a pool configuration block.", ^{
            pool = [TestActor poolWithSize:2 configuration:^(id actor, NSUInteger index) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(index);
            }];
            
            expect(pool.actors.count).to.equal(2);
            
            TestActor *actorOne = pool.actors[0];
            TestActor *actorTwo = pool.actors[1];
            
            expect(actorOne).to.beInstanceOf([TestActor class]);
            expect(actorTwo).to.beInstanceOf([TestActor class]);
            expect(actorOne.uuid).to.equal(@0);
            expect(actorTwo.uuid).to.equal(@1);
        });
    });
    
    describe(@"invocations", ^{
        
        beforeEach(^{
            pool = [TestActor poolWithSize:2 configuration:^(id actor, NSUInteger index) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(index);
            }];
            otherActor = [TestActor new];
        });
        
        describe(@"sync", ^{
            
            it (@"returns a sync proxy", ^{
                expect([pool.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            });
            
            it(@"dispatches invocations synchronously to an idle actor.", ^{
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
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
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
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
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
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
            
            beforeEach(^{
                pool = [TestActor poolWithSize:2 configuration:^(NSObject *actor, NSUInteger index) {
                    TestActor *testActor = (TestActor *)actor;
                    testActor.uuid = @(index);
                }];
                otherActor = [TestActor new];
            });
            
            it (@"returns a promise proxy.", ^{
                expect([pool.promise isMemberOfClass:[TBActorProxyPromise class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronously on an idle actor returning a value through a promise.", ^{
                __block PMKPromise *promise;
                __block id blockResult;
                waitUntil(^(DoneCallback done) {
                    promise = (PMKPromise *)[pool.promise returnSomething];
                    promise.then(^(id result) {
                        blockResult = result;
                        done();
                    });
                });
                expect(blockResult).to.beInTheRangeOf(@0, @1);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles messages from other actors.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool subscribe:@"message" selector:@selector(handler:)];
                
                waitUntil(^(DoneCallback done) {
                    actorOne.monitorBlock = ^{
                        done();
                    };
                    actorTwo.monitorBlock = ^{
                        done();
                    };
                    [pool publish:@"message" payload:@8];
                });
                
                if (actorOne.symbol) {
                    expect(actorOne.symbol).to.equal(8);
                    expect(actorTwo.symbol).to.beNil;
                } else {
                    expect(actorOne.symbol).to.beNil;
                    expect(actorTwo.symbol).to.equal(8);
                }
            });
            
            it(@"handles messages from a specified actor.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool subscribeToActor:otherActor messageName:@"message" selector:@selector(handler:)];
                
                waitUntil(^(DoneCallback done) {
                    actorOne.monitorBlock = ^{
                        done();
                    };
                    actorTwo.monitorBlock = ^{
                        done();
                    };
                    [otherActor publish:@"message" payload:@10];
                });
                
                if (actorOne.symbol) {
                    expect(actorOne.symbol).to.equal(@10);
                    expect(actorTwo.symbol).to.beNil;
                } else {
                    expect(actorOne.symbol).to.beNil;
                    expect(actorTwo.symbol).to.equal(@10);
                }
            });
            
            it(@"ignores messages from an unspecified actor.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool subscribeToActor:otherActor messageName:@"message" selector:@selector(handler:)];
                
                [pool publish:@"message" payload:@10];
                expect(actorOne.symbol).to.beNil;
                expect(actorTwo.symbol).to.beNil;
            });
            
            it(@"handles generic NSNotifications", ^{
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                NSObject *sender = [NSObject new];
                [pool subscribeToSender:sender messageName:@"message" selector:@selector(handlerRaw:)];
                
                waitUntil(^(DoneCallback done) {
                    actorOne.monitorBlock = ^{
                        done();
                    };
                    actorTwo.monitorBlock = ^{
                        done();
                    };
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"message" object:sender userInfo:@{@"symbol":@5}];
                });
                
                if (actorOne.symbol) {
                    expect(actorOne.symbol).to.equal(@5);
                    expect(actorTwo.symbol).to.beNil;
                } else {
                    expect(actorOne.symbol).to.beNil;
                    expect(actorTwo.symbol).to.equal(@5);
                }
            });
        });
    });
    
    describe(@"load distribution", ^{
        
        __block size_t poolSize = 10;
        __block size_t taskCount = 100;
        __block NSUInteger threshold = taskCount * 0.5;
        
        beforeEach(^{
            pool = [TestActor poolWithSize:poolSize configuration:^(id actor, NSUInteger index) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(index);
            }];
            otherActor = [TestActor new];
            testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
            completionQueue = dispatch_queue_create("completionQueue", DISPATCH_QUEUE_SERIAL);
            results = [NSMutableArray new];
        });
        
        it(@"seeds long work synchronously onto multiple actors", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSNumber *uuid = [pool.sync returnSomethingBlocking];
                dispatch_sync(completionQueue, ^{
                    [results addObject:uuid];
                });
            });
            expect(checkDistribution(results, poolSize, taskCount)).to.equal(YES);
        });
        
        it(@"seeds short work synchronously onto multiple actors", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSNumber *uuid = [pool.sync returnSomething];
                dispatch_sync(completionQueue, ^{
                    [results addObject:uuid];
                });
            });
            expect(checkDistribution(results, poolSize, taskCount)).to.equal(YES);
        });
        
        it(@"seeds long work asynchronously onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [pool.async returnSomethingBlockingWithCompletion:^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
            expect(checkDistribution(results, poolSize, threshold)).to.equal(YES);
        });
        
        it(@"seeds short work asynchronously onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [pool.async returnSomethingWithCompletion:^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
            expect(checkDistribution(results, poolSize, threshold)).to.equal(YES);
        });
        
        it(@"seeds long promised onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    PMKPromise *promise = (PMKPromise *)[pool.promise returnSomethingBlocking];
                    promise.then(^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    });
                });
            });
            expect(checkDistribution(results, poolSize, threshold)).to.equal(YES);
        });
        
        it(@"seeds short promised onto multiple actors", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    PMKPromise *promise = (PMKPromise *)[pool.promise returnSomething];
                    promise.then(^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    });
                });
            });
            expect(checkDistribution(results, poolSize, threshold)).to.equal(YES);
        });
    });
});

SpecEnd
