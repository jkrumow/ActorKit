//
//  TBActorRegistry.h
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActor.h"


@interface TBActorRegistry : NSObject

@property(nonatomic, strong, readonly) NSDictionary *actors;

- (void)registerActor:(TBActor *)actor withName:(NSString *)name;
- (void)removeActorWithName:(NSString *)name;

- (void)startUp;
- (void)shutDown;
@end
