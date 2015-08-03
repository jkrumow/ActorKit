//
//  TBActorProxy.h
//  TBActors
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBActor;
@interface TBActorProxy : NSProxy

@property (nonatomic, strong) TBActor *actor;

+ (TBActorProxy *)proxyWithActor:(TBActor *)actor;
- (instancetype)initWithActor:(TBActor *)actor;
@end
