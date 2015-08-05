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
__block TBActor *actor;


describe(@"TBActorProxy", ^{
    
    beforeEach(^{
        actor = [[TBActor alloc] init];
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
