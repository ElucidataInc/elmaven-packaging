#/bin/sh

# if [ -x "$(command -v XQuartz)" ]; then
#   echo "XQuartz already installed"
#     open -a XQuartz
#     # command
# else
#     echo "Install xquarts"
#     VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $4}'`
#     cp -rf $VOLUME/*.app /Applications
#     hdiutil detach $VOLUME
#     open -a XQuartz
# fi

if [ -x "$(command -v docker)" ]; then
  echo "Docker already installed"
    open -a Docker
    # open /Applications/Docker.app --args -AppCommandLineArg
    while ! docker system info > /dev/null 2>&1; do sleep 1; done
    echo "Update docker and pull kushalgupta/msconvertgui:0.1"
    docker pull kushalgupta/msconvertgui:0.1
    # command
else
    echo "Install Docker"
    VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
    cp -rf $VOLUME/*.app /Applications
    hdiutil detach $VOLUME
    open -a Docker
    while ! docker system info > /dev/null 2>&1; do sleep 1; done
    echo "Update docker and pull kushalgupta/msconvertgui:0.1"
    docker pull kushalgupta/msconvertgui:0.1
fi




# VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
# cp -rf $VOLUME/*.app /Applications
# hdiutil detach $VOLUME
