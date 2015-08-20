//
//  TBActorPool+Promises.h
//  ActorKitPromises
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"

/**
 *  This category adds support for promises to TBActorPool.
 */
@interface TBActorPool (Promises)

/**
 *  Creates a TBActorProxyPromise instance to handle the message sent to the actor.
 *
 *  @return The TBActorProxyPromise instance.
 */
- (id)promise;
@end
