#!/bin/bash

# autobuildNoLicense.sh
#/*
#   author : Ton Schoots
#
#   This bash script automatically builds a dockerized hub
#
#   issues :
#         17-09-2016      $TAG and $Productversion should be the same should this be and assert?
#*/


_IMAGE=
_LICENSE=
_DOCKER_NODE=
_ON_PREM=false
_BUILD_USER=serv-builder
_DEVELOPER_REPO=bds-release

usage () {
  echo 'This should be started with the following mandatory fields
        -i | --images : the name of the image to create
        -l | --license : the license you got from Black Duck support
        -n | --node : the Docker node on which to build the Hub image 
        -u | --user : the user that has write access on the node 
        -o | --on-prem : build with on-prem settings for the Hub
        -d | --developer-repo : build the Hub installation from a developer repository 
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
      -n | --node )        shift
                           _DOCKER_NODE=$1
                           ;;
      -u | --user )        shift
                           _BUILD_USER=$1
                           ;;
      -o | --on-prem )     shift
                           _ON_PREM=$1
                           ;;
      -d | --developer-repo )     shift
                           _DEVELOPER_REPO=$1
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
#if [ $_IMAGE -eq "" | $_LICENSE -eq "" | $_DOCKER_NODE -eq "" | $_ON_PREM -eq "" ]; do
if [ "$_IMAGE" == "" ]  || [ "$_LICENSE" == "" ] || [ "$_DOCKER_NODE" == "" ] || [ "$_BUILD_USER" == "" ]; then
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



# unzip installer to determine build versions
mkdir ./tmp
find . -name "appmgr.hubinstall*.zip" -exec unzip -o  {}  -d ./tmp \;
find . -type f -name "hub.web-*.zip" -exec unzip -o {} -d ./tmp \;
find . -type f -name "main.web-*.war" -exec unzip -o {} -d ./tmp \;
find . -type f -name "MANIFEST.MF" -exec dos2unix {} \;
Productversion=$(find . -type f -name "MANIFEST.MF" -exec cat {} \; | grep Product-version | sed 's/Product-version: //' | tr -d '\r' | tr -d '\n' )
Build=$(find . -type f -name "MANIFEST.MF" -exec cat {} \; | grep Build: | sed 's/Build: //' | tr -d '\r' | tr -d '\n' )
Buildtime=$(find . -type f -name "MANIFEST.MF" -exec cat {} \; | grep Build-time: | sed 's/Build-time: //' | tr -d '\r' | tr -d '\n' )
#LastCommit=$(find . -type f -name "MANIFEST.MF" -exec cat {} \; | grep Last-Commit: | sed 's/Last-Commit: //' | tr -d '\r' | tr -d '\n' )
BDSHubUIVersion=$(find . -type f -name "MANIFEST.MF" -exec cat {} \; | grep BDS-Hub-UI-Version: | sed 's/BDS-Hub-UI-Version: //' | tr -d '\r' | tr -d '\n' )
rm -rf  ./tmp

#build the initial image
docker build  --no-cache \
              --force-rm \
              --file Dockerfile-ci \
              --build-arg=constraint:node==${_DOCKER_NODE} \
              --build-arg "License=${_LICENSE}" \
              --build-arg "Productversion=${Productversion}" \
              --build-arg "Build=${Build}" \
              --build-arg "Buildtime=${Buildtime}" \
              --build-arg "BDSHubUIVersion=${BDSHubUIVersion}" -t  "${_TMP_IMG_NAME}" .  

if [ "$?" != "0" ]; then exit $?; fi

# Configure the volume staging area for the installation
ssh ${_BUILD_USER}@${_DOCKER_NODE}.dc1.lan "rm -rf ~/hub-install"
ssh ${_BUILD_USER}@${_DOCKER_NODE}.dc1.lan "mkdir ~/hub-install"
find . -name "appmgr.hubinstall*.zip" -exec unzip -o  {}  -d . \;
find . -name "bds-override.properties" -exec sed -i '$ a\PROP_ZK_DATA_DIR=/var/lib/blckdck/hub/zookeeper/data'  {} \;
find . -name "silentInstall.properties" -exec sed -i "$ a\PROP_ACTIVE_REGID=${_LICENSE}"  {} \;
if [ "$_DEVELOPER_REPO" != "" ]; then
  echo "Is a developer build, update the silentInstall.properties"
  find . -name "silentInstall.properties" -exec cat {} \;
  
  find . -name "silentInstall.properties" -exec sed -i "s/PROP_USE_WEB_PROXY=n/PROP_USE_WEB_PROXY=y/" {} \;
  find . -name "silentInstall.properties" -exec sed -i "s/PROP_WEB_PROXY_PROTOCOL=/PROP_WEB_PROXY_PROTOCOL=http/" {} \;
  find . -name "silentInstall.properties" -exec sed -i "s/PROP_WEB_PROXY_HOST=/PROP_WEB_PROXY_HOST=tank.blackducksoftware.com/" {} \;
  find . -name "silentInstall.properties" -exec sed -i "s/PROP_WEB_PROXY_PORT=/PROP_WEB_PROXY_PORT=3128/" {} \;
  find . -name "silentInstall.properties" -exec cat {} \;
fi
scp -r . serv-builder@eng-ddc-node01.dc1.lan:~/hub-install/.

#start initial image with the install script
if [ "$_ON_PREM" != "true" ]; then
  if [ "$_DEVELOPMENT_REPO" != "" ]; then
    echo "Developer build"
    docker run -i --sysctl kernel.shmmax=323485952 --label node:${_DOCKER_NODE} --name=$_CONTAINER_NAME -v /home/serv-builder/hub-install:/tmp/hub-install -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_TMP_IMG_NAME "/tmp/hub-install/installNoLicense.sh --developer-repo ${_DEVELOPER_REPO}"
    if [ "$?" != "0" ]; then exit $?; fi
  else
    echo "Not an on-prem build"
    docker run -i --sysctl kernel.shmmax=323485952 --label node:${_DOCKER_NODE} --name=$_CONTAINER_NAME -v /home/serv-builder/hub-install:/tmp/hub-install -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_TMP_IMG_NAME /tmp/hub-install/installNoLicense.sh
    if [ "$?" != "0" ]; then exit $?; fi
  fi
else
  echo "On-prem build..."
  docker run -i --sysctl kernel.shmmax=323485952 --label node:${_DOCKER_NODE} --name=$_CONTAINER_NAME -v /home/serv-builder/hub-install:/tmp/hub-install -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 $_TMP_IMG_NAME "/tmp/hub-install/installNoLicense.sh --on-prem true"
  if [ "$?" != "0" ]; then exit $?; fi
fi
if [ "$?" != "0" ]; then exit $?; fi

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
