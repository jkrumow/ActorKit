//
//  TBActorProxySync.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxySync.h"
#import "TBActor.h"

@implementation TBActorProxySync

+ (TBActorProxySync *)proxyWithActor:(TBActor *)actor
{
    return [[TBActorProxySync alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([[NSOperationQueue currentQueue] isEqual:self.actor]) {
        [invocation invokeWithTarget:self.actor];
    } else {
        [self.actor addOperationWithBlock:^{
            [invocation invokeWithTarget:self.actor];
        }];
        [self.actor waitUntilAllOperationsAreFinished];
    }
}

@end
