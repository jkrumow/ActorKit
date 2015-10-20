//
//  TBActorSupervisionPoolSpec.m
//  ActorKit
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright © 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

SpecBegin(TBActorSupervisionPool)

__block TBActorSupervisionPool *actors;
__block dispatch_queue_t testQueue;
__block dispatch_queue_t testQueue2;
__block dispatch_queue_t completionQueue;
__block dispatch_queue_t completionQueue2;
__block NSMutableArray *results;
__block NSMutableArray *results2;
__block size_t taskCount = 25;

describe(@"TBActorSupervisionPool", ^{
    
    beforeEach(^{
        actors = [TBActorSupervisionPool new];
        testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
        completionQueue = dispatch_queue_create("completionQueue", DISPATCH_QUEUE_SERIAL);
        testQueue2 = dispatch_queue_create("testQueue2", DISPATCH_QUEUE_CONCURRENT);
        completionQueue2 = dispatch_queue_create("completionQueue2", DISPATCH_QUEUE_SERIAL);
        results = [NSMutableArray new];
        results2 = [NSMutableArray new];
    });
    
    afterEach(^{
        actors = nil;
        testQueue = nil;
        completionQueue = nil;
        testQueue2 = nil;
        completionQueue2 = nil;
        results = nil;
        results2 = nil;
    });
    
    it(@"creates a singleton instance", ^{
        TBActorSupervisionPool *instanceOne = [TBActorSupervisionPool sharedInstance];
        TBActorSupervisionPool *instanceTwo = [TBActorSupervisionPool sharedInstance];
        
        expect(instanceOne).to.equal(instanceTwo);
    });
    
    it(@"creates an actor based on a creation block", ^{
        [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        TestActor *master = actors[@"master"];
        expect(master).notTo.beNil;
        
        master.uuid = @(1);
        NSNumber *uuid = [[actors[@"master"] sync] uuid];
        expect(uuid).to.equal(1);
    });
    
    it(@"returns supervisors by given actor ids", ^{
        [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        NSArray *supervisors = [actors supervisorsForIds:[NSSet setWithObjects:@"master", @"none", nil]];
        expect(supervisors).to.haveACountOf(1);
        
        TBActorSupervisor *supervisor = supervisors.firstObject;
        expect(supervisor.Id).to.equal(@"master");
    });
    
    it(@"throws an exception when an Id is already in use", ^{
        [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        expect(^{
            [actors superviseWithId:@"master" creationBlock:nil];
        }).to.raise(TBAKException);
    });
    
    describe(@"crashes and recreation", ^{
        
        it(@"re-creates an actor after a crash", ^{
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            TestActor *master = actors[@"master"];
            expect(master).notTo.beNil;
            
            // Create state and crash
            master.uuid = @(1);
            [master crashWithError:nil];
            
            TestActor *newMaster = actors[@"master"];
            expect(newMaster).notTo.beNil;
            expect(newMaster).notTo.equal(master);
            expect(newMaster.uuid).to.beNil;
        });
        
        it(@"executes remaining operations on the re-created actor instance after a crash", ^{
            
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [[actors[@"master"] async] address:^(NSString *address) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:address];
                            
                            if (results.count == 5) {
                                [actors[@"master"] crashWithError:[NSError errorWithDomain:@"com.tarbrain.ActorKit" code:100 userInfo:nil]];
                            }
                            if (results.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
            
            NSLog(@"results: %@", results);
            
            NSCountedSet *set = [NSCountedSet setWithArray:results];
            expect(set.count).to.equal(2);
        });
    });
    
    describe(@"linking", ^{
        
        it(@"it recreates linked actors after simultanious crashes", ^{
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"slave" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"otherslave" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"slave.slave" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            [actors linkActor:@"slave" toActor:@"master"];
            [actors linkActor:@"otherslave" toActor:@"master"];
            [actors linkActor:@"slave.slave" toActor:@"slave"];
            
            TestActor *master = actors[@"master"];
            TestActor *slave = actors[@"slave"];
            TestActor *otherSlave = actors[@"otherslave"];
            TestActor *slaveSlave = actors[@"slave.slave"];
            
            // Create state and crash two actors
            master.uuid = @(0);
            slave.uuid = @(1);
            otherSlave.uuid = @(2);
            slaveSlave.uuid = @(11);
            
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [[actors[@"master"] async] address:^(NSString *address) {
                        dispatch_sync(completionQueue, ^{
                            [results addObject:address];
                            
                            if (results.count == 5) {
                                [actors[@"master"] crashWithError:[NSError errorWithDomain:@"com.tarbrain.ActorKit" code:100 userInfo:nil]];
                            }
                            if (results.count == taskCount && results2.count == taskCount) {
                                done();
                            }
                        });
                    }];
                    
                    [[actors[@"slave.slave"] async] address:^(NSString *address) {
                        dispatch_sync(completionQueue2, ^{
                            [results2 addObject:address];
                            
                            if (results2.count == 5) {
                                [actors[@"slave.slave"] crashWithError:[NSError errorWithDomain:@"com.tarbrain.ActorKit" code:100 userInfo:nil]];
                            }
                            if (results.count == taskCount && results2.count == taskCount) {
                                done();
                            }
                        });
                    }];
                });
            });
            
            TestActor *newMaster = actors[@"master"];
            TestActor *newSlave = actors[@"slave"];
            TestActor *newOtherSlave = actors[@"otherslave"];
            TestActor *newSlaveSlave = actors[@"slave.slave"];
            
            expect(newMaster).notTo.beNil;
            expect(newSlave).notTo.beNil;
            expect(newOtherSlave).notTo.beNil;
            expect(newSlaveSlave).notTo.beNil;
            
            expect(newMaster).notTo.equal(master);
            expect(newSlave).notTo.equal(slave);
            expect(newOtherSlave).notTo.equal(otherSlave);
            expect(newSlaveSlave).notTo.equal(slaveSlave);
            
            expect(newMaster.uuid).to.beNil;
            expect(newSlave.uuid).to.beNil;
            expect(newOtherSlave.uuid).to.beNil;
            expect(newSlaveSlave.uuid).to.beNil;
            
            NSLog(@"results: %@", results);
            NSLog(@"results2: %@", results2);
            
            NSCountedSet *set = [NSCountedSet setWithArray:results];
            expect(set.count).to.equal(2);
            
            NSCountedSet *set2 = [NSCountedSet setWithArray:results2];
            expect(set2.count).to.beInTheRangeOf(2, 3);
        });
        
        it(@"throws an exception when linking actors causes circular references", ^{
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"slave" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"otherslave" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"slave.slave" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            [actors linkActor:@"slave" toActor:@"master"];
            [actors linkActor:@"otherslave" toActor:@"master"];
            [actors linkActor:@"slave.slave" toActor:@"slave"];
            
            expect(^{
                [actors linkActor:@"master" toActor:@"slave.slave"];
            }).to.raise(TBAKException);
        });
    });
});

SpecEnd
