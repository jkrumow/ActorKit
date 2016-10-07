//
//  NSError+ActorKitSupervision.m
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

static NSString * const TBAKErrorDomain = @"com.jkrumow.ActorKit";
static NSString * const TBAKUnderlyingException = @"underlyingException";

@implementation NSError (ActorKitSupervision)

+ (instancetype)tbak_wrappingErrorForException:(NSException *)exception
{
    return [NSError errorWithDomain:TBAKErrorDomain code:100 userInfo:@{TBAKUnderlyingException:exception}];
}
    
- (NSString *)tbak_errorDescription
{
    if (self.userInfo[TBAKUnderlyingException]) {
        NSException *exception = self.userInfo[TBAKUnderlyingException];
        return [NSString stringWithFormat:@"Exception in actor operation: %@, '%@', at: %@", exception.name, exception.reason, exception.callStackSymbols];
    }
    return [NSString stringWithFormat:@"%@ %li %@", self.domain, (long)self.code, self.localizedDescription];
}

@end
