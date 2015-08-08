//
//  TBActorProxyFuture.m
//  ActorKit
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyFuture.h"
#import "TBActor.h"
#import "TBActorFuture.h"
#import "NSInvocation+ActorKit.h"

@implementation TBActorProxyFuture

+ (TBActorProxyFuture *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxyFuture alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];

    TBActorFuture *future = [[TBActorFuture alloc] initWithInvocation:invocation];
    [invocation setReturnValue:&future];
    [self.actor addOperation:future];
}

@end
