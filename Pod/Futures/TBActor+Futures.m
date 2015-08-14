//
//  TBActor+Futures.m
//  ActorKitFutures
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor+Futures.h"
#import "TBActorProxyFuture.h"

@implementation TBActor (Futures)

- (id)future:(void (^)(id))completion
{
    return [TBActorProxyFuture proxyWithActor:self completion:completion];
}

@end
