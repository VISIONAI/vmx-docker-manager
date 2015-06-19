#!/bin/sh
#
# Admin tool to upload local models from a VMX node into
# models.vision.ai. Requires administrator priviledges (SSH key) on
# models.vision.ai.
# 
# Copyright vision.ai 2015

VMX_LOCAL="http://cloud6.vision.ai"

VMX_SSH="root@models.vision.ai"
VMX_REMOTE="https://models.vision.ai"
VMX_REMOTE_DIR="/incoming"

NAME=$1

#make sure local endpoint works
if [ "`curl -s $VMX_LOCAL`" = "" ]; then
    echo "Cannot communicate with local VMX at $VMX_LOCAL"
    echo "Make sure VMX is running"
    exit
fi

#Make sure the remote endpoint is responsing to REST API requests
HAS_MODELS=`curl -s $VMX_REMOTE/model | jq -r '.data[]'`
if [ "$HAS_MODELS" = "" ]; then
    echo "Remote endpoint $VMX_REMOTE is not listing models, exiting"
    exit
fi

#Make sure we have two command line arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 model_name" >&2

  NAMES=`curl -s $VMX_LOCAL/model | jq -r '.data[] .name'`
  echo "Valid names are:" $NAMES
  exit
fi

HI=`ssh -o PreferredAuthentications=publickey $VMX_SSH "echo hi" 2>/dev/null`
if [ "$HI" = "" ]; then
    echo "Improper credentials for talking to $VMX_REMOTE"
    echo "Remember to log-in with: ssh-add && ssh -A this.box.ip"
    exit
fi


#jump into local directory
cd `dirname $0`

#Get the UUID for the desired model
UUID=`curl -s $VMX_LOCAL/model | jq -r '.data[] | select(.name=="'$NAME'") .uuid'`

if [ ! -n "$UUID" ]; then
    echo "Error: Cannot find a UUID for name" $NAME "in local models" $VMX_LOCAL
    echo "Not copying"
    exit
fi

#check if that UUID is present on the remote server
IS_PRESENT=`curl -s $VMX_REMOTE/model | jq -r '.data[] | select(.uuid=="'$UUID'") .name'`

if [ -n "$IS_PRESENT" ]; then
    echo "Warning: already found UUID" $UUID "on remote server" $VMX_REMOTE
    echo "Not copying"
    exit
fi

echo UUID of object $NAME is $UUID

echo "Preparing tarball for copy"
TARBALL=/tmp/$UUID.tar
cd /tmp/
mkdir $UUID

#use curl to pull down models
curl -o $UUID/image.jpg $VMX_LOCAL/models/$UUID/image.jpg
curl -o $UUID/model.json $VMX_LOCAL/models/$UUID/model.json
curl -o $UUID/model.data $VMX_LOCAL/models/$UUID/model.data
curl -o $UUID/data_set.json $VMX_LOCAL/models/$UUID/data_set.json
curl -o $UUID/compiled.data $VMX_LOCAL/models/$UUID/compiled.data

tar cf $TARBALL $UUID
cd - > /dev/null 2>&1
gzip $TARBALL
TARBALL=${TARBALL}.gz

echo "Copying tarball"
ssh $VMX_SSH "mkdir -p $VMX_REMOTE_DIR"
scp $TARBALL $VMX_SSH:$VMX_REMOTE_DIR

echo "Importing into remote container"
ssh $VMX_SSH "~/vmx-docker-manager/import_models.sh"

echo "Clearing tarball on local"
rm $TARBALL

cd - > /dev/null 2>&1
