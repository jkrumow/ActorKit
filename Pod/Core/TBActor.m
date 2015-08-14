//
//  TBActor.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor.h"
#import "TBActorProxySync.h"
#import "TBActorProxyAsync.h"
#import "TBActorProxyFuture.h"
#import "TBActorPool.h"

static NSString * const TBAKActorQueue = @"com.tarbrain.ActorKit.TBActor";

@interface TBActor ()

@end

@implementation TBActor

+ (instancetype)actorWithConfiguration:(TBActorConfigurationBlock)configuration
{
    return [[self alloc] initWithConfiguration:configuration];
}

+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration
{
    NSMutableArray *actors = [NSMutableArray new];
    for (NSUInteger i=0; i < size; i++) {
        TBActor *actor = [self new];
        if (configuration) {
            configuration(actor, i);
        }
        [actors addObject:actor];
    }
    return [[TBActorPool alloc] initWithActors:actors];
}

- (instancetype)initWithConfiguration:(TBActorConfigurationBlock)configuration
{
    self = [super init];
    if (self) {
        [self _initialize];
        
        if (configuration) {
            configuration(self);
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllOperations];
    [self.subscriptions enumerateObjectsUsingBlock:^(NSString *messageName, BOOL *stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:messageName object:nil];
    }];
}

- (void)_initialize
{
    self.name = TBAKActorQueue;
    self.maxConcurrentOperationCount = 1;
    self.subscriptions = [NSMutableSet new];
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
    [self.subscriptions addObject:messageName];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:messageName
                                                      object:publisher
                                                       queue:self
                                                  usingBlock:^(NSNotification *note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                      [self performSelector:selector withObject:note.userInfo];
#pragma clang diagnostic pop
                                                  }];
}

- (void)publish:(NSString *)messageName payload:(NSDictionary *)payload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:messageName
                                                        object:self
                                                      userInfo:payload.copy]; // Copy payload to prevent shared state.
}

@end
