//
//  TBActorProxy.h
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBActor.h"

@interface TBActorProxy : NSProxy

@property (nonatomic, strong, readonly) TBActor *actor;

+ (TBActorProxy *)proxyWithActor:(TBActor *)actor;
- (instancetype)initWithActor:(TBActor *)actor;
@end
