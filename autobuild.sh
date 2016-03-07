#!/bin/bash


# initialize constants
_IMAGE="blackducksoftware/hub_test"
_TAG=$(find . -name "appmgr.hubinstall*.zip" | sed 's/.*full-//' | sed 's/\.zip//')
_IMAGE_NAME="$_IMAGE:$_TAG"
_CONTAINER_NAME="hub_install"
_LICENSE="ton_hub_0036000001Yq9f6"

#build the initial image
docker build -t  "$_IMAGE_NAME" .


# unzip installer
find . -name "appmgr.hubinstall*.zip" -exec unzip -o  {}  -d . \;
# override install properties to put data in one place
 find . -name "bds-override.properties" -exec sed -i '$ a\PROP_ZK_DATA_DIR=/var/lib/blckdck/hub/zookeeper/data'  {} \;
# set license in properties file
 find . -name "silentInstall.properties" -exec sed -i "$ a\PROP_ACTIVE_REGID=$_LICENSE"  {} \;


#start initial image with the install script
#docker run -ti -h $(hostname) --name=$_CONTAINER_NAME -v $(pwd):/tmp/hubinstall -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_IMAGE_NAME /bin/bash
docker run -ti -h $(hostname) --name=$_CONTAINER_NAME -v $(pwd):/tmp/hubinstall -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_IMAGE_NAME /tmp/hubinstall/install.sh

# commit the installation container to image
docker commit $_CONTAINER_NAME $IMAGE_NAME

# remove the install container
docker rm $_CONTAINER_NAME

# remove the install dir
