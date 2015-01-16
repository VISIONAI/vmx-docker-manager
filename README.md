##Requirements
    64 bit linux and docker >= 1.2

##Instructions

Either clone the repo

    git clone https://github.com/VISIONAI/vmx-docker-manager.git

Or download the shell script directly: https://raw.githubusercontent.com/VISIONAI/vmx-docker-manager/master/vmx

    Usage: vmx COMMAND [OPTIONS]

    Commands:
        start PORT: Start vmx on localhost:PORT
        stop:       Stop vmx
        enter:      Shell access to docker
        init :      Download and start the containers that have the pre-reqs, mcr, etc.
                    (This is done automatically the first time you start vmx)
        update TAG: Update your vmx (will stop vmx first). TAG must be
                    "latest" or "dev", defaults to "latest"
        backup:     Backup your vmx data (models, session logs, config file)
        
##Example:
 Run vmx on port 3000
    
    $  ./vmx start 3000

 Stop vmx

    $ ./vmx stop

 Backup your data to  /Users/tomasz/projects/vmx-docker-manager/.vmx-backup/

    $  ./vmx backup
    
 Restore from a backup

    $  ./vmx restore .vmx-backup/2014_FriNov21_20_04
 
 Update vmx to latest (stable) version

    $  ./vmx update

or 

    $  ./vmx update latest

 Update vmx to dev version

    $  ./vmx update dev

   


##Explanation

vmx-docker-manager automatically downloads all dependencies.  In
general, VMX requires a few files/folder to be available:
 - MATLAB MCR (Matlab Compiler Runtime)
 - Mount points for:
   - Session Information
   - Local Model storage
 - Certain open source libraries

The VMX Docker manager is a set of sane defaults and configurations that store user data (session and models) in seperate volumes at /vmx/sessions and /vmx/models; and loads the binaries into /vmx/build.  Those mount points, along with the matlab MCR dependency are run within the context of an Ubuntu 14.04 with the required libraries.

The dockerfiles that build the referenced docker images can be found here:

- https://github.com/VISIONAI/docker-mcr-2014a
- https://github.com/VISIONAI/docker-vmx-userdata
- https://github.com/VISIONAI/docker-vmx-middle
- https://github.com/VISIONAI/docker-vmx-server
- https://github.com/VISIONAI/docker-vmx-appbuilder
