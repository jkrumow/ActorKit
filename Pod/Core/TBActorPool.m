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
@end

@implementation TBActorPool

- (instancetype)initWithActors:(NSArray *)actors
{
    self = [super init];
    if (self) {
        _priv_actors = actors;
        self.actorQueue.name = TBAKActorPoolQueue;
    }
    return self;
}

- (NSArray *)actors
{
    return self.priv_actors.copy;
}

- (id)sync
{
    return [TBActorProxySync proxyWithActor:self.idleActor];
}

- (id)async
{
    return [TBActorProxyAsync proxyWithActor:self.idleActor];
}

- (void)subscribeToPublisher:(id)publisher withMessageName:(NSString *)messageName selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:publisher
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self.async performSelector:selector withObject:note.userInfo[TBAKActorPayload]];
#pragma clang diagnostic pop
                                                  }];
}

- (NSObject *)idleActor
{
    NSObject *idleActor = nil;
    NSUInteger lowest = NSUIntegerMax;
    @synchronized(self) {
        for (NSObject *actor in self.actors) {
            if (actor.actorQueue.operationCount == 0) {
                idleActor = actor;
                break;
            }
            if (actor.actorQueue.operationCount < lowest) {
                lowest = actor.actorQueue.operationCount;
                idleActor = actor;
            }
        }
    }
    return idleActor;
}

@end
