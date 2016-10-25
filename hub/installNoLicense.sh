#!/bin/bash

# installNoLicense.sh

echo "HUB install starting"

echo "Making the /opt/blackduck/install folder"
mkdir -p /opt/blackduck/install

echo "Copying the installation files into the /opt/blackduck/install folder"
cp --verbose -r /tmp/hub-install /opt/blackduck/install

echo "Starting the installation procedures"
# start installation
find /opt/blackduck/install -name "appmgr.hubinstall" -execdir {} -sf /opt/blackduck/install/silentInstall.properties \; 

echo "Stop the Hub"
# stop hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh stop

echo "Start the Hub"
# start hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh start

echo "Cleanup the licensing"
# remove all license related stuff
rm -rf /opt/blackduck/hub/logs/appmgr/bd-AppmgrAgent.log*
rm -rf /opt/blackduck/hub/bd-install_log.txt

# remove license file
rm -rf /opt/blackduck/hub/config/suite_v1.xml

echo "Remove the installation folder when we're done"
# remove installation directory
rm -rf /opt/blackduck/install
