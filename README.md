##Requirements
    64 bit linux and docker >= 1.2

##Instructions

Either clone the repo

    git clone https://github.com/VISIONAI/vmx-docker-manager.git

Or download the shell script directly: https://raw.githubusercontent.com/VISIONAI/vmx-docker-manager/master/vmx

    ./vmx
    Usage: vmx COMMAND [OPTIONS]
    Commands:
        start PORT:  Start vmx on localhost:PORT
        stop:   Stop vmx
        enter:  Shell access to docker
        init :  download and start the containers that have the pre-reqs, mcr, etc. (This is done automatically the first time y ou start vmx)
        
        
##Example:
 Run vmx on port 3000
    
    $  ./vmx start 3000


##Explanation

VMX requires a few files/folder to be available:
 - Matlab Dependency
 - Mount points for:
   - Session Information
   - Local Model storage
 - Certain open source libraries

The VMX Docker manager is a set of sane defaults and configurations that store user data (session and models) in seperate volumes at /vmx/sessions and /vmx/models; and loads the binaries into /vmx/build.  Those mount points, along with the matlab MCR dependency are run within the context of an Ubuntu 14.04 with the required libraries.

The dockerfiles that build the referenced dockers can be found here: https://github.com/VISIONAI/vmx-public-docker
