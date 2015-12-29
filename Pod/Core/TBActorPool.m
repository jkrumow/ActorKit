//
//  TBActorPool.m
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool.h"
#import "NSObject+ActorKit.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"
#import "TBActorProxyBroadcast.h"

static NSString * const TBAKActorPoolQueue = @"com.tarbrain.ActorKit.TBActorPool";

@interface TBActorPool ()
@property (nonatomic) NSMutableSet *priv_actors;
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
        
        _priv_actors = [NSMutableSet new];
        for (NSUInteger i=0; i < size; i++) {
            [self.priv_actors addObject:[self _createActor]];
        }
        [self.priv_actors makeObjectsPerformSelector:@selector(setPool:) withObject:self];
    }
    return self;
}

- (void)dealloc
{
    [self.priv_actors makeObjectsPerformSelector:@selector(setPool:) withObject:nil];
}

- (NSSet *)actors
{
    return self.priv_actors.copy;
}

- (void)tbak_suspend
{
    [super tbak_suspend];
    for (NSObject *actor in self.actors) {
        actor.actorQueue.suspended = YES;
    }
}

- (void)tbak_resume
{
    for (NSObject *actor in self.actors) {
        actor.actorQueue.suspended = NO;
    }
    [super tbak_resume];
}

#pragma mark - Invocatons

- (id)broadcast
{
    return [[TBActorProxyBroadcast alloc] initWithPool:self];
}

#pragma mark - Pubsub

- (void)subscribe:(NSString *)notificationName selector:(SEL)selector
{
    [self storeSubscription:notificationName selector:selector];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:notificationName
                                                      object:nil
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [weakSelf.async performSelector:selector withObject:note.userInfo[TBAKActorPayload]];
#pragma clang diagnostic pop
                                                  }];
}

#pragma mark - Manage actors in pool

- (NSObject *)availableActor
{
    @synchronized(_priv_actors) {
        __block NSObject *actor = nil;
        __block NSUInteger lowest = NSUIntegerMax;
        [self.priv_actors enumerateObjectsUsingBlock:^(NSObject *anActor, BOOL *stop) {
            if (anActor.loadCount.unsignedIntegerValue == 0) {
                actor = anActor;
                *stop = YES;
            }
            if (anActor.loadCount.unsignedIntegerValue < lowest) {
                lowest = anActor.loadCount.unsignedIntegerValue;
                actor = anActor;
            }
        }];
        if (actor) {
            actor.loadCount = @(actor.loadCount.unsignedIntegerValue + 1);
        }
        return actor;
    }
}

- (void)relinquishActor:(NSObject *)actor
{
    @synchronized(_priv_actors) {
        if (actor.loadCount.unsignedIntegerValue > 0) {
            actor.loadCount = @(actor.loadCount.unsignedIntegerValue - 1);
        }
    }
}

- (void)removeActor:(NSObject *)actor
{
    @synchronized(_priv_actors) {
        [self.priv_actors removeObject:actor];
    }
}

- (NSObject *)createActor
{
    @synchronized(_priv_actors) {
        NSObject *actor = [self _createActor];
        [self.priv_actors addObject:actor];
        return actor;
    }
}

- (NSObject *)_createActor
{
    NSObject *actor = [self.klass new];
    if (self.configuration) {
        self.configuration(actor);
    }
    return actor;
}

@end
