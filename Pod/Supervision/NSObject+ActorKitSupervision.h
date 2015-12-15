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

@interface NSObject (ActorKitSupervision)

/**
 *  Reference to the current supervisor. Can be messaged through TBActorSupervison protocol.
 */
@property (nonatomic, weak, nullable) NSObject <TBActorSupervision> *supervisor;

/**
 *  Notifies the supervisor about the crash using the TBActorSupervison protocol.
 *
 *  @param error The optional error.
 */
- (void)crashWithError:(nullable NSError *)error;
@end
NS_ASSUME_NONNULL_END
