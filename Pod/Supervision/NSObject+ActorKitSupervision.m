//
//  NSObject+ActorKitSupervision.m
//  ActorKitSupervision
//
//  Created by Julian Krumow on 21.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "NSObject+ActorKitSupervision.h"
#import "TBActorPool+ActorKitSupervision.h"
#import "TBActorSupervisor.h"

@implementation NSObject (ActorKitSupervision)
@dynamic supervisor;

- (NSObject<TBActorSupervision> *)supervisor
{
    return objc_getAssociatedObject(self, @selector(supervisor));
}

- (void)setSupervisor:(NSObject<TBActorSupervision> *)supervisor
{
    objc_setAssociatedObject(self, @selector(supervisor), supervisor, OBJC_ASSOCIATION_ASSIGN);
}

- (void)crashWithError:(NSError *)error
{
    if (self.pool) {
        [self.pool crashWithActor:self error:error];
    } else if (self.supervisor) {
        [self.supervisor.sync actor:self didCrashWithError:error];
    }
}

@end
