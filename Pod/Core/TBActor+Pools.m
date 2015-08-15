//
//  TBActor+Pools.m
//  ActorKit
//
//  Created by Julian Krumow on 15.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor+Pools.h"

@implementation TBActor (Pools)

+ (TBActorPool *)poolWithSize:(NSUInteger)size configuration:(TBActorPoolConfigurationBlock)configuration
{
    NSMutableArray *actors = [NSMutableArray new];
    for (NSUInteger i=0; i < size; i++) {
        TBActor *actor = [self new];
        if (configuration) {
            configuration(actor, i);
        }
        [actors addObject:actor];
    }
    return [[TBActorPool alloc] initWithActors:actors];
}

@end
