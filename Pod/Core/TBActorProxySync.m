//
//  TBActorProxySync.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxySync.h"
#import "TBActorPool.h"
#import "NSObject+ActorKit.h"
#import "NSInvocation+ActorKit.h"

@implementation TBActorProxySync

+ (TBActorProxy *)proxyWithActor:(NSObject *)actor
{
    return [[TBActorProxySync alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [self.actor.actorQueue addOperation:operation];
    [self.actor.actorQueue waitUntilAllOperationsAreFinished];
    
    if (self.actor.pool) {
        [self.actor.pool freeActor:self.actor];
    }
}

@end
