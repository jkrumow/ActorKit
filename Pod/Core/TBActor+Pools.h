//
//  TBActor+Pools.h
//  ActorKit
//
//  Created by Julian Krumow on 15.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"

/**
 *  A block to configure a pool of actors.
 *
 *  @param actor The actor instance to configure.
 *  @param index The index of the actor in the pool.
 */
typedef void (^TBActorPoolConfigurationBlock)(TBActor *actor, NSUInteger index);


/**
 *  This category adds support for the creation of actor pools to the TBActor class.
 */
@interface TBActor (Pools)

/**
 *  Creates a pool of actors of the current class using a specified configuration block.
 *
 *  @param configuration The configuration block.
 *
 *  @return The created actor pool instance.
 */
+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration;

@end
