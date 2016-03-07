#!/bin/bash

/opt/blackduck/hub/appmgr/zookeeper/bin/zkServer.sh start

/opt/blackduck/hub/appmgr/zookeeper/bin/zkCli.sh -server localhost:4181 create /hub/config/blackduck.kbdetail.host kb_detail
/opt/blackduck/hub/appmgr/zookeeper/bin/zkCli.sh -server localhost:4181 create /hub/config/blackduck.kbdetail.port 8080
/opt/blackduck/hub/appmgr/zookeeper/bin/zkCli.sh -server localhost:4181 create /hub/config/blackduck.kbdetail.scheme http

/opt/blackduck/hub/appmgr/bin/agentcmd.sh Hub bounce
/opt/blackduck/hub/appmgr/bin/agentcmd.sh JobRunnerAgent-1 bounce

/opt/blackduck/hub/appmgr/bin/hubcontrol.sh start
/bin/bash
