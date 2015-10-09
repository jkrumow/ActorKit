//
//  TBActorSupervison.h
//  ActorKit
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This protocol describes an actor inside a supervision pool.
 */
@protocol TBActorSupervison <NSObject>

/**
 *  Notifies the receiver that the specified actor has crashed with an error.
 *
 *  @param actor The actor which has crashed.
 *  @param error The error describing the crash.
 */
- (void)actor:(NSObject *)actor didCrashWithError:(NSError *)error;
@end
