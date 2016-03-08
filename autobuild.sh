#!/bin/bash


_IMAGE=
_LICENSE=

usage () {
  echo 'This should be started with the following mandatory fields
        -i | --images : the name of the image to create
        -l | --license : the license you got from Black Duck support
       ' 
}

while [ "$1" != "" ]; do
  case $1 in 
      -i | --image )       shift
                           _IMAGE=$1
                           ;;
      -l | --license )     shift
                           _LICENSE=$1
                           ;;
      -h | --help )        usage
                           exit
                           ;;
      * )                  usage
                           exit 1
  esac
  shift
done

# check mandatory parameters
#if [ $_IMAGE -eq "" | $_LICENSE -eq "" ]; do
if [ "$_IMAGE" == "" ]  || [ "$_LICENSE" == "" ]; then
  usage
  exit
fi


# initialize constants
_TAG=$(find . -name "appmgr.hubinstall*.zip" | sed 's/.*full-//' | sed 's/\.zip//')
if [ "$_TAG" == "" ]; then
  echo "installer not present in this directory or not of format appmgr.hubinstall*.zip"
  exit 2
fi
_IMAGE_NAME="$_IMAGE:$_TAG"
_CONTAINER_NAME="hub_install"
_TMP_IMG_NAME="hub_install:temp"

#build the initial image
docker build -t  "$_TMP_IMG_NAME" .


# unzip installer
find . -name "appmgr.hubinstall*.zip" -exec unzip -o  {}  -d . \;

# override install properties to put data in one place
find . -name "bds-override.properties" -exec sed -i '$ a\PROP_ZK_DATA_DIR=/var/lib/blckdck/hub/zookeeper/data'  {} \;

# set license in properties file
find . -name "silentInstall.properties" -exec sed -i "$ a\PROP_ACTIVE_REGID=$_LICENSE"  {} \;


#start initial image with the install script
docker run -ti -h $(hostname) --name=$_CONTAINER_NAME -v $(pwd):/tmp/hubinstall -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_TMP_IMG_NAME /tmp/hubinstall/install.sh

# commit the installation container to image
docker commit --change='CMD [ "/opt/blackduck/maiastra/start.sh" ]' $_CONTAINER_NAME $_IMAGE_NAME


# remove the install container
docker rm $_CONTAINER_NAME

# remove temp image
docker rmi $_TMP_IMG_NAME

# remove last line in the silent.properties file so lincense is removed
 find . -name "silentInstall.properties" -exec sed -i '$ d'  {} \;

# remove the install dir
rm -rf  $(ls -all | grep "^d" | grep "appmgr\.hubinstall" | awk '{print $9}')
