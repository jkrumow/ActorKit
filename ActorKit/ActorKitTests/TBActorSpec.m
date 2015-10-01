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
    });
    
    describe(@"actorName", ^{
    
        it(@"sets default nil names for actors.", ^{
            expect(actor.actorName).to.beNil;
        });
        
        it(@"sets custom names for actors.", ^{
            actor.actorName = @"foo";
            expect(actor.actorName).to.equal(@"foo");
        });
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
});

SpecEnd
