//
//  TBActorProxyFuture.m
//  ActorKit
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyFuture.h"
#import "TBActor.h"
#import "NSInvocation+ActorKit.h"

@implementation TBActorProxyFuture

+ (TBActorProxyFuture *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxyFuture alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [invocation setReturnValue:&operation];
    [self.actor addOperation:operation];
}

@end
