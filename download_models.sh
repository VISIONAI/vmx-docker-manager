#!/bin/sh 
#
# Script to download all models from models.vision.ai which are not
# presen tin the local model store. The model data is transferred into
# the /incoming folder, and must be imported into VMX using
# ./import_incoming.sh.
#
# Example:
#   ./download_a.sh
#   ./import_incoming.sh
#
# Copyright vision.ai 2015

#Change the remote URL if you want to download models from another VMXnode
#REMOTE_URL="http://192.168.1.103:3000"
REMOTE_URL="https://models.vision.ai"

#Change the local URL if running VMX on another port
#LOCAL_URL="http://localhost:3000"
LOCAL_URL="http://localhost"

#The directory where we make VMX model tarballs after downloading
TARGET_DIRECTORY=/incoming/

echo "This script will download all new models from" $REMOTE_URL "into" $LOCAL_URL
LOCAL_UUIDS=`curl -s ${LOCAL_URL}/model | jq -r '.data[] .uuid'`
REMOTE_UUIDS=`curl -s ${REMOTE_URL}/model | jq -r '.data[] .uuid'`
echo "got here"
for UUID in $REMOTE_UUIDS; do
    if [ ! -n "`echo $LOCAL_UUIDS | grep $UUID`" ]; then
	EXTRA="does not exist, so downloading"
	echo $UUID $EXTRA
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
	EXTRA="already exists"
	echo $UUID $EXTRA
    fi    
done

echo "Finished downloading"
echo "Consider Using ./import_models.sh to import into VMX container"
