//
//  TBActorPool+Promises.m
//  ActorKitPromises
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorPool+Promises.h"
#import "TBActorProxyPromise.h"

@implementation TBActorPool (Promises)

- (id)promise
{
    return [TBActorProxyPromise proxyWithActor:self.idleActor];
}

@end
