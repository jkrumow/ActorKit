//
//  TBActorRuntime.h
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor.h"

@interface TBActorRuntime : NSObject

@property(nonatomic, strong, readonly) NSDictionary *actors;
@property(nonatomic, strong, readonly) NSDictionary *actorPools;

- (void)registerActor:(TBActor *)actor withName:(NSString *)name;
- (void)removeActorWithName:(NSString *)name;

- (void)startup;
- (void)shutDown;
@end
