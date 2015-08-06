//
//  TBActorRegistry.m
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorRegistry.h"


@interface TBActorRegistry ()
@property (nonatomic, strong) NSMutableDictionary *priv_actors;
@end

@implementation TBActorRegistry

- (instancetype)init
{
    self = [super init];
    if (self) {
        _priv_actors = [NSMutableDictionary new];
    }
    return self;
}

- (NSDictionary *)actors
{
    return self.priv_actors.copy;
}

- (void)registerActor:(TBActor *)actor withName:(NSString *)name
{
    [self.priv_actors setObject:actor forKey:name];
}

- (void)removeActorWithName:(NSString *)name
{
    [self.priv_actors removeObjectForKey:name];
}

- (void)startUp
{
    
}

- (void)shutDown
{
    
}

@end
