//
//  TBActorPool.m
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"
#import "TBActorProxyBroadcast.h"

static NSString * const TBAKActorPoolQueue = @"com.tarbrain.ActorKit.TBActorPool";

@interface TBActorPool ()
@property (nonatomic) NSMutableArray *priv_actors;
@property (nonatomic) NSMutableArray *loadCounters;

@property (nonatomic) Class klass;
@property (nonatomic, copy) TBActorPoolConfigurationBlock configuration;
@end

@implementation TBActorPool

- (instancetype)init
{
    return [self initWithSize:0 class:[NSObject class] configuration:nil];
}

- (instancetype)initWithSize:(NSUInteger)size class:(Class)klass configuration:(TBActorPoolConfigurationBlock)configuration
{
    self = [super init];
    if (self) {
        self.actorQueue.name = TBAKActorPoolQueue;
        
        _klass = klass;
        _configuration = configuration;
        
        _priv_actors = [NSMutableArray new];
        for (NSUInteger i=0; i < size; i++) {
            [self.priv_actors addObject:[self createActorWithIndex:i]];
        }
        [self.priv_actors makeObjectsPerformSelector:@selector(setPool:) withObject:self];
        
        _loadCounters = [NSMutableArray new];
        for (NSUInteger i=0; i < self.priv_actors.count; i++) {
            [self.loadCounters addObject:@(0)];
        }
    }
    return self;
}

- (void)dealloc
{
    [self.priv_actors makeObjectsPerformSelector:@selector(setPool:) withObject:nil];
}

- (NSArray *)actors
{
    return self.priv_actors.copy;
}

- (void)suspend
{
    [super suspend];
    for (NSObject *actor in self.actors) {
        actor.actorQueue.suspended = YES;
    }
}

- (void)resume
{
    for (NSObject *actor in self.actors) {
        actor.actorQueue.suspended = NO;
    }
    [super resume];
}

#pragma mark - Invocatons

- (id)broadcast
{
    return [[TBActorProxyBroadcast alloc] initWithPool:self];
}

#pragma mark - Pubsub

- (void)subscribeToActor:(NSObject *)actor messageName:(NSString *)messageName selector:(SEL)selector
{
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:actor
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [weakSelf.async performSelector:selector withObject:note.userInfo[TBAKActorPayload]];
#pragma clang diagnostic pop
                                                  }];
}

- (void)subscribeToSender:(id)sender messageName:(NSString *)messageName selector:(SEL)selector
{
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:sender
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [weakSelf.async performSelector:selector withObject:note.userInfo];
#pragma clang diagnostic pop
                                                  }];
}

#pragma mark - Manage actors in pool

- (NSObject *)availableActor
{
    NSObject *actor = nil;
    @synchronized(_priv_actors) {
        __block NSUInteger index = 0;
        __block NSUInteger lowest = NSUIntegerMax;
        [self.loadCounters enumerateObjectsUsingBlock:^(NSNumber *count, NSUInteger idx, BOOL *stop) {
            if (count.unsignedIntegerValue == 0) {
                index = idx;
                *stop = YES;
            }
            if (count.unsignedIntegerValue < lowest) {
                lowest = count.unsignedIntegerValue;
                index = idx;
            }
        }];
        actor = self.priv_actors[index];
        self.loadCounters[index] = @(lowest + 1);
    }
    return actor;
}

- (void)relinquishActor:(NSObject *)actor
{
    @synchronized(_priv_actors) {
        if (![self.priv_actors containsObject:actor]) {
            return;
        }
        NSUInteger index = [self.priv_actors indexOfObject:actor];
        NSUInteger value = [self.loadCounters[index] unsignedIntegerValue];
        value -= 1;
        MAX(0, value);
        self.loadCounters[index] = @(value);
    }
}

- (void)removeActor:(NSObject *)actor
{
    @synchronized(_priv_actors) {
        if (![self.priv_actors containsObject:actor]) {
            return;
        }
        NSUInteger index = [self.priv_actors indexOfObject:actor];
        [self.priv_actors removeObjectAtIndex:index];
        [self.loadCounters removeObjectAtIndex:index];
    }
}

- (NSObject *)createActor
{
    @synchronized(_priv_actors) {
        NSObject *actor = [self createActorWithIndex:self.priv_actors.count];
        [self.priv_actors addObject:actor];
        [self.loadCounters addObject:@(0)];
        return actor;
    }
}

- (NSObject *)createActorWithIndex:(NSUInteger)index
{
    NSObject *actor = [self.klass new];
    if (self.configuration) {
        self.configuration(actor, index);
    }
    return actor;
}

@end
