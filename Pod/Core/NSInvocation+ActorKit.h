//
//  NSInvocation+ActorKit.h
//  ActorKit
//
//  Created by Julian Krumow on 06.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This category extends NSInvocation with methods to create library specific exception objects.
 */
@interface NSInvocation (ActorKit)

/**
 *  Creates a copy of the invocation instance.
 *
 *  @return The copy.
 */
- (id)tbak_copy;
@end
