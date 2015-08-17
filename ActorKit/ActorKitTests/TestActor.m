//
//  TestActor.m
//  ActorKitTests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

@implementation TestActor
@synthesize symbol = _symbol;

- (void)setSymbol:(NSNumber *)symbol
{
    NSLog(@"%@ setSymbol: %@", self.uuid, symbol);
    _symbol = symbol;
    
    if (self.monitorBlock) {
        self.monitorBlock();
    }
}

- (NSNumber *)symbol
{
    NSLog(@"%@ get symbol: %@", self.uuid, _symbol);
    return _symbol;
}

- (void)setSymbol:(NSNumber *)symbol withCompletion:(void (^)(NSNumber *))completion
{
    [self setSymbol:symbol];
    
    if (completion) {
        completion(symbol);
    }
}

- (void)doSomething
{
    NSLog(@"%@ doSomething", self.uuid);
}

- (void)doSomething:(NSString *)stuff withCompletion:(void (^)(NSString *))completion
{
    [self doSomething];
    
    if (completion) {
        completion(stuff);
    }
}

- (NSNumber *)returnSomething
{
    NSLog(@"%@ returnSomething %@", self.uuid, self.uuid);
    return self.uuid;
}

- (NSNumber *)returnSomethingBlocking
{
    sleep([self _randomSleepInterval]);
    return [self returnSomething];
}

- (void)handlerOne:(id)payload
{
    NSLog(@"%@ handlerOne: %@", self.uuid, payload);
    self.symbol = payload;
}

- (void)handlerTwo:(id)payload
{
    NSLog(@"%@ handlerTwo: %@", self.uuid, payload);
    self.symbol = payload;
}

- (void)handlerThree:(id)payload
{
    NSLog(@"%@ handlerThree: %@", self.uuid, payload);
    self.symbol = payload;
}

- (void)handlerFour:(id)payload
{
    NSLog(@"%@ handlerFour: %@", self.uuid, payload);
    self.symbol = payload;
}

- (void)blockSomething
{
    NSLog(@"%@ blockSomething", self.uuid);
    sleep([self _randomSleepInterval]);
    NSLog(@"%@ blockSomething ...done", self.uuid);
}

- (void)blockSomething:(void (^)(void))completion
{
    [self blockSomething];
    if (completion) {
        completion();
    }
}

- (double)_randomSleepInterval
{
    return (rand() % 1000) / 1000.0;
}

@end
