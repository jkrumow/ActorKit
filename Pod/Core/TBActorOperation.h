//
//  TBActorOperation.h
//  ActorKit
//
//  Created by Julian Krumow on 22.11.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TBActorOperation : NSBlockOperation

@property (nonatomic) NSInvocation *invocation;

+ (instancetype)operationWithInvocation:(NSInvocation *)invocation;
@end
NS_ASSUME_NONNULL_END
