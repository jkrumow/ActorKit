//
//  TBActorProxySpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import <ActorKit/ActorKit.h>


SpecBegin(TBActorProxy)

__block TBActorProxy *proxy;
__block NSNumber *actor;


describe(@"TBActorProxy", ^{
    
    beforeEach(^{
        actor = @(0);
    });
    
    it (@"throws an exception when base class is initialized with designated initializer.", ^{
        expect(^{
            proxy = [[TBActorProxy alloc] initWithActor:actor];
        }).to.raise(TBAKException);
    });
});

SpecEnd
