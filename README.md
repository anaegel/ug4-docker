# ug4-docker

1. Serial standard. 

* APT_MODULES_UGBUILD="cmake make clang-10 llvm-10 libc-dev libblas-dev liblapack-dev"
* UG4_CC=clang-10
* UG4_CXX=clang++-10

2. Parallel (mpich). 

* APT_MODULES_UGBUILD="cmake make mpich libc-dev libblas-dev liblapack-dev"
* UG4_CC=mpicc
* UG4_CXX=mpicxx
