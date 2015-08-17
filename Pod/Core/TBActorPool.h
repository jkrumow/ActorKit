//
//  TBActorPool.h
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBActor.h"

/**
 *  This class represents a pool of TBActor instances.
 */
@interface TBActorPool : TBActor

/**
 *  The actors in the pool.
 */
@property (nonatomic, strong, readonly) NSArray *actors;

/**
 *  Initializes a pool with an array of actors.
 *
 *  @param actors The array to be pooled.
 *
 *  @return The initialized TBActorPool instance.
 */
- (instancetype)initWithActors:(NSArray *)actors;

- (TBActor *)idleActor;
@end
