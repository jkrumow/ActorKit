//
//  TBActorPool+ActorKitSupervision.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 23.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"

NS_ASSUME_NONNULL_BEGIN

@interface TBActorPool (ActorKitSupervision)

/**
 *  Notifies the supervisor about the crash using the TBActorSupervison protocol.
 *
 *  @param actor The actor in the pool which has crashed.
 *  @param error The optional error.
 */
- (void)crashWithActor:(NSObject *)actor error:(nullable NSError *)error;
@end
NS_ASSUME_NONNULL_END
