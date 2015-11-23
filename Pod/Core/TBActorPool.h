//
//  TBActorPool.h
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+ActorKit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a pool of actor instances.
 */
@interface TBActorPool : NSObject

/**
 *  The actors in the pool.
 */
@property (nonatomic, readonly) NSArray<__kindof NSObject *> *actors;

/**
 *  Designated initializer for a pool with an array of actors.
 *
 *  @param actors The array to be pooled.
 *
 *  @return The initialized TBActorPool instance.
 */
- (instancetype)initWithSize:(NSUInteger)size class:(Class)klass configuration:(nullable TBActorPoolConfigurationBlock)configuration NS_DESIGNATED_INITIALIZER;

/**
 *  Creates a TBActorProxyBroadcast instance to handle the message sent to the pool.
 *
 *  @return The TBActorProxyBroadcast instance.
 */
- (id)broadcast;

/**
 *  Returns an available actor from the pool. This will be the least busy actor in the pool.
 *
 *  @return The available actor.
 */
- (NSObject *)availableActor;

/**
 *  Tells the receiver that a task has been processed on the specified actor.
 *  Influences the load distribution inside the pool.
 *
 *  @param actor The actor to relinquish.
 */
- (void)relinquishActor:(NSObject *)actor;
@end
NS_ASSUME_NONNULL_END
