#/bin/sh

echo $1



export DISPLAY=:0 && ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}') && xhost $ip && docker run --rm --name msmac -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /Users/osx/Downloads/data:/data:rw -e DISPLAY=$ip:0 kushalgupta/msconvertgui:0.1

# if [ -x "$(command -v docker)" ]; then
#   echo "Docker already installed"
#     # command
# else
#     echo "Install Docker"
# fi
