//
//  TBActorProxy.h
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBActor.h"

/**
 *  This class represents an "abstract" base class for actor proxies.
 *
 *  It manages the outside method invocations on its actor.
 */
@interface TBActorProxy : NSProxy

/**
 *  The actor associated with this proxy instance.
 */
@property (nonatomic, strong, readonly) TBActor *actor;

/**
 *  Creates a proxy instance with a given actor. Must be overidden by a subtype.
 *
 *  Throws an exception when called on base class.
 *
 *  @param actor The associated actor.
 *
 *  @return The created proxy instance.
 */
+ (TBActorProxy *)proxyWithActor:(TBActor *)actor;

/**
 *  Initializes a proxy instance with a given actor. Must be overidden by a subtype.
 *
 *  Throws an exception when called on base class.
 *
 *  @param actor The associated actor.
 *
 *  @return The initialized proxy instance.
 */
- (instancetype)initWithActor:(TBActor *)actor;
@end
