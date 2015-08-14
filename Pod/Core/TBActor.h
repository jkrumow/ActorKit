//
//  TBActor.h
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBActor;
@class TBActorPool;
typedef void (^TBActorConfigurationBlock)(TBActor *actor);
typedef void (^TBActorPoolConfigurationBlock)(TBActor *actor, NSUInteger index);

@interface TBActor : NSOperationQueue

@property (nonatomic, strong)NSMutableSet *subscriptions;

+ (instancetype)actorWithConfiguration:(TBActorConfigurationBlock)configuration;
+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration;

- (instancetype)initWithConfiguration:(TBActorConfigurationBlock)configuration;

- (id)sync;
- (id)async;

- (void)subscribe:(NSString *)messageName selector:(SEL)selector;
- (void)subscribeToPublisher:(id)actor withMessageName:(NSString *)messageName selector:(SEL)selector;
- (void)publish:(NSString *)messageName payload:(id)payload;
@end

