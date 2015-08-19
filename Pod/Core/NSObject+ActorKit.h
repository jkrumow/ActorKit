//
//  NSObject+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 19.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBActor.h"

FOUNDATION_EXPORT NSString * const TBAKActorPayload;

/**
 *  A block to configure a pool of actors.
 *
 *  @param actor The actor instance to configure.
 *  @param index The index of the actor in the pool.
 */
typedef void (^TBActorPoolConfigurationBlock)(NSObject<TBActor> *actor, NSUInteger index);

@protocol TBActor;
@class TBActorPool;
@interface NSObject (ActorKit) <TBActor>

@property (nonatomic, strong) NSOperationQueue *actorQueue;

/**
 *  Creates a pool of actors of the current class using a specified configuration block.
 *
 *  @param configuration The configuration block.
 *
 *  @return The created actor pool instance.
 */
+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration;
@end
