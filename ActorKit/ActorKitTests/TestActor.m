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
    NSLog(@"%@ returnSomething", self.uuid);
    return self.uuid;
}

- (NSNumber *)returnSomethingBlocking
{
    NSLog(@"%@ returnSomethingBlocking", self.uuid);
    sleep([self _randomSleepInterval]);
    NSLog(@"%@ returnSomethingBlocking ...done", self.uuid);
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
    NSLog(@"%@ handler: %@", self.uuid, payload);
    self.symbol = payload;
}

- (void)handlerRaw:(NSDictionary *)payload
{
    NSLog(@"%@ handler: %@", self.uuid, payload);
    self.symbol = payload[@"symbol"];
}

- (void)blockSomething
{
    NSLog(@"%@ blockSomething", self.uuid);
    sleep([self _randomSleepInterval]);
    NSLog(@"%@ blockSomething ...done", self.uuid);
}

- (void)blockSomethingWithCompletion:(void (^)(void))completion
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
