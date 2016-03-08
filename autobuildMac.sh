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
#prop_file=$(find . -name "silentInstall.properties")
if [ "$prop_file" == "" ]; then
  echo "no bds-override.properties file found."
  exit
fi
cat <<EOT >> $prop_file
PROP_ZK_DATA_DIR=/var/lib/blckdck/hub/zookeeper/data
EOT

# set license in properties file
prop_file=$(find . -name "silentInstall.properties")
if [ $prop_file == "" ]; then
  echo "no silentInstall.properties file found."
  exit
fi
tmp_prop_file=$(echo "$prop_file.tmp")
cp $prop_file $tmp_prop_file
cat <<EOT >> $prop_file
PROP_ACTIVE_REGID=$_LICENSE
EOT


#start initial image with the install script
docker run -ti -h $(hostname) --name=$_CONTAINER_NAME -v $(pwd):/tmp/hubinstall -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_TMP_IMG_NAME /tmp/hubinstall/install.sh

# commit the installation container to image
docker commit --change='CMD [ "/opt/blackduck/maiastra/start.sh" ]' $_CONTAINER_NAME $_IMAGE_NAME


# remove the install container
docker rm $_CONTAINER_NAME

# remove temp image
docker rmi $_TMP_IMG_NAME


# remove the install dir
rm -rf  $(ls -all | grep "^d" | grep "appmgr\.hubinstall" | awk '{print $9}')

# restore properties file and remove tmp file
cp $tmp_prop_file $prop_file
rm -rf $tmp_prop_file
