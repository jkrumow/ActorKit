//
//  TBActorSupervisionPool.m
//  ActorKit
//
//  Created by Julian Krumow on 11.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisionPool.h"

@implementation TBActorSupervisionPool

- (instancetype)init
{
    self = [super init];
    if (self) {
        _priv_actors = [NSMutableDictionary new];
        _supervisors = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)idForActor:(NSObject *)actor
{
    return [[self.priv_actors allKeysForObject:actor] firstObject];
}

- (void)superviseWithId:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock
{
    TBActorSupervisor *supervisor = [[TBActorSupervisor alloc] initWithPool:self];
    supervisor.Id = Id;
    supervisor.creationBlock = creationBlock;
    self.supervisors[Id] = supervisor;
    [supervisor recreateActor];
}

- (void)linkActor:(NSString *)linkedActorId toActor:(NSString *)actorId
{
    TBActorSupervisor *supervisor = self.supervisors[actorId];
    [supervisor.links addObject:linkedActorId];
}

#pragma mark - Keyed subscripting

- (id)objectForKeyedSubscript:(NSString *)key
{
    return self.priv_actors[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    self.priv_actors[key] = obj;
}

@end
