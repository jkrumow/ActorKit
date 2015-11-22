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

@interface NSError (ActorKit)

+ (instancetype)wrappingErrorForException:(NSException *)exception;

@end
NS_ASSUME_NONNULL_END
