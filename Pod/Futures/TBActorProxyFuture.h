//
//  TBActorProxyFuture.h
//  ActorKitFutures
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"

@interface TBActorProxyFuture : TBActorProxy

/**
 *  Creates a proxy instance with a given actor and a completion block.
 *
 *  @param actor      The associated actor.
 *  @param completion The future's completion block.
 *
 *  @return The created proxy instance.
 */
+ (TBActorProxyFuture *)proxyWithActor:(NSObject<TBActor> *)actor completion:(void (^)(id))completion;

/**
 *  Initializes a proxy instance with a given actor and a completion block.
 *
 *  @param actor      The associated actor.
 *  @param completion The future's completion block.
 *
 *  @return The initialized proxy instance.
 */
- (instancetype)initWithActor:(NSObject<TBActor> *)actor completion:(void (^)(id))completion;
@end
