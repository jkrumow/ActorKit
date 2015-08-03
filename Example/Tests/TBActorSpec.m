//
//  TBActorSpec.m
//  Tests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

#import "TestActor.h"

SpecBegin(TBActor)

__block TestActor *actor;

describe(@"TBActor", ^{
    
    beforeEach(^{
        actor = [[TestActor alloc] init];
    });
    
    it (@"executes a method synchronuously.", ^{
        [actor.sync doStuff];
    });
    
    it (@"executes a parameterized method synchronuously.", ^{
        [actor.sync doStuff:@"aaaaaah" withFooBar:666];
    });
    
    it (@"executes a method asynchronuously.", ^{
        [actor.async doStuff];
        
        sleep(0.1);
    });
    
    it (@"executes a parameterized method asynchronuously.", ^{
        [actor.async doStuff:@"aaaaaah" withFooBar:666];
        
        sleep(0.1);
    });
});

SpecEnd
