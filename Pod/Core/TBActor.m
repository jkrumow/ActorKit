//
//  TBActor.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"


static NSString * const TBAKActorQueue = @"com.tarbrain.ActorKit.TBActor";

@interface TBActor ()
@property (nonatomic, strong)TBActorProxy *proxySync;
@property (nonatomic, strong)TBActorProxy *proxyAsync;
@end

@implementation TBActor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = TBAKActorQueue;
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (id)sync
{
    if (_proxySync == nil) {
        _proxySync = [TBActorProxySync proxyWithActor:self];
    }
    return _proxySync;
}

- (id)async
{
    if (_proxyAsync == nil) {
        _proxyAsync = [TBActorProxyAsync proxyWithActor:self];
    }
    return _proxyAsync;
}

@end
