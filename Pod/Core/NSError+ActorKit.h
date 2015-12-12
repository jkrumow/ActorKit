//
//  NSError+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const TBAKErrorDomain;
FOUNDATION_EXPORT NSString * const TBAKUnderlyingException;

/**
 *  This category extends NSError with ActorKit functionality.
 */
@interface NSError (ActorKit)

/**
 *  Returns a wrapping error containing a given NSException object.
 *
 *  @param exception The exception to wrap.
 *
 *  @return The created NSError instance.
 */
+ (instancetype)tbak_wrappingErrorForException:(NSException *)exception;

- (NSString *)tbak_errorDescription;

@end
NS_ASSUME_NONNULL_END
