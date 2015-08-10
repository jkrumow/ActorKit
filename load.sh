#!/bin/sh

a=0

until [ ! $a -lt 10 ]
do
   a=`expr $a + 1`
   xctool run-tests -workspace ActorKit/ActorKit.xcworkspace -scheme ActorKitTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
done