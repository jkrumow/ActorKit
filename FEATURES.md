# Features:

### FutureProxy

- casting to Future instead of real return value?
- find better solution - is  `-forwardinvocation:` pattern really necessary?
- blocking futures unorthodox in cocoa - better use pubsub

### Actor Lifecycle

- if crashing and restarting of actors is an option:
    - linking
    - supervision
    - actor lifecycle concept

Contra:

- quite unorthodox in native app development
- crashing loses state - How much effort is needed to recreate state depends on application design
- exceptions will not be caught by supervisor on all cases. Often exceptions get stuck inside blocks -> objc is not an exception driven language
