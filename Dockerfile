ARG BASE_IMAGE=ros:melodic-ros-base-l4t-r32.4.4

###############################################################################################################################################
#
# build
# $ docker build -t jetson-nano-csi-cam-ros:melodic-l4t-r32.4.4 .
#
# run
# $ docker run --network host -v /tmp/argus_socket:/tmp/argus_socket --runtime nvidia --rm -it jetson-nano-csi-cam-ros:melodic-l4t-r32.4.4
#
###############################################################################################################################################

FROM ${BASE_IMAGE}

# prepare source
WORKDIR /root/ros_workspace/src
RUN git clone https://github.com/ros-drivers/gscam.git && \
    sed -e "s/EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1$/EXTRA_CMAKE_FLAGS = -DUSE_ROSBUILD:BOOL=1 -DGSTREAMER_VERSION_1_x=On/" -i gscam/Makefile
COPY . /root/ros_workspace/src/jetson_nano_csi_cam/

# build packages
WORKDIR /root/ros_workspace
RUN apt-get update -qq && \
    rosdep update -q && \
    apt-get install -qq -y gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev && \
    rosdep install -r -y -i --from-paths src && \
    . /opt/ros/melodic/setup.sh && \
    catkin init && \
    catkin build && \
    rm -rf /var/lib/apt/lists/*

# install ROS env settings
RUN apt-get update -qq && \
    apt-get install -y -qq iproute2 && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i -e "s/^exec/#exec/g" /ros_entrypoint.sh && \
    echo "" >> /ros_entrypoint.sh && \
    echo "source /ros_env.sh" >> /ros_entrypoint.sh && \
    echo "exec \"\$@\"" >> /ros_entrypoint.sh && \
    echo "source /root/ros_workspace/devel/setup.bash" >> /ros_env.sh && \
    echo "export MYWLAN0IP=\$(ip a show \$(ip a | grep -o -e \"wl.*\:\" | sed -e \"s/://g\") | grep -o -E \"([0-9]+\.){3}[0-9]+\" | head -n1)" >> /ros_env.sh && \
    echo "export MYETH0IP=\$(ip a show \$(ip a | grep -o -e \"en.*\:\" -e \"eth[0-9]*\:\" | sed -e \"s/://g\") | grep -o -E \"([0-9]+\.){3}[0-9]+\" | head -n1)" >> /ros_env.sh && \
    echo "export ROS_IP=\$(echo \$MYETH0IP \$MYWLAN0IP \$(hostname -i) | cut -d' ' -f1)" >> /ros_env.sh && \
    echo "export ROS_MASTER_URI=http://\$ROS_IP:11311" >> /ros_env.sh
