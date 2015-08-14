//
//  TBActor+Futures.h
//  ActorKitFutures
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor.h"

@interface TBActor (Futures)

- (id)future:(void(^)(id value))completion;
@end
