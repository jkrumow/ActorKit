//
//  NSException+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TBAKException;

@interface NSException (ActorKit)

+ (NSException *)tbak_abstractClassException:(Class)klass;

@end
