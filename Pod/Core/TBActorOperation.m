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

+ (instancetype)operationWithInvocation:(NSInvocation *)invocation
{
    TBActorOperation *operation = [TBActorOperation new];
    operation.invocation = invocation;
    [operation.invocation retainArguments];
    [operation addExecutionBlock:^{
        [invocation invoke];
    }];
    return operation;
}

- (void)main
{
    @try {
        [super main];
    }
    @catch (NSException *exception) {
        if ([self.invocation.target respondsToSelector:@selector(crashWithError:)]) {
            [self.invocation.target crashWithError:[NSError wrappingErrorForException:exception]];
        }
    }
}

@end
