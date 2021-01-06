# ug4-docker
Service scripts for automating the generation of docker images.

The following substitutions will be made:

' UG4DOCKER_CONFIG_XYZ => UG4DOCKER_CONFIG_XYZ' 

1. Serial standard. [https://hub.docker.com/r/ug4docker/ug4-devel]

* UG4DOCKER_APTMODULES_UGBUILD="cmake make clang-10 llvm-10 libc-dev libblas-dev liblapack-dev"
* UG4DOCKER_CC=clang-10
* UG4DOCKER_CXX=clang++-10

2. Parallel (mpich). [https://hub.docker.com/r/ug4docker/ug4-devel-mpi]

* UG4DOCKER_APTMODULES_UGBUILD="cmake make mpich libc-dev libblas-dev liblapack-dev"
* UG4DOCKER_CC=mpicc
* UG4DOCKER_CXX=mpicxx
