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
@property (nonatomic, strong) NSArray *priv_actors;
@property (nonatomic, strong) NSMutableArray *loadCounters;
@end

@implementation TBActorPool

- (instancetype)initWithActors:(NSArray *)actors
{
    self = [super init];
    if (self) {
        self.actorQueue.name = TBAKActorPoolQueue;
        
        _priv_actors = actors;
        [_priv_actors makeObjectsPerformSelector:@selector(setPool:) withObject:self];
        
        _loadCounters = [NSMutableArray new];
        [_priv_actors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_loadCounters addObject:@(0)];
        }];
    }
    return self;
}

- (NSArray *)actors
{
    return self.priv_actors.copy;
}

- (id)broadcast
{
    return [TBActorProxyBroadcast proxyWithPool:self];
}

- (void)subscribeToActor:(id)actor messageName:(NSString *)messageName selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:actor
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self.async performSelector:selector withObject:note.userInfo[TBAKActorPayload]];
#pragma clang diagnostic pop
                                                  }];
}

- (void)subscribeToSender:(id)sender messageName:(NSString *)messageName selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:sender
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self.async performSelector:selector withObject:note.userInfo];
#pragma clang diagnostic pop
                                                  }];
}

- (NSObject *)idleActor
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
        NSUInteger value = [self.loadCounters[index] unsignedIntegerValue];
        self.loadCounters[index] = @(value + 1);
    }
    return actor;
}

- (void)freeActor:(NSObject *)actor
{
    @synchronized(_priv_actors) {
        NSUInteger index = [self.priv_actors indexOfObject:actor];
        NSUInteger value = [self.loadCounters[index] unsignedIntegerValue];
        value -= 1;
        MAX(0, value);
        self.loadCounters[index] = @(value);
    }
}

@end
