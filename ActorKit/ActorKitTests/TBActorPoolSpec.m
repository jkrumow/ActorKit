//
//  TBActorPoolSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import "TestActor.h"

SpecBegin(TBActorPool)

__block TBActorPool *pool;
__block TestActor *otherActor;
__block dispatch_queue_t testQueue;

describe(@"TBActorPool", ^{
    
    afterEach(^{
        [pool unsubscribe:@"message"];
        pool = nil;
        otherActor = nil;
        testQueue = nil;
    });
    
    describe(@"initialization", ^{
        
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
                    [pool.async blockSomething:^{
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
    
    describe(@"thread safety", ^{
        
        __block size_t loadSize = 30;
        
        beforeEach(^{
            pool = [TestActor poolWithSize:10 configuration:^(id actor, NSUInteger index) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(index);
            }];
            otherActor = [TestActor new];
            testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
        });
        
        it(@"seeds sync work on multiple actors", ^{
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                NSNumber *uuid = [pool.sync uuid];
                NSLog(@"uuid: %@", uuid);
            });
            sleep(1);
        });
        
        it(@"seeds async work on multiple actors", ^{
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                [pool.async blockSomething];
            });
            sleep(1);
        });
        
        it(@"seeds work on multiple subscribers", ^{
            [pool subscribe:@"message" selector:@selector(blockSomething)];
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                [pool publish:@"message" payload:@500];
            });
            sleep(1);
        });
    });
});

SpecEnd
