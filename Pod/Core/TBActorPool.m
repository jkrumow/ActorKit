//
//  TBActorPool.m
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"

@interface TBActorPool ()
@property (nonatomic, strong) NSArray *priv_actors;
@end

@implementation TBActorPool

- (instancetype)initWithActors:(NSArray *)actors
{
    self = [super init];
    if (self) {
        _priv_actors = actors;
    }
    return self;
}

- (NSArray *)actors
{
    return self.priv_actors.copy;
}

- (id)sync
{
    return [TBActorProxySync proxyWithActors:self.actors];
}

- (id)async
{
    return [TBActorProxyAsync proxyWithActors:self.actors];
}

@end
