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
        
        it(@"initializes itself with a given configuration block", ^{
            
            TestActor *blockActor = [[TestActor alloc] initWithBlock:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @5;
            }];
            expect(blockActor.uuid).to.equal(@5);
        });
    });
    
    describe(@"proxies", ^{
        
        it (@"returns a sync proxy", ^{
            
            expect([actor.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
            // expect(proxy).to.beMemberOf([TBActorProxySync class]);
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
            
            [actor.sync doStuff:@"aaaaaah" withCompletion:^(NSString *string){
                NSLog(@"string: %@", string);
            }];
        });
        
        it (@"invokes a parameterized method asynchronuously", ^{
            
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
    
    describe(@"pools", ^{
        
        it(@"creates a pool of actors of its own class", ^{
            
            TBActorPool *pool = [TestActor poolWithSize:2 block:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @1;
            }];
            expect(pool.actors.count).to.equal(2);
            expect(pool.actors[0]).to.beInstanceOf([TestActor class]);
            expect(pool.actors[1]).to.beInstanceOf([TestActor class]);
        });
        
        it(@"dispatches invocations synchronuously to all pooled actors.", ^{
            
            TBActorPool *pool = [TestActor poolWithSize:2 block:^(TBActor *actor) {
                TestActor *testActor = (TestActor *)actor;
                testActor.uuid = @1;
            }];
            
            [pool.sync setUuid:@123];
            
            TestActor *actorOne = pool.actors[0];
            TestActor *actorTwo = pool.actors[1];
            
            expect(actorOne.uuid).to.equal(@123);
            expect(actorTwo.uuid).to.equal(@123);
            
            [pool.async setUuid:@456];
            sleep(0.5);
            
            actorOne = pool.actors[0];
            actorTwo = pool.actors[1];
            
            expect(actorOne.uuid).to.equal(@456);
            expect(actorTwo.uuid).to.equal(@456);
            
            NSNumber *uuid = [pool.sync uuid];
            expect(uuid).to.equal(@456);
            
            uuid = [pool.async uuid];
            expect(uuid).to.beNil;
        });
    });
});

SpecEnd
