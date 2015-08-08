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

describe(@"TBActorPool", ^{
    
    afterEach(^{
        pool = nil;
        otherActor = nil;
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
    
    describe(@"usage", ^{
        
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
                
                expect(actorOne.symbol).to.beNil;
                expect(actorTwo.symbol).to.equal(@456);
            });
        });
        
        describe(@"future", ^{
            
            it (@"returns a future proxy.", ^{
                expect([pool.future isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronuously returning a value through a future.", ^{
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                actorOne.symbol = @100;
                actorTwo.symbol = @200;
                
                __block TBActorFuture *future = nil;
                waitUntil(^(DoneCallback done) {
                    [pool.async blockSomething:^{
                        done();
                    }];
                    future = (TBActorFuture *)[pool.future symbol];
                });
                expect(future.result).to.equal(@200);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles broadcasted subscriptions and publishing.", ^{
                [pool subscribe:@"three" selector:@selector(handlerThree:)];
                
                expect(^{
                    [pool publish:@"three" payload:@8];
                }).to.notify(@"three");
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.symbol).to.equal(@8);
                expect(actorTwo.symbol).to.beNil;
                
            });
            
            it(@"handles messages from a specified actor.", ^{
                [pool subscribeToPublisher:otherActor withMessageName:@"four" selector:@selector(handlerFour:)];
                [pool.sync setSymbol:@0];
                
                [otherActor publish:@"four" payload:@10];
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.symbol).to.equal(@10);
                expect(actorTwo.symbol).to.beNil;
            });
            
            it(@"ignores messages from an unspecified actor.", ^{
                [pool subscribeToPublisher:otherActor withMessageName:@"four" selector:@selector(handlerFour:)];
                [pool.sync setSymbol:@0];
                
                [pool publish:@"four" payload:@10];
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.symbol).to.equal(@0);
                expect(actorTwo.symbol).to.beNil;
            });
        });
    });
});

SpecEnd
