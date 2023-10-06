#!/usr/bin/env bash

# Configuration
RESOURCE_PACK_FOLDER=/home/ubuntu/resource-pack
SERVER_PATH=/var/lib/pterodactyl/volumes/6579b795-e795-4df0-b8aa-e9cc4c637bc2 # Test Server
# SERVER_PATH=/var/lib/pterodactyl/volumes/b1107111-8ef9-4536-8370-66c62abed9b7 # Production Server
SERVER_RESOURCE_PATH=/home/ubuntu/lostcraftersweb/html/resourcepack
SERVER_RESOURCE_URI="https\\\:\/\/www.lostcrafterssmp.com\/resourcepack\/"

# Checkout latest pack
command_result=`git -C ${RESOURCE_PACK_FOLDER} checkout main`
command_result_exit_code=$?

if [[ ${command_result_exit_code} -ne 0 ]]; then
    echo "Error checking out main branch"
    exit 1
fi

command_result=`git -C ${RESOURCE_PACK_FOLDER} pull`
command_result_exit_code=$?

if [[ ${command_result_exit_code} -ne 0 ]]; then
    echo "Error pulling from github"
    exit 1
fi

GIT_COMMIT_ID=`git -C ${RESOURCE_PACK_FOLDER} log --oneline | head -n 1 | awk '{print $1}'`
echo "Git Commit ID: ${GIT_COMMIT_ID}"

# Create a new resource pack zip
RESOURCE_PACK_ZIP="resourcepack-${GIT_COMMIT_ID}.zip"

# rm -f ${SERVER_RESOURCE_PATH}/*.zip # disabled while testing the script
zip ${SERVER_RESOURCE_PATH}/${RESOURCE_PACK_ZIP} ${RESOURCE_PACK_FOLDER}/assets ${RESOURCE_PACK_FOLDER}/pack.mcmeta ${RESOURCE_PACK_FOLDER}/pack.png

# Generate SHA1 sum
RESOURCE_PACK_SHA1=`sha1sum ${SERVER_RESOURCE_PATH}/${RESOURCE_PACK_ZIP} | awk '{print $1}'`
echo "Resource Pack SHA1: ${RESOURCE_PACK_SHA1}"

# Update server.properties
sed -i.bak "s/^\(resource-pack=\).*/\1${SERVER_RESOURCE_URI}${RESOURCE_PACK_ZIP}/" "${SERVER_PATH}/server.properties"
sed -I "" "s/^\(resource-pack-sha1=\).*/\1${RESOURCE_PACK_SHA1}/" "${SERVER_PATH}/server.properties"

# Done
