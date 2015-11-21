//
//  TBActorProxyBroadcast.h
//  ActorKit
//
//  Created by Julian Krumow on 15.09.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"

NS_ASSUME_NONNULL_BEGIN

@class TBActorPool;

/**
 *  This class represents a proxy which invokes message asynchronously on all actors inside a pool.
 */
@interface TBActorProxyBroadcast : TBActorProxy

/**
 *  The actor pool associated with this proxy instance.
 */
@property (nonatomic) TBActorPool *pool;

/**
 *  Initializes a proxy instance with a given actor pool.
 *
 *  @param pool The associated actor pool.
 *
 *  @return The initialized proxy instance.
 */
- (nullable instancetype)initWithPool:(TBActorPool *)pool;
@end
NS_ASSUME_NONNULL_END
