//
//  TBActorProxy.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"
#import "TBActorPool.h"
#import "NSObject+ActorKit.h"
#import "NSException+ActorKit.h"


@implementation TBActorProxy

+ (TBActorProxy *)proxyWithActor:(NSObject *)actor
{
    @throw [NSException tbak_abstractClassException:[TBActorProxy class]];
    return nil;
}

- (instancetype)initWithActor:(NSObject *)actor
{
    if (self.class == TBActorProxy.class) {
        @throw [NSException tbak_abstractClassException:[TBActorProxy class]];
    }
    _actor = actor;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    if ([self.actor isKindOfClass:[TBActorPool class]]) {
        TBActorPool *pool = (TBActorPool *)self.actor;
        self.actor = [pool idleActor];
    }
    return [self.actor methodSignatureForSelector:selector];
}

- (void)freeActor
{
    if (self.actor.pool) {
        [self.actor.pool freeActor:self.actor];
    }
}

@end
