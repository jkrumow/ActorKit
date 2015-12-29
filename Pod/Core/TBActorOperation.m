//
//  TBActorOperation.m
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorOperation.h"

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
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self respondsToSelector:NSSelectorFromString(@"tbak_handleCrash:forInvocation:")] &&
            [self performSelector:NSSelectorFromString(@"tbak_handleCrash:forInvocation:")
                       withObject:exception
                       withObject:self.invocation]) {
                return;
            }
#pragma clang diagnostic pop
        
        @throw;
    }
}

@end
