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
    return [TBActorProxyFuture proxyWithActor:self.idleActor];
}

- (id)future:(void (^)(id))completion
{
    return [TBActorProxyFuture proxyWithActor:self.idleActor completion:completion];
}

@end
