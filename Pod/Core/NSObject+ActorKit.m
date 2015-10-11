//
//  NSObject+ActorKit.m
//  ActorKit
//
//  Created by Julian Krumow on 19.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSObject+ActorKit.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"
#import "TBActorSupervisor.h"
#import "TBActorPool.h"


NSUInteger const TBAKActorQueueMaxOperationCount = 1;
NSString * const TBAKActorQueue = @"com.tarbrain.ActorKit.ActorQueue";
NSString * const TBAKActorPayload = @"com.tarbrain.ActorKit.ActorPayload";

@implementation NSObject (ActorKit)
@dynamic actorQueue;
@dynamic supervisor;
@dynamic pool;


- (NSOperationQueue *)actorQueue
{
    @synchronized(self) {
        NSOperationQueue *queue = objc_getAssociatedObject(self, @selector(actorQueue));
        if (queue == nil) {
            queue = [NSOperationQueue new];
            queue.name = TBAKActorQueue;
            queue.maxConcurrentOperationCount = TBAKActorQueueMaxOperationCount;
            self.actorQueue = queue;
        }
        return queue;
    }
}

- (void)setActorQueue:(NSOperationQueue *)actorQueue
{
    objc_setAssociatedObject(self, @selector(actorQueue), actorQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject<TBActorSupervision> *)supervisor
{
    return objc_getAssociatedObject(self, @selector(supervisor));
}

- (void)setSupervisor:(NSObject<TBActorSupervision> *)supervisor
{
    objc_setAssociatedObject(self, @selector(supervisor), supervisor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TBActorPool *)pool
{
    return objc_getAssociatedObject(self, @selector(pool));
}

- (void)setPool:(TBActorPool *)pool
{
    objc_setAssociatedObject(self, @selector(pool), pool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Invocatons

- (id)sync
{
    return [TBActorProxySync proxyWithActor:self];
}

- (id)async
{
    return [TBActorProxyAsync proxyWithActor:self];
}

#pragma mark - Pubsub

- (void)subscribe:(NSString *)messageName selector:(SEL)selector
{
    [self subscribeToActor:nil messageName:messageName selector:selector];
}

- (void)subscribeToActor:(NSObject *)actor messageName:(NSString *)messageName selector:(SEL)selector;
{
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:actor
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self performSelector:selector withObject:note.userInfo[TBAKActorPayload]];
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
                                                      [self performSelector:selector withObject:note.userInfo];
#pragma clang diagnostic pop
                                                  }];
}

- (void)unsubscribe:(NSString *)messageName
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:messageName object:nil];
}

- (void)publish:(NSString *)messageName payload:(id)payload
{
    NSDictionary *dictionary = nil;
    if (payload) {
        dictionary = @{TBAKActorPayload:[payload copy]};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:messageName
                                                        object:self
                                                      userInfo:dictionary]; // Copy payload to prevent shared state.
}

- (void)crashWithError:(NSError *)error
{
    if (self.pool) {
        [self.pool crashWithError:error];
    } else if (self.supervisor) {
        [self.supervisor actor:self didCrashWithError:error];
    }
}

- (void)cancel
{
    [self.actorQueue cancelAllOperations];
}

#pragma mark - Pools

+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration
{
    NSMutableArray *actors = [NSMutableArray new];
    for (NSUInteger i=0; i < size; i++) {
        NSObject *actor = [self new];
        if (configuration) {
            configuration(actor, i);
        }
        [actors addObject:actor];
    }
    return [[TBActorPool alloc] initWithActors:actors];
}

@end
