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
 *  @param actor A pointer to the actor to create.
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
@interface TBActorSupervisor : NSMutableDictionary <TBActorSupervision>

/**
 *  The unique ID of the supervised actor.
 */
@property (nonatomic) NSString *Id;

/**
 *  THe block used to create the supervised actor.
 */
@property (nonatomic, copy, nullable) TBActorCreationBlock creationBlock;

/**
 *  IDs of linked actors.
 */
@property (nonatomic) NSMutableSet *links;

/**
 *  Initializes a supervisor with a given supervision pool instance.
 *
 *  @param pool The supervision pool
 *
 *  @return The initialized supervisor instance.
 */
- (instancetype)initWithPool:(TBActorSupervisionPool *)pool NS_DESIGNATED_INITIALIZER;

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
