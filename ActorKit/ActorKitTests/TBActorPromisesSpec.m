//
//  TBActorPromisesSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 17.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>
#import <ActorKit/Promises.h>

#import "TestActor.h"


SpecBegin(TBActorPromise)

__block TestActor *actor;
__block TestActor *otherActor;

__block TBActorPool *pool;
__block dispatch_queue_t testQueue;


describe(@"TBActorPromises", ^{
    
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
    
    describe(@"promise", ^{
        
        it (@"returns a promise proxy.", ^{
            expect([actor.promise isMemberOfClass:[TBActorProxyPromise class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronuously returning a value through a promise.", ^{
            __block id blockResult;
            __block PMKPromise *promise;
            waitUntil(^(DoneCallback done) {
                promise = (PMKPromise *)[actor.promise returnSomethingBlocking];
                promise.then(^(id result) {
                    blockResult = result;
                    done();
                });
            });
            expect(blockResult).to.equal(@0);
        });
    });
});

describe(@"TBActorPool", ^{
    
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
    
    describe(@"promise", ^{
        
        it (@"returns a promise proxy.", ^{
            expect([pool.promise isMemberOfClass:[TBActorProxyPromise class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronuously on an idle actor returning a value through a promise.", ^{
            __block PMKPromise *promise;
            __block id blockResult;
            waitUntil(^(DoneCallback done) {
                [pool.async blockSomething:^{
                    done();
                }];
                promise = (PMKPromise *)[pool.promise returnSomething];
                promise.then(^(id result) {
                    blockResult = result;
                });
            });
            expect(blockResult).to.beInTheRangeOf(@0, @1);
        });
    });
    
    describe(@"thread safety", ^{
        
        __block size_t loadSize = 30;
        it(@"seeds work on multiple actors", ^{
            dispatch_apply(loadSize, testQueue, ^(size_t index) {
                PMKPromise *promise = (PMKPromise *)[pool.promise returnSomething];
                promise.then(^(id result) {
                    NSLog(@"FUTURE: result: %@", result);
                });
            });
            sleep(1);
        });
    });
});

SpecEnd
