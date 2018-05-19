#/bin/sh

if [ -x "$(command -v docker)" ]; then
  echo "Docker already installed"
    open -a Docker
    # open /Applications/Docker.app --args -AppCommandLineArg
    while ! docker system info > /dev/null 2>&1; do sleep 1; done
    echo "Update docker and pull kushalgupta/msconvert:0.2"
    docker pull kushalgupta/msconvert:0.2
    # command
else
    echo "Install xquarts"
    # VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
    # cp -rf $VOLUME/*.app /Applications
    # hdiutil detach $VOLUME
    # open -a Docker
    # echo "Install docker"

    VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
    cp -rf $VOLUME/*.app /Applications
    hdiutil detach $VOLUME
    open -a Docker
    # open /Applications/Docker.app --args -AppCommandLineArg
    while ! docker system info > /dev/null 2>&1; do sleep 1; done
    echo "Update docker and pull kushalgupta/msconvertgui:0.2"
    docker pull kushalgupta/msconvertgui:0.1
fi




# VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
# cp -rf $VOLUME/*.app /Applications
# hdiutil detach $VOLUME
