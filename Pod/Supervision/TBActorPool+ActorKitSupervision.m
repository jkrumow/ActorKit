//
//  TBActorPool+ActorKitSupervision.m
//  ActorKitSupervision
//
//  Created by Julian Krumow on 23.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool+ActorKitSupervision.h"
#import "NSObject+ActorKitSupervision.h"

@implementation TBActorPool (ActorKitSupervision)

- (void)tbak_suspend
{
    [super tbak_suspend];
    for (NSObject *actor in self.actors) {
        actor.actorQueue.suspended = YES;
    }
}
    
- (void)tbak_resume
{
    for (NSObject *actor in self.actors) {
        actor.actorQueue.suspended = NO;
    }
    [super tbak_resume];
}
- (void)crashWithError:(NSError *)error
{
    [self.supervisor.sync pool:self didCrashWithError:error];
}

- (void)crashWithActor:(NSObject *)actor error:(NSError *)error
{
    [self.supervisor.sync actor:actor inPool:self didCrashWithError:error];
}

@end
