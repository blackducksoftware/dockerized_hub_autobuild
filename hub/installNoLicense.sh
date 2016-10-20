#!/bin/bash

# installNoLicense.sh

echo "HUB install starting"


# start installation
find /opt/blackduck/install -name "appmgr.hubinstall" -execdir  {} -sf /opt/blackduck/install/silentInstall.properties \; 


# stop hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh stop

# start hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh start

# remove all license related stuff
rm -rf /opt/blackduck/hub/logs/appmgr/bd-AppmgrAgent.log*
rm -rf /opt/blackduck/hub/bd-install_log.txt

# remove license file
rm -rf /opt/blackduck/hub/config/suite_v1.xml
