cmake_minimum_required(VERSION 2.8.3)
project(jetson_nano_csi_cam)

find_package(catkin REQUIRED COMPONENTS
  gscam
)


###################################
## catkin specific configuration ##
###################################

catkin_package(
  CATKIN_DEPENDS gscam
)

###########
## Build ##
###########

include_directories(
# include
  ${catkin_INCLUDE_DIRS}
)

#############
## Install ##
#############

foreach(dir launch)
  install(DIRECTORY ${dir}/ 
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/${dir}
  )
endforeach(dir)

#############
## Testing ##
#############

