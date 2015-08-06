//
//  TBActorProxyAsync.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyAsync.h"
#import "TBActor.h"
#import "NSInvocation+ActorKit.h"

@implementation TBActorProxyAsync

+ (TBActorProxyAsync *)proxyWithActors:(NSArray *)actors
{
    return [[TBActorProxyAsync alloc] initWithActors:actors];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (TBActor *actor in self.actors) {
        
        NSInvocation *actorInvocation = invocation.copy;
        [actorInvocation setTarget:actor];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:actorInvocation];
        [actor addOperation:operation];
    }
}

@end
