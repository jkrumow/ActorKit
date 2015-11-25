//
//  TestActor.h
//  ActorKitTests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

@interface TestActor : NSObject

@property (nonatomic) NSNumber *uuid;
@property (nonatomic) NSNumber *symbol;
@property (nonatomic, copy) void (^monitorBlock)(void);

- (void)setSymbol:(NSNumber *)symbol withCompletion:(void (^)(NSNumber *))completion;
- (void)doSomething;
- (void)doSomething:(NSString *)stuff withCompletion:(void (^)(NSString *))completion;
- (NSString *)address;
- (NSString *)addressBlocking;
- (void)address:(void (^)(NSString *))completion;
- (void)addressBlocking:(void (^)(NSString *))completion;
- (NSNumber *)returnSomething;
- (NSNumber *)returnSomethingBlocking;
- (void)returnSomethingWithCompletion:(void (^)(NSNumber *))completion;
- (void)returnSomethingBlockingWithCompletion:(void (^)(NSNumber *))completion;
- (void)handler:(id)payload;
- (void)handlerRaw:(NSDictionary *)payload;
- (void)blockSomething;
- (void)blockSomethingWithCompletion:(void (^)(void))completion;
- (void)doCrash;
@end
