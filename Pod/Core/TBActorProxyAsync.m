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

+ (TBActorProxyAsync *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxyAsync alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [self.actor addOperation:operation];
}

@end
