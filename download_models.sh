#!/bin/sh 
#
# Script to download all models from models.vision.ai which are not
# present in the local model store. The model data is transferred into
# the /incoming folder, and must be imported into VMX using
# ./import_incoming.sh.
#
# Example:
#   ./download_models.sh
#   ./import_incoming.sh
#
# REMOTE_URL: the VMXnode which we download models from
# LOCAL_URL:  the location of this VMXnode
#
# Copyright vision.ai 2015


#Change the remote URL if you want to download models from another VMXnode
#REMOTE_URL="http://192.168.1.103:3000"
REMOTE_URL="https://models.vision.ai"

#Change the local URL if running VMX on another port
#LOCAL_URL="http://localhost:3000"
#LOCAL_URL="http://localhost"
LOCAL_URL="https://vmx-docker-test.vision.ai"

echo "This script will download all new models from" $REMOTE_URL "into" $LOCAL_URL

#Make sure we have jq
if [ ! -e `which jq1` ]; then
    echo "Warning jq command line parser not installed"
    echo "try apt-get install jq"
    echo "Exiting"
    exit
fi

#Make sure LOCAL_URL is valid
if [ ! -n "`curl -s ${LOCAL_URL}/model | jq -r '.data'`" ]; then
    echo "Problem communicating with LOCAL_URL:" $LOCAL_URL
    echo "Exiting"
    exit
fi

#Make sure REMOTE_URL is valid
if [ ! -n "`curl -s ${REMOTE_URL}/model | jq -r '.data'`" ]; then
    echo "Problem communicating with REMOTE_URL:" $REMOTE_URL
    echo "Exiting"
    exit
fi

#The directory where we make VMX model tarballs after downloading
TARGET_DIRECTORY=/incoming/
mkdir $TARGET_DIRECTORY > /dev/null 2>&1

LOCAL_UUIDS=`curl -s ${LOCAL_URL}/model | jq -r '.data[] .uuid'`
REMOTE_UUIDS=`curl -s ${REMOTE_URL}/model | jq -r '.data[] .uuid'`

for UUID in $REMOTE_UUIDS; do
    if [ ! -n "`echo $LOCAL_UUIDS | grep $UUID`" ]; then
	echo $UUID "does not exist, so downloading"
	mkdir $TARGET_DIRECTORY/$UUID/
	curl -o $TARGET_DIRECTORY/$UUID/image.jpg $REMOTE_URL/models/$UUID/image.jpg
	curl -o $TARGET_DIRECTORY/$UUID/model.json $REMOTE_URL/models/$UUID/model.json
	curl -o $TARGET_DIRECTORY/$UUID/model.data $REMOTE_URL/models/$UUID/model.data
	curl -o $TARGET_DIRECTORY/$UUID/data_set.json $REMOTE_URL/models/$UUID/data_set.json
	curl -o $TARGET_DIRECTORY/$UUID/compiled.data $REMOTE_URL/models/$UUID/compiled.data
	cd $TARGET_DIRECTORY/
	tar cf $UUID.tar $UUID
	gzip $UUID.tar
	rm -rf $UUID
	cd - > /dev/null 2>&1
    else
	echo $UUID "already exists, not downloading"
    fi    
done

echo "Finished downloading"
echo "Consider Using ./import_models.sh to import into VMX container"
