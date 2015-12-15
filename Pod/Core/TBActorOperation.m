//
//  TBActorOperation.m
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorOperation.h"
#import "NSObject+ActorKit.h"

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
        if ([self respondsToSelector:NSSelectorFromString(@"handleCrash:forTarget:")] &&
            [self performSelector:NSSelectorFromString(@"handleCrash:forTarget:")
                       withObject:exception
                       withObject:self.invocation.target]) {
                return;
            }
#pragma clang diagnostic pop
        
        @throw;
    }
}

@end
