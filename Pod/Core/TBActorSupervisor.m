//
//  TBActorSupervisor.m
//  ActorKit
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisor.h"
#import "TBActorSupervisionPool.h"
#import "NSObject+ActorKit.h"

@interface TBActorSupervisor ()
@property (nonatomic, strong) NSObject *actor;
@property (nonatomic, strong) TBActorSupervisionPool *pool;
@end

@implementation TBActorSupervisor

- (instancetype)init
{
    return [self initWithPool:nil];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithPool:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithPool:nil];
}

- (instancetype)initWithPool:(TBActorSupervisionPool *)pool
{
    self = [super init];
    if (self) {
        _pool = pool;
        _links = [NSMutableSet new];
    }
    return self;
}

- (void)createActor
{
    NSObject *actor = nil;
    self.creationBlock(&actor);
    actor.supervisor = self;
    self.actor = actor;
    self.pool[self.Id] = actor;
    [self _createLinkedActors];
}

- (void)recreateActor
{
    [self.actor cancel];
    [self createActor];
}

#pragma mark - internal methods

- (void)_createLinkedActors
{
    [self.links enumerateObjectsUsingBlock:^(NSString *linkId, BOOL *stop) {
        TBActorSupervisor *linkedSupervisor = self.pool.supervisors[linkId];
        [linkedSupervisor recreateActor];
    }];
}

#pragma mark - TBActorSupervison

- (void)actor:(NSObject *)actor didCrashWithError:(NSError *)error
{
    [self recreateActor];
}

@end
