//
//  TestActor.m
//  ActorKitTests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

@implementation TestActor

- (void)doStuff
{
    NSLog(@"doStuff.");
}

- (void)doStuff:(NSString *)stuff withCompletion:(void (^)(NSString *))completion
{
    NSLog(@"doStuff %@", stuff);
    
    if (completion) {
        completion(stuff);
    }
}

- (void)handlerOne:(id)payload
{
    NSLog(@"handlerOne: %@", payload);
    self.uuid = payload;
}

- (void)handlerTwo:(id)payload
{
    NSLog(@"handlerTwo: %@", payload);
    self.uuid = payload;
}

- (void)handlerThree:(id)payload
{
    NSLog(@"handlerThree: %@", payload);
    self.uuid = payload;
}

- (void)handlerFour:(id)payload
{
    NSLog(@"handlerFour: %@", payload);
    self.uuid = payload;
}

@end

