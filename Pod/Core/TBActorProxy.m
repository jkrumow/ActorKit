//
//  TBActorProxy.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"
#import "TBActor.h"
#import "NSException+ActorKit.h"


@implementation TBActorProxy

+ (TBActorProxy *)proxyWithActor:(TBActor *)actor
{
    @throw [NSException tbak_abstractClassException:[TBActorProxy class]];
    return nil;
}

+ (TBActorProxy *)proxyWithActors:(NSArray *)actors
{
    @throw [NSException tbak_abstractClassException:[TBActorProxy class]];
    return nil;
}

- (instancetype)initWithActor:(TBActor *)actor
{
    if (self.class == TBActorProxy.class) {
        @throw [NSException tbak_abstractClassException:[TBActorProxy class]];
    }
    _actors = @[actor];
    return self;
}

- (instancetype)initWithActors:(NSArray *)actors
{
    if (self.class == TBActorProxy.class) {
        @throw [NSException tbak_abstractClassException:[TBActorProxy class]];
    }
    _actors = actors;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.actors.firstObject methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
}

@end
