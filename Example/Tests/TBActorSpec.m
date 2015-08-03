//
//  TBActorsTests.m
//  TBActorsTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>


@interface TestActor : TBActor

- (void)doStuff;
- (void)doStuff:(NSString *)stuff withFooBar:(NSUInteger)foobar;
@end

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


SpecBegin()

__block TestActor *actor;

describe(@"TBActor", ^{
    
    beforeEach(^{
        actor = [[TestActor alloc] init];
    });
    
    it (@"executes a method synchronuously.", ^{
        [actor.sync doStuff];
    });
    
    it (@"executes a parameterized method synchronuously.", ^{
        [actor.sync doStuff:@"aaaaaah" withFooBar:666];
    });

    it (@"executes a method asynchronuously.", ^{
        [actor.async doStuff];
        
        sleep(1);
    });
    
    it (@"executes a parameterized method synchronuously.", ^{
        [actor.async doStuff:@"aaaaaah" withFooBar:666];
        
        sleep(1);
    });

});
    
    
SpecEnd
