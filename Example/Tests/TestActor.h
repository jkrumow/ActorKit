//
//  TestActor.h
//  Tests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

@interface TestActor : TBActor

- (void)doStuff;
- (void)doStuff:(NSString *)stuff withFooBar:(NSUInteger)foobar;
@end
