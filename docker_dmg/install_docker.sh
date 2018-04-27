#/bin/sh

VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
cp -rf $VOLUME/*.app /Applications
hdiutil detach $VOLUME
