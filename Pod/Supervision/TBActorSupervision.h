//
//  TBActorSupervison.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This protocol defines the interactor between an actor and a supervisor.
 */
@protocol TBActorSupervision <NSObject>

/**
 *  Notifies the receiver that the specified actor has crashed with an error.
 *
 *  @param actor The actor which has crashed.
 *  @param error The error describing the crash.
 */
- (void)actor:(NSObject *)actor didCrashWithError:(nullable NSError *)error;
@end
NS_ASSUME_NONNULL_END
