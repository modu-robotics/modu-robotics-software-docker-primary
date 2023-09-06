FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt update && \
    apt -y install \
    wget \
    git \
    cmake \
    curl \
    lsb-release \
    build-essential \
    gzip \
    ca-certificates \
    openssh-client \
    tar

# Install bazelisk
ENV BAZELISK_VERSION="v1.17.0"
RUN if [[ "$(uname -m)" == "x86_64" ]]; then \
        curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-amd64; \
    elif [[ "$(uname -m)" == "aarch64" ]]; then \
        curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-arm64; \
    else \
        echo "Unsupported architecture"; \
        exit 1; \
    fi && \
    chmod +x /usr/local/bin/bazel

# Install other system libraries
RUN apt -y install \
    gnupg2 \
    libeigen3-dev \
    liburdfdom-dev \
    libboost-all-dev \
    libfmt-dev \
    libzstd-dev \
    liblz4-dev \
    libgtest-dev

# Define variables
ENV BASE=/modu-robotics-software-third-party
ENV INSTALL_DIR=/opt/modu-robotics-software-third-party
RUN mkdir $BASE $INSTALL_DIR

# Install casadi
RUN mkdir $INSTALL_DIR/casadi $INSTALL_DIR/casadi/bin $INSTALL_DIR/casadi/lib $INSTALL_DIR/casadi/include && \
    cd $BASE && git clone --branch nightly-release-3.6.3 https://github.com/casadi/casadi.git && \
    cd casadi && mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/casadi -DBIN_PREFIX=$INSTALL_DIR/casadi/bin -DLIB_PREFIX=$INSTALL_DIR/casadi/lib -DINCLUDE_PREFIX=$INSTALL_DIR/casadi/include -DCMAKE_BUILD_TYPE=Release -DWITH_BUILD_EIGEN3=ON -DWITH_OSQP=ON -DWITH_BUILD_OSQP=ON -DWITH_QPOASES=ON -DWITH_LAPACK=ON -DWITH_BUILD_LAPACK=ON -DWITH_IPOPT=ON -DWITH_BUILD_IPOPT=ON -DWITH_MUMPS=ON -DWITH_BUILD_METIS=ON -DWITH_BUILD_MUMPS=ON -DWITH_EXAMPLES=OFF && \
    make -j && make install

# Install pinocchio
RUN mkdir $INSTALL_DIR/pinocchio && cd $BASE && git clone --recursive --branch pinocchio3-preview https://github.com/stack-of-tasks/pinocchio && \
        cd pinocchio && mkdir build && cd build && \
        cmake .. -DCMAKE_PREFIX_PATH=$INSTALL_DIR/casadi/lib/cmake/casadi -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/pinocchio -D_PKG_CONFIG_PREFIX=$INSTALL_DIR/pinocchio -DCMAKE_BUILD_TYPE=Release -DBUILD_WITH_CASADI_SUPPORT=ON -DBUILD_PYTHON_INTERFACE=OFF && \
        make -j && make install
