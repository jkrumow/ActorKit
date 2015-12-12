//
//  NSError+ActorKit.m
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSError+ActorKit.h"

NSString * const TBAKErrorDomain = @"com.tarbrain.ActorKit";
NSString * const TBAKUnderlyingException = @"underlyingException";

@implementation NSError (ActorKit)

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
    return self.localizedDescription;
}

@end
