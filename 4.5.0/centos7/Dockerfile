FROM centos:7
#https://github.com/griddb/griddb/releases/tag/v4.5.0
ENV GRIDDB_VERSION=4.5.0
ENV GRIDDB_DOWNLOAD_SHA512 905cd7a47d66ff4c7f9c39492a7b189144f42ba541160db0df7320d08c543d483873193bb4ee3ed272d57bc04efa77e2d7d8e62fef83dc5f9b0c53a9f51c73cb
ENV GS_HOME=/var/lib/gridstore
ENV GS_LOG=/var/lib/gridstore/log
ENV PORTS=10001

#Install griddb sever
RUN set -eux \
    && yum install -y wget \
    && yum groupinstall -y "Development Tools" \
    && yum clean all \
#Download package griddb sever
    && wget -q https://github.com/griddb/griddb/releases/download/v${GRIDDB_VERSION}/griddb-${GRIDDB_VERSION}-1.linux.x86_64.rpm \
#Check sha512sum package
    && echo "$GRIDDB_DOWNLOAD_SHA512 griddb-${GRIDDB_VERSION}-1.linux.x86_64.rpm" | sha512sum --strict --check \
#Install package griddb sever
    && rpm -ivh griddb-${GRIDDB_VERSION}-1.linux.x86_64.rpm \
#Remove package
    && rm griddb-${GRIDDB_VERSION}-1.linux.x86_64.rpm

VOLUME /var/lib/gridstore

#config file for griddb
COPY start-griddb.sh /
RUN chmod a+x /start-griddb.sh
USER gsadm
ENTRYPOINT ["/bin/bash", "/start-griddb.sh"]
EXPOSE $PORTS
CMD ["griddb"]

