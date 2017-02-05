##
# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# Dockerfile to build a Docker image with the Swift binaries and its dependencies.

FROM ubuntu:14.04
MAINTAINER IBM Swift Engineering at IBM Cloud
LABEL Description="Linux Ubuntu 14.04 image with the Swift binaries."

# Set environment variables for image
ENV HOME /root
ENV WORK_DIR /root

# Set WORKDIR
WORKDIR ${WORK_DIR}

# Linux OS utils
RUN apt-get update && apt-get install -y \
  automake \
  build-essential \
  clang \
  curl \
  gcc-4.8 \
  git \
  g++-4.8 \
  libblocksruntime-dev \
  libbsd-dev \
  libcurl4-gnutls-dev \
  libcurl3 \
  libglib2.0-dev \
  libpython2.7 \
  libicu-dev \
  libkqueue-dev \
  libtool \
  openssh-client \
  vim \
  wget \
  binutils-gold

RUN cd /tmp/ \
    && curl -L -O https://github.com/zeromq/zeromq4-1/releases/download/v4.1.4/zeromq-4.1.4.tar.gz \
    && tar xf /tmp/zeromq-4.1.4.tar.gz \
    && cd /tmp/zeromq-4.1.4 \
    && ./configure --without-libsodium \
    && make \
    && make install

RUN apt-get install -y openssl libssl-dev

RUN apt-get install systemtap-sdt-dev

RUN wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - \
  && apt-get install -y software-properties-common \
  && apt-add-repository "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.8 main"

RUN apt-get update \
  && apt-get install -y clang-3.8

RUN ln -s /usr/bin/clang-3.8 /usr/bin/clang \
  && ln -s /usr/bin/clang++-3.8 /usr/bin/clang++ \
  && clang --version

RUN apt-get install binutils-gold

ENV SWIFT_SNAPSHOT swift-DEVELOPMENT-SNAPSHOT-2017-01-24-a
ENV UBUNTU_VERSION ubuntu14.04
ENV UBUNTU_VERSION_NO_DOTS ubuntu1404
ENV SWIFT_BRANCH development

# Install Swift compiler
RUN wget https://swift.org/builds/$SWIFT_BRANCH/$UBUNTU_VERSION_NO_DOTS/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz \
  && tar xzvf $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz \
  && rm $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
ENV PATH $WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr/bin:$PATH
RUN swiftc -h

#Hack to force usage of the gold linker
# RUN rm /usr/bin/ld && ln -s /usr/bin/ld.gold /usr/bin/ld

#Install Pip3
RUN apt-get install -y python3-pip

RUN pip3 install --upgrade pip

# Install Jupyter
RUN pip3 install jupyter

COPY . ${WORK_DIR}/iSwift
WORKDIR ${WORK_DIR}/iSwift

RUN swift package update
RUN swift build -Xcc -IIncludes
RUN jupyter kernelspec install SwiftyKernel

EXPOSE 8888

RUN mkdir notebooks

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--NotebookApp.token=", "--ip=0.0.0.0", "--Session.key=\"b''\"", "--notebook-dir=notebooks"]
