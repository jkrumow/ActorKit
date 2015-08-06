//
//  TBActorRegistry.m
//  ActorKitTests
//
//  Created by Julian Krumow on 06.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import <ActorKit/ActorKit.h>

#import "TestActor.h"


SpecBegin(TBActorRegistry)

__block TBActorRegistry *registry;
__block TestActor *actor;
__block TestActor *otherActor;

describe(@"TBActorRegistry", ^{
    
    beforeEach(^{
        registry = [[TBActorRegistry alloc] init];
        actor = [[TestActor alloc] init];
        otherActor = [[TestActor alloc] init];
    });
    
    afterEach(^{
        registry = nil;
        actor = nil;
        otherActor = nil;
    });
    
    describe(@"registerActor:withName:", ^{
        
        it(@"stores an actor under a specified name.", ^{
            [registry registerActor:actor withName:@"actor"];
            [registry registerActor:otherActor withName:@"otherActor"];
            expect(registry.actors[@"actor"]).to.equal(actor);
            expect(registry.actors[@"otherActor"]).to.equal(otherActor);
        });
    });
    
    describe(@"removeActorWithName:", ^{
        
        it(@"stores an actor under a specified name.", ^{
            [registry registerActor:actor withName:@"actor"];
            [registry registerActor:otherActor withName:@"otherActor"];
            
            [registry removeActorWithName:@"foo"];
            expect(registry.actors[@"actor"]).to.equal(actor);
            expect(registry.actors[@"otherActor"]).to.equal(otherActor);
            
            [registry removeActorWithName:@"otherActor"];
            expect(registry.actors[@"actor"]).to.equal(actor);
            expect(registry.actors[@"otherActor"]).to.beNil;
        });
    });
    
    describe(@"startUp", ^{
        
        it(@"starts up the entire actor environment.", ^{
            [registry startUp];
        });
    });
    
    describe(@"shutDown", ^{
        
        it(@"shuts down the entire actor environment.", ^{
            [registry shutDown];
        });
    });
});

SpecEnd