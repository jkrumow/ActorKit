//
//  TBActorProxySync.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxySync.h"
#import "TBActor.h"
#import "NSInvocation+ActorKit.h"

@implementation TBActorProxySync

+ (TBActorProxySync *)proxyWithActors:(NSArray *)actors
{
    return [[TBActorProxySync alloc] initWithActors:actors];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (TBActor *actor in self.actors) {
        
        NSInvocation *actorInvocation = invocation.copy;
        [actorInvocation setTarget:actor];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:actorInvocation];
        [actor addOperation:operation];
        [actor waitUntilAllOperationsAreFinished];
    }
}

@end
