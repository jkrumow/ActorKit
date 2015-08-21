# ActorKit CHANGELOG

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
