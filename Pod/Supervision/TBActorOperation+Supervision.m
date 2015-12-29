//
//  TBActorOperation+Supervision.m
//  ActorKitSupervision
//
//  Created by Julian Krumow on 15.12.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorOperation+Supervision.h"
#import "NSError+ActorKit.h"

@implementation TBActorOperation (Supervision)

- (BOOL)tbak_handleCrash:(NSException *)exception forInvocation:(NSInvocation *)invocation
{
    NSObject *target = invocation.target;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([target respondsToSelector:NSSelectorFromString(@"supervisor")]) {
        if ([target performSelector:NSSelectorFromString(@"supervisor")] || [target.pool performSelector:NSSelectorFromString(@"supervisor")]) {
            [target performSelector:NSSelectorFromString(@"crashWithError:") withObject:[NSError tbak_wrappingErrorForException:exception]];
            return YES;
        }
    }
#pragma clang diagnostic pop
    
    return NO;
}

@end
