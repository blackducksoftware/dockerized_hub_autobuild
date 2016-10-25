#!/bin/bash

while [ "$1" != "" ]; do
  case $1 in
      -d | --developer-repo )   shift
                           _DEVELOPER_REPO=$1
                           ;;
      -o | --on-prem )     shift
                           _ON_PREM=$1
                           ;;
      -h | --help )        usage
                           exit
                           ;;
      * )                  usage
                           exit 1
  esac
  shift
done

# installNoLicense.sh
echo "HUB install starting"

echo "Making the /opt/blackduck/install folder"
mkdir -p /opt/blackduck/install

echo "Copying the installation files into the /opt/blackduck/install folder"
cp --verbose -r /tmp/hub-install/* /opt/blackduck/install

if [ "$_DEVELOPER" != "" ]; then
  echo "Setting the APPMGR_HUBINSTALL_OPTS for developer builds"
  export APPMGR_HUBINSTALL_OPTS=-DartifactoryURL=http://artifactory.blackducksoftware.com -DartifactoryPrefix=artifactory -DartifactoryRepo=bds-release
fi

echo "Starting the installation procedures"
# start installation
find /opt/blackduck/install -name "appmgr.hubinstall" -execdir {} -sf /opt/blackduck/install/silentInstall.properties \; 

echo "Stop the Hub"
# stop hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh stop

echo "Start the Hub"
# start hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh start

if [ "$_ON_PREM" == "true" ]; then
  echo "Doing an on-prem install, configuring the zkCli.sh settings..."
  sleep 10

/opt/blackduck/hub/appmgr/zookeeper/bin/zkCli.sh -server localhost:4181 <<EOF
  create /hub/config/blackduck.kbdetail.host rest_detail
  create /hub/config/blackduck.kbdetail.port 8080
  create /hub/config/blackduck.kbdetail.scheme http
  create /hub/config/blackduck.kbsearch.host rest_search
  create /hub/config/blackduck.kbsearch.port 8080
  create /hub/config/blackduck.kbsearch.scheme http
  create /hub/config/blackduck.kbvuln.host rest_vuln
  create /hub/config/blackduck.kbvuln.port 8080
  create /hub/config/blackduck.kbvuln.scheme http
  create /hub/config/blackduck.kbmatch.host rest_match
  create /hub/config/blackduck.kbmatch.port 8080
  create /hub/config/blackduck.kbmatch.scheme http
  create /hub/config/blackduck.kblicense.host rest_detail
  create /hub/config/blackduck.kblicense.port 8080
  create /hub/config/blackduck.kblicense.scheme http
  create /hub/config/blackduck.kbsearch.vuln.host rest_search
  create /hub/config/blackduck.kbsearch.vuln.port 8080
  create /hub/config/blackduck.kbsearch.vuln.scheme http
  create /hub/config/blackduck.kbreleasedetail.host rest_detail
  create /hub/config/blackduck.kbreleasedetail.port 8080
  create /hub/config/blackduck.kbreleasedetail.scheme http
  
  create /hub/prop/PROP_HUB_JOBRUNNER_MX_MB 8192

  quit
EOF

  /opt/blackduck/hub/appmgr/bin/agentcmd.sh Hub bounce
  /opt/blackduck/hub/appmgr/bin/agentcmd.sh JobRunnerAgent-1 bounce
fi

echo "Cleanup the licensing"
# remove all license related stuff
rm -rf /opt/blackduck/hub/logs/appmgr/bd-AppmgrAgent.log*
rm -rf /opt/blackduck/hub/bd-install_log.txt

# remove license file
rm -rf /opt/blackduck/hub/config/suite_v1.xml

echo "Remove the installation folder when we're done"
# remove installation directory
rm -rf /opt/blackduck/install
