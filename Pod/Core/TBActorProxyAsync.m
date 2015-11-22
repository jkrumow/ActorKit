//
//  TBActorProxyAsync.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyAsync.h"
#import "NSObject+ActorKit.h"
#import "TBActorOperation.h"
#import "TBActorPool.h"

@implementation TBActorProxyAsync

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];
    TBActorOperation *operation = [TBActorOperation operationWithInvocation:invocation];
    operation.completionBlock = ^{
        [self relinquishActor];
    };
    [self.actor.actorQueue addOperation:operation];
}

@end
