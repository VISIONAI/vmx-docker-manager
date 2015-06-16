#!/bin/sh
#
# Script to import all models (represented as tarballs) from the
# /incoming folder into the vmx model container
#
# Copyright vision.ai 2015

TARGET_DIRECTORY='/incoming'

docker stop vmx-export 2> /dev/null
docker rm vmx-export 2> /dev/null

NFILES=`ls $TARGET_DIRECTORY/*.gz 2>/dev/null | wc -l`
echo "Number of" $TARGET_DIRECTORY "Models:" $NFILES
if [ "$NFILES" = "0" ]; then
    echo "No models to import, exiting"
    exit
else
    echo "Importing $NFILES models"
fi

docker run --rm --name vmx-export --volumes-from vmx-userdata:rw \
    -v $TARGET_DIRECTORY:/incoming ubuntu /bin/bash \
    -c "cp -R /incoming/*.gz /vmx/models && cd /vmx/models/ && cat *.gz | tar -xvzf - -i && rm *.gz"

#Remove models from /incoming after they have been imported
rm -f $TARGET_DIRECTORY/*.gz
