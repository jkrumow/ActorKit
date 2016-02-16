//
//  TBActorSupervisor.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBActorSupervision.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This block helps to create an actor.
 *
 *  @return The created actor.
 */
typedef NSObject * _Nonnull (^TBActorCreationBlock)(void);

@class TBActorSupervisionPool;

/**
 *  This class represents a supervisor pool to manage the lifecycle of multiple actors.
 *  It can detect crashes of actors and recreates them. If other actors are linked to a crashed actor they
 *  will be re-created recursively.
 *
 *  To access an actor by ID use keyed subscripting:
 *
 *  TBActorSupervisor *supervisor = ...
 *  NSObject *actor = supervisor[@"myActor"];
 */
@interface TBActorSupervisor : NSObject <TBActorSupervision>

/**
 *  The unique ID of the supervised actor.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 *  The block used to create the supervised actor.
 */
@property (nonatomic, copy, readonly) TBActorCreationBlock creationBlock;

/**
 *  IDs of linked actors.
 */
@property (nonatomic, readonly) NSMutableSet *links;

/**
 *  Initializes a supervisor with a given supervision pool instance.
 *
 *  @param pool    The supervision pool
 *  @param Id      The ID of the supervised actor
 *  @creationBlock The block to create the supervised actor
 *
 *  @return The initialized supervisor instance.
 */
- (instancetype)initWithPool:(TBActorSupervisionPool *)pool Id:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock NS_DESIGNATED_INITIALIZER;

/**
 *  Creates an actor and puts it under supervision.
 */
- (void)createActor;

/**
 *  Destroys an actor and creates a new instance.
 */
- (void)recreateActor;
@end
NS_ASSUME_NONNULL_END
