//
//  TBActorPool+Futures.m
//  ActorKitFutures
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool+Futures.h"
#import "TBActorProxyFuture.h"

@implementation TBActorPool (Futures)

- (id)future
{
    return [TBActorProxyFuture proxyWithActor:[self _poolIdleActor]];
}

- (id)future:(void (^)(id))completion
{
    return [TBActorProxyFuture proxyWithActor:[self _poolIdleActor] completion:completion];
}

- (TBActor *)_poolIdleActor
{
    TBActor *idleActor = nil;
    NSUInteger lowest = NSUIntegerMax;
    @synchronized(self) {
        for (TBActor *actor in self.actors) {
            if (actor.operationCount == 0) {
                idleActor = actor;
                break;
            }
            if (actor.operationCount < lowest) {
                lowest = actor.operationCount;
                idleActor = actor;
            }
        }
    }
    return idleActor;
}

@end
