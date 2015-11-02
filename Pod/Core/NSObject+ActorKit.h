//
//  NSObject+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 19.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 *  The payload of a notification sent between actors.
 */
FOUNDATION_EXPORT NSString * const TBAKActorPayload;

/**
 *  A block to configure a pool of actors.
 *
 *  @param actor The actor instance to configure.
 *  @param index The index of the actor in the pool.
 */
typedef void (^TBActorPoolConfigurationBlock)(NSObject *actor, NSUInteger index);

@class TBActorPool;

/**
 *  This category extends NSObject with actor model functionality.
 */
@interface NSObject (ActorKit)

/**
 *  The actor's operation queue.
 */
@property (nonatomic, strong) NSOperationQueue *actorQueue;

/**
 *  The pool the actor may belong to.
 */
@property (nonatomic, weak) TBActorPool *pool;

/**
 *  Returns the actor's operation queue.
 *
 *  @return The operation queue.
 */
- (NSOperationQueue *)actorQueue;

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
 *  Subscribes to an NSNotification sent from other actors.
 *
 *  @param messageName The name of the notification.
 *  @param selector    The selector of the method to be called when receiving the notification.
 */
- (void)subscribe:(NSString *)messageName selector:(SEL)selector;

/**
 *  Subscribes to an NSNotification sent from a specified actor.
 *
 *  @param actor       The actor to subscribe to.
 *  @param messageName The name of the notification.
 *  @param selector    The selector of the method to be called when receiving the notification.
 */
- (void)subscribeToActor:(NSObject *)actor messageName:(NSString *)messageName selector:(SEL)selector;

/**
 *  Subscribes to an NSNotification sent from a generic sender.
 *  The method specified by `selector` will receive the raw `userInfo` dictionary.
 *
 *  @param sender      The sender to subscribe to.
 *  @param messageName The name of the notification.
 *  @param selector    The selector of the method to be called when receiving the notification.
 */
- (void)subscribeToSender:(id)sender messageName:(NSString *)messageName selector:(SEL)selector;

/**
 *  Unsubscribes an NSNotification from other actors or generic senders.
 *
 *  @param messageName The name of the notification.
 */
- (void)unsubscribe:(NSString *)messageName;

/**
 *  Send a notification to other actors.
 *
 *  @param messageName The name of the notification.
 *  @param payload     The payload of the notification.
 */
- (void)publish:(NSString *)messageName payload:(id)payload;

/**
 *  Creates a pool of actors of the current class using a specified configuration block.
 *
 *  @param configuration The configuration block.
 *
 *  @return The created actor pool instance.
 */
+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration;
@end
