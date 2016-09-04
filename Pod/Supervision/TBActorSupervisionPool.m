//
//  TBActorSupervisionPool.m
//  ActorKitSupervision
//
//  Created by Julian Krumow on 11.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisionPool.h"
#import "NSObject+ActorKit.h"
#import "NSException+ActorKitSupervision.h"

static NSString * const TBAKActorSupervisionPoolQueue = @"com.jkrumow.ActorKit.TBActorSupervisionPool";

@interface TBActorSupervisionPool ()
@property (nonatomic) NSMutableDictionary *actors;
@property (nonatomic) NSMutableDictionary *supervisors;
@end

@implementation TBActorSupervisionPool

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id _sharedInstance = nil;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actorQueue.name = TBAKActorSupervisionPoolQueue;
        _actors = [NSMutableDictionary new];
        _supervisors = [NSMutableDictionary new];
    }
    return self;
}

- (void)superviseWithId:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock
{
    if (self.supervisors[Id]) {
        @throw [NSException tbak_supervisionDuplicateException:Id];
    }
    self.supervisors[Id] = [[TBActorSupervisor alloc] initWithPool:self Id:Id creationBlock:creationBlock];
}

- (void)unsuperviseActorWithId:(NSString *)Id
{
    [self.actors removeObjectForKey:Id];
    [self.supervisors removeObjectForKey:Id];
}

- (void)linkActor:(NSString *)actorId toParentActor:(NSString *)parentActorId
{
    [self _validateLinkFrom:actorId to:parentActorId];
    TBActorSupervisor *supervisor = self.supervisors[parentActorId];
    [supervisor.links addObject:actorId];
}

- (NSString *)idForActor:(NSObject *)actor
{
    return [self.actors allKeysForObject:actor].firstObject;
}

- (NSArray *)supervisorsForIds:(NSSet *)Ids
{
    NSMutableArray *supervisors = [[self.supervisors objectsForKeys:Ids.allObjects
                                                     notFoundMarker:[NSNull null]]
                                   mutableCopy];
    [supervisors removeObject:[NSNull null]];
    return supervisors;
}

- (void)updateSupervisorsWithIds:(NSSet *)Ids
{
    NSArray *supervisors = [self supervisorsForIds:Ids];
    for (TBActorSupervisor *supervisor in supervisors) {
        [supervisor.sync recreateActor];
    }
}

- (void)_validateLinkFrom:(NSString *)actorId to:(NSString *)parentActorId
{
    TBActorSupervisor *supervisor = self.supervisors[actorId];
    if ([supervisor.links containsObject:parentActorId]) {
        @throw [NSException tbak_supervisionLinkException:actorId to:parentActorId];
    }
    for (NSString *linkId in supervisor.links) {
        [self _validateLinkFrom:linkId to:parentActorId];
    }
}

#pragma mark - Keyed subscripting

- (id)objectForKeyedSubscript:(NSString *)key
{
    return (self.actors.sync)[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    (self.actors.sync)[key] = obj;
}

@end
