//
//  TBActorSupervisionPoolSpec.m
//  ActorKitTests
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright © 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/Supervision.h>

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
    
    it(@"returns the id of a given actor instance", ^{
        [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
            *actor = [TestActor new];
        }];
        TestActor *actor = actors[@"master"];
        TestActor *otherActor = [TestActor new];
        
        expect([actors idForActor:actor]).to.equal(@"master");
        expect([actors idForActor:otherActor]).to.beNil;
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
                        @synchronized(results) {
                            [results addObject:address];
                            
                            if (results.count == 5) {
                                [actors[@"master"] doCrash];
                            }
                            if (results.count == taskCount) {
                                done();
                            }
                        }
                    }];
                });
            });
            
            NSLog(@"results: %@", results);
            
            NSCountedSet *set = [NSCountedSet setWithArray:results];
            expect(set.count).to.equal(2);
        });
        
        it(@"executes remaining operations on the re-created actor-pool instance after a crash", ^{
            
            [actors superviseWithId:@"pool" creationBlock:^(NSObject **actor) {
                *actor = [TestActor poolWithSize:2 configuration:^(NSObject *actor, NSUInteger index) {
                    TestActor *testActor = (TestActor *)actor;
                    testActor.uuid = @(index);
                }];
            }];
            
            TBActorPool *poolInstance = actors[@"pool"];
            NSLog(@"0: %@", poolInstance.actors[0]);
            NSLog(@"1: %@", poolInstance.actors[1]);
            
            TestActor *actorToCrash = poolInstance.actors[0];
            
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                [[actors[@"pool"] async] addressBlocking:^(NSString *address) {
                    @synchronized(results) {
                        [results addObject:address];
                        
                        if (results.count == 2) {
                            [actorToCrash doCrash];
                        }
                    }
                }];
            });
            
            sleep(1);
            
            NSLog(@"results: %@", results);
            
            TBActorPool *newInstance = actors[@"pool"];
            NSLog(@"0: %@", newInstance.actors[0]);
            NSLog(@"1: %@", newInstance.actors[1]);
            
            expect(poolInstance).notTo.equal(newInstance);
        });
    });
    describe(@"linking", ^{
        
        it(@"it recreates linked actors after simultanious crashes", ^{
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"otherchild" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"child.child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            [actors linkActor:@"child" toParentActor:@"master"];
            [actors linkActor:@"otherchild" toParentActor:@"master"];
            [actors linkActor:@"child.child" toParentActor:@"master"];
            
            TestActor *master = actors[@"master"];
            TestActor *child = actors[@"child"];
            TestActor *otherSlave = actors[@"otherchild"];
            TestActor *childSlave = actors[@"child.child"];
            
            // Create state and crash two actors
            master.uuid = @(0);
            child.uuid = @(1);
            otherSlave.uuid = @(2);
            childSlave.uuid = @(11);
            
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [[actors[@"master"] async] address:^(NSString *address) {
                        @synchronized(results) {
                            [results addObject:address];
                            
                            if (results.count == 5) {
                                [actors[@"master"] doCrash];
                            }
                            if (results.count == taskCount && results2.count == taskCount) {
                                done();
                            }
                        }
                    }];
                    
                    [[actors[@"child.child"] async] address:^(NSString *address) {
                        @synchronized(results) {
                            [results2 addObject:address];
                            
                            if (results2.count == 5) {
                                [actors[@"child.child"] doCrash];
                            }
                            if (results.count == taskCount && results2.count == taskCount) {
                                done();
                            }
                        }
                    }];
                });
            });
            
            TestActor *newMaster = actors[@"master"];
            TestActor *newSlave = actors[@"child"];
            TestActor *newOtherSlave = actors[@"otherchild"];
            TestActor *newSlaveSlave = actors[@"child.child"];
            
            expect(newMaster).notTo.beNil;
            expect(newSlave).notTo.beNil;
            expect(newOtherSlave).notTo.beNil;
            expect(newSlaveSlave).notTo.beNil;
            
            expect(newMaster).notTo.equal(master);
            expect(newSlave).notTo.equal(child);
            expect(newOtherSlave).notTo.equal(otherSlave);
            expect(newSlaveSlave).notTo.equal(childSlave);
            
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
            [actors superviseWithId:@"child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"otherchild" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"child.child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            [actors linkActor:@"child" toParentActor:@"master"];
            [actors linkActor:@"otherchild" toParentActor:@"master"];
            [actors linkActor:@"child.child" toParentActor:@"child"];
            
            expect(^{
                [actors linkActor:@"master" toParentActor:@"child.child"];
            }).to.raise(TBAKException);
        });
    });
});

SpecEnd
