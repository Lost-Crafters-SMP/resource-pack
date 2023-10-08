#!/usr/bin/env bash

# Configuration
RESOURCE_PACK_FOLDER=/home/ubuntu/resource-pack
SERVER_PATH=/var/lib/pterodactyl/volumes
SERVER_RESOURCE_PATH=/home/ubuntu/lostcraftersweb/html/resourcepack
SERVER_RESOURCE_URI="https\\\:\/\/www.lostcrafterssmp.com\/resourcepack\/"

PRODUCTION_SERVER_ID="b1107111-8ef9-4536-8370-66c62abed9b7"
TEST_SERVER_ID="6579b795-e795-4df0-b8aa-e9cc4c637bc2"
CREATIVE_SERVER_ID="c8cdf4a4-4eae-4bc5-8754-7479b1feb15d"

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

# todo: add variable to skip rm (for running manually)
# todo: add option for number of resource packs to keep

# delete the oldest resource pack, this process will keep the last few resource packs. to add more, just touch fake .zip files in the resource pack folder
OLDEST_RESOURCE_PACK="$(ls ${SERVER_RESOURCE_PATH} -lt | grep -v '^d' | tail -1 | awk '{print $NF}')"
rm -f ${SERVER_RESOURCE_PATH}/${OLDEST_RESOURCE_PACK}

# todo: check to see if file exists
# zip ${SERVER_RESOURCE_PATH}/${RESOURCE_PACK_ZIP} ${RESOURCE_PACK_FOLDER}/assets ${RESOURCE_PACK_FOLDER}/pack.mcmeta ${RESOURCE_PACK_FOLDER}/pack.png
cd ${RESOURCE_PACK_FOLDER} && zip -r ${SERVER_RESOURCE_PATH}/${RESOURCE_PACK_ZIP} assets pack.mcmeta pack.png && cd -

# Generate SHA1 sum
RESOURCE_PACK_SHA1=`sha1sum ${SERVER_RESOURCE_PATH}/${RESOURCE_PACK_ZIP} | awk '{print $1}'`
echo "Resource Pack SHA1: ${RESOURCE_PACK_SHA1}"

# todo: add variable to select / skip servers
# Update server.properties on the production server
sed -i.bak "s/^\(resource-pack=\).*/\1${SERVER_RESOURCE_URI}${RESOURCE_PACK_ZIP}/" "${SERVER_PATH}/${PRODUCTION_SERVER_ID}/server.properties"
sed -i "s/^\(resource-pack-sha1=\).*/\1${RESOURCE_PACK_SHA1}/" "${SERVER_PATH}/${PRODUCTION_SERVER_ID}/server.properties"

# Update server.properties on the creative server
sed -i.bak "s/^\(resource-pack=\).*/\1${SERVER_RESOURCE_URI}${RESOURCE_PACK_ZIP}/" "${SERVER_PATH}/${CREATIVE_SERVER_ID}/server.properties"
sed -i "s/^\(resource-pack-sha1=\).*/\1${RESOURCE_PACK_SHA1}/" "${SERVER_PATH}/${CREATIVE_SERVER_ID}/server.properties"

# Update server.properties on the test server
sed -i.bak "s/^\(resource-pack=\).*/\1${SERVER_RESOURCE_URI}${RESOURCE_PACK_ZIP}/" "${SERVER_PATH}/${TEST_SERVER_ID}/server.properties"
sed -i "s/^\(resource-pack-sha1=\).*/\1${RESOURCE_PACK_SHA1}/" "${SERVER_PATH}/${TEST_SERVER_ID}/server.properties"

# Done

# this bash script should just be refactored as functions
# notes:
# - create main script that has all the logic for processing flags and call the functions
# - can move the function.sh scripts to a folder or use a file name pattern, such as zyz.function.sh and source them
