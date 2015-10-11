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

@class TBActorSupervisionPool;

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

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, copy) TBActorCreationBlock creationBlock;
@property (nonatomic, strong) NSMutableSet *links;

- (instancetype)initWithPool:(TBActorSupervisionPool *)pool NS_DESIGNATED_INITIALIZER;

- (void)createActor;
- (void)recreateActor;
@end
