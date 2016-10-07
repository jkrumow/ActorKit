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
#import "TBActorOperation.h"
#import "NSError+ActorKitSupervision.h"

static NSString * const TBAKActorSupervisorQueue = @"com.jkrumow.ActorKit.TBActorSupervisor";

@interface TBActorSupervisor ()
@property (nonatomic) NSObject *actor;
@end

@implementation TBActorSupervisor
@synthesize supervisionPool = _supervisionPool;

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

- (void)dealloc
{
    [self _destroyActor];
}

#pragma mark - Actor lifecycle

- (void)createActor
{
    _actor = self.creationBlock();
    self.actor.supervisor = self;
    self.supervisionPool[self.Id] = self.actor;
}

- (void)recreateActor
{
    NSObject *actor = self.actor;
    [actor tbak_suspend];
    [self createActor];
    [self _recreateLinkedActors];
    [self _transferMailboxFromActor:actor toActor:self.actor];
    [self _transferSubscriptionsFromActor:actor toActor:self.actor];
    [self.actor tbak_resume];
}

- (void)_recreatePool
{
    TBActorPool *pool = (TBActorPool *)self.actor;
    [pool tbak_suspend];
    [self createActor];
    [self _recreateLinkedActors];
    TBActorPool *newPool = (TBActorPool *)self.actor;
    [self _transferMailboxesFromPool:pool toPool:newPool];
    [self _transferSubscriptionsFromPool:pool toPool:newPool];
    [newPool tbak_resume];
}

- (void)_recreateActor:(NSObject *)actor inPool:(TBActorPool *)pool
{
    [pool tbak_suspend];
    [pool removeActor:actor];
    NSObject *newActor = [pool createActor];
    [self _transferMailboxFromActor:actor toActor:newActor];
    [self _transferSubscriptionsFromActor:actor toActor:newActor];
    [pool tbak_resume];
}

- (void)_recreateLinkedActors
{
    [self.supervisionPool updateSupervisorsWithIds:self.links];
}

- (void)_destroyActor
{
    for (NSString *link in self.links) {
        [self.supervisionPool unsuperviseActorWithId:link];
    }
    [self.actor tbak_suspend];
    [self _removeSubscriptionsFromActor:self.actor];
}

- (void)_transferMailboxFromActor:(NSObject *)actor toActor:(NSObject *)newActor
{
    newActor.actorQueue = actor.actorQueue;
    for (TBActorOperation *operation in newActor.actorQueue.operations) {
        if (![operation isKindOfClass:TBActorOperation.class] || (operation.isExecuting || operation.isCancelled || operation.isFinished)) {
            continue;
        }
        operation.invocation.target = newActor;
    }
}

- (void)_transferMailboxesFromPool:(TBActorPool *)pool toPool:(TBActorPool *)newPool
{
    [self _transferMailboxFromActor:pool toActor:newPool];
    for (NSUInteger index=0; index < pool.actors.count; index++) {
        NSObject *actor = pool.actors[index];
        NSObject *newActor = newPool.actors[index];
        [self _transferMailboxFromActor:actor toActor:newActor];
    }
}

- (void)_transferSubscriptionsFromActor:(NSObject *)actor toActor:(NSObject *)newActor
{
    for (NSString *notificationName in actor.subscriptions.allKeys) {
        for (NSValue *value in actor.subscriptions[notificationName]) {
            SEL selector = value.pointerValue;
            [newActor subscribe:notificationName selector:selector];
        }
    }
    [self _removeSubscriptionsFromActor:actor];
}

- (void)_removeSubscriptionsFromActor:(NSObject *)actor
{
    for (NSString *notificationName in actor.subscriptions.allKeys) {
        [actor unsubscribe:notificationName];
    }
}

- (void)_transferSubscriptionsFromPool:(TBActorPool *)pool toPool:(TBActorPool *)newPool
{
    [self _transferSubscriptionsFromActor:pool toActor:newPool];
    for (NSUInteger index=0; index < pool.actors.count; index++) {
        NSObject *actor = pool.actors[index];
        NSObject *newActor = newPool.actors[index];
        [self _transferSubscriptionsFromActor:actor toActor:newActor];
    }
}

#pragma mark - TBActorSupervison

- (void)actor:(NSObject *)actor didCrashWithError:(NSError *)error
{
    NSLog(@"Actor '%@' <%p> crashed: %@",
          [self.supervisionPool idForActor:actor], actor, error.tbak_errorDescription);
    
    [self recreateActor];
}

- (void)pool:(TBActorPool *)pool didCrashWithError:(NSError *)error
{
    NSLog(@"Pool '%@' <%p> crashed: %@",
          [self.supervisionPool idForActor:pool], pool, error.tbak_errorDescription);
    
    [self _recreatePool];
}

- (void)actor:(NSObject *)actor inPool:(TBActorPool *)pool didCrashWithError:(NSError *)error
{
    NSLog(@"Actor <%p> in pool '%@' <%p> crashed: %@",
          actor, [self.supervisionPool idForActor:pool], pool, error.tbak_errorDescription);
    
    [self _recreateActor:actor inPool:pool];
}

@end
