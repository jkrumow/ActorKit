//
//  TBActorRuntime.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorRuntime.h"

static NSString * const TBAKActorRuntimeQueue = @"com.tarbrain.ActorKit.TBActorRuntime";

@interface TBActorRuntime ()
@property (nonatomic, strong) NSMutableDictionary *priv_actors;
@property (nonatomic, strong) NSOperationQueue *workerQueue;
@end

@implementation TBActorRuntime

- (instancetype)init
{
    self = [super init];
    if (self) {
        _priv_actors = [NSMutableDictionary new];
    }
    return self;
}

- (NSDictionary *)actors
{
    return self.priv_actors.copy;
}

- (void)registerActor:(TBActor *)actor withName:(NSString *)name
{
    [self.priv_actors setObject:actor forKey:name];
}

- (void)removeActorWithName:(NSString *)name
{
    [self.priv_actors removeObjectForKey:name];
}

- (void)startup
{
    [self.priv_actors enumerateKeysAndObjectsUsingBlock:^(id key, TBActor *actor, BOOL *stop) {
        [actor startup];
    }];
}

- (void)shutDown
{
    [self.priv_actors enumerateKeysAndObjectsUsingBlock:^(id key, TBActor *actor, BOOL *stop) {
        [actor shutDown];
    }];
}

@end
