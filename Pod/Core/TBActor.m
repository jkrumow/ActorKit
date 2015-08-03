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


static NSString * const TBAKActorQueue = @"com.tarbrain.ActorKit.TBActorQueue";

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
    return [TBActorProxySync proxyWithActor:self];
}

- (id)async
{
    return [TBActorProxyAsync proxyWithActor:self];
}

@end
