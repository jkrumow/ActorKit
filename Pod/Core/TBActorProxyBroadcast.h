//
//  TBActorProxyBroadcast.h
//  ActorKit
//
//  Created by Julian Krumow on 15.09.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxy.h"

@class TBActorPool;
@interface TBActorProxyBroadcast : TBActorProxy

@property (nonatomic, strong) TBActorPool *pool;

+ (TBActorProxy *)proxyWithPool:(TBActorPool *)pool;
- (instancetype)initWithPool:(TBActorPool *)pool;
@end
