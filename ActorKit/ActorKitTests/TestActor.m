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
    _symbol = symbol;
    if (self.monitorBlock) {
        self.monitorBlock();
    }
}

- (NSNumber *)symbol
{
    return _symbol;
}

- (void)setSymbol:(NSNumber *)symbol withCompletion:(void (^)(NSNumber *))completion
{
    [self setSymbol:symbol];
    completion(symbol);
}

- (void)doSomething
{
    NSLog(@"%@ doSomething", self.uuid);
}

- (void)doSomething:(NSString *)stuff withCompletion:(void (^)(NSString *))completion
{
    [self doSomething];
    completion(stuff);
}

- (void)address:(void (^)(id))completion
{
    completion(self);
}

- (NSNumber *)returnSomething
{
    return self.uuid;
}

- (NSNumber *)returnSomethingBlocking
{
    sleep([self _randomSleepInterval]);
    return [self returnSomething];
}

- (void)returnSomethingWithCompletion:(void (^)(NSNumber *))completion
{
    NSNumber *number = [self returnSomething];
    completion(number);
}

- (void)returnSomethingBlockingWithCompletion:(void (^)(NSNumber *))completion
{
    NSNumber *number = [self returnSomethingBlocking];
    completion(number);
}

- (void)handler:(id)payload
{
    self.symbol = payload;
}

- (void)handlerRaw:(NSDictionary *)payload
{
    self.symbol = payload[@"symbol"];
}

- (void)blockSomething
{
    sleep([self _randomSleepInterval]);
}

- (void)blockSomethingWithCompletion:(void (^)(void))completion
{
    [self blockSomething];
    completion();
}

- (double)_randomSleepInterval
{
    return (rand() % 1000) / 1000.0;
}

@end
