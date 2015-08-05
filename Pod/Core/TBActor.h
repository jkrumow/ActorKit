//
//  TBActor.h
//  ActorKit
//
//  Created by Julian Krumow on 13.07.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBActor : NSOperationQueue

- (instancetype)initWithBlock:(void(^)(TBActor *actor))block;

- (id)sync;
- (id)async;

- (void)subscribe:(NSString *)messageName selector:(SEL)selector;
- (void)subscribeToPublisher:(id)actor withMessageName:(NSString *)messageName selector:(SEL)selector;
- (void)post:(NSString *)messageName payload:(id)payload;
@end
