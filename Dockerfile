ARG BASE_CONTAINER=ubuntu:bionic
FROM ${BASE_CONTAINER} AS ugbase

################################################
# STAGE 0: Config
ENV DEBIAN_FRONTEND=noninteractive


################################################
# STAGE 1: Setup for ughub in /opt/ughub
# => Separate image
################################################
FROM ugbase AS ughub

ARG APT_MODULES_UGHUB="git python"
RUN echo "Arguments for apt: ${APT_MODULES_UGHUB}"
RUN echo "Arguments for apt: ${UG4_WITH_XEUS}"
# LABEL version="1.0"

#install requirements
RUN apt list --installed

RUN apt-get update && apt-get -y install ${APT_MODULES_UGHUB}
WORKDIR /opt
RUN git clone https://github.com/UG4/ughub.git ughub;  
ENV PATH=$PATH:/opt/ughub


################################################
# STAGE 2: Install packages to '/opt/ug4'
# => Image
################################################
FROM ughub AS ug4-base-install

ENV UG4_ROOT /opt/ug4/
ARG UG4_MODULES="ugcore ConvectionDiffusion Examples Limex"

WORKDIR ${UG4_ROOT}
RUN ughub init;\
    ughub install ${UG4_MODULES}
    # ughub git pull;
    # mkdir headers -p;\
    # mkdir apps -p

################################################
# STAGE 3: Build UG4
# => Image
################################################
FROM ug4-base-install AS ug4-dev-config

# Configure using ARG, e.g.
# ARG UG4DOCKER_APTMODULES_UGBUILD="cmake make clang-10 llvm-10 libc-dev libblas-dev liblapack-dev"
# ARG UG4DOCKER_CC=gcc
# ARG UG4DOCKER_CXX=g++

ARG UG4_CONF_APTMODULES_UGBUILD="cmake:make:clang-10:llvm-10:libc-dev:libblas-dev:liblapack-dev"
ARG UG4DOCKER_CC=clang-10
ARG UG4DOCKER_CXX=clang++-10

ARG UG4_CONF_NUM_MAKE=2
ARG UG4_CMAKE_OPTIONS=""

ARG UG4_CONF_DIM="2"
ARG UG4_CONF_CPU="1"
ARG UG4_WITH_XEUS=OFF


RUN echo "Arguments: UG4_CONF_APTMODULES_UGBUILD = ${UG4_CONF_APTMODULES_UGBUILD}"
RUN echo "Arguments: UG4DOCKER_CXX = ${UG4DOCKER_CXX}"
RUN echo "Arguments: UG4_WITH_XEUS = ${UG4_WITH_XEUS}"
RUN echo "Arguments: UG4_CMAKE_OPTIONS = ${UG4_CMAKE_OPTIONS}"


# RUN apt-get update; apt-get install -y ${UG4_CONF_APTMODULES_UGBUILD}
RUN apt-get update;
RUN echo "Installing: ${UG4_CONF_APTMODULES_UGBUILD}" 
RUN echo "${UG4_CONF_APTMODULES_UGBUILD}" | sed 's/:/ /g'  | xargs apt-get install -y

#Build config
WORKDIR ${UG4_ROOT}/build
RUN cmake .. -DCMAKE_CXX_COMPILER=${UG4DOCKER_CXX} -DCMAKE_C_COMPILER=${UG4DOCKER_CC} -DDIM=${UG4_CONF_DIM} -DENABLE_ALL_PLUGINS=OFF -DCPU=${UG4_CONF_CPU} -DCOMPILE_INFO=OFF -DUSE_XEUS=${UG4_WITH_XEUS}
RUN cmake ${UG4_CMAKE_OPTIONS} .. 
    
#Build process   
FROM ug4-dev-config AS ug4-dev-build
WORKDIR ${UG4_ROOT}/build
RUN make -j${UG4_CONF_NUM_MAKE}

################################################
# STAGE 4: Extract executable, libs [and headers] 
# (=> reduce imagesize)
################################################
FROM ug4-dev-build AS ug4-dev
WORKDIR ${UG4_ROOT}
RUN rm -rf build


################################################
# with JUPYTER: Activate build for jupyter.
#        Add Xeus, JupyterToolbox and xeus-kernel.
################################################
FROM ug4-dev-config AS ug4-dev-jupyter
WORKDIR ${UG4_ROOT}/build

# Fetch conda
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install git wget libssl-dev uuid-dev
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash ./Miniconda3-latest-Linux-x86_64.sh -p /opt/miniconda -b
ENV PATH=${PATH}:/opt/miniconda/bin
RUN conda create -n ug4env
RUN conda update -y conda
RUN conda install xeus=0.25.1 xeus-cling xwidgets zeromq -c conda-forge


# Fetch JupyterToolbox.
WORKDIR ${UG4_ROOT}
RUN ughub init;\
    ughub install JupyterToolbox

# Expand exisiting installation.
WORKDIR ${UG4_ROOT}/build
RUN cmake .. -DJupyterToolbox=ON -DUSE_XEUS=ON;
RUN make -j${UG4_CONF_NUM_MAKE}

# Build kernel.
WORKDIR ${UG4_ROOT}/tools/xeus-ug4-kernel
RUN git pull;
RUN less CMakeLists.txt
RUN mkdir build

WORKDIR ${UG4_ROOT}/tools/xeus-ug4-kernel/build
RUN cmake ..  -DCMAKE_CXX_COMPILER=${UG4DOCKER_CXX} -DCMAKE_C_COMPILER=${UG4DOCKER_CC}; make VERBOSE=1




# FROM ugbuild-with-jupyter AS ug4-devel-with-jupyter
# WORKDIR /opt/ug4-dev
# RUN rm -rf build


