//
//  NSException+ActorKitSupervision.m
//  ActorKitSupervision
//
//  Created by Julian Krumow on 21.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSException+ActorKitSupervision.h"
#import "NSException+ActorKit.h"

static NSString * const TBAKSupervisionDuplicateExceptionReason = @"Cannot supervise actor. ID %@ already in use.";
static NSString * const TBAKSupervisionLinkExceptionReason = @"Linking %@ to %@ will cause circular references.";

@implementation NSException (ActorKitSupervision)

+ (NSException *)tbak_supervisionDuplicateException:(NSString *)Id
{
    return [NSException exceptionWithName:TBAKException reason:[NSString stringWithFormat:TBAKSupervisionDuplicateExceptionReason, Id] userInfo:nil];
}

+ (NSException *)tbak_supervisionLinkException:(NSString *)linkedActorId to:(NSString *)actorId
{
    return [NSException exceptionWithName:TBAKException reason:[NSString stringWithFormat:TBAKSupervisionLinkExceptionReason, linkedActorId, actorId] userInfo:nil];
}

@end
