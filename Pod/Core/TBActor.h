//
//  TBActor.h
//  ActorKit
//
//  Created by Julian Krumow on 19.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBActor <NSObject>
@optional

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
- (void)subscribeToPublisher:(id)actor withMessageName:(NSString *)messageName selector:(SEL)selector;

/**
 *  Unsubscribes an NSNotification from other actors.
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

@end
