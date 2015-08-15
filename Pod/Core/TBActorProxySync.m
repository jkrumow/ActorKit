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

+ (TBActorProxy *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxySync alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [self.actor addOperation:operation];
    [self.actor waitUntilAllOperationsAreFinished];
}

@end
