//
//  TBActor.h
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBActor;

/**
 *  A block to configure an actor.
 *
 *  @param actor The actor instance to configure.
 */
typedef void (^TBActorConfigurationBlock)(TBActor *actor);

/**
 This class represents an actor.
 
 It is based on an NSOperationQueue which manages the actor's underlying thread.
 */
@interface TBActor : NSOperationQueue

/**
 *  Lists all messages the actor subscribes to.
 */
@property (nonatomic, strong) NSMutableSet *subscriptions;

/**
 *  Creates an actor using a specified configuration block.
 *
 *  @param configuration The configuration block.
 *
 *  @return The created actor instance.
 */
+ (instancetype)actorWithConfiguration:(TBActorConfigurationBlock)configuration;

/**
 *  Initializes an actor using a specified configuration block.
 *
 *  @param configuration The configuration block.
 *
 *  @return The initialized actor instance.
 */
- (instancetype)initWithConfiguration:(TBActorConfigurationBlock)configuration;

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
- (void)subscribeToPublisher:(id)actor withMessageName:(NSString *)messageName selector:(SEL)selector;

/**
 *  Send a notification to other actors.
 *
 *  @param messageName The name of the notification.
 *  @param payload     The payload of the notification.
 */
- (void)publish:(NSString *)messageName payload:(id)payload;
@end

