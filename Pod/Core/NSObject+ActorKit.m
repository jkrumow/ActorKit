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

NSUInteger const TBAKActorQueueMaxOperationCount = 1;
NSString * const TBAKActorQueue = @"com.jkrumow.ActorKit.ActorQueue";
NSString * const TBAKActorPayload = @"com.jkrumow.ActorKit.ActorPayload";

@implementation NSObject (ActorKit)
@dynamic actorQueue;
@dynamic subscriptions;
@dynamic pool;
@dynamic loadCount;

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

- (NSMutableDictionary *)subscriptions
{
    @synchronized(self) {
        NSMutableDictionary *subscriptions = objc_getAssociatedObject(self, @selector(subscriptions));
        if (subscriptions == nil) {
            subscriptions = [NSMutableDictionary new];
            self.subscriptions = subscriptions;
        }
        return subscriptions;
    }
}

- (void)setSubscriptions:(NSMutableArray *)subscriptions
{
    objc_setAssociatedObject(self, @selector(subscriptions), subscriptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TBActorPool *)pool
{
    return objc_getAssociatedObject(self, @selector(pool));
}

- (void)setPool:(TBActorPool *)pool
{
    objc_setAssociatedObject(self, @selector(pool), pool, OBJC_ASSOCIATION_ASSIGN);
}

- (NSNumber *)loadCount
{
    @synchronized(self) {
        NSNumber *count = objc_getAssociatedObject(self, @selector(loadCount));
        if (count == nil) {
            count = @(0);
            self.loadCount = count;
        }
        return count;
    }
}

- (void)setLoadCount:(NSNumber *)loadCount
{
    objc_setAssociatedObject(self, @selector(loadCount), loadCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Invocatons

- (id)sync
{
    return [[TBActorProxySync alloc] initWithActor:self];
}

- (id)async
{
    return [[TBActorProxyAsync alloc] initWithActor:self];
}

#pragma mark - Pubsub

- (void)storeSubscription:(NSString *)notificationName selector:(SEL)selector
{
    if (self.subscriptions[notificationName] == nil) {
        self.subscriptions[notificationName] = [NSMutableArray new];
    }
    NSMutableArray *selectors = self.subscriptions[notificationName];
    [selectors addObject:[NSValue valueWithPointer:selector]];
}

- (void)subscribe:(NSString *)notificationName selector:(SEL)selector
{
    [self storeSubscription:notificationName selector:selector];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:notificationName
                                                      object:nil
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      id payload = note.userInfo[TBAKActorPayload];
                                                      if (payload == nil) {
                                                          payload = note.userInfo;
                                                      }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                          [weakSelf performSelector:selector withObject:payload];
#pragma clang diagnostic pop
                                                  }];
}

- (void)unsubscribe:(NSString *)notificationName
{
    [self.subscriptions removeObjectForKey:notificationName];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

- (void)publish:(NSString *)notificationName payload:(id)payload
{
    NSDictionary *dictionary = nil;
    if (payload) {
        dictionary = @{TBAKActorPayload:[payload copy]}; // Copy payload to prevent shared state.
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:self
                                                      userInfo:dictionary];
}

#pragma mark - Pools

+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration
{
    return [[TBActorPool alloc] initWithSize:size class:self configuration:configuration];
}

#pragma mark  - Queue

- (void)tbak_suspend
{
    self.actorQueue.suspended = YES;
}

- (void)tbak_resume
{
    self.actorQueue.suspended = NO;
}
@end
