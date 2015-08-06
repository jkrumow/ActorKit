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
__block TBActorPool *pool;

describe(@"TBActorRegistry", ^{
    
    beforeEach(^{
        registry = [TBActorRegistry new];
        actor = [TestActor new];
        pool = [TestActor poolWithSize:1 configuration:nil];
    });
    
    afterEach(^{
        registry = nil;
        actor = nil;
        pool = nil;
    });
    
    describe(@"registerActor:withName:", ^{
        
        it(@"stores an actor under a specified name.", ^{
            [registry registerActor:actor withName:@"actor"];
            [registry registerActor:pool withName:@"pool"];
            expect(registry.actors[@"actor"]).to.equal(actor);
            expect(registry.actors[@"pool"]).to.equal(pool);
        });
    });
    
    describe(@"removeActorWithName:", ^{
        
        it(@"stores an actor under a specified name.", ^{
            [registry registerActor:actor withName:@"actor"];
            [registry registerActor:pool withName:@"pool"];
            
            [registry removeActorWithName:@"foo"];
            expect(registry.actors[@"actor"]).to.equal(actor);
            expect(registry.actors[@"pool"]).to.equal(pool);
            
            [registry removeActorWithName:@"pool"];
            expect(registry.actors[@"actor"]).to.equal(actor);
            expect(registry.actors[@"pool"]).to.beNil;
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