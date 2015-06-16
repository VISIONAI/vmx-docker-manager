#Script to import all models (represented as tarballs) from the
#/incoming folder into the vmx containers

docker run --rm --name vmx-export --volumes-from vmx-userdata:rw -v /incoming:/incoming ubuntu /bin/bash -c "cp -R /incoming/* /vmx/models && cd /vmx/models/ && cat *.gz | tar -xvzf - -i && rm *.gz"
