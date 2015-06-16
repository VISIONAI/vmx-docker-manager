#!/bin/sh 
#
# Script to download all models from models.vision.ai which we might
# not already have present in the local model store. The model data is
# transferred into the local /incoming folder.
#
# Copyright vision.ai 2015

REMOTE_URL="https://models.vision.ai"
LOCAL_URL="http://localhost"

echo "This script will download all new models from models.vision.ai"
LOCAL_UUIDS=`curl -s ${LOCAL_URL}/model | jq -r '.data[] .uuid'`
REMOTE_UUIDS=`curl -s ${REMOTE_URL}/model | jq -r '.data[] .uuid'`
for UUID in $REMOTE_UUIDS; do
    if [ ! -n "`echo $LOCAL_UUIDS | grep $UUID`" ]; then
	EXTRA="does not exist, so downloading"
	echo $UUID $EXTRA
	mkdir /incoming/$UUID/
	curl -o /incoming/$UUID/image.jpg $REMOTE_URL/models/$UUID/image.jpg
	curl -o /incoming/$UUID/model.json $REMOTE_URL/models/$UUID/model.json
	curl -o /incoming/$UUID/model.data $REMOTE_URL/models/$UUID/model.data
	curl -o /incoming/$UUID/data_set.json $REMOTE_URL/models/$UUID/data_set.json
	curl -o /incoming/$UUID/compiled.data $REMOTE_URL/models/$UUID/compiled.data
	cd /incoming/
	tar cf $UUID.tar $UUID
	gzip $UUID.tar
	rm -rf $UUID
	cd - > /dev/null 2>&1
    else
	EXTRA="already exists"
	echo $UUID $EXTRA
    fi
    
done

