//
//  TBActorProxyFuture.m
//  ActorKitFutures
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyFuture.h"
#import "TBActorPool.h"
#import "TBActorFuture.h"
#import "NSInvocation+ActorKit.h"
#import "NSObject+ActorKit.h"

@interface TBActorProxyFuture ()
@property (nonatomic, strong) TBActorFuture *future;
@property (nonatomic, copy) void (^completion)(id);
@end

@implementation TBActorProxyFuture

+ (TBActorProxy *)proxyWithActor:(NSObject *)actor
{
    return [[TBActorProxyFuture alloc] initWithActor:actor];
}

+ (TBActorProxyFuture *)proxyWithActor:(NSObject *)actor completion:(void (^)(id))completion
{
    return [[TBActorProxyFuture alloc] initWithActor:actor completion:completion];
}

- (instancetype)initWithActor:(NSObject *)actor completion:(void (^)(id))completion
{
    self = [super initWithActor:actor];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue] ? : [NSOperationQueue mainQueue];
    
    // Create invocation for message to be sent to the actor - result will be stored in 'future.result'
    NSInvocation *forwardedInvocation = invocation.tbak_copy;
    [forwardedInvocation setTarget:self.actor];
    self.future = [[TBActorFuture alloc] initWithInvocation:forwardedInvocation];
    
    // Hook up completion block.
    __block TBActorProxyFuture *blockSelf = self;
    [self.future setCompletionBlock:^{
        
        [currentQueue addOperationWithBlock:^{
            if (blockSelf.completion) {
                blockSelf.completion(blockSelf.future.result);
            }
        }];
        [blockSelf freeActor];
    }];
    
    // Return future back to original sender - change invocation selector to helper method
    [invocation setSelector:@selector(_returnFuture)];
    [invocation invoke];
    
    [self.actor.actorQueue addOperation:self.future];
}

- (id)_returnFuture
{
    return self.future;
}

@end
