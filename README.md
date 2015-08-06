# ActorKit

[![Version](https://img.shields.io/cocoapods/v/ActorKit.svg?style=flat)](http://cocoadocs.org/docsets/ActorKit)
[![License](https://img.shields.io/cocoapods/l/ActorKit.svg?style=flat)](http://cocoadocs.org/docsets/ActorKit)
[![Platform](https://img.shields.io/cocoapods/p/ActorKit.svg?style=flat)](http://cocoadocs.org/docsets/ActorKit)
[![CI Status](http://img.shields.io/travis/tarbrain/ActorKit.svg?style=flat)](https://travis-ci.org/tarbrain/ActorKit)
[![Coverage Status](https://img.shields.io/coveralls/tarbrain/ActorKit/master.svg?style=flat)](https://coveralls.io/r/tarbrain/ActorKit)

A lightweight actor framework in Objective-C.

## Features

* Actors
* Actor Pools
* Syncronous and asyncronous invocations
* Message subscription and publication
* Actor registry

## Example Project

To run the example project, clone the repo, and run `pod install` from the `ActorKit` directory first.

## Requirements

* Xcode 6
* watchOS 2.0
* iOS 5.0
* OS X 10.7

## Installation

ActorKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ActorKit"
```

## Usage

### Configuration

```objc
#import <ActorKit/ActorKit.h>
```

### Creating an actor

Create a subclass of `TBActor`:

```objc
@interface WorkerActor : TBActor
@property(nonatomic, strong) NSString *name;
- (void)doSomething;
- (void)handler:(id)payload;
@end

@implementation WorkerActor

- (void)doSomething
{
    // ...
}

- (void)handler:(id)payload
{
    // ...
}
@end
```

Create an actor instance:

```objc
WorkerActor *actor = [WorkerActor new];
```

Create an actor instance using a configuration block:

```objc
WorkerActor *actor = [WorkerActor actorWithConfiguration:^(TBActor *actor) {
    WorkerActor *worker = (WorkerActor *)actor;
    worker.name = @"foo";
}];
```

### Sending messages to the actor

Send a synchronous message to the actor:

```objc
[actor.sync doSomething];
```

Send a asynchronous message to the actor:

```objc
[actor.async doSomething];
```

### Subscribing to messages from other actors

Subscribe to a broadcasted message and set a selector which takes the message's payload as an argument:

```objc
[actor subscribe:@"message" selector:@selector(handler:)];
```

Subscribe to a specified actor and set a selector which takes the message's payload as an argument:

```objc
[actor subscribeToPublisher:otherActor
            withMessageName:@"otherMessage"
                   selector:@selector(handler:)];
```

### Publishing messages to other actors

Publish a message with a payload:

```objc
[actor publish:@"message" payload:@5];
```

### Actor Pools

The actor pool class `TBActorPool` is a subtype of actor so it is basically a proxy actor which mananges multiple child actors. All messages will be invoked on all actors in the pool.

Create an actor pool using your actor subclass which you like to pool:

```objc
TBActorPool *pool = [WorkerActor poolWithSize:10 configuration:^(TBActor *actor, NSUInteger index) {
    WorkerActor *worker = (WorkerActor *)actor;
    worker.name = @"worker";
    worker.id = @(index);
}];
```

The configuration block will be executed for each created actor in the pool.

You can send messages to the pool:

```objc
[pool.sync setName:@"worker"];
[pool.async doSomething];
```

Same goes for subscriptions:

```objc
[pool subscribe:@"messageToWorkers" selector:@selector(handler:)];
```

The handler will be executed on each actor in the pool.

### Holding actors in a registry

Create an actor Registry:

```objc
TBActorRegistry registry = [TBActorRegistry new];
```

Add actors and pools to the registry:

```objc
[registry registerActor:actor withName:@"actor"];
[registry registerActor:pool withName:@"pool"];
```

Remove actors and pools from the registry:

```objc
[registry removeActorWithName:@"actor"];
[registry removeActorWithName:@"pool"];
```


## Useful Theory on Actors

- https://en.wikipedia.org/wiki/Actor_model

## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

ActorKit is available under the MIT license. See the LICENSE file for more info.
