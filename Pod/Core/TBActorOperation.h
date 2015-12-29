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
 *  This class represents an operation to execute an NSInvocation on an actor's operation queue.
 *  It catches exceptions and passes them on via the selector `tbak_handleCrash:(NSException *)exception forInvocation:(NSInvocation *)invocation` if a subtype or a category implements it.
 */
@interface TBActorOperation : NSOperation

/**
 *  The invocation to be executed by the operations main method.
 */
@property (nonatomic) NSInvocation *invocation;

/**
 *  Initializes an TBActorOperation with a given NSInvocation.
 *
 *  @param invocation The invication to execute.
 *
 *  @return The initialized operation instance.
 */
- (instancetype)initWithInvocation:(NSInvocation *)invocation NS_DESIGNATED_INITIALIZER;
@end
NS_ASSUME_NONNULL_END
