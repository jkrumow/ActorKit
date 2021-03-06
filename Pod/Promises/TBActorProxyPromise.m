//
//  TBActorProxyPromise.m
//  ActorKitPromises
//
//  Created by Julian Krumow on 07.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <PromiseKit/PromiseKit.h>

#import "TBActorProxyPromise.h"
#import "NSInvocation+ActorKit.h"
#import "NSObject+ActorKit.h"
#import "TBActorOperation.h"

@interface TBActorProxyPromise ()
@property (nonatomic) AnyPromise *promise;
@end

@implementation TBActorProxyPromise

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // Create invocation for message to be sent to the actor
    NSInvocation *forwardedInvocation = invocation.tbak_copy;
    forwardedInvocation.target = self.actor;
    TBActorOperation *operation = [[TBActorOperation alloc] initWithInvocation:forwardedInvocation];
    
    // Create promise wrapping the invocation operation.
    self.promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        __block TBActorOperation *blockOperation = operation;
        operation.completionBlock = ^{
            id returnValue = nil;
            [blockOperation.invocation getReturnValue:&returnValue];
            resolve(returnValue);
            [self relinquishActor];
        };
        [self.actor.actorQueue addOperation:operation];
    }];
    
    // Return promise back to original sender - change invocation selector to helper method
    invocation.selector = @selector(_returnPromise);
    [invocation invoke];
}

- (id)_returnPromise
{
    return self.promise;
}

@end
