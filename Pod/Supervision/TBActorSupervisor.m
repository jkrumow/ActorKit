//
//  TBActorSupervisor.m
//  ActorKitSupervision
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisor.h"
#import "TBActorSupervisionPool.h"
#import "NSObject+ActorKitSupervision.h"
#import "TBActorPool.h"

static NSString * const TBAKActorSupervisorQueue = @"com.tarbrain.ActorKit.TBActorSupervisor";

@interface TBActorSupervisor ()
@property (nonatomic, weak) TBActorSupervisionPool *supervisionPool;
@property (nonatomic) NSObject *actor;
@end

@implementation TBActorSupervisor

- (instancetype)init
{
    return [self initWithPool:[TBActorSupervisionPool new]];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithPool:[TBActorSupervisionPool new]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithPool:[TBActorSupervisionPool new]];
}

- (instancetype)initWithPool:(TBActorSupervisionPool *)pool
{
    self = [super init];
    if (self) {
        self.actorQueue.name = TBAKActorSupervisorQueue;
        _supervisionPool = pool;
        _links = [NSMutableSet new];
    }
    return self;
}

#pragma mark - Creation

- (void)createActor
{
    NSObject *actor = nil;
    self.creationBlock(&actor);
    actor.supervisor = self;
    self.actor = actor;
    self.supervisionPool[self.Id] = actor;
    [self _createLinkedActors];
}

#pragma mark - Recreation

- (void)recreateActor
{
    // Save invocations in mailbox and update target
    [self.actor suspend];
    NSOperationQueue *queue = self.actor.actorQueue;
    [self createActor];
    self.actor.actorQueue = queue;
    [self updateInvocationTarget:self.actor inQueue:queue];
    [self.actor resume];
}

- (void)recreatePool
{
    TBActorPool *pool = (TBActorPool *)self.actor;
    [pool suspend];
    NSOperationQueue *poolQueue = pool.actorQueue;
    NSArray *queues = [pool.actors valueForKeyPath:@"actorQueue"];
    [self createActor];
    TBActorPool *newPool = (TBActorPool *)self.actor;
    newPool.actorQueue = poolQueue;
    [self updateInvocationTarget:newPool inQueue:newPool.actorQueue];
    NSUInteger index = 0;
    for (NSObject *actor in newPool.actors) {
        actor.actorQueue = queues[index];
        [self updateInvocationTarget:actor inQueue:actor.actorQueue];
    }
    [newPool resume];
}

- (void)recreateActor:(NSObject *)actor inPool:(TBActorPool *)pool
{
    [pool suspend];
    NSOperationQueue *queue = actor.actorQueue;
    [pool removeActor:actor];
    NSObject *newActor = [pool createActor];
    [self updateInvocationTarget:newActor inQueue:queue];
    newActor.actorQueue = queue;
    [pool resume];
}

- (void)updateInvocationTarget:(NSObject *)target inQueue:(NSOperationQueue *)queue
{
    for (NSInvocationOperation *operation in queue.operations) {
        if (operation.isExecuting || operation.isCancelled || operation.isFinished) {
            continue;
        }
        operation.invocation.target = target;
    }
}

#pragma mark - Internal methods

- (void)_createLinkedActors
{
    NSArray *linkedSupervisors = [self.supervisionPool supervisorsForIds:self.links];
    for (TBActorSupervisor *supervisor in linkedSupervisors) {
        [supervisor.sync recreateActor];
    }
}

#pragma mark - TBActorSupervison

- (void)actor:(NSObject *)actor didCrashWithError:(NSError *)error
{
    if ([actor isKindOfClass:[TBActorPool class]]) {
        [self recreatePool];
    } else {
        [self recreateActor];
    }
}

- (void)actor:(NSObject *)actor inPool:(TBActorPool *)pool didCrashWithError:(NSError *)error
{
    [self recreateActor:actor inPool:pool];
}

@end
