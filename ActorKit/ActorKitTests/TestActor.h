//
//  TestActor.h
//  Tests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

@interface TestActor : TBActor

@property (nonatomic, strong) NSNumber *uuid;

- (void)doStuff;
- (void)doStuff:(NSString *)stuff withCompletion:(void (^)(NSString *))completion;
- (void)handlerOne:(id)payload;
- (void)handlerTwo:(id)payload;
@end
