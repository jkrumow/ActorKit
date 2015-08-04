//
//  TBActorSpec.m
//  Tests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

SpecBegin(TBActor)

__block TestActor *actor;

describe(@"TBActor", ^{
    
    beforeEach(^{
        actor = [[TestActor alloc] init];
    });
    
    afterEach(^{
        [actor shutDown];
        actor = nil;
    });

    it (@"returns a sync proxy.", ^{
        id proxy = actor.sync;
        BOOL isClass = [proxy isMemberOfClass:[TBActorProxySync class]];
        expect(isClass).to.beTruthy;
    });
    
    it (@"returns an async proxy.", ^{
        id proxy = actor.sync;
        BOOL isClass = [proxy isMemberOfClass:[TBActorProxyAsync class]];
        expect(isClass).to.beTruthy;
    });
    
    it (@"executes a method synchronuously.", ^{
        [actor.sync doStuff];
    });
    
    it (@"executes a parameterized method synchronuously.", ^{
        [actor.sync doStuff:@"aaaaaah" withCompletion:^(NSString *string){
            NSLog(@"string: %@", string);
        }];
    });
    
    it (@"executes a parameterized method asynchronuously.", ^{
        [actor.async doStuff:@"aaaaaah" withCompletion:^(NSString *string){
            NSLog(@"string: %@", string);
        }];
        sleep(0.1);
    });

    it (@"handles subscriptions and publishing", ^{
    
        [actor subscribe:@"nameOne" selector:@selector(handlerOne:)];
        [actor subscribeToPublisher:actor withMessageName:@"nameTwo" selector:@selector(handlerTwo:)];
        
        [actor publish:@"nameOne" payload:@{@"One":@5}];
        [actor publish:@"nameTwo" payload:@{@"Two":@10}];
    });
});

SpecEnd
