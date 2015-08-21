//
//  TBActorSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import "TestActor.h"


SpecBegin(TBActor)

__block TestActor *actor;
__block NSMutableArray *otherActor;

describe(@"TBActor", ^{
    
    afterEach(^{
        [actor unsubscribe:@"message"];
        actor = nil;
        otherActor = nil;
    });
    
    describe(@"invocations", ^{
        
        beforeEach(^{
            actor = [TestActor new];
            actor.uuid = @0;
            otherActor = [NSMutableArray new];
        });

        describe(@"sync", ^{
            
            it (@"returns a sync proxy.", ^{
                expect([actor.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            });
            
            it (@"invokes a method synchronuously.", ^{
                __block NSString *result;
                [actor.sync doSomething:@"foo" withCompletion:^(NSString *string){
                    result = string;
                }];
                expect(result).to.equal(@"foo");
            });
        });

        describe(@"async", ^{
            
            it (@"returns an async proxy.", ^{
                expect([actor.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
            });
            
            it (@"invokes a method asynchronuously.", ^{
                __block NSString *result;
                waitUntil(^(DoneCallback done) {
                    [actor.async doSomething:@"foo" withCompletion:^(NSString *string){
                        result = string;
                        done();
                    }];
                });
                expect(result).to.equal(@"foo");
            });
        });

        describe(@"pubsub", ^{
            
            it (@"handles broadcasted subscriptions and publishing.", ^{
                [actor subscribe:@"message" selector:@selector(handler:)];
                
                expect(^{
                    [actor publish:@"message" payload:@5];
                }).to.notify(@"message");
                expect(actor.symbol).to.equal(@5);
            });
            
            it(@"handles messages from a specified actor.", ^{
                [actor subscribeToPublisher:otherActor withMessageName:@"message" selector:@selector(handler:)];
                actor.symbol = @5;
                
                [otherActor publish:@"message" payload:nil];
                expect(actor.symbol).to.beNil;
            });
            
            it(@"ignores messages from an unspecified actor.", ^{
                [actor subscribeToPublisher:otherActor withMessageName:@"message" selector:@selector(handler:)];
                actor.symbol = @5;
                
                [actor publish:@"message" payload:@10];
                expect(actor.symbol).to.equal(@5);
            });
        });

    });
});

SpecEnd
