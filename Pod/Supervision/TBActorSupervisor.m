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

- (void)createActor
{
    NSObject *actor = nil;
    self.creationBlock(&actor);
    actor.supervisor = self;
    self.actor = actor;
    self.supervisionPool[self.Id] = actor;
    [self _createLinkedActors];
}

- (void)recreateActor
{
    // Save invocations in mailbox and update target
    self.actor.actorQueue.suspended = YES;
    NSOperationQueue *queue = self.actor.actorQueue;
    [self createActor];
    self.actor.actorQueue = queue;
    [self updateInvocationTargetsInQueue:queue];
    queue.suspended = NO;
}

- (void)updateInvocationTargetsInQueue:(NSOperationQueue *)queue
{
    for (NSInvocationOperation *operation in queue.operations) {
        if (operation.isExecuting || operation.isCancelled || operation.isFinished) {
            continue;
        }
        operation.invocation.target = self.actor;
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
    [self recreateActor];
}

@end