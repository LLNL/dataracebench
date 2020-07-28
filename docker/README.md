# Using Docker for dataracebench

### Prerequisite

1. OS:
Ubuntu 18.04

1. Install docker
```bash
sudo apt update
sudo apt install docker.io
```
or check the guide in docker offical website.
https://docs.docker.com/get-docker/

## Using Docker images

You can use docker images by directly pull from docker hub into your machine.

### Get the docker images

All the docker images ready for use are uploaded to DockerHub.
https://hub.docker.com/repository/docker/yshixyz/dataracebench
The images contains all three tools (Intel Inspector need a valid license, we are not providing its image) and dataracebench. You may need update dataracebench to the latest github version. And they should be mounted into the docker container. The detail instrucions are as following:

#### ThreadSanitizer
```bash
sudo docker push yshixyz/dataracebench:Tsan
```
#### Archer
```bash
sudo docker push yshixyz/dataracebench:archer
```
#### ROMP
```bash
sudo docker push yshixyz/dataracebench:test
```
#### Intel Inspector
A valid license is required to install and use Intel Inspector.

### Create a container

After download the docker image from docker hub, user need create contariner for four tools.

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
sudo docker run -it --name drb_romp yshixyz/dataracebench:test
```

#### Intel Inspector

Assump user have built their own Intel image:

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

## Build Docker images

Instead of use docker images from docker hub, user could also build the Docker images for easier deployment.

```bash
# get the dataracebench source code at github
git clone https://github.com/LLNL/dataracebench.git
```
#### Archer

```bash
# enter the Archer tools srouce folder first
cd docker
docker build -t drb-archer -f Dockerfile.drbArcher .
```

#### ThreadSanitizer

```bash
# enter the Tsan srouce folder first
cd docker
docker build -t drb-tsan -f Dockerfile.drbTsan .
```

### Romp and Intel Inspector

Romp is installed by spark which generate a random hash code in the file. You should create and run empty docker image or using our docker container directly.
The instruction for using Romp can be find at https://github.com/zygyz/romp.

Intel Inspector need a valid intel license to use. User need its own intel license to use Intel Inspector. And you should use this empty docker image.

```bash
# enter the datarace srouce folder first
cd docker
docker build -t drb-tsan -f Dockerfile.dataracebench .
```
