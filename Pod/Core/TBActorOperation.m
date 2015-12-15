//
//  TBActorOperation.m
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorOperation.h"
#import "NSObject+ActorKit.h"
#import "NSException+ActorKit.h"
#import "NSError+ActorKit.h"

@implementation TBActorOperation

- (instancetype)init
{
    self = [self initWithInvocation:[NSInvocation new]];
    return self;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation
{
    self = [super init];
    if (self) {
        [invocation retainArguments];
        _invocation = invocation;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled) {
        return;
    }
    @try {
        [self.invocation invoke];
    }
    @catch (NSException *exception) {
        if ([self.invocation.target respondsToSelector:NSSelectorFromString(@"crashWithError:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.invocation.target performSelector:NSSelectorFromString(@"crashWithError:") withObject:[NSError tbak_wrappingErrorForException:exception]];
#pragma clang diagnostic pop
        } else {
            @throw exception;
        }
    }
}

@end
