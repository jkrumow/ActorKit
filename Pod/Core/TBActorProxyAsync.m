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

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([[NSOperationQueue currentQueue] isEqual:self.actor]) {
        [invocation invokeWithTarget:self.actor];
    } else {
        [self.actor addOperationWithBlock:^{
            [invocation invokeWithTarget:self.actor];
        }];
    }
}

@end
