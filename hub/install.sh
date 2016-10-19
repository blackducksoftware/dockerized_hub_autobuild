#!/bin/bash

echo "HUB install starting"


# start installation
find /tmp/hubinstall/ -name "appmgr.hubinstall" -execdir  {} -sf /tmp/hubinstall/silentInstall.properties \; 


# stop hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh stop

# start hub
/opt/blackduck/hub/appmgr/bin/hubcontrol.sh start

