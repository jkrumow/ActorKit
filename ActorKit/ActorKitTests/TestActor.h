//
//  TestActor.h
//  ActorKitTests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

@interface TestActor : TBActor

@property (nonatomic, strong) NSNumber *uuid;
@property (nonatomic, strong) NSNumber *symbol;
@property (nonatomic, copy) void (^monitorBlock)(void);

- (void)setSymbol:(NSNumber *)symbol withCompletion:(void (^)(NSNumber *))completion;
- (void)doSomething;
- (void)doSomething:(NSString *)stuff withCompletion:(void (^)(NSString *))completion;
- (NSNumber *)returnSomething;
- (void)handlerOne:(id)payload;
- (void)handlerTwo:(id)payload;
- (void)handlerThree:(id)payload;
- (void)handlerFour:(id)payload;
- (void)blockSomething;
- (void)blockSomething:(void (^)(void))completion;
@end
