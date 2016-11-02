# check the tars are all in place and named correctly
TARS="kb_vuln kb_match kb_auth kb_search kb_detail kb_solr hubdoc hub kvs kb_match_db"

for TAR in $TARS
do
  if [ ! -f ${TAR}.tar ]; then
    echo "Could not find find ${TAR}.tar.  Are you sure it's in this folder?"
    exit 1
  fi
done

# load each file into docker
for TAR in $TARS
do
  echo "Loading image ${TAR}.tar into Docker."
  docker load < ${TAR}.tar
done
