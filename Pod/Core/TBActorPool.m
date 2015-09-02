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

static NSString * const TBAKActorPoolQueue = @"com.tarbrain.ActorKit.TBActorPool";

@interface TBActorPool ()
@property (nonatomic, strong) NSArray *priv_actors;
@property (nonatomic, strong) NSMutableSet *idleActors;
@property (nonatomic, strong) NSMutableSet *busyActors;
@end

@implementation TBActorPool

- (instancetype)initWithActors:(NSArray *)actors
{
    self = [super init];
    if (self) {
        _priv_actors = actors;
        [self.priv_actors makeObjectsPerformSelector:@selector(setPool:) withObject:self];
        
        _idleActors = [[NSMutableSet alloc] initWithArray:self.priv_actors];
        _busyActors = [NSMutableSet new];
        self.actorQueue.name = TBAKActorPoolQueue;
    }
    return self;
}

- (NSArray *)actors
{
    return self.priv_actors.copy;
}

- (void)subscribeToActor:(id)actor withMessageName:(NSString *)messageName selector:(SEL)selector
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

- (void)subscribeToSender:(id)sender withMessageName:(NSString *)messageName selector:(SEL)selector
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
    NSObject *idleActor = nil;
    NSUInteger lowest = NSUIntegerMax;
    @synchronized(_priv_actors) {
        idleActor = [self.idleActors anyObject];
        if (idleActor) {
            [self.busyActors addObject:idleActor];
            [self.idleActors removeObject:idleActor];
        } else {
            for (NSObject *actor in self.busyActors) {
                NSUInteger operationCount = actor.actorQueue.operationCount;
                if (operationCount < lowest) {
                    lowest = operationCount;
                    idleActor = actor;
                }
            }
        }
    }
    return idleActor;
}

- (void)freeActor:(NSObject *)actor
{
    @synchronized(_priv_actors) {
        if (actor.actorQueue.operationCount == 0) {
            [self.busyActors removeObject:actor];
            [self.idleActors addObject:actor];
        }
    }
}

@end
