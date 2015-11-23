//
//  TBActorOperation.m
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorOperation.h"
#import "NSException+ActorKit.h"
#import "NSError+ActorKit.h"
#import "NSObject+ActorKitSupervision.h"

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
    @try {
        [self.invocation invoke];
    }
    @catch (NSException *exception) {
        if ([self.invocation.target respondsToSelector:@selector(crashWithError:)]) {
            [self.invocation.target crashWithError:[NSError wrappingErrorForException:exception]];
        }
    }
}

@end
