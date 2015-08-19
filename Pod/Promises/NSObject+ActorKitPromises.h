//
//  NSObject+ActorKitPromises.h
//  ActorKitPromises
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor.h"

/**
 *  This category extends NSObject with methods to use futues in async calls.
 */
@interface NSObject (ActorKitPromises) <TBActor>

/**
 *  Creates a TBActorProxyPromise instance to handle the message sent to the actor.
 *
 *  @return The TBActorProxyPromise instance.
 */
- (id)promise;
@end
