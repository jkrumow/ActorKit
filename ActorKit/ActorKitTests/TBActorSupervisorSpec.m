//
//  TBActorSupervisorSpec.m
//  ActorKit
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright © 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

SpecBegin(TBActorSupervisor)

__block TBActorSupervisor *supervisor;

describe(@"TBActorSupervisor", ^{
    
    beforeEach(^{
        supervisor = [TBActorSupervisor new];
    });
    
    afterEach(^{
        supervisor = nil;
    });
    
    it(@"creates an actor based on a creation block", ^{
        [supervisor superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        TestActor *master = supervisor[@"master"];
        expect(master).notTo.equal(nil);
        
        master.uuid = @(1);
        NSNumber *uuid = [[supervisor[@"master"] sync] uuid];
        expect(uuid).to.equal(1);
    });
    
    it(@"re-creates an actor after a crash", ^{
        [supervisor superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        TestActor *master = supervisor[@"master"];
        expect(master).notTo.equal(nil);

        // create state and crash
        master.uuid = @(1);
        [master crashWithError:nil];
        
        TestActor *newMaster = supervisor[@"master"];
        expect(newMaster).notTo.equal(nil);
        expect(newMaster).notTo.equal(master);
        expect(newMaster.uuid).to.equal(nil);
    });
    
    it(@"it recreates an actor cluster after a crash", ^{
        [supervisor superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        [supervisor superviseWithId:@"slave" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        [supervisor superviseWithId:@"otherslave" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        [supervisor superviseWithId:@"slave.slave" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        
        [supervisor linkActor:@"slave" toActor:@"master"];
        [supervisor linkActor:@"otherslave" toActor:@"master"];
        [supervisor linkActor:@"slave.slave" toActor:@"slave"];
        
        TestActor *master = supervisor[@"master"];
        TestActor *slave = supervisor[@"slave"];
        TestActor *otherSlave = supervisor[@"otherslave"];
        TestActor *slaveSlave = supervisor[@"slave.slave"];
        
        // create state and crash
        master.uuid = @(0);
        slave.uuid = @(1);
        otherSlave.uuid = @(2);
        slaveSlave.uuid = @(11);
        [master crashWithError:[NSError errorWithDomain:@"com.tarbrain.ActorKit" code:100 userInfo:nil]];
        
        TestActor *newMaster = supervisor[@"master"];
        TestActor *newSlave = supervisor[@"slave"];
        TestActor *newOtherSlave = supervisor[@"otherslave"];
        TestActor *newSlaveSlave = supervisor[@"slave.slave"];
        
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
