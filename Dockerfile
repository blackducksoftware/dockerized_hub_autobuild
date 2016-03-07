FROM centos:latest
MAINTAINER Ton Schoots <ton@maiastra.com>


# the ports to expose for this image
EXPOSE 4181 8080 7081 55436 8009 8983 8909 80 443

RUN set -x

# update the packages
RUN yum update -y && yum install -y \
  hostname \
  nc \
  libcap \
  nmap-ncat \
#  tar \
  passwd \
  redhat-lsb-core \
#  unzip \
  which

# set root password
RUN echo blackduck | passwd --stdin root

# create user and groups necessary for installation
RUN groupadd blckdck
RUN useradd -g blckdck blckdck
RUN echo blackduck | passwd --stdin blckdck

# preinstall stuff
RUN mkdir -p /opt/blackduck && chown blckdck:blckdck /opt/blackduck   \
#    && mkdir -p /home/blackduck && chown blckdck:blckdck /home/blackduck \
    && mkdir -p /var/lib/blckdck && chown blckdck:blckdck /var/lib/blckdck \
    && mkdir -p /var/spool/clones && chown blckdck:blckdck  /var/spool/clones \
    && mkdir -p /var/spool/mirrors && chown blckdck:blckdck /var/spool/mirrors \    
    && mkdir -p /opt/blackduck/maiastra && chown -R blckdck:blckdck /opt/blackduck \
    && usermod -m -d /home/blackduck blckdck 


COPY ./start.sh /opt/blackduck/maiastra/
COPY ./onPremiseKB.sh /opt/blackduck/maiastra
RUN  chown -R blckdck:blckdck opt/blackduck/maiastra \
     && chmod -R 775 /opt/blackduck/maiastra/


#VOLUME /var/lib/blckdck/hub # this will be mounted under root which won't work for installer

# when the container starts run as blckdck user
USER blckdck
CMD bash -c '/opt/blackduck/maiastra/start.sh';'bash'
