//
//  TBActorPool+ActorKitSupervision.h
//  Pods
//
//  Created by Julian Krumow on 23.11.15.
//
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
