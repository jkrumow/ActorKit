//
//  TBActorPool.h
//  ActorKit
//
//  Created by Julian Krumow on 05.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBActor.h"


@interface TBActorPool : TBActor

@property (nonatomic, strong, readonly) NSArray *actors;

- (instancetype)initWithActors:(NSArray *)actors;
@end
