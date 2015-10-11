//
//  NSException+ActorKit.m
//  ActorKit
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSException+ActorKit.h"

NSString * const TBAKException = @"TBAKException";

static NSString * const TBAKAbstractClassExceptionReason = @"Class %@ is abstract an cannot be instanciated.";
static NSString * const TBAKSupervisionDuplicateExceptionReason = @"Cannot supervise actor. ID %@ already in use.";

@implementation NSException (ActorKit)

+ (NSException *)tbak_abstractClassException:(Class)klass
{
	return [NSException exceptionWithName:TBAKException reason:[NSString stringWithFormat:TBAKAbstractClassExceptionReason, NSStringFromClass(klass)] userInfo:nil];
}
+ (NSException *)tbak_supervisionDuplicateException:(NSString *)Id
{
	return [NSException exceptionWithName:TBAKException reason:[NSString stringWithFormat:TBAKSupervisionDuplicateExceptionReason, Id] userInfo:nil];
}

@end
