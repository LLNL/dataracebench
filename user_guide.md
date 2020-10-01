## Overview

### A.1.1  How software can be obtained (if available)?
DataRaceBench v1.3.0 can be found at GitHub, 
https://github.com/LLNL/dataracebench}{https://github.com/LLNL/dataracebench.

Alternatively, it can be pulled as a Docker Image directly from the Docker Hub, https://hub.docker.com/repository/docker/yshixyz/dataracebench 

### A.1.2  Hardware dependencies.
The computation node we used is from the Lassen IBM POWER9 nodes with NVIDIA Volta GPUs as described at https://hpc.llnl.gov/hardware/platforms/lassen . The nodes there are machines running Linux operating systems. 
Any similar hardware supporting execution of OpenMP programs should be supported. The DRB can be run on AWS using AWS Parallel Cluster to configure and launch an Elastic HPC Cluster. We need to estimate instance type, volume type, the minimum, and the maximum number of compute nodes, VPC, and deployment region. Also, it is possible to have an EBS snapshot of the shared disk for reusability with the Amazon Elastic Block Store. 

### A.1.3  Software dependencies.
As a benchmark suite, DataRaceBench is provided as a Dockerized Service. The images contain Archer, ROMP, and ThreadSanitizer tools (Intel Inspector need a valid license, hence its image is not provided) and DataRaceBench. One may need to update DataRaceBench (DRB) to the latest Github version and mount it into the docker container. The image details are as follows:

1. ThreadSanitizer, version 10.0, and compiler support for Clang/LLVM 10.0
2. Archer, release version release_60, and compiler support for Clang/LLVM 6.0
3. ROMP, version 20ac93c, and compiler support for GCC/gfortran 7.4.0.
4. Coderrect Scanner, version 0.8.0, and compiler support for Clang/LLVM 9.0

We have used Intel Inspector, version 2020(build 603904), and compiler support for Intel Compiler 19.1.0.166 and the latest version of DRB, (https://github.com/LLNL/dataracebench.git bf219c401aeefe6e3dc32dafed0278a7417486ee).

### A.1.4  Datasets.
All programs in DataRaceBench have built-in data sets. No additional input files are needed. A configuration file is used to specify different sizes of arrays or to run selected programs only.


## A.2 Installation
Follow the below steps to use the DataRaceBench:
* ThreadSanitizer: sudo docker pull yshixyz/dataracebench:Tsan
* Archer: sudo docker pull yshixyz/dataracebench:archer
* ROMP: sudo docker pull yshixyz/dataracebench:romp
* Coderrect Scanner: see the coderrect [Quick Start](https://coderrect.com/documentation/quick-start/) page
* Intel Inspector: A valid license is required to install and use Intel Inspector.

After downloading the docker image, a user needs to create containers for all the five tools.
* Archer: docker run -it --name drb\_archer yshixyz/dataracebench:archer
* ThreadSanitizer: sudo docker run -it --name drb\_tsan yshixyz/dataracebench:Tsan
* ROMP: sudo docker run -it --name drb\_romp yshixyz/dataracebench:romp
* Coderrect Scanner: Assume user have built their own image - sudo docker run -it --name drb\_coderrect bash
* Intel Inspector: Assume user have built their own Intel image - sudo docker run -it --name drb\_intel bash

DRB is automated with the provided scripts which are covered in the next section.

It is recommended to update the copy of DRB in the docker to the latest version from the master branch of https://github.com/LLNL/dataracebench to have latest bug fixes. 

## A.3  Evaluation Workflow
Once the above setup is completed, one can start and enter the respective docker container using one of the below commands:
* docker start drb\_archer; sudo docker exec -it -u root drb\_archer bash
* docker restart drb\_Tsan; sudo docker exec -it -u root drb\_tsan bash
* docker stop drb\_romp; sudo docker exec -it -u root drb\_romp bash
* docker rm drb\_intel; sudo docker exec -it -u root drb\_intel bash

DataRaceBench’s execution script, check-data-races.sh, has builtin support for all the five tools. Once we enter a container, we need to set the environment for ROMP and Intel Inspector. To use ROMP, we need to run the following commands to set the context:

**_Environment setup - ROMP_**
```
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

For Intel Inspector, we need to run the following code to set the environment:

**_Environment setup - Intel Inspector_**
```
source /opt/intel/parallel_studio_xe_2020.0.088/bin/psxevars.sh
export PATH=/opt/intel/bin:$PATH
```

Double-check the file location and the added path for the correct environment variables setup.
To run the DRB, use:
`./check-data-race.sh --toolname language (./check-data-race.sh --romp fortran)`

Use below to see all the possible options:
```
#show more helpful information for this script
./check-data-races.sh --help
```

We can even run partial test programs using `--customize` flag. One should enter the test programs to run in the `list.def` and tools to test in the `tool.def` file. Rest all the steps remains the same and can be referred to from the above `--help` option.

## A.4  Evaluation and Results
Running check-data-races.sh generates csv files stored in a sub-directory, named results, containing multiple lines of information. Each line indicates results of one or several experiments of a given tool under a certain configuration, with fields for:
* The name of the evaluated tool.
* The filename of the microbenchmark.
* True or false (indicating whether the microbenchmark is known to have a data race).
* The number of threads being used for execution.
* Varying length array size (reports N/A if the microbenchmark has no variable length array(s)).
* How many data races the tool reports for this experiment.
* The elapsed time reported in seconds in the experiment.

