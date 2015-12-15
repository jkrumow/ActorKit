//
//  TBActorOperation+Supervision.h
//  ActorKitSupervision
//
//  Created by Julian Krumow on 15.12.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <ActorKit/ActorKit.h>

@interface TBActorOperation (Supervision)

- (BOOL)handleCrash:(NSException *)exception forTarget:(NSObject *)target;
@end
