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

@interface TBActorProxyFuture ()
@property (nonatomic, strong) TBActorFuture *future;
@end

@implementation TBActorProxyFuture

+ (TBActorProxyFuture *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxyFuture alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSInvocation *forwardedInvocation = invocation.tbak_copy;
    [forwardedInvocation setTarget:self.actor];
    self.future = [[TBActorFuture alloc] initWithInvocation:forwardedInvocation];
    
    [invocation setSelector:@selector(returnFuture)];
    [invocation invoke];
    
    [self.actor addOperation:self.future];
}

- (id)returnFuture
{
    return self.future;
}

@end
