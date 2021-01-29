#!/bin/bash

# example: sudo ./deploy_cs_docker_images_to_prod.sh 2668
# 
# 2688 = cloudsure platform and labserver build number
#        normally provided by Justin Higa

set -x -eo pipefail

image_version=$1

source_registry='registry.oriontest.net'
source_k8s_platform="${source_registry}/cloud-sure-k8s-platform"
source_k8s_labserver="${source_registry}/cloud-sure-k8s-labserver"
target_registry='127.0.0.1:5001'
target_k8s_platform="${target_registry}/cloud-sure-k8s-platform"
target_k8s_labserver="${target_registry}/cloud-sure-k8s-labserver"

# Pull source images
docker pull ${source_k8s_platform}:${image_version}
docker pull ${source_k8s_labserver}:${image_version}

# Get image id's
platform_image_id=$(sudo docker images | grep cloud-sure-k8s-platform | grep ${image_version} | awk '{print $3}' | head -1)
labserver_image_id=$(sudo docker images | grep cloud-sure-k8s-labserver | grep ${image_version} | awk '{print $3}'| head -1)
echo "cloud-sure-k8s-platform image id: ${platform_image_id}"
echo "cloud-sure-k8s-labserver image id: ${labserver_image_id}"

# Tag images
docker tag ${platform_image_id} ${target_k8s_platform}:${image_version}
docker tag ${labserver_image_id} ${target_k8s_labserver}:${image_version}
docker tag ${platform_image_id} ${target_k8s_platform}:released
docker tag ${labserver_image_id} ${target_k8s_labserver}:released

# Push images
docker push ${target_k8s_platform}:${image_version}
docker push ${target_k8s_labserver}:${image_version}
docker push ${target_k8s_platform}:released
docker push ${target_k8s_labserver}:released
