//
//  TBActorSupervisor.m
//  ActorKit
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisor.h"
#import "NSObject+ActorKit.h"

@interface TBActorSupervisionSet : NSObject
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, copy) TBActorCreationBlock creationBlock;
@property (nonatomic, strong) NSMutableSet *links;
@end
@implementation TBActorSupervisionSet
- (instancetype)init
{
    self = [super init];
    if (self) {
        _links = [NSMutableSet new];
    }
    return self;
}
@end

@interface TBActorSupervisor ()
@property (nonatomic, strong) NSMutableDictionary *priv_actors;
@property (nonatomic, strong) NSMutableDictionary *supervisionSets;
@end

@implementation TBActorSupervisor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _priv_actors = [NSMutableDictionary new];
        _supervisionSets = [NSMutableDictionary new];
    }
    return self;
}

- (void)superviseWithId:(NSString *)Id creationBlock:(TBActorCreationBlock)creationBlock
{
    TBActorSupervisionSet *set = [TBActorSupervisionSet new];
    set.Id = Id;
    set.creationBlock = creationBlock;
    [self.supervisionSets setObject:set forKey:Id];
    [self _createActorFromSet:set];
}

- (void)linkActor:(NSString *)linkedActorId toActor:(NSString *)actorId
{
    TBActorSupervisionSet *set = self.supervisionSets[actorId];
    [set.links addObject:linkedActorId];
}

#pragma mark - internal methods

- (void)_createActorFromSet:(TBActorSupervisionSet *)set
{
    NSObject *actor = nil;
    set.creationBlock(&actor);
    actor.supervisor = self;
    self.priv_actors[set.Id] = actor;
    [self _createLinkedActorsFromSet:set];
}

- (void)_createLinkedActorsFromSet:(TBActorSupervisionSet *)set
{
    [set.links enumerateObjectsUsingBlock:^(NSString *linkId, BOOL *stop) {
        TBActorSupervisionSet *linkedSet = self.supervisionSets[linkId];
        [self _createActorFromSet:linkedSet];
    }];
}

- (NSString *)_idForActor:(NSObject *)actor
{
    return [[self.priv_actors allKeysForObject:actor] firstObject];
}

#pragma mark - TBActorSupervison

- (void)actor:(NSObject *)actor didCrashWithError:(NSError *)error
{
    [actor cancel];
    [self _createActorFromSet:self.supervisionSets[[self _idForActor:actor]]];
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return self.priv_actors[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    self.priv_actors[key] = obj;
}

@end
