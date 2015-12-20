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
#import "TBActorOperation+Supervision.h"
#import "TBACtorOperation.h"
#import "NSError+ActorKit.h"

static NSString * const TBAKActorSupervisorQueue = @"com.tarbrain.ActorKit.TBActorSupervisor";

@interface TBActorSupervisor ()
@property (nonatomic, weak) TBActorSupervisionPool *supervisionPool;
@property (nonatomic) NSObject *actor;
@end

@implementation TBActorSupervisor

- (instancetype)init
{
    return [self initWithPool:[TBActorSupervisionPool new] Id:@"" creationBlock:^NSObject * _Nonnull{
        return nil;
    }];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithPool:[TBActorSupervisionPool new] Id:@"" creationBlock:^NSObject * _Nonnull{
        return nil;
    }];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithPool:[TBActorSupervisionPool new] Id:@"" creationBlock:^NSObject * _Nonnull{
        return nil;
    }];
}

- (instancetype)initWithPool:(TBActorSupervisionPool *)pool Id:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock
{
    self = [super init];
    if (self) {
        self.actorQueue.name = TBAKActorSupervisorQueue;
        _supervisionPool = pool;
        _Id = Id;
        _creationBlock = creationBlock;
        _links = [NSMutableSet new];
        
        [self createActor];
    }
    return self;
}

#pragma mark - Creation

- (void)createActor
{
    NSObject *actor = self.creationBlock();
    actor.supervisor = self;
    self.actor = actor;
    self.supervisionPool[self.Id] = actor;
    [self _createLinkedActors];
}

#pragma mark - Recreation

- (void)recreateActor
{
    NSObject *actor = self.actor;
    [self.actor tbak_suspend];
    [self createActor];
    [self transferMailboxFromActor:actor toActor:self.actor];
    [self transferSubscriptionsFromActor:actor toActor:self.actor];
    [self.actor tbak_resume];
}

- (void)recreatePool
{
    TBActorPool *pool = (TBActorPool *)self.actor;
    [pool tbak_suspend];
    [self createActor];
    TBActorPool *newPool = (TBActorPool *)self.actor;
    [self transferMailboxesFromPool:pool toPool:newPool];
    [self transferSubscriptionsFromPool:pool toPool:newPool];
    [newPool tbak_resume];
}

- (void)recreateActor:(NSObject *)actor inPool:(TBActorPool *)pool
{
    [pool tbak_suspend];
    [pool removeActor:actor];
    NSObject *newActor = [pool createActor];
    [self transferMailboxFromActor:actor toActor:newActor];
    [self transferSubscriptionsFromActor:actor toActor:newActor];
    [pool tbak_resume];
}

- (void)transferMailboxFromActor:(NSObject *)actor toActor:(NSObject *)newActor
{
    newActor.actorQueue = actor.actorQueue;
    for (TBActorOperation *operation in newActor.actorQueue.operations) {
        if (![operation isKindOfClass:TBActorOperation.class] || (operation.isExecuting || operation.isCancelled || operation.isFinished)) {
            continue;
        }
        operation.invocation.target = newActor;
    }
}

- (void)transferMailboxesFromPool:(TBActorPool *)pool toPool:(TBActorPool *)newPool
{
    [self transferMailboxFromActor:pool toActor:newPool];
    NSArray *actors = pool.actors.allObjects;
    NSArray *newActors = newPool.actors.allObjects;
    for (NSUInteger index=0; index < actors.count; index++) {
        NSObject *actor = actors[index];
        NSObject *newActor = newActors[index];
        [self transferMailboxFromActor:actor toActor:newActor];
    }
}

- (void)transferSubscriptionsFromActor:(NSObject *)actor toActor:(NSObject *)newActor
{
    for (NSString *notificationName in actor.subscriptions.allKeys) {
        for (NSValue *value in actor.subscriptions[notificationName]) {
            SEL selector = value.pointerValue;
            [newActor subscribe:notificationName selector:selector];
        }
        [actor unsubscribe:notificationName];
    }
}

- (void)transferSubscriptionsFromPool:(TBActorPool *)pool toPool:(TBActorPool *)newPool
{
    [self transferSubscriptionsFromActor:pool toActor:newPool];
    NSArray *actors = pool.actors.allObjects;
    NSArray *newActors = newPool.actors.allObjects;
    for (NSUInteger index=0; index < actors.count; index++) {
        NSObject *actor = actors[index];
        NSObject *newActor = newActors[index];
        [self transferSubscriptionsFromActor:actor toActor:newActor];
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
    NSLog(@"Actor %p did crash with error: %@", actor, error.tbak_errorDescription);
    if ([actor isKindOfClass:[TBActorPool class]]) {
        [self recreatePool];
    } else {
        [self recreateActor];
    }
}

- (void)actor:(NSObject *)actor inPool:(TBActorPool *)pool didCrashWithError:(NSError *)error
{
    NSLog(@"Actor %p in pool %p did crash with error: %@", actor, pool, error.tbak_errorDescription);
    [self recreateActor:actor inPool:pool];
}

@end
