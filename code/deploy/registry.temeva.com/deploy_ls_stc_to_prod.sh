#!/bin/bash

# example: sudo ./deploy_ls_stc_to_prod.sh 5.18.0296

set -x -eo pipefail

release_version=$1
mj_version=$(echo $release_version | cut -d'.' -f1,2)

readonly AF_BASE_URL="https://artifactory.srv.orionprod.net/artifactory/stc/releases"
readonly WORKING_DIR=$HOME/tmp/${mj_version}
readonly labserver_filename="labserver-${release_version}.tar.xz"
readonly stc_filename="Spirent_TestCenter_Docker_${release_version}.zip"

if [[ ! -d $WORKING_DIR ]]; then
    mkdir $WORKING_DIR
fi

cd $WORKING_DIR
rm -rf ${WORKDIR_DIR}\stc_*.tgz
rm -rf ${WORKDIR_DIR}\python
rm -rf ${WORKDIR_DIR}\README.md
rm -rf ${WORKDIR_DIR}\spirent_docker

# Download labserver and stc images from artifactory
if [[ ! -f ${labserver_filename} ]]; then
  wget ${AF_BASE_URL}/${mj_version}/${labserver_filename}
fi

if [[ ! -f ${stc_filename} ]]; then
  wget ${AF_BASE_URL}/${mj_version}/${stc_filename}
fi

# Load, tag and push labserver image to registry.temeva.com
docker load -i ./${labserver_filename}
ls_image_id=$(docker images -q registry.oriontest.net/labserver)
docker tag $ls_image_id 127.0.0.1:5001/labserver:${mj_version}
docker push 127.0.0.1:5001/labserver:${mj_version}

# Unzip, load, tag and push stc image from the extracted files
unzip ${stc_filename}
docker load -i ./stc_${release_version}.tgz
stc_image_id=$(docker images -q stc:${release_version})
docker tag ${stc_image_id} 127.0.0.1:5001/stc:${release_version}
docker push 127.0.0.1:5001/stc:${release_version}

# clean up
cd $HOME
rm -rf ${WORKING_DIR}
docker rmi -f ${ls_image_id}
docker rmi -f ${stc_image_id}
