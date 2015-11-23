//
//  TBActorProxySync.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxySync.h"
#import "NSObject+ActorKit.h"
#import "TBActorOperation.h"
#import "TBActorPool.h"

@implementation TBActorProxySync

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:self.actor];
    
    TBActorOperation *operation = [[TBActorOperation alloc] initWithInvocation:invocation];
    [self.actor.actorQueue addOperations:@[operation] waitUntilFinished:YES];
    [self relinquishActor];
}

@end
