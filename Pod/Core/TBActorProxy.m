//
//  TBActorProxy.m
//  TBActors
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"
#import "TBActor.h"


@implementation TBActorProxy

+ (TBActorProxy *)proxyWithActor:(TBActor *)actor
{
    return nil; // throw exception "pseudo-abstract class"
}

- (instancetype)initWithActor:(TBActor *)actor
{
    self.actor = actor;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.actor methodSignatureForSelector:selector];
}

@end
