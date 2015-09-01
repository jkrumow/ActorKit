//
//  TBActorFuturesSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import <ActorKit/Futures.h>

#import "TestActor.h"


SpecBegin(TBActorFuture)

__block TestActor *actor;
__block TestActor *otherActor;

__block TBActorPool *pool;
__block dispatch_queue_t testQueue;

describe(@"TBActorFutures", ^{
    
    beforeEach(^{
        actor = [TestActor new];
        actor.uuid = @0;
        otherActor = [TestActor new];
        otherActor.uuid = @1;
    });
    
    afterEach(^{
        actor = nil;
        otherActor = nil;
    });
    
    
    describe(@"future", ^{
        
        it (@"returns a future proxy.", ^{
            expect([actor.future isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
        });
        
        it (@"returns a future proxy with a completion block.", ^{
            expect([[actor future:^(id result) {}] isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronously returning a value through a future.", ^{
            __block TBActorFuture *future;
            waitUntil(^(DoneCallback done) {
                future = (TBActorFuture *)[[actor future:^(id value){
                    NSLog(@"result: %@", value);
                    done();
                }] returnSomethingBlocking];
                
            });
            expect(future.result).to.equal(@0);
        });
    });
});

describe(@"TBActorPool", ^{
    
    beforeEach(^{
        pool = [TestActor poolWithSize:2 configuration:^(id actor, NSUInteger index) {
            TestActor *testActor = (TestActor *)actor;
            testActor.uuid = @(index);
        }];
        otherActor = [TestActor new];
        testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    afterEach(^{
        pool = nil;
        otherActor = nil;
        testQueue = nil;
    });
    
    describe(@"future", ^{
        
        it (@"returns a future proxy.", ^{
            expect([pool.future isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
        });
        
        it (@"returns a future proxy with a completion block.", ^{
            expect([[pool future:nil] isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronously on an idle actor returning a value through a future.", ^{
            __block TBActorFuture *future = nil;
            waitUntil(^(DoneCallback done) {
                future = (TBActorFuture *)[[pool future:^(id result) {
                    done();
                }] returnSomething];
            });
            expect(future.result).to.equal(@0);
        });
    });
    
    describe(@"thread safety", ^{
        
        __block size_t loadSize = 30;
        it(@"seeds future work on multiple actors", ^{
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                [[pool future:^(id result){
                    NSLog(@"result: %@", result);
                }] returnSomething];
            });
            sleep(1);
        });
    });
});

SpecEnd
