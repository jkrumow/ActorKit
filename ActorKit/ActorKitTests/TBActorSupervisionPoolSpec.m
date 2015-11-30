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
__block NSMutableArray *addresses;
__block NSMutableArray *addresses2;
__block size_t taskCount = 25;

describe(@"TBActorSupervisionPool", ^{
    
    beforeEach(^{
        actors = [TBActorSupervisionPool new];
        testQueue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
        addresses = [NSMutableArray new];
        addresses2 = [NSMutableArray new];
    });
    
    afterEach(^{
        actors = nil;
        testQueue = nil;
        addresses = nil;
        addresses2 = nil;
    });
    
    it(@"creates a singleton instance", ^{
        TBActorSupervisionPool *instanceOne = [TBActorSupervisionPool sharedInstance];
        TBActorSupervisionPool *instanceTwo = [TBActorSupervisionPool sharedInstance];
        
        expect(instanceOne).to.equal(instanceTwo);
    });
    
    it(@"creates an actor with a given ID from a creation block", ^{
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
            [master crashWithError:nil];
            
            TestActor *newMaster = actors[@"master"];
            expect(newMaster).notTo.beNil;
            expect(newMaster).notTo.equal(master);
        });
        
        it(@"executes remaining operations on the re-created actor instance after a crash", ^{
            
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            TestActor *master = actors[@"master"];
            
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [[actors[@"master"] async] address:^(NSString *address) {
                        @synchronized(addresses) {
                            [addresses addObject:address];
                            
                            if (addresses.count == 5) {
                                [master.async doCrash];
                            }
                            if (addresses.count == taskCount) {
                                done();
                            }
                        }
                    }];
                });
            });
            
            NSLog(@"addresses: %@", addresses);
            expect(addresses).to.haveACountOf(taskCount);
            
            NSCountedSet *set = [NSCountedSet setWithArray:addresses];
            expect(set.count).to.equal(2);
        });
        
        it(@"re-creates a new actor pool after a crash", ^{
            
            [actors superviseWithId:@"pool" creationBlock:^(NSObject **actor) {
                *actor = [TestActor poolWithSize:2 configuration:nil];
            }];
            
            TBActorPool *pool = actors[@"pool"];
            TestActor *workerOne = pool.actors.allObjects[0];
            TestActor *workerTwo = pool.actors.allObjects[1];
            
            NSLog(@"actors: %@", pool.actors);
            
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                [[actors[@"pool"] async] addressBlocking:^(NSString *address) {
                    @synchronized(addresses) {
                        [addresses addObject:address];
                        
                        if (addresses.count == 5) {
                            [pool crashWithError:nil];
                        }
                    }
                }];
            });
            
            sleep(1);
            
            TBActorPool *newPool = actors[@"pool"];
            
            NSLog(@"actors: %@", newPool.actors);
            
            expect(newPool).notTo.equal(pool);
            expect(newPool.actors).notTo.contain(workerOne);
            expect(newPool.actors).notTo.contain(workerTwo);
            
            NSLog(@"addresses: %@", addresses);
            
            expect(addresses).to.haveACountOf(taskCount);
            
            NSCountedSet *set = [NSCountedSet setWithArray:addresses];
            expect(set.count).to.equal(4);
        });
        
        it(@"executes remaining operations on the re-created pooled actor instance after a crash", ^{
            
            [actors superviseWithId:@"pool" creationBlock:^(NSObject **actor) {
                *actor = [TestActor poolWithSize:2 configuration:nil];
            }];
            
            TBActorPool *pool = actors[@"pool"];
            TestActor *workerOne = pool.actors.allObjects[0];
            TestActor *workerTwo = pool.actors.allObjects[1];
            
            NSLog(@"actors: %@", pool.actors);
            
            dispatch_apply(taskCount, testQueue, ^(size_t index) {
                [[actors[@"pool"] async] addressBlocking:^(NSString *address) {
                    @synchronized(addresses) {
                        [addresses addObject:address];
                        
                        if (addresses.count == 5) {
                            [workerOne.async doCrash];
                        }
                    }
                }];
            });
            
            sleep(1);
            
            TBActorPool *samePool = actors[@"pool"];
            
            NSLog(@"actors: %@", samePool.actors);
            
            expect(samePool).to.equal(pool);
            expect(samePool.actors).notTo.contain(workerOne);
            expect(samePool.actors).to.contain(workerTwo);
            
            NSLog(@"addresses: %@", addresses);
            
            expect(addresses).to.haveACountOf(taskCount);
            
            NSCountedSet *set = [NSCountedSet setWithArray:addresses];
            expect(set.count).to.beInTheRangeOf(2, 3);
        });
    });
    
    describe(@"pubsub", ^{
    
        it(@"re-creates an actor with subscriptions", ^{
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            TestActor *master = actors[@"master"];
            expect(master).notTo.beNil;
            
            // Create state and crash
            [master subscribe:@"notification" selector:@selector(handler:)];
            [master subscribe:@"signal" selector:@selector(handlerRaw:)];
            [master crashWithError:nil];
            
            TestActor *newMaster = actors[@"master"];
            expect(newMaster).notTo.beNil;
            expect(newMaster).notTo.equal(master);
            expect(newMaster.subscriptions.allKeys).to.haveACountOf(2);
        });
        
        it(@"re-creates an actor pool with subscriptions", ^{
            [actors superviseWithId:@"pool" creationBlock:^(NSObject **actor) {
                *actor = [TestActor poolWithSize:1 configuration:nil];
            }];
            
            TBActorPool *pool = actors[@"pool"];
            
            // Create state and crash
            [pool subscribe:@"notification" selector:@selector(handler:)];
            [pool.actors.anyObject subscribe:@"signal" selector:@selector(handlerRaw:)];
            [pool crashWithError:nil];
            
            TBActorPool *newPool = actors[@"pool"];
            expect(newPool.subscriptions.allKeys).to.haveACountOf(1);
            expect(newPool.actors.anyObject.subscriptions.allKeys).to.haveACountOf(1);
        });
        
        it(@"re-creates a pooled actor instance with subscriptions", ^{
            [actors superviseWithId:@"pool" creationBlock:^(NSObject **actor) {
                *actor = [TestActor poolWithSize:1 configuration:nil];
            }];
            
            TBActorPool *pool = actors[@"pool"];
            TestActor *workerOne = pool.actors.anyObject;
            
            // Create state and crash
            [pool subscribe:@"notification" selector:@selector(handler:)];
            [workerOne subscribe:@"signal" selector:@selector(handlerRaw:)];
            [workerOne crashWithError:nil];
            
            pool = actors[@"pool"];
            workerOne = pool.actors.anyObject;
            expect(pool.subscriptions.allKeys).to.haveACountOf(1);
            expect(workerOne.subscriptions.allKeys).to.haveACountOf(1);
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
            [actors superviseWithId:@"otherChild" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"child.child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            [actors linkActor:@"child" toParentActor:@"master"];
            [actors linkActor:@"otherChild" toParentActor:@"master"];
            [actors linkActor:@"child.child" toParentActor:@"master"];
            
            TestActor *master = actors[@"master"];
            TestActor *child = actors[@"child"];
            TestActor *otherChild = actors[@"otherChild"];
            TestActor *childChild = actors[@"child.child"];
            
            // Create state and crash two actors
            
            waitUntil(^(DoneCallback done) {
                dispatch_apply(taskCount, testQueue, ^(size_t index) {
                    [[actors[@"master"] async] address:^(NSString *address) {
                        @synchronized(addresses) {
                            [addresses addObject:address];
                            
                            if (addresses.count == 5) {
                                [master.async doCrash];
                            }
                            if (addresses.count == taskCount && addresses2.count == taskCount) {
                                done();
                            }
                        }
                    }];
                    
                    [[actors[@"child.child"] async] address:^(NSString *address) {
                        @synchronized(addresses) {
                            [addresses2 addObject:address];
                            
                            if (addresses2.count == 5) {
                                [childChild.async doCrash];
                            }
                            if (addresses.count == taskCount && addresses2.count == taskCount) {
                                done();
                            }
                        }
                    }];
                });
            });
            
            TestActor *newMaster = actors[@"master"];
            TestActor *newChild = actors[@"child"];
            TestActor *newOtherChild = actors[@"otherChild"];
            TestActor *newChildChild = actors[@"child.child"];
            
            expect(newMaster).notTo.beNil;
            expect(newChild).notTo.beNil;
            expect(newOtherChild).notTo.beNil;
            expect(newChildChild).notTo.beNil;
            
            expect(newMaster).notTo.equal(master);
            expect(newChild).notTo.equal(child);
            expect(newOtherChild).notTo.equal(otherChild);
            expect(newChildChild).notTo.equal(childChild);
            
            NSLog(@"addresses: %@", addresses);
            NSLog(@"addresses2: %@", addresses2);
            
            expect(addresses).to.haveACountOf(taskCount);
            expect(addresses2).to.haveACountOf(taskCount);
            
            NSCountedSet *set = [NSCountedSet setWithArray:addresses];
            expect(set.count).to.equal(2);
            
            NSCountedSet *set2 = [NSCountedSet setWithArray:addresses2];
            expect(set2.count).to.beInTheRangeOf(2, 3);
        });
        
        it(@"throws an exception when linking actors causes circular references", ^{
            [actors superviseWithId:@"master" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"otherChild" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            [actors superviseWithId:@"child.child" creationBlock:^(NSObject **actor) {
                *actor = [TestActor new];
            }];
            
            [actors linkActor:@"child" toParentActor:@"master"];
            [actors linkActor:@"otherChild" toParentActor:@"master"];
            [actors linkActor:@"child.child" toParentActor:@"child"];
            
            expect(^{
                [actors linkActor:@"master" toParentActor:@"child.child"];
            }).to.raise(TBAKException);
        });
    });
});

SpecEnd
