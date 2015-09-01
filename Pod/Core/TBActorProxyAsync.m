//
//  TBActorProxyAsync.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyAsync.h"
#import "TBActorPool.h"
#import "NSObject+ActorKit.h"
#import "NSInvocation+ActorKit.h"

@implementation TBActorProxyAsync

+ (TBActorProxy *)proxyWithActor:(NSObject *)actor
{
    return [[TBActorProxyAsync alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    operation.completionBlock = ^{
        if (self.actor.pool) {
            [self.actor.pool freeActor:self.actor];
        }
    };
    [self.actor.actorQueue addOperation:operation];
}

@end
