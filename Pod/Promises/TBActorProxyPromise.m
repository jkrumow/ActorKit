//
//  TBActorProxyPromise.m
//  ActorKitPromises
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <PromiseKit/PromiseKit.h>

#import "TBActorProxyPromise.h"
#import "TBActorPool.h"
#import "NSInvocation+ActorKit.h"
#import "NSObject+ActorKit.h"

@interface TBActorProxyPromise ()
@property (nonatomic, strong) PMKPromise *promise;
@end

@implementation TBActorProxyPromise

+ (TBActorProxy *)proxyWithActor:(NSObject *)actor
{
    return [[TBActorProxyPromise alloc] initWithActor:actor];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // Create invocation for message to be sent to the actor
    NSInvocation *forwardedInvocation = invocation.tbak_copy;
    [forwardedInvocation setTarget:self.actor];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:forwardedInvocation];
    
    // Create promise wrapping the invocation operation.
    self.promise = [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        __block NSInvocationOperation *blockOperation = operation;
        operation.completionBlock = ^{
            resolve(blockOperation.result);
            [self relinquishActor];
        };
        [self.actor.actorQueue addOperation:operation];
    }];
    
    // Return promise back to original sender - change invocation selector to helper method
    [invocation setSelector:@selector(_returnPromise)];
    [invocation invoke];
}

- (id)_returnPromise
{
    return self.promise;
}

@end
