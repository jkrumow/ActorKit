//
//  NSObject+ActorKitFutures.h
//  ActorKitFutures
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


/**
 *  This category extends NSObject with methods to use futures in async calls.
 */
@interface NSObject (ActorKitFutures)

/**
 *  Creates a TBActorProxyFuture instance to handle the message sent to the actor.
 *
 *  @return The TBActorProxyFuture instance.
 */
- (id)future;

/**
 *  Creates a TBActorProxyFuture instance to handle the message sent to the actor.
 *
 *  @param completion The completion block of the future.
 *
 *  @return The TBActorProxyFuture instance.
 */
- (id)future:(void(^)(id result))completion;
@end
