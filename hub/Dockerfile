FROM centos:latest
MAINTAINER Ton Schoots <ton@maiastra.com>

ARG Productversion=unknown
ARG Build=unknown
ARG Buildtime=unknown
ARG BDSHubUIVersion=unknown

LABEL Productversion=${Productversion} \
      Build=${Build}  \
      Buildtime=${Buildtime}  \
      BDSHubUIVersion=${BDSHubUIVersion} \
      START="if docker ps -a | grep hub_data; \
              then \
                 echo \"all ok starting the hub ${Productversion}\"; \
              else \
                 echo \"datacontainer hub_data not available creating new one\"; \
                 docker run -v /var/lib/blckdck/hub  -v /opt/blackduck/hub/config --name hub_data blackducksoftware/hub:${Productversion} true; \
             fi; \
             docker run   -h $(hostname) --volumes-from hub_data --name=hub --rm -p 4181:4181 -p 8080:8080 -p 7081:7081 -p 55436:55436 -p 8009:8009 -p 8993:8993 -p 8909:8909 blackducksoftware/hub:${Productversion}" \
      STOP="docker stop hub" \
      CLEAN="docker stop hub && docker rm hub_data;"

# the ports to expose for this image
EXPOSE 4181 8080 7081 55436 8009 8983 8909 80 443

RUN set -x

# update the packages
RUN yum update -y && yum install -y \
  hostname \
  nc \
  libcap \
  nmap-ncat \
  passwd \
  redhat-lsb-core \
  which \
  # set root password
  &&  echo blackduck | passwd --stdin root \
  # create user and groups necessary for installation
  && groupadd blckdck \
  && useradd -g blckdck blckdck \
  && echo blackduck | passwd --stdin blckdck \
  # preinstall stuff
  && mkdir -p /opt/blackduck && chown blckdck:blckdck /opt/blackduck   \
  && mkdir -p /var/lib/blckdck && chown blckdck:blckdck /var/lib/blckdck \
  && mkdir -p /var/spool/clones && chown blckdck:blckdck  /var/spool/clones \
  && mkdir -p /var/spool/mirrors && chown blckdck:blckdck /var/spool/mirrors \    
  && mkdir -p /opt/blackduck/maiastra && chown -R blckdck:blckdck /opt/blackduck \
  && usermod -m -d /home/blackduck blckdck
#  && yum remove -y passwd 


COPY ./start.sh /opt/blackduck/maiastra/
RUN  chown -R blckdck:blckdck opt/blackduck/maiastra \
     && chmod -R 775 /opt/blackduck/maiastra/


#VOLUME /var/lib/blckdck/hub # this will be mounted under root which won't work for installer

# when the container starts run as blckdck user
USER blckdck
ENTRYPOINT [ "bash" , "-c" ]
CMD [ "/opt/blackduck/maiastra/start.sh" ] 
