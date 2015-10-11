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

describe(@"TBActorSupervisionPool", ^{
    
    beforeEach(^{
        actors = [TBActorSupervisionPool new];
    });
    
    afterEach(^{
        actors = nil;
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
    
    it(@"cancels remaining operations on the queue when actor crashed", ^{
        [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        waitUntil(^(DoneCallback done) {
            [[actors[@"master"] async] doSomething:@"0" withCompletion:^(NSString *string) {
                [actors[@"master"] crashWithError:[NSError errorWithDomain:@"com.tarbrain.ActorKit" code:100 userInfo:nil]];
                done();
            }];
            [[actors[@"master"] async] doSomething:@"1" withCompletion:^(NSString *string) {
                XCTFail(@"operation should be cancelled");
            }];
        });
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
});

SpecEnd
