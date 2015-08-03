//
//  TestActor.m
//  Tests
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

- (void)doStuff:(NSString *)stuff withFooBar:(NSUInteger)foobar
{
    NSLog(@"doStuff %@ foobar: %lu", stuff, (unsigned long)foobar);
}

@end

