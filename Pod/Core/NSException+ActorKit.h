//
//  NSException+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString * const TBAKException;

/**
 *  This category extends NSException with methods to create library specific exception objects.
 */
@interface NSException (ActorKit)

/**
 *  The class or method you are using is abstract.
 *
 *  @param klass The class the exception refers to.
 *
 *  @return The created exception.
 */
+ (NSException *)tbak_abstractClassException:(Class)klass;

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
@end
