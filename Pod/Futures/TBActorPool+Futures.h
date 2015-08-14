//
//  TBActorPool+Futures.h
//  ActorKitFutures
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"

@interface TBActorPool (Futures)

- (id)future;
- (id)future:(void (^)(id result))completion;
@end
