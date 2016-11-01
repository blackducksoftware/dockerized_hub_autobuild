_DOCKER_NODE=$1
_DOMAIN=$2

if [ "$_DOCKER_NODE" == "" ]; then
  echo "You must provide the docker node to create volumes and networks against.  Pass it in as the first parameter without a domain name."
  exit 1
fi

if [ "$_DOMAIN" == "" ]; then
  echo "You must provide the domain name that the node will live on.  Otherwise, when you go to access the Hub, it won't work."
  exit 1
fi

docker network create -d bridge ${_DOCKER_NODE}/hub_default
docker volume create -d local --name ${_DOCKER_NODE}/hub_db_data
docker volume create -d local --name ${_DOCKER_NODE}/hub_lic_data
docker run --network=hub_default -it -d -p 1235:8080 --name kb_auth kb_auth:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 5432:5432 --name db_detail kvs:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 5433:5432 --name db_match kb_match_db:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 8983:8983 --name kb_solr kb_solr:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 1234:8080 --name rest_detail kb_detail:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 1236:8080 --name rest_match kb_match:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 1237:8080 --name rest_vuln kb_vuln:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 1238:8080 --name kb_search kb_search:on_prem_1.0.0 /bin/bash
docker run --network=hub_default -it -d -p 9999:8080 --name hubdoc hub_documentation:on_prem_1.0.0
docker run --network=hub_default -it -d --hostname=${_DOCKER_NODE}.${_DOMAIN} -p 4181 -p 8080:8080 -p 7081:7081 -p 55436 -p 8009 -p 8993 -p 8909 -v hub_db_data:/var/lib/blckdck/hub:rw -v hub_lic_data:/opt/blackduck/hub/config:rw --name hub hub_onprem:on_prem_1.0.0
