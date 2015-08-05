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

describe(@"TBActorPool", ^{
    
    afterEach(^{
        pool = nil;
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
                
                [pool.sync setUuid:@123];
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.uuid).to.equal(@123);
                expect(actorTwo.uuid).to.equal(@123);
                
                NSNumber *uuid = [pool.sync uuid];
                expect(uuid).to.equal(@123);
            });
            
            it(@"dispatches invocations synchronuously to all pooled actors.", ^{
                
                [pool.async setUuid:@456];
                sleep(0.5);
                
                TestActor *actorOne = pool.actors[0];
                TestActor *actorTwo = pool.actors[1];
                
                expect(actorOne.uuid).to.equal(@456);
                expect(actorTwo.uuid).to.equal(@456);
                
                NSNumber *uuid = [pool.async uuid];
                expect(uuid).to.beNil;
            });
        });
    });
});

SpecEnd
