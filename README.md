# ActorKit

[![Version](https://img.shields.io/cocoapods/v/ActorKit.svg?style=flat)](http://cocoadocs.org/docsets/ActorKit)
[![License](https://img.shields.io/cocoapods/l/ActorKit.svg?style=flat)](http://cocoadocs.org/docsets/ActorKit)
[![Platform](https://img.shields.io/cocoapods/p/ActorKit.svg?style=flat)](http://cocoadocs.org/docsets/ActorKit)
[![CI Status](http://img.shields.io/travis/jkrumow/ActorKit.svg?style=flat)](https://travis-ci.org/jkrumow/ActorKit)

A lightweight actor framework in Objective-C.

## Features

* Actors
* Actor Pools
* Synchronous and asynchronous invocations
* Promises
* Notification subscription and publication
* Supervision
* Linking

## Requirements

* iOS 8.0
* watchOS 2.0
* tvOS 9.0
* OS X 10.9

## Installation

ActorKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ActorKit'
```

## Usage

Importing `<ActorKit/ActorKit.h>` provides you with the core functionality of the framework.

### Creating an Actor

Every subtype of `NSObject` can be turned into an actor:

```objc
Worker *worker = [[Worker alloc] initWithName:@"Bee"];
NSMutableArray *array = [NSMutableArray new];
```

### Sending Messages to Actors

To send a synchronous message to the actor initiate the call with `sync`:

```objc
BOOL success = [worker.sync doSomething];
```

Send an asynchronous message to the actor call `async`:

```objc
[array.async removeAllObjects];
```

### Subscribing to notifications from other actors

To subscribe to a broadcasted notification set the notification name and a selector which takes the notification's payload as an argument:

```objc
[worker subscribe:@"notification" selector:@selector(handler:)];

- (void)handler:(NSNumber *)number
{
    // ...
}
```

### Publishing notifications to other actors

Publish a notification with a payload:

```objc
[self publish:@"notification" payload:@5];
```

To unsubscribe from a notification:

```objc
[worker unsubscribe:@"notification"];
```

Before destroying an actor you should unsubscribe from all notifications.

### Actor Pools

The class `TBActorPool` is basically a proxy actor which mananges multiple actors of the same type. A message which is send to the pool will be forwarded to an actor inside the pool which has the lowest workload at the time the message is processed.

You can create an actor pool by invoking the method below on the class of your coice. An actor instance will be created and passed into the configuration block for further initialization:

```objc
TBActorPool *pool = [Worker poolWithSize:10 configuration:^(NSObject *actor) {
    Worker *worker = (Worker *)actor;
    worker.name = @"worker";
    worker.Id = @(123);
}];
```

You can send messages to the pool:

```objc
[pool.sync setName:@"worker"];
[pool.async doSomething];
```

Same goes for subscriptions:

```objc
[pool subscribe:@"notificationToWorkers" selector:@selector(handler:)];
[pool unsubscribe:@"notificationToWorkers"];
```

The handler will be executed on an available actor in the pool.

#### Broadcasts

To send an asynchronous message to all actors inside the pool:

```objc
[pool.broadcast ping];
```

### Promises

Promise support using [PromiseKit](http://promisekit.org) is available via the subspec `Promises`:

```ruby
target 'MyApp', :exclusive => true do
  pod 'ActorKit/Promises'
end
```

```objc
#import <ActorKit/Promises.h>
```

Send a asynchronous message and receive a promise back:

```objc
AnyPromise *promise = (AnyPromise *)[worker.promise returnSomethingBlocking];
promise.then(^(id result) {
    
    // ...
});
```

### Supervision and Linking of Actors

Supervision and Linking is available via the subspec `Supervision`:

```ruby
target 'MyApp', :exclusive => true do
  pod 'ActorKit/Supervision'
end
```

```objc
#import <ActorKit/Supervision.h>
```

#### Supervised Actors

You can create supervised actors by passing an id and a creation block to a supervision pool:

```objc
TBActorSupervisionPool *actors = [TBActorSupervisionPool new];

[actors superviseWithId:@"master" creationBlock:^NSObject * {
    Worker *worker = Worker.new;
    worker.name = @"master";
    worker.Id = @(123);
    return worker;
}];
```

The creation block will be called whenever the actor needs to be (re)created.

#### Accessing Actors Inside the Supervision Pool

Access the supervised actor by its id on the supervision pool:

```objc
[actors[@"master"].sync doSomething];
```

#### Unsupervising Actors

To remove an actor from a supervision pool:

```objc
[actors unsuperviseActorWithId:@"master"];
```

#### Linking Actors

Links establish parent-child relationships between actors. Linked actors will be supervised depending on each other. If the parent actor crashes the child actor will be re-created as well. Whenever an actor is removed from the supervision pool its linked actors are removed as well.

```objc
[actors linkActor:@"child" toParentActor:@"master"];
```

To remove a link:

```objc
[actors unlinkActor:@"child" fromParentActor:@"master"];
```

#### Recovering from Crashes

Whenever a supervised actor crashes it is re-created and will resume processing pending messages from its mailbox.

**Special behavior for pools:**

- when the pool actor itself crashes the whole pool is recreated completely and the content of all mailboxes will be processed by the new pool instance
- when an actor inside the pool crashes only that instance is recreated and its mailbox content will be processed by its successor

You can also communicate a crash manually by calling `crashWithError:`:

```objc
@implementation Worker

- (void)doSomething
{
    NSError *error = nil;
    [self _doSomethingInternal:&error];
    if (error) {
        [self crashWithError:error];
    }
}

@end
```
**Attention:** Cocoa is not a framework which employs exceptions as a legitimate means to communicate errors. There are a lot of layers which prevent exceptions to bubble up the stack until they can be handled by the supervisor (GCD etc.). So be prepared for exceptions which still can crash the application.

**Warning:** Scheduling your own operations on the actor queue directly is strongly discouraged since the supervision can not guarantee that this operations can be executed properly by the new actor instance.

## Architecture

This framework seeks for a very simple implementation of actors. It basically consists of a category which lazily adds an `NSOperationQueue` to the `NSObject` which should work as an actor. Messages sent to the actor are forwarded by an `NSProxy` using `NSInvocation` and `NSOperation` objects. These classes represent mailboxes, threads and messages etc.

## Example Project

To run the example project, clone the repo, and run `pod install` from the `ActorKit` directory first.

## Useful Theory on Actors

- https://en.wikipedia.org/wiki/Actor_model

## Author

Julian Krumow, julian.krumow@bogusmachine.com

## License

ActorKit is available under the MIT license. See the LICENSE file for more info.
