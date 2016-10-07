//
//  NSObject+ActorKitSupervision.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 21.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBActorSupervision.h"
#import "NSObject+ActorKit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This category extends NSObject with methods specific to supervision.
 */
@interface NSObject (ActorKitSupervision)

/**
 *  Reference to the current supervisor. Can be messaged through TBActorSupervison protocol.
 */
@property (nonatomic, weak, nullable) NSObject <TBActorSupervision> *supervisor;

/**
 *  Suspends the actorQueue.
 */
- (void)tbak_suspend;
    
/**
 *  Resumes the actorQueue.
 */
- (void)tbak_resume;
    
/**
 *  Returns `YES` when the actor or its pool is supervised.
 *
 *  @return `YES` when supervised.
 */
- (BOOL)isSupervised;

/**
 *  Notifies the supervisor about the crash using the TBActorSupervison protocol.
 *
 *  @param error The optional error.
 */
- (void)crashWithError:(nullable NSError *)error;
@end
NS_ASSUME_NONNULL_END
