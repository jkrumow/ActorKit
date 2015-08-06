//
//  TestActor.m
//  ActorKitTests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

@implementation TestActor

- (void)setSymbol:(NSNumber *)symbol
{
    NSLog(@"setting symbol on actor: %@", self.uuid);
    _symbol = symbol;
}

- (void)setSymbol:(NSNumber *)symbol withCompletion:(void (^)(NSNumber *))completion
{
    [self setSymbol:symbol];
    
    if (completion) {
        completion(symbol);
    }
}

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
    self.symbol = payload;
}

- (void)handlerTwo:(id)payload
{
    NSLog(@"handlerTwo: %@", payload);
    self.symbol = payload;
}

- (void)handlerThree:(id)payload
{
    NSLog(@"handlerThree: %@", payload);
    self.symbol = payload;
}

- (void)handlerFour:(id)payload
{
    NSLog(@"handlerFour: %@", payload);
    self.symbol = payload;
}

@end

