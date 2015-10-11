//
//  TBActorSupervisionPool.h
//  ActorKit
//
//  Created by Julian Krumow on 11.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBActorSupervisor.h"

@interface TBActorSupervisionPool : NSObject

/**
 *  Creates an actor, puts it under supervision and adds it to the supervision pool.
 *
 *  @exception Throws an exception when an ID is already in use.
 *
 *  @param Id            The ID of the actor to create.
 *  @param creationBlock The block to create the actor.
 */
- (void)superviseWithId:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock;

/**
 *  Links two actors by their IDs. If the master actor crashes, the given supervisor
 *  will re-create the linked actors as well.
 *
 *  @param linkedAactorId The actor to link.
 *  @param actorId        The actor to link to.
 */
- (void)linkActor:(NSString *)linkedActorId toActor:(NSString *)actorId;

/**
 *  Returns the ID of a given actor instance
 *
 *  @param actor The actor instance.
 *
 *  @return The ID of the given actor instance. Can be nil if actor does not exist.
 */
- (NSString *)idForActor:(NSObject *)actor;

/**
 *  Returns supervisors for a given set actor ids.
 *
 *  @param Ids A set of actor IDs.
 *
 *  @return An array containing all supervisors.
 */
- (NSArray *)supervisorsForIds:(NSSet *)Ids;

- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
@end
