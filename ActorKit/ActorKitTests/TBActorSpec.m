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
__block TestActor *otherActor;

describe(@"TBActor", ^{
    
    afterEach(^{
        actor = nil;
        otherActor = nil;
    });
    
    describe(@"initialization", ^{
        
        it(@"initializes itself with a given configuration block", ^{
            
            actor = [[TestActor alloc] initWithConfiguration:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @5;
            }];
            expect(actor.uuid).to.equal(@5);
        });
    });
    
    describe(@"usage", ^{
        
        beforeEach(^{
            actor = [[TestActor alloc] init];
            otherActor = [[TestActor alloc] init];
        });
        
        describe(@"proxies", ^{
            
            it (@"returns a sync proxy", ^{
                
                expect([actor.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
                // expect(proxy).to.beInstanceOf([TBActorProxySync class]);
            });
            
            it (@"returns an async proxy", ^{
                
                expect([actor.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
                // expect(proxy).to.beInstanceOf([TBActorProxyAsync class]);
            });
        });
        
        describe(@"method invocations", ^{
            
            it (@"invokes a method synchronuously", ^{
                
                [actor.sync doStuff];
            });
            
            it (@"invokes a parameterized method synchronuously", ^{
                
                [actor.sync doStuff:@"foo" withCompletion:^(NSString *string){
                    NSLog(@"string: %@", string);
                }];
            });
            
            it (@"invokes a parameterized method asynchronuously", ^{
                
                [actor.async doStuff:@"foo" withCompletion:^(NSString *string){
                    NSLog(@"string: %@", string);
                }];
                sleep(0.1);
            });
        });
        
        describe(@"pubsub", ^{
            
            it (@"handles broadcasted subscriptions and publishing", ^{
                
                [actor subscribe:@"one" selector:@selector(handlerOne:)];
                
                expect(^{
                    [actor publish:@"one" payload:@5];
                }).to.notify(@"one");
                expect(actor.uuid).to.equal(@5);
                
            });
            
            it(@"handles messages from a specified actor", ^{
                
                [actor subscribeToPublisher:otherActor withMessageName:@"two" selector:@selector(handlerTwo:)];
                actor.uuid = @5;
                
                [otherActor publish:@"two" payload:@10];
                expect(actor.uuid).to.equal(@10);
            });
            
            it(@"ignores messages from an unspecified actor", ^{
                
                [actor subscribeToPublisher:otherActor withMessageName:@"two" selector:@selector(handlerTwo:)];
                actor.uuid = @5;
                
                [actor publish:@"two" payload:@10];
                expect(actor.uuid).to.equal(@5);
            });
        });
    });
});

SpecEnd
