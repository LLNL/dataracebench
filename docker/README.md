# Using Docker for dataracebench

### Prerequisite

1. OS:
Ubuntu 18.04

1. Install docker
```bash
sudo apt update
sudo apt install docker.io
```
or check the guide in docker official website.
https://docs.docker.com/get-docker/

## Using Docker images

You can use docker images by directly pull from docker hub into your machine.

### Get the docker images

All the docker images ready for use are uploaded to DockerHub.
https://hub.docker.com/repository/docker/yshixyz/dataracebench
The images contains all three tools (Intel Inspector need a valid license, we are not providing its image) and dataracebench. You may need update dataracebench to the latest github version. And they should be mounted into the docker container. The detail instrucions are as following:

#### ThreadSanitizer
```bash
sudo docker pull yshixyz/dataracebench:Tsan
```
#### Archer
```bash
sudo docker pull yshixyz/dataracebench:archer
```
#### ROMP
```bash
sudo docker pull yshixyz/dataracebench:romp
```
#### Intel Inspector
A valid license is required to install and use Intel Inspector.

### Create a container

After downloading the docker image from docker hub, the user needs to create a container for the four tools.

#### Archer
```bash
sudo docker run -it --name drb_archer yshixyz/dataracebench:archer
```
#### ThreadSanitizer
```bash
sudo docker run -it --name drb_tsan yshixyz/dataracebench:Tsan
```
#### ROMP
```bash
sudo docker run -it --name drb_romp yshixyz/dataracebench:romp
```

#### Intel Inspector

Assumes user have built their own Intel image:

```bash
sudo docker run -it --name drb_intel bash
```


### Start/Restart/Stop/Delete a container

```bash
sudo docker start drb_Tsan
sudo docker restart drb_Tsan
sudo docker stop drb_Tsan
sudo docker rm drb_Tsan
```

### Enter a container
After creating a container, run the following command to enter it for debugging or something else.
```bash
sudo docker exec -it drb_tsan bash
```
### Run scripts

#### set environments
When entering a container, you need set the enviorment for ROMP and Intel Insepctor.
For using ROMP, you need run following code to set the enviorment:
```bash
source /home/drb/modules/init/bash
module use /home/drb/spack/Modules/modules/linux-ubuntu18.04-haswell
module load gcc-7.4.0-gcc-7.5.0-moe6s7c
module load llvm-openmp-romp-mod-gcc-7.4.0-cs7qzdu
module load glog-0.3.5-gcc-7.4.0-gqqsqah
module load dyninst-10.1.2-gcc-7.4.0-ohvswfl
export DYNINSTAPI_RT_LIB=/home/drb/spack/Modules/packages/linux-ubuntu18.04-haswell/gcc-7.4.0/dyninst-10.1.2-ohvswflc5hmntqwldkswrmwexnb56hzm/lib/libdyninstAPI_RT.so
export ROMP_PATH=/home/drb/spack/Modules/packages/linux-ubuntu18.04-haswell/gcc-7.4.0/romp-master-i4tglb74pfvppyxbq42iljsrcxmexnrv/lib/libromp.so
export PATH=/home/drb/spack/Modules/packages/linux-ubuntu18.04-haswell/gcc-7.4.0/romp-master-i4tglb74pfvppyxbq42iljsrcxmexnrv/bin:$PATH
```

For Intel Inspector, you need run following code to set the environment:
```bash
source /opt/intel/parallel_studio_xe_2020.0.088/bin/psxevars.sh
export PATH=/opt/intel/bin:$PATH
```

The location of file and the harsh name which created by spark, may be different. You should check the the file name and their location in your docker container.

#### test with tool


```bash
cd dataracebench
./check-data-race.sh --toolname language (./check-data-race.sh --romp fortran)
```

## Build Docker images

Instead of use docker images from docker hub, user could also build the Docker images for easier deployment.

```bash
# get the dataracebench source code at github
git clone https://github.com/LLNL/dataracebench.git
```
#### Archer

```bash
# enter the Archer tools source folder first
cd docker
docker build -t drb-archer -f Dockerfile.drbArcher .
```

#### ThreadSanitizer

```bash
# enter the Tsan source folder first
cd docker
docker build -t drb-tsan -f Dockerfile.drbTsan .
```

### Romp and Intel Inspector

Romp is installed by spark which generate a random hash code in the file. You should create and run empty docker image or using our docker container directly.
The instruction for using Romp can be find at https://github.com/zygyz/romp.

Intel Inspector need a valid intel license to use. User need its own intel license to use Intel Inspector. And you should use this empty docker image.

```bash
# enter the datarace source folder first
cd docker
docker build -t drb-tsan -f Dockerfile.dataracebench .
```
