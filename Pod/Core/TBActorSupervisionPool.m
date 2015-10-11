//
//  TBActorSupervisionPool.m
//  ActorKit
//
//  Created by Julian Krumow on 11.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisionPool.h"
#import "NSObject+ActorKit.h"
#import "NSException+ActorKit.h"

@interface TBActorSupervisionPool ()
@property (nonatomic, strong) NSMutableDictionary *actors;
@property (nonatomic, strong) NSMutableDictionary *supervisors;
@end

@implementation TBActorSupervisionPool

- (instancetype)init
{
    self = [super init];
    if (self) {
        _actors = [NSMutableDictionary new];
        _supervisors = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)idForActor:(NSObject *)actor
{
    return [[self.actors allKeysForObject:actor] firstObject];
}

- (NSArray *)supervisorsForIds:(NSSet *)Ids
{
    NSMutableArray *supervisors = [[self.supervisors objectsForKeys:[Ids allObjects] notFoundMarker:[NSNull null]] mutableCopy];
    [supervisors removeObject:[NSNull null]];
    return supervisors;
}

- (void)superviseWithId:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock
{
    if (self.supervisors[Id]) {
        @throw [NSException tbak_supervisionDuplicateException:Id];
    }
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
    return self.actors[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    self.actors[key] = obj;
}

@end
