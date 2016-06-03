#!/bin/bash

/opt/blackduck/hub/appmgr/bin/hubcontrol.sh start
/bin/bash

#make a loop so the container stays alive
while :; do
  sleep 5h  #waits 5 hours
done
