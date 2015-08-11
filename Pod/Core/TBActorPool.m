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
#import "TBActorProxyFuture.h"

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
        self.name = TBAKActorPoolQueue;
    }
    return self;
}

- (NSArray *)actors
{
    return self.priv_actors.copy;
}

- (id)sync
{
    return [TBActorProxySync proxyWithActor:self._idleActor];
}

- (id)async
{
    return [TBActorProxyAsync proxyWithActor:self._idleActor];
}

- (id)future
{
    return [TBActorProxyFuture proxyWithActor:self._idleActor];
}

- (void)subscribeToPublisher:(id)publisher withMessageName:(NSString *)messageName selector:(SEL)selector
{
    [self.subscriptions addObject:messageName];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:publisher
                                                       queue:self
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self.async performSelector:selector withObject:note.userInfo];
#pragma clang diagnostic pop
                                                  }];
}

- (TBActor *)_idleActor
{
    TBActor *idleActor = nil;
    NSUInteger lowest = NSUIntegerMax;
    @synchronized(self) {
        for (TBActor *actor in self.actors) {
            if (actor.operationCount == 0) {
                idleActor = actor;
                break;
            }
            if (actor.operationCount < lowest) {
                lowest = actor.operationCount;
                idleActor = actor;
            }
        }
    }
    return idleActor;
}

@end
