//
//  TBActor+Promises.m
//  ActorKitPromises
//
//  Created by Julian Krumow on 14.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor+Promises.h"
#import "TBActorProxyPromise.h"

@implementation TBActor (Promises)

- (id)promise
{
    return [TBActorProxyPromise proxyWithActor:self];
}

@end
