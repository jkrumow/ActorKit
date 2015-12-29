//
//  TBActorPool.h
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A block to configure a pool of actors.
 *
 *  @param actor The actor instance to configure.
 */
typedef void (^TBActorPoolConfigurationBlock)(NSObject *actor);

/**
 *  This class represents a pool of actor instances.
 */
@interface TBActorPool : NSObject

/**
 *  The actors in the pool.
 */
@property (nonatomic, readonly) NSSet<__kindof NSObject *> *actors;

/**
 *  Designated initializer for a pool with an array of actors.
 *
 *  @param size         The size of the pool.
 *  @param klass        The class of the pooled actors.
 *  @param confguration The configurationblock to set up the actors.
 *
 *  @return The initialized TBActorPool instance.
 */
- (instancetype)initWithSize:(NSUInteger)size
                       class:(Class)klass
               configuration:(nullable TBActorPoolConfigurationBlock)configuration NS_DESIGNATED_INITIALIZER;

/**
 *  The size of the pool.
 *
 *  @return The size.
 */
- (NSUInteger)size;

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

/**
 *  Removes a given actor from the pool.
 *
 *  @param actor The actor to remove.
 */
- (void)removeActor:(NSObject *)actor;

/**
 *  Creates and adds a new actor to the pool.
 *
 *  @return The created actor instance.
 */
- (NSObject *)createActor;
@end
NS_ASSUME_NONNULL_END
