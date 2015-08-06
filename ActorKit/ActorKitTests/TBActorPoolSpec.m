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

describe(@"TBActorPool", ^{
    
    afterEach(^{
        pool = nil;
        otherActor = nil;
    });
    
    describe(@"initialization", ^{
        
        it(@"creates a pool of actors of its own class", ^{
            
            pool = [TestActor poolWithSize:2 configuration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @1;
            }];
            
            expect(pool.actors.count).to.equal(2);
            expect(pool.actors[0]).to.beInstanceOf([TestActor class]);
            expect(pool.actors[1]).to.beInstanceOf([TestActor class]);
        });
    });
    
    describe(@"usage", ^{
        
        beforeEach(^{
            pool = [TestActor poolWithSize:2 configuration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @1;
            }];
            otherActor = [[TestActor alloc] init];
        });
        
        describe(@"proxies", ^{
            
            it (@"returns a sync proxy", ^{
                
                expect([pool.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            });
            
            it (@"returns an async proxy", ^{
                
                expect([pool.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
            });
        });
        
        describe(@"method invocations", ^{
            
            it(@"dispatches invocations synchronuously to all pooled actors.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                actorOne.uuid = @1;
                actorTwo.uuid = @2;
                
                [pool.sync setSymbol:@123];
                expect(actorOne.symbol).to.equal(@123);
                expect(actorTwo.symbol).to.equal(@123);
            });
            
            it(@"dispatches invocations asynchronuously to all pooled actors.", ^{
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                actorOne.uuid = @1;
                actorTwo.uuid = @2;
                
                waitUntil(^(DoneCallback done) {
                    [pool.async setSymbol:@456 withCompletion:^(NSNumber *symbol){
                        done();
                    }];
                });
                
                expect(actorOne.symbol).to.equal(@456);
                expect(actorTwo.symbol).to.equal(@456);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles broadcasted subscriptions and publishing", ^{
                
                [pool subscribe:@"three" selector:@selector(handlerThree:)];
                
                expect(^{
                    [pool publish:@"three" payload:@8];
                }).to.notify(@"three");
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.symbol).to.equal(@8);
                expect(actorTwo.symbol).to.equal(@8);
                
            });
            
            it(@"handles messages from a specified actor", ^{
                
                [pool subscribeToPublisher:otherActor withMessageName:@"four" selector:@selector(handlerFour:)];
                [pool.sync setSymbol:@0];
                
                [otherActor publish:@"four" payload:@10];
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.symbol).to.equal(@10);
                expect(actorTwo.symbol).to.equal(@10);
            });
            
            it(@"ignores messages from an unspecified actor", ^{
                
                [pool subscribeToPublisher:otherActor withMessageName:@"four" selector:@selector(handlerFour:)];
                [pool.sync setSymbol:@0];
                
                [pool publish:@"four" payload:@10];
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.symbol).to.equal(@0);
                expect(actorTwo.symbol).to.equal(@0);
            });
        });
    });
});

SpecEnd
