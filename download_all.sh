#!/bin/sh
#Script to download all models from models.vision.ai which we might not already have

LOCAL_UUIDS=`curl -s https://localhost/model | jq -r '.data[] .uuid'`
REMOTE_UUIDS=`curl -s https://models.vision.ai/model | jq -r '.data[] .uuid'`
for UUID in $REMOTE_UUIDS; do
    if [ -n `echo $LOCAL_UUIDS | grep $UUID` ]; then
	EXTRA="does not exist"

	mkdir /incoming/$UUID/
	curl -o /incoming/$UUID/data_set.json https://models.vision.ai/models/$UUID/data_set.json
	curl -o /incoming/$UUID/image.jpg https://models.vision.ai/models/$UUID/image.jpg
	curl -o /incoming/$UUID/model.data https://models.vision.ai/models/$UUID/model.data
	curl -o /incoming/$UUID/compiled.data https://models.vision.ai/models/$UUID/compiled.data
	cd /incoming/
	tar cf $UUID.tar $UUID
	gzip $UUID.tar
	rm -rf $UUID
	cd - > /dev/null 2>&1
    else
	EXTRA="exists"
    fi
    #echo $UUID $EXTRA
done

