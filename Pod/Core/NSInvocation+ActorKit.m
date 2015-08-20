//
//  NSInvocation+ActorKit.m
//  ActorKit
//
//  Created by Julian Krumow on 06.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSInvocation+ActorKit.h"


@implementation NSInvocation (ActorKit)

- (id)tbak_copy
{
	NSInvocation *copy = [NSInvocation invocationWithMethodSignature:[self methodSignature]];
	NSUInteger numberOfArguments = [[self methodSignature] numberOfArguments];
	
	for (int i = 0; i < numberOfArguments; i++) {
		char buffer[sizeof(intmax_t)];
		[self getArgument:(void *)&buffer atIndex:i];
		[copy setArgument:(void *)&buffer atIndex:i];
	}
	return copy;
}

@end
