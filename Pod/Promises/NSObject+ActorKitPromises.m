//
//  NSObject+ActorKitPromises.m
//  ActorKitPromises
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSObject+ActorKitPromises.h"
#import "TBActorProxyPromise.h"

@implementation NSObject (ActorKitPromises)

- (id)promise
{
    return [[TBActorProxyPromise alloc] initWithActor:self];
}

@end
