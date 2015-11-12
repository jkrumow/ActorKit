//
//  TBActorSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/Promises.h>
#import "TestActor.h"


SpecBegin(TBActor)

__block TestActor *actor;
__block NSMutableArray *otherActor;
__block dispatch_queue_t testQueue;
__block dispatch_queue_t completionQueue;
__block NSMutableArray *results;

describe(@"TBActor", ^{
    
    beforeEach(^{
        actor = [TestActor new];
        actor.uuid = @0;
        otherActor = [NSMutableArray new];
    });
    
    afterEach(^{
        [actor unsubscribe:@"message"];
        actor = nil;
        otherActor = nil;
        testQueue = nil;
        completionQueue = nil;
        results = nil;
    });
    
    describe(@"sync", ^{
        
        it (@"returns a sync proxy.", ^{
            expect([actor.sync isMemberOfClass:[TBActorProxySync class]]).to.beTruthy;
        });
        
        it (@"invokes a method synchronously.", ^{
            __block NSString *result;
            [actor.sync doSomething:@"foo" withCompletion:^(NSString *string){
                result = string;
            }];
            expect(result).to.equal(@"foo");
        });
    });
    
    describe(@"async", ^{
        
        it (@"returns an async proxy.", ^{
            expect([actor.async isMemberOfClass:[TBActorProxyAsync class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronously.", ^{
            __block NSString *result;
            waitUntil(^(DoneCallback done) {
                [actor.async doSomething:@"foo" withCompletion:^(NSString *string){
                    result = string;
                    done();
                }];
            });
            expect(result).to.equal(@"foo");
        });
    });
    
    describe(@"promise", ^{
        
        it (@"returns a promise proxy.", ^{
            expect([actor.promise isMemberOfClass:[TBActorProxyPromise class]]).to.beTruthy;
        });
        
        it (@"invokes a method asynchronously returning a value through a promise.", ^{
            __block id blockResult;
            __block AnyPromise *promise;
            waitUntil(^(DoneCallback done) {
                promise = (AnyPromise *)[actor.promise returnSomethingBlocking];
                promise.then(^(id result) {
                    blockResult = result;
                    done();
                });
            });
            expect(blockResult).to.equal(@0);
        });
    });
    
    describe(@"pubsub", ^{
        
        it (@"handles messages from other actors.", ^{
            [actor subscribe:@"message" selector:@selector(handler:)];
            
            expect(^{
                [actor publish:@"message" payload:@5];
            }).to.notify(@"message");
            expect(actor.symbol).to.equal(@5);
        });
        
        it(@"handles messages from a specified actor.", ^{
            [actor subscribeToActor:otherActor messageName:@"message" selector:@selector(handler:)];
            actor.symbol = @5;
            
            [otherActor publish:@"message" payload:nil];
            expect(actor.symbol).to.beNil;
        });
        
        it(@"ignores messages from an unspecified actor.", ^{
            [actor subscribeToActor:otherActor messageName:@"message" selector:@selector(handler:)];
            actor.symbol = @5;
            
            [actor publish:@"message" payload:@10];
            expect(actor.symbol).to.equal(@5);
        });
        
        it(@"handles generic NSNotifications", ^{
            NSObject *sender = [NSObject new];
            [actor subscribeToSender:sender messageName:@"message" selector:@selector(handlerRaw:)];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"message" object:sender userInfo:@{@"symbol":@5}];
            expect(actor.symbol).to.equal(@5);
        });
    });
    
    describe(@"thread safety", ^{
        
        __block size_t taskCount = 10;
        
        beforeEach(^{
            testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
            completionQueue = dispatch_queue_create("completionQueue", DISPATCH_QUEUE_SERIAL);
            results = [NSMutableArray new];
        });
        
        it(@"creates its operation queue lazily once", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSOperationQueue *queue = [actor actorQueue];
                dispatch_sync(completionQueue, ^{
                    [results addObject:queue];
                });
            });
            NSCountedSet *set = [NSCountedSet setWithArray:results];
            expect(set.count).to.equal(1);
            expect([set countForObject:actor.actorQueue]).to.equal(taskCount);
        });
        
        it(@"executes concurrent short synchronous invocations safely", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSNumber *uuid = [actor.sync returnSomethingBlocking];
                dispatch_sync(completionQueue, ^{
                    [results addObject:uuid];
                });
            });
            expect(results).to.haveACountOf(taskCount);
        });
        
        it(@"executes concurrent long synchronous invocations safely", ^{
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                NSNumber *uuid = [actor.sync returnSomething];
                dispatch_sync(completionQueue, ^{
                    [results addObject:uuid];
                });
            });
            expect(results).to.haveACountOf(taskCount);
        });
        
        it(@"executes concurrent short asynchronous invocations safely", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [actor.async returnSomethingBlockingWithCompletion:^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
        });
        
        it(@"executes concurrent long asynchronous invocations safely", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [actor.async returnSomethingWithCompletion:^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
        });
        
        it(@"executes concurrent short promised invocations safely", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    AnyPromise *promise = (AnyPromise *)[actor.promise returnSomethingBlocking];
                    promise.then(^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    });
                });
            });
        });
        
        it(@"executes concurrent long promised invocations safely", ^{
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    AnyPromise *promise = (AnyPromise *)[actor.promise returnSomething];
                    promise.then(^(NSNumber *uuid) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:uuid];
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    });
                });
            });
        });
    });
});

SpecEnd
