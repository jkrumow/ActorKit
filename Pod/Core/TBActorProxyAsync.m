//
//  TBActorProxyAsync.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyAsync.h"
#import "TBActor.h"

@implementation TBActorProxyAsync

+ (TBActorProxyAsync *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxyAsync alloc] initWithActor:actor];
}

+ (TBActorProxyAsync *)proxyWithActors:(NSArray *)actors
{
    return [[TBActorProxyAsync alloc] initWithActors:actors];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (TBActor *actor in self.actors) {
        [actor addOperationWithBlock:^{
            [invocation invokeWithTarget:actor];
        }];
    }
}

@end
