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

+ (TBActorProxySync *)proxyWithActors:(NSArray *)actors
{
    return [[TBActorProxySync alloc] initWithActors:actors];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (TBActor *actor in self.actors) {
        [actor addOperationWithBlock:^{
            [invocation invokeWithTarget:actor];
        }];
        [actor waitUntilAllOperationsAreFinished];
    }
}

@end
