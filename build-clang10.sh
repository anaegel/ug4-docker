#!/bin/sh
export UG4_CONF_APTMODULES_UGBUILD="cmake:make:llvm-10:clang-10:libc-dev:libblas-dev:liblapack-dev"
export UG4DOCKER_CC="clang-10"
export UG4DOCKER_CXX="clang++-10"
export UG4_CONF_NUM_MAKE=1
# export UG4_CMAKE_OPTIONS="-DUSE_XEUS=ON"

docker build --target ug4-dev-juypter -t anaegel/ug4-dev-jupyter --build-arg UG4_CONF_APTMODULES_UGBUILD="${UG4_CONF_APTMODULES_UGBUILD}" --build-arg UG4DOCKER_CC="$UG4DOCKER_CC" --build-arg UG4DOCKER_CXX="$UG4DOCKER_CXX"  --build-arg UG4_CONF_NUM_MAKE="${UG4_CONF_NUM_MAKE}" --build-arg UG4_CMAKE_OPTIONS=${UG4_CMAKE_OPTIONS} .   

docker build -t anaegel/ug4-dev --target ug4-dev --build-arg UG4_CONF_APTMODULES_UGBUILD="${UG4_CONF_APTMODULES_UGBUILD}" --build-arg UG4DOCKER_CC="$UG4DOCKER_CC" --build-arg UG4DOCKER_CXX="$UG4DOCKER_CXX" --build-arg UG4_CONF_NUM_MAKE="${UG4_CONF_NUM_MAKE}" --build-arg UG4_CMAKE_OPTIONS=${UG4_CMAKE_OPTIONS} . 



