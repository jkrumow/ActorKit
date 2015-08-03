//
//  TBActorsTests.m
//  Tests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

#import "TestActor.h"


SpecBegin(TBActorProxy)

__block TBActorProxy *proxy;
__block TestActor *actor;


describe(@"TBActorProxy", ^{
    
    beforeEach(^{
        actor = [[TestActor alloc] init];
    });
    
    it (@"throws an exception when base class is created", ^{
        expect(^{
            [TBActorProxy proxyWithActor:actor];
        }).to.raise(TBAKException);
    });
    
    it (@"throws an exception when base class is initialized", ^{
        expect(^{
            proxy = [[TBActorProxy alloc] initWithActor:actor];
        }).to.raise(TBAKException);
    });
});

SpecEnd
