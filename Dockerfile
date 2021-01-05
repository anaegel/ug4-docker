ARG BASE_CONTAINER=ubuntu:bionic
ARG DEBIAN_FRONTEND=noninteractive

ENV APT_MODULES_UGBUILD="cmake make clang-10 llvm-10 libc-dev libblas-dev liblapack-dev"
ENV UG4_CC="clang-10"
ENV UG4_CXX="clang++-10"

################################################
# STAGE 1: Setup for ughub in /opt/ughub
# => Separate image
################################################
FROM ${BASE_CONTAINER} AS ughub

ARG APT_MODULES_UGHUB="git python"
ARG UG4_WITH_XEUS=OFF
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
# STAGE 2: Install packages to '/opt/ug4-dev'
# => Image
################################################
FROM ughub AS uginstall

ENV UG4_ROOT /opt/ug4-dev/
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
FROM uginstall AS ugbuild

# Install dependencies

ARG UG4_CONF_DIM="2"
ARG UG4_CONF_CPU="1"

RUN echo "Arguments for apt: ${APT_MODULES_UGBUILD}"
RUN echo "Arguments for apt: ${UG4_CXX}" 
RUN apt-get update; apt-get install -y ${APT_MODULES_UGBUILD}

#Build process
WORKDIR ${UG4_ROOT}/build
# ENV CXX_FLAGS="-lstdc++"
RUN cmake .. -DCMAKE_CXX_COMPILER=${UG4_CXX} -DCMAKE_C_COMPILER=${UG4_CC} -DDIM=${UG4_CONF_DIM} -DENABLE_ALL_PLUGINS=OFF -DCPU=${UG4_CONF_CPU} -DCOMPILE_INFO=OFF -DUSE_XEUS=${UG4_WITH_XEUS};\
    make -j10
    

################################################
# STAGE 4: Extract executable, libs [and headers] 
# (=> reduce imagesize)
################################################
FROM ugbuild AS ug4-devel
WORKDIR /opt/ug4-dev
RUN rm -rf build

################################################
# NEW STAGE: Activate build for jupyter.
#        Add Xeus, JupyterToolbox and xeus-kernel.
################################################

# FROM uginstall AS ugbuild-with-jupyter

# Fetch conda
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install git wget libssl-dev uuid-dev
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# RUN bash ./Miniconda3-latest-Linux-x86_64.sh -p /opt/miniconda -b
# ENV PATH=${PATH}:/opt/miniconda/bin
# RUN conda create -n ug4env
# RUN conda update -y conda
# RUN conda install xeus=0.25.1 xeus-cling xwidgets zeromq -c conda-forge



# Fetch JupyterToolbox
# WORKDIR ${UG4_ROOT}
# RUN ughub init;\
#   ughub install JupyterToolbox

# Expand exisiting build.
# WORKDIR ${UG4_ROOT}/build
# RUN cmake .. -DJupyterToolbox=ON ; make -j3

# Build kernel.
# WORKDIR ${UG4_ROOT}/tools/xeus-ug4-kernel
# RUN git pull;
# RUN less CMakeLists.txt
# RUN mkdir build

# WORKDIR ${UG4_ROOT}/tools/xeus-ug4-kernel/build
# RUN cmake ..  -DCMAKE_CXX_COMPILER=clang++-10 -DCMAKE_C_COMPILER=clang-10; make VERBOSE=1




# FROM ugbuild-with-jupyter AS ug4-devel-with-jupyter
# WORKDIR /opt/ug4-dev
# RUN rm -rf build


