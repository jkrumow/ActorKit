//
//  TBActorOperation.h
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class extends an NSBlockOperation with actor related functionality.
 */
@interface TBActorOperation : NSBlockOperation

/**
 *  The invocation to be executed by the operations main method.
 */
@property (nonatomic) NSInvocation *invocation;

/**
 *  Creates an TBActorOperation with a given NSInvocation.
 *
 *  @param invocation The invication to execute.
 *
 *  @return The created operation instance.
 */
+ (instancetype)operationWithInvocation:(NSInvocation *)invocation;
@end
NS_ASSUME_NONNULL_END
