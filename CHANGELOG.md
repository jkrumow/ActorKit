# ActorKit CHANGELOG

## 0.55.0

- add unsupervising to supervision subspec
- add unlinking to supervision subspec

## 0.51.0

- cleanup error messages

## 0.50.0

- updated project after change of github user name

## 0.30.0

- promise sub spec supports all four platforms now
- cleaned up supervision code

## 0.25.0

- cleaned up supervision code
- improved tests

## 0.22.0

- improved log output for crashes under supervision

## 0.21.0

- handles regular NSNotification by passing the whole `userInfo` dictionary instead of only the `TBAKActorPayload`

## 0.20.0

- re-throw exceptions when not under supervision
- code cleanup and stability improvements

## 0.16.0

- re-add supervision and linking via subspec `Supervision`
- simplified pub-sub API

## 0.15.0

- Update subspec `ActorKit/Promises` to use latest version of `PromiseKit`

## 0.12.1

- Add nullability annotations and generics to improve Swift compatibility
- Fixed retain cycle in pubsub mechanism

## 0.12.0

- Remove supervision and linking

## 0.11.0

- Improve thread safety of `TBActorSupervisor` and `TBActorSupervisionPool`

## 0.10.0

- Execute scheduled invocations on re-created supervised actor after a crash

## 0.9.0

- Add supervision and linking

## 0.8.0

- Add support for tvOS 9.0

## 0.7.5

- Add `TBActorProxyBroadcast` to broadcast messages into all actors in a pool.

## 0.7.2

- Add instance method `subscribeToSender:withMessageName:selector:` to subscribe to NSNotification of generic senders with aw payload.

## 0.7.1

- Fixes bug which caused crash when posting message with payload being nil

## 0.7.0

- Fixes platform support. All subspecs support iOS, watchOS and OS X except 'ActorKit/Promises'

## 0.6.0

- Major refactoring to make every NSObject an actor

## 0.5.0

- Add subspec Promises (experimental) which uses the pod 'PromiseKit'
- Moved futures into separate (experimental) sub-dependency 'Futures'
- Remove TBActorRegistry

## 0.3.0

- Add future proxy
- Load distribution in actor pools
- Class methods to create TBActor and TBActorPool

## 0.2.0

- Actors
- Actor Pools
- synchronous and asynchronous invocations
- Message subscription and publication

## 0.1.0

- initial release
