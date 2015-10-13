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
__block dispatch_queue_t completionQueue;
__block NSMutableArray *results;

describe(@"TBActorSupervisionPool", ^{
    
    beforeEach(^{
        actors = [TBActorSupervisionPool new];
        testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
        completionQueue = dispatch_queue_create("completionQueue", DISPATCH_QUEUE_SERIAL);
        results = [NSMutableArray new];
    });
    
    afterEach(^{
        actors = nil;
        testQueue = nil;
        completionQueue = nil;
        results = nil;
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
        expect(master).notTo.equal(nil);
        
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
    
    it(@"re-creates an actor after a crash", ^{
        [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        TestActor *master = actors[@"master"];
        expect(master).notTo.equal(nil);
        
        // create state and crash
        master.uuid = @(1);
        [master crashWithError:nil];
        
        TestActor *newMaster = actors[@"master"];
        expect(newMaster).notTo.equal(nil);
        expect(newMaster).notTo.equal(master);
        expect(newMaster.uuid).to.equal(nil);
    });
    
    it(@"executes remaining operations on the re-created actor instance after a crash", ^{
        
        __block size_t taskCount = 25;
        
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
        
        TestActor *actor = actors[@"master"];
        NSString *address = [actor address];
        expect([set countForObject:address]).to.beInTheRangeOf(19, 20);
    });
    
    it(@"it recreates an actor cluster after a crash", ^{
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
        
        // create state and crash
        master.uuid = @(0);
        slave.uuid = @(1);
        otherSlave.uuid = @(2);
        slaveSlave.uuid = @(11);
        [master crashWithError:[NSError errorWithDomain:@"com.tarbrain.ActorKit" code:100 userInfo:nil]];
        
        TestActor *newMaster = actors[@"master"];
        TestActor *newSlave = actors[@"slave"];
        TestActor *newOtherSlave = actors[@"otherslave"];
        TestActor *newSlaveSlave = actors[@"slave.slave"];
        
        expect(newMaster).notTo.equal(nil);
        expect(newSlave).notTo.equal(nil);
        expect(newOtherSlave).notTo.equal(nil);
        expect(newSlaveSlave).notTo.equal(nil);
        
        expect(newMaster).notTo.equal(master);
        expect(newSlave).notTo.equal(slave);
        expect(newOtherSlave).notTo.equal(otherSlave);
        expect(newSlaveSlave).notTo.equal(slaveSlave);
        
        expect(newMaster.uuid).to.equal(nil);
        expect(newSlave.uuid).to.equal(nil);
        expect(newOtherSlave.uuid).to.equal(nil);
        expect(newSlaveSlave.uuid).to.equal(nil);
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

SpecEnd
