#!/bin/csh
mkdir -p Run$1
cd Run$1
echo "hello, world" > Data$2
@ snooze = $1 * 2
echo "about to sleep for " $snooze >> Data$2
date >> Data$2
sleep $snooze
date >> Data$2
echo "done with sleep for " $snooze >> Data$2
exit
