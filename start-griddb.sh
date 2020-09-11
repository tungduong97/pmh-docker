#!/bin/bash

if [ "${1:0:1}" = '-' ]; then
    set -- griddb "$@"
fi

# usage: read_env VAR [DEFAULT]
#    ie: read_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
read_env() {
    local var="$1"
    local def="${2:-}"
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    fi
    export "$var"="$val"
}
save_config() {
    echo "GRIDDB_CLUSTER_NAME=\"$GRIDDB_CLUSTER_NAME\"" >> /var/lib/gridstore/conf/gridstore.conf
    echo "GRIDDB_USERNAME=\"$GRIDDB_USERNAME\""         >> /var/lib/gridstore/conf/gridstore.conf
    echo "GRIDDB_PASSWORD=\"$GRIDDB_PASSWORD\""         >> /var/lib/gridstore/conf/gridstore.conf
    echo "GRIDDB_NODE_NUM=\"$GRIDDB_NODE_NUM\""         >> /var/lib/gridstore/conf/gridstore.conf
}

#First parameter after run images
if [ "${1}" = 'griddb' ]
then
    isSystemInitialized=0
    if [ "$(ls -A /var/lib/gridstore/data)" ]; then
        isSystemInitialized=1
    fi

    if [ $isSystemInitialized = 0 ]; then
        read_env GRIDDB_CLUSTER_NAME "dockergriddb"
        read_env GRIDDB_USERNAME 'admin'
        read_env GRIDDB_PASSWORD 'admin'

        # extra modification based on environment variable
        gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD
        sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json

        # MULTICAST mode
        if [ ! -z $NOTIFICATION_ADDRESS ]; then
            echo "MULTICAST mode address"
            sed -i -e s/\"notificationAddress\":\"239.0.0.1\"/\"notificationAddress\":\"$NOTIFICATION_ADDRESS\"/g \/var/lib/gridstore/conf/gs_cluster.json
        fi

        if [ ! -z $NOTIFICATION_PORT ]; then
            echo "MULTICAST mode port"
            sed -i -e s/\"notificationPort\":31999/\"notificationPort\":$NOTIFICATION_PORT/g \/var/lib/gridstore/conf/gs_cluster.json
        fi

        # FIXED_LIST mode
        if [ ! -z $NOTIFICATION_MEMBER ]; then
            echo "FIXED_LIST mode, not suported"
            exit 1
        fi

        # PROVIDER mode
        if [ ! -z $NOTIFICATION_PROVIDER ]; then
            echo "PROVIDER mode, not supported"
            exit 1
        fi

        # Write to config file
        save_config
    fi
    # Read config file
    . /var/lib/gridstore/conf/gridstore.conf
    # Start service
    gs_startnode -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD
    if [ -z "$GRIDDB_NODE_NUM" ]; then
        gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD
    else
        gs_joincluster -c $GRIDDB_CLUSTER_NAME -n $GRIDDB_NODE_NUM -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD -w
    fi
    # Wait
    tail -f /var/lib/gridstore/log/gsstartup.log

fi
exec "$@"