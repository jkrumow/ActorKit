//
//  TBActorPool+ActorKitSupervision.m
//  Pods
//
//  Created by Julian Krumow on 23.11.15.
//
//

#import "TBActorPool+ActorKitSupervision.h"
#import "NSObject+ActorKitSupervision.h"
#import "TBActorSupervisor.h"

@implementation TBActorPool (ActorKitSupervision)

- (void)crashWithActor:(NSObject *)actor error:(NSError *)error
{
    [self.supervisor.sync actor:actor inPool:self didCrashWithError:error];
}

@end
