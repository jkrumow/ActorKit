//
//  TBActorPoolSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import <ActorKit/ActorKit.h>

#import "TestActor.h"

SpecBegin(TBActorPool)

__block TBActorPool *pool;
__block TestActor *otherActor;
__block dispatch_queue_t testQueue;

describe(@"TBActorPool", ^{
    
    afterEach(^{
        pool = nil;
        otherActor = nil;
        testQueue = nil;
    });
    
    describe(@"initialization", ^{
        
        it(@"creates a pool of actors of its own class and a pool configuration block.", ^{
            pool = [TestActor poolWithSize:2 configuration:^(TBActor *actor, NSUInteger index) {
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
            pool = [TestActor poolWithSize:2 configuration:^(TBActor *actor, NSUInteger index) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @(index);
            }];
            otherActor = [TestActor new];
        });
        
        describe(@"sync", ^{
            
            it (@"returns a sync proxy", ^{
                expect([pool.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            });
            
            it(@"dispatches invocations synchronuously to an idle actor.", ^{
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool.sync blockSomething];
                [pool.sync setSymbol:@123];
                expect(actorOne.symbol).to.equal(@123);
                expect(actorTwo.symbol).to.beNil;
            });
        });
        
        describe(@"async", ^{
            
            it (@"returns an async proxy", ^{
                expect([pool.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
            });
            
            it(@"dispatches invocations asynchronuously to an idle actor.", ^{
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                waitUntil(^(DoneCallback done) {
                    [pool.async blockSomething:^{
                        done();
                    }];
                    [pool.async setSymbol:@456];
                });
                
                if (actorOne.symbol == nil && actorTwo.symbol == nil) {
                    XCTFail(@"One actor must set symbol.");
                }
                if (actorOne.symbol != nil && actorTwo.symbol != nil) {
                    XCTFail(@"Only one actor can set symbol.");
                }
            });
        });
        
        describe(@"future", ^{
            
            it (@"returns a future proxy.", ^{
                expect([pool.future isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronuously on an idle actor returning a value through a future.", ^{
                __block TBActorFuture *future = nil;
                waitUntil(^(DoneCallback done) {
                    [pool.async blockSomething:^{
                        done();
                    }];
                    future = (TBActorFuture *)[pool.future returnSomething];
                });
                expect(future.result).to.beInTheRangeOf(@0, @1);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles broadcasted subscriptions and publishing.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool subscribe:@"three" selector:@selector(handlerThree:)];
                
                waitUntil(^(DoneCallback done) {
                    actorOne.monitorBlock = ^{
                        done();
                    };
                    [pool publish:@"three" payload:@8];
                });
                
                expect(actorOne.symbol).to.equal(@8);
                expect(actorTwo.symbol).to.beNil;
            });
            
            it(@"handles messages from a specified actor.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool subscribeToPublisher:otherActor withMessageName:@"four" selector:@selector(handlerFour:)];
                
                waitUntil(^(DoneCallback done) {
                    actorOne.monitorBlock = ^{
                        done();
                    };
                    [otherActor publish:@"four" payload:@10];
                });
                
                expect(actorOne.symbol).to.equal(@10);
                expect(actorTwo.symbol).to.beNil;
            });
            
            it(@"ignores messages from an unspecified actor.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                [pool subscribeToPublisher:otherActor withMessageName:@"four" selector:@selector(handlerFour:)];
                
                [pool publish:@"four" payload:@10];
                expect(actorOne.symbol).to.beNil;
                
                expect(actorTwo.symbol).to.beNil;
            });
        });
    });
    
    describe(@"thread safety", ^{
        
        __block size_t loadSize = 30;
        
        beforeEach(^{
            pool = [TestActor poolWithSize:10 configuration:^(TBActor *actor, NSUInteger index) {
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
        
        it(@"seeds future work on multiple actors", ^{
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                TBActorFuture *future = (TBActorFuture *)[pool.future returnSomething];
                __block TBActorFuture *blockFuture = future;
                future.completionBlock = ^{
                    NSLog(@"future: uuid %@", blockFuture.result);
                };
            });
            sleep(1);
        });
        
        it(@"seeds work on multiple subscribers", ^{
            [pool subscribe:@"block" selector:@selector(blockSomething)];
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                [pool publish:@"block" payload:@500];
            });
            sleep(1);
        });
    });
});

SpecEnd
