#!/bin/sh
#
# Script to import all models (represented as tarballs) from the
# /incoming folder into the vmx model container
#
# Copyright vision.ai 2015

docker stop vmx-export 2> /dev/null
docker rm vmx-export 2> /dev/null
NFILES=`ls /incoming/*.gz 2>/dev/null | wc -l`
echo "Number of /incoming Models:" $NFILES
if [ "$NFILES" = "0" ]; then
    exit
fi
docker run --rm --name vmx-export --volumes-from vmx-userdata:rw \
    -v /incoming:/incoming ubuntu /bin/bash \
    -c "cp -R /incoming/*.gz /vmx/models && cd /vmx/models/ && cat *.gz | tar -xvzf - -i && rm *.gz"
