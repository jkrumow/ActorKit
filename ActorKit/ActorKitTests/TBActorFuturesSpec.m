//
//  TBActorFuturesSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//


#import <ActorKit/ActorKit.h>
#import <ActorKit/Futures.h>

#import "TestActor.h"


SpecBegin(TBActorFuture)

__block TestActor *actor;
__block TestActor *otherActor;

__block TBActorPool *pool;
__block dispatch_queue_t testQueue;

describe(@"TBActorFutures", ^{
    
    beforeEach(^{
        actor = [TestActor actorWithConfiguration:^(TBActor *actor) {
            TestActor *testActor = (TestActor *)actor;
            testActor.uuid = @0;
        }];
        otherActor = [TestActor actorWithConfiguration:^(TBActor *actor) {
            TestActor *testActor = (TestActor *)actor;
            testActor.uuid = @1;
        }];
    });
    
    afterEach(^{
        actor = nil;
        otherActor = nil;
    });
    
    
    describe(@"future", ^{
        
        it (@"returns a future proxy.", ^{
            expect([[actor future:nil] isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronuously returning a value through a future.", ^{
            __block TBActorFuture *future;
            waitUntil(^(DoneCallback done) {
                future = (TBActorFuture *)[[actor future:^(id value){
                    done();
                }] returnSomethingBlocking];
                
            });
            expect(future.result).to.equal(@0);
        });
    });
});

describe(@"TBActorPool", ^{
    /*
    beforeEach(^{
        pool = [TestActor poolWithSize:2 configuration:^(TBActor *actor, NSUInteger index) {
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
            expect([[pool future:nil] isMemberOfClass:[TBActorProxyFuture class]]).to.beTruthy;
        });

        it (@"invokes a method asynchronuously on an idle actor returning a value through a future.", ^{
            __block TBActorFuture *future = nil;
            waitUntil(^(DoneCallback done) {
                [pool.async blockSomething:^{
                    done();
                }];
                future = (TBActorFuture *)[pool.future returnSomething];
            });
            expect(future.result).to.beInTheRangeOf(@0, @1);
        });
    });

    describe(@"thread safety", ^{
        
        __block size_t loadSize = 30;
        it(@"seeds future work on multiple actors", ^{
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                TBActorFuture *future = (TBActorFuture *)[pool.future returnSomething];
                __block TBActorFuture *blockFuture = future;
                future.completionBlock = ^{
                    NSLog(@"future: uuid %@", blockFuture.result);
                };
            });
            sleep(1);
        });
    });
     */
});

SpecEnd
