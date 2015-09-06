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
* Synchronous and asynchronous invocations
* Promises
* Message subscription and publication

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


### Creating an actor

By importing `<ActorKit/ActorKit.h>` each class derived from NSObject can be used as an actor.

```objc
Worker *worker = [[Worker alloc] initWithName:@"Bee"];
NSMutableArray *array = [NSMutableArray new];
```

### Sending messages to the actor

Send a synchronous message to the actor:

```objc
[worker.sync doSomething];
```

Send a asynchronous message to the actor:

```objc
[array.async removeAllObjects];
```

### Subscribing to messages from other actors

Subscribe to a broadcasted message and set a selector which takes the message's payload as an argument:

```objc
[worker subscribe:@"message" selector:@selector(handler:)];

- (void)handler:(NSNumber *)number
{
    // ...
}
```

Subscribe to a specified actor:

```objc
[worker subscribeToActor:anotherActor
             messageName:@"anotherMessage"
                selector:@selector(handler:)];
```

### Publishing messages to other actors

Publish a message with a payload:

```objc
[array publish:@"message" payload:@5];
```

### Unsubscribing

To unsibscribe form a message:

```objc
[worker unsubscribe:@"message"];
```

Before destroying an actor you should unsubscribe from all messages.

### Actor Pools

The actor pool class `TBActorPool` is a subtype of actor so it is basically a proxy actor which mananges multiple actors. A received message will be forwarded on an available actor in the pool.

Create an actor pool using your actor subclass which you like to pool:

```objc
TBActorPool *pool = [WorkerActor poolWithSize:10 configuration:^(NSObject *actor, NSUInteger index) {
    WorkerActor *worker = (WorkerActor *)actor;
    worker.name = @"worker";
    worker.id = @(index);
}];
```

The configuration block will be executed on an available actor in the pool.

You can send messages to the pool:

```objc
[pool.sync setName:@"worker"];
[pool.async doSomething];
```

Same goes for subscriptions:

```objc
[pool subscribe:@"messageToWorkers" selector:@selector(handler:)];
```

And unsubscriptions:
```objc
[pool unsubscribe:@"messageToWorkers"];
```

The handler will be executed on an available actor in the pool.

### (work in progress) Promises

Promise support is contained in the subspec `Promises`:

```ruby
target 'MyApp', :exclusive => true do
  pod 'ActorKit/Promises'
end
```

Actors and pool can return a promise for an asynchronous task.

```objc
#import <ActorKit/Promises.h>
```

Send a asynchronous message and receive a promise back:

```objc
TBActorPromise *promise = (TBActorPromise *)[worker.promise returnSomethingBlocking];
promise.then(^(id result) {
    
    // ...
});
```

## Architecture

This framework seeks for a very simple implementation of actors. It basically consists of a category which lazily adds an `NSOperationQueue` to the `NSObject` which should work as an actor. Messages sent to the actor are forwarded by an `NSProxy` using `NSInvocationOperations`. These three classes practically represent mailbox, thread, runloop and message.

## Useful Theory on Actors

- https://en.wikipedia.org/wiki/Actor_model

## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

ActorKit is available under the MIT license. See the LICENSE file for more info.
