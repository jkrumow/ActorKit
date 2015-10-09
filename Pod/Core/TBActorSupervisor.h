//
//  TBActorSupervisor.h
//  Pods
//
//  Created by Julian Krumow on 09.10.15.
//
//

#import <Foundation/Foundation.h>

#import "TBActorSupervison.h"

/**
 *  This block helps to create an actor.
 *
 *  @param actor A pointer to the actor to create.
 */
typedef void (^TBActorCreationBlock)(NSObject **actor);

/**
 *  This class represents a supervisor pool to manage the lifecycle of multiple actors.
 *  It can detect crashes of actors and recreates them. If other actors are linked to a crashed actor they
 *  will be re-created recursively.
 *
 *  To access an actor by Id use keyed subscripting:
 *
 *  TBActorSupervisor *supervisor = ...
 *  NSObject *actor = supervisor[@"myActor"];
 */
@interface TBActorSupervisor : NSMutableDictionary <TBActorSupervison>

/**
 *  Creates an actor and puts it under supervision.
 *
 *  @param Id            The ID of the actor to create.
 *  @param creationBlock The block to create the actor.
 */
- (void)superviseWithId:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock;

/**
 *  Links two actors by their IDs. If the master actor crashes, the linked actor will be re-created s well.
 *
 *  @param linkedAactorId The actor to link.
 *  @param actorId        The actor to link to.
 */
- (void)linkActor:(NSString *)linkedActorId toActor:(NSString *)actorId;
@end
