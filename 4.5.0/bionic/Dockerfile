FROM ubuntu:18.04

#https://github.com/griddb/griddb/releases/tag/v4.5.0
ENV GRIDDB_VERSION=4.5.0
ENV GRIDDB_DOWNLOAD_SHA512 298acc1a859bf8762ff216c5e5689a8d2722b918525442cb41c8a9424b84fd3563738cd4f8ab85e7fb13f47a8b63f2359760a0a542c7232d8ba15dbf6138ec1c
ENV GS_HOME=/var/lib/gridstore
ENV GS_LOG=/var/lib/gridstore/log
ENV PORTS=10001

RUN set -eux \
    && apt-get update \
#Install dependency for griddb
    && apt-get install -y dpkg python wget \
    && apt-get clean all \
#Download package griddb sever
    && wget -q https://github.com/griddb/griddb/releases/download/v${GRIDDB_VERSION}/griddb_${GRIDDB_VERSION}_amd64.deb \
#Check sha512sum package
    && echo "$GRIDDB_DOWNLOAD_SHA512 griddb_${GRIDDB_VERSION}_amd64.deb" | sha512sum --strict --check \
#Install package griddb sever
    && dpkg -i griddb_${GRIDDB_VERSION}_amd64.deb \
#Remove package
    && rm griddb_${GRIDDB_VERSION}_amd64.deb

VOLUME /var/lib/gridstore

#config file for griddb
COPY start-griddb.sh /
RUN chmod a+x /start-griddb.sh
USER gsadm
ENTRYPOINT ["/bin/bash", "/start-griddb.sh"]
EXPOSE $PORTS
CMD ["griddb"]