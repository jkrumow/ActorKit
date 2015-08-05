//
//  TBActorSpec.m
//  Tests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

SpecBegin(TBActor)

__block TestActor *actor;
__block TestActor *otherActor;

describe(@"TBActor", ^{
    
    beforeEach(^{
        actor = [[TestActor alloc] init];
        otherActor = [[TestActor alloc] init];
    });
    
    afterEach(^{
        actor = nil;
        otherActor = nil;
    });
    
    describe(@"initialization", ^{
    
        it(@"initializes itself with a given configuration block.", ^{
        
            TestActor *blockActor = [[TestActor alloc] initWithBlock:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @5;
            }];
            expect(blockActor.uuid).to.equal(@5);
        });
    });
    
    describe(@"proxies", ^{
        
        it (@"returns a sync proxy.", ^{
            
            id proxy = actor.sync;
            BOOL isClass = [proxy isMemberOfClass:[TBActorProxySync class]];
            expect(isClass).to.beTruthy;
        });
        
        it (@"returns an async proxy.", ^{
            
            id proxy = actor.sync;
            BOOL isClass = [proxy isMemberOfClass:[TBActorProxyAsync class]];
            expect(isClass).to.beTruthy;
        });
    });
    
    describe(@"method invocations", ^{
        
        it (@"invokes a method synchronuously.", ^{
            
            [actor.sync doStuff];
        });
        
        it (@"invokes a parameterized method synchronuously.", ^{
            
            [actor.sync doStuff:@"aaaaaah" withCompletion:^(NSString *string){
                NSLog(@"string: %@", string);
            }];
        });
        
        it (@"invokes a parameterized method asynchronuously.", ^{
            
            [actor.async doStuff:@"aaaaaah" withCompletion:^(NSString *string){
                NSLog(@"string: %@", string);
            }];
            sleep(0.1);
        });
    });
    
    describe(@"pubsub", ^{
        
        it (@"handles broadcasted subscriptions and publishing", ^{
            
            [actor subscribe:@"one" selector:@selector(handlerOne:)];
            
            expect(^{
                [actor post:@"one" payload:@5];
            }).to.notify(@"one");
            expect(actor.uuid).to.equal(@5);
            
        });
        
        it(@"handles messages from a specified actor", ^{
            
            [actor subscribeToPublisher:otherActor withMessageName:@"two" selector:@selector(handlerTwo:)];
            actor.uuid = @5;
            
            [actor post:@"two" payload:@10];
            expect(actor.uuid).to.equal(@5);
            
            [otherActor post:@"two" payload:@10];
            expect(actor.uuid).to.equal(@10);
        });
    });
});

SpecEnd
