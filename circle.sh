#!/bin/bash -ex

case "$1" in
  pre_machine)
    # ensure correct level of parallelism
    expected_nodes=1
    if [ "$CIRCLE_NODE_TOTAL" -ne "$expected_nodes" ]
    then
        echo "Parallelism is set to ${CIRCLE_NODE_TOTAL}x, but we need ${expected_nodes}x."
        exit 1
    fi

    # have docker bind to localhost
    docker_opts='DOCKER_OPTS="$DOCKER_OPTS -H tcp://0.0.0.0:2375"'
    sudo sh -c "echo '$docker_opts' >> /etc/default/docker"

    # install current docker releases
    sudo sh -c "curl -L -o /usr/bin/docker 'http://s3-external-1.amazonaws.com/circle-downloads/docker-1.8.1-circleci'"
    sudo sh -c "chmod 0755 /usr/bin/docker"
    sudo sh -c "service docker start"

    cat /etc/default/docker
    ;;

  post_machine)
    # fix permissions on docker.log so it can be collected as an artifact
    sudo chown ubuntu:ubuntu /var/log/upstart/docker.log
    ;;

  dependencies)
    ;;

  pre_test)
    # clean the artifacts dir from the previous build
    rm -rf artifacts && mkdir artifacts
    ;;

  test)
    ;;

  post_test)
    ;;

  collect_test_reports)
    ;;

esac