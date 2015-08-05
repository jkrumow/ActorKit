# Todos:

- add pubsub messaging system

```objc

[self subscribe:@"NSNotificationName" selector:@selector(handler)];
[self publish:@"NSNotificationName" payload:dict];

- (void)subscribe:(NSString *)notificationName selector(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:nil
    queue:self.actor usingBlock:^(NSNotification *note) {
        [self.actor performSelector:selector withObject:note.userInfo];
    }];
}

- (void)publish:(NSString *)notificationName payload:(NSDictionary *)payload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                        object:self
                                        userInfo:payload];
}
```

- actor lifecycle concept
- linking
- streamline initialization of custom actors with configuration blocks
- evaluate useful actor runtime features
- add future / promise proxy
