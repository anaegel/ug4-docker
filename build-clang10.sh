#!/bin/sh
export UG4DOCKER_CONFIG_APTMODULES_UGBUILD='"cmake make clang-10 llvm-10 libc-dev libblas-dev liblapack-dev"'
export UG4DOCKER_CONFIG_CC="clang-10"
export UG4DOCKER_CONFIG_CXX="clang++-10"
sh hooks/post_checkout
