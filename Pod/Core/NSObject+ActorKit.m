//
//  NSObject+ActorKit.m
//  ActorKit
//
//  Created by Julian Krumow on 19.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+ActorKit.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"
#import "TBActorPool.h"


NSUInteger const TBAKActorQueueMaxOperationCount = 1;
NSString * const TBAKActorQueue = @"com.tarbrain.ActorKit.ActorQueue";
NSString * const TBAKActorPayload = @"com.tarbrain.ActorKit.ActorPayload";

@implementation NSObject (ActorKit)
@dynamic actorQueue;

- (NSOperationQueue *)actorQueue
{
    NSOperationQueue *queue = objc_getAssociatedObject(self, @selector(actorQueue));
    
    if (queue == nil) {
        queue = [NSOperationQueue new];
        queue.name = TBAKActorQueue;
        queue.maxConcurrentOperationCount = TBAKActorQueueMaxOperationCount;
        [self setActorQueue:queue];
    }
    
    return queue;
}

- (void)setActorQueue:(NSOperationQueue *)actorQueue
{
    objc_setAssociatedObject(self, @selector(actorQueue), actorQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    [self subscribeToPublisher:nil withMessageName:messageName selector:selector];
}

- (void)subscribeToPublisher:(id)publisher withMessageName:(NSString *)messageName selector:(SEL)selector;
{
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:publisher
                                                       queue:self.actorQueue
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self performSelector:selector withObject:note.userInfo[TBAKActorPayload]];
#pragma clang diagnostic pop
                                                  }];
}

- (void)unsubscribe:(NSString *)messageName
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:messageName object:nil];
}

// TODO: send address from sending actor
- (void)publish:(NSString *)messageName payload:(NSDictionary *)payload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:messageName
                                                        object:self
                                                      userInfo:@{TBAKActorPayload:payload.copy}]; // Copy payload to prevent shared state.
}

+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration
{
    NSMutableArray *actors = [NSMutableArray new];
    for (NSUInteger i=0; i < size; i++) {
        id actor = [self new];
        if (configuration) {
            configuration(actor, i);
        }
        [actors addObject:actor];
    }
    return [[TBActorPool alloc] initWithActors:actors];
}

@end
