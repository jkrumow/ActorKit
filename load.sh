#!/bin/sh

set -e

i=0
max=$1

echo "Will perform $max iterations"

until [ ! $i -lt $max ]
do
   i=`expr $i + 1`
   echo "Running iteration $i"
   xctool run-tests -workspace ActorKit/ActorKit.xcworkspace -scheme ActorKitTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
done
