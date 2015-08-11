//
//  TBActorSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import <ActorKit/ActorKit.h>

#import "TestActor.h"


SpecBegin(TBActor)

__block TestActor *actor;
__block TestActor *otherActor;

describe(@"TBActor", ^{
    
    afterEach(^{
        actor = nil;
        otherActor = nil;
    });
    
    describe(@"initialization", ^{
        
        it(@"creates an actor with a given configuration block.", ^{
            actor = [TestActor actorWithConfiguration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @5;
            }];
            expect([actor.async isMemberOfClass:[TestActor class]]).to.beTruthy;
        });
        
        it(@"initializes itself with a given configuration block.", ^{
            actor = [[TestActor alloc] initWithConfiguration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @5;
            }];
            expect(actor.uuid).to.equal(@5);
        });
    });
    
    describe(@"usage", ^{
        
        beforeEach(^{
            actor = [TestActor actorWithConfiguration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @0;
            }];
            otherActor = [TestActor actorWithConfiguration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @1;
            }];
        });
        
        describe(@"sync", ^{
            
            it (@"returns a sync proxy.", ^{
                expect([actor.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            });
            
            it (@"invokes a method synchronuously.", ^{
                [actor.sync doSomething:@"foo" withCompletion:^(NSString *string){
                    NSLog(@"string: %@", string);
                }];
            });
        });
        
        describe(@"async", ^{
            
            it (@"returns an async proxy.", ^{
                expect([actor.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronuously.", ^{
                waitUntil(^(DoneCallback done) {
                    [actor.async doSomething:@"foo" withCompletion:^(NSString *string){
                        done();
                    }];
                });
            });
        });
        
        describe(@"future", ^{
            
            it (@"returns a future proxy.", ^{
                expect([actor.future isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronuously returning a value through a future.", ^{
                __block TBActorFuture *future;
                waitUntil(^(DoneCallback done) {
                    future = (TBActorFuture *)[actor.future returnSomethingBlocking];
                    future.completionBlock = ^{
                        done();
                    };
                });
                expect(future.result).to.equal(@0);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles broadcasted subscriptions and publishing.", ^{
                [actor subscribe:@"one" selector:@selector(handlerOne:)];
                
                expect(^{
                    [actor publish:@"one" payload:@5];
                }).to.notify(@"one");
                expect(actor.symbol).to.equal(@5);
                
            });
            
            it(@"handles messages from a specified actor.", ^{
                [actor subscribeToPublisher:otherActor withMessageName:@"two" selector:@selector(handlerTwo:)];
                actor.symbol = @5;
                
                [otherActor publish:@"two" payload:@10];
                expect(actor.symbol).to.equal(@10);
            });
            
            it(@"ignores messages from an unspecified actor.", ^{
                [actor subscribeToPublisher:otherActor withMessageName:@"two" selector:@selector(handlerTwo:)];
                actor.symbol = @5;
                
                [actor publish:@"two" payload:@10];
                expect(actor.symbol).to.equal(@5);
            });
        });
    });
});

SpecEnd
