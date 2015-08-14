//
//  TBActorProxyFuture.h
//  ActorKitFutures
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"

@interface TBActorProxyFuture : TBActorProxy
+ (TBActorProxyFuture *)proxyWithActor:(TBActor *)actor completion:(void (^)(id))completion;
- (instancetype)initWithActor:(TBActor *)actor completion:(void (^)(id))completion;
@end
