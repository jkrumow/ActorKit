//
//  NSObject+ActorKitFutures.m
//  ActorKitFutures
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import "NSObject+ActorKitFutures.h"
#import "TBActorProxyFuture.h"

@implementation NSObject (ActorKitFutures)

- (id)future
{
    return [TBActorProxyFuture proxyWithActor:self];
}

- (id)future:(void (^)(id))completion
{
    return [TBActorProxyFuture proxyWithActor:self completion:completion];
}

@end
