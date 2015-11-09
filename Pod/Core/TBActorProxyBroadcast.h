//
//  TBActorProxyBroadcast.h
//  ActorKit
//
//  Created by Julian Krumow on 15.09.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"

@class TBActorPool;

/**
 *  This class represents a proxy which invokes message asynchronously on all actors inside a pool.
 */
@interface TBActorProxyBroadcast : TBActorProxy

/**
 *  The actor pool associated with this proxy instance.
 */
@property (nonatomic, strong, nonnull) TBActorPool *pool;

/**
 *  Initializes a proxy instance with a given actor pool.
 *
 *  @param pool The associated actor pool.
 *
 *  @return The initialized proxy instance.
 */
- (nullable instancetype)initWithPool:(nonnull TBActorPool *)pool;
@end
