#/bin/sh


if [ -x "$(command -v XQuartz)" ]; then
    echo "XQuartz already installed"
    open -a XQuartz
else
    echo "Install XQuartz"
    VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
    installer -package $VOLUME/XQuartz.pkg -target /
    # cp -rf $VOLUME/*.app /Applications && hdiutil detach $VOLUME && open -a XQuartz
    hdiutil detach $VOLUME
    open -a XQuartz
fi




# VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
# cp -rf $VOLUME/*.app /Applications
# hdiutil detach $VOLUME
