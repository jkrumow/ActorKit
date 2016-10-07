//
//  NSException+ActorKitSupervision.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 21.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This category extends NSException with methods to create supervision specific exception objects.
 */
@interface NSException (ActorKitSupervision)
    
/**
 *  Thrown when when the specified actor ID is already in use.
 *
 *  @param Id The actor ID in question.
 *
 *  @return The created exception.
 */
+ (NSException *)tbak_supervisionDuplicateException:(NSString *)Id;

/**
 *  Thrown when linking would cause circular references.
 *
 *  @param linkedActorId The actor to link.
 *  @param actorId       The actor to link to.
 *
 *  @return The created exception.
 */
+ (NSException *)tbak_supervisionLinkException:(NSString *)linkedActorId to:(NSString *)actorId;

/**
 *  Thrown when unlinking is not possible.
 *
 *  @param linkedActorId The actor to unlink.
 *  @param actorId       The actor to unlink from.
 *
 *  @return The created exception.
 */
+ (NSException *)tbak_supervisionUnlinkException:(NSString *)linkedActorId from:(NSString *)actorId;

@end
NS_ASSUME_NONNULL_END
