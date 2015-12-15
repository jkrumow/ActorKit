//
//  TBActorOperation+Supervision.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 15.12.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This category extends TBActorOperation with methods specific to supervision.
 */
@interface TBActorOperation (Supervision)

/**
 *  Handles the crash of an invocation. Returns `YES` if the exception could be handled.
 *
 *  @param exception  The exceptioin to handle.
 *  @param invocation The invocation which caused the crash.
 *
 *  @return `YES` if the exception could be handled.
 */
- (BOOL)handleCrash:(NSException *)exception forInvocation:(NSInvocation *)invocation;
@end
NS_ASSUME_NONNULL_END
