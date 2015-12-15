//
//  NSObject+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 19.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "TBActorPool.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The payload of a notification sent between actors.
 */
FOUNDATION_EXPORT NSString * const TBAKActorPayload;

/**
 *  This category extends NSObject with actor model functionality.
 */
@interface NSObject (ActorKit)

/**
 *  The actor's operation queue.
 */
@property (nonatomic) NSOperationQueue *actorQueue;

/**
 *  Stores notification name and selector of a subscription.
 */
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray *> *subscriptions;

/**
 *  The pool the actor may belong to.
 */
@property (nonatomic, weak, nullable) TBActorPool *pool;

/**
 *  The number of operations queued on this actor. Used only when inside a TBActorPool.
 */
@property (nonatomic) NSNumber *loadCount;

/**
 *  Suspends the actorQueue.
 */
- (void)tbak_suspend;

/**
 *  Resumes the actorQueue.
 */
- (void)tbak_resume;

/**
 *  Creates a TBActorProxySync instance to handle the message sent to the actor.
 *
 *  @return The TBActorProxySync instance.
 */
- (id)sync;

/**
 *  Creates a TBActorProxyAsync instance to handle the message sent to the actor.
 *
 *  @return The TBActorProxyAsync instance.
 */
- (id)async;

/**
 *  Stores subscription information in property 'subscriptions'.
 *
 *  @param notificationName The name of the notification to subscribe to.
 *  @param selector         The selector to execute whe receiving a notification.
 */
- (void)storeSubscription:(NSString *)notificationName selector:(SEL)selector;

/**
 *  Subscribes to an NSNotification sent from other actors.
 *
 *  @param notificationName The name of the notification.
 *  @param selector         The selector of the method to be called when receiving the notification.
 */
- (void)subscribe:(NSString *)notificationName selector:(SEL)selector;

/**
 *  Unsubscribes an NSNotification from other actors or generic senders.
 *
 *  @param notificationName The name of the notification.
 */
- (void)unsubscribe:(NSString *)notificationName;

/**
 *  Send a notification to other actors.
 *
 *  @param notificationName The name of the notification.
 *  @param payload          The payload of the notification.
 */
- (void)publish:(NSString *)notificationName payload:(nullable id)payload;

/**
 *  Creates a pool of actors of the current class using a specified configuration block.
 *
 *  @param configuration The configuration block.
 *
 *  @return The created actor pool instance.
 */
+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(nullable TBActorPoolConfigurationBlock)configuration;
@end

NS_ASSUME_NONNULL_END
