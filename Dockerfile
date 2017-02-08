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

FROM norionomura/sourcekit:302

# Set environment variables for image
ENV HOME /root
ENV WORK_DIR /root

# Set WORKDIR
WORKDIR ${WORK_DIR}

RUN apt-get update && \
 apt-get -y install build-essential

# Install ZMQ
RUN cd /tmp/ \
    && curl -L -O https://github.com/zeromq/zeromq4-1/releases/download/v4.1.4/zeromq-4.1.4.tar.gz \
    && tar xf /tmp/zeromq-4.1.4.tar.gz \
    && cd /tmp/zeromq-4.1.4 \
    && ./configure --without-libsodium \
    && make \
    && make install

RUN apt-get -y install openssl libssl-dev

#Install Pip3
RUN apt-get install -y python3-pip

RUN pip3 install --upgrade pip

# Install Jupyter
RUN pip3 install jupyter

COPY . ${WORK_DIR}/iSwift
WORKDIR ${WORK_DIR}/iSwift

RUN swift package update
RUN swift build
RUN jupyter kernelspec install iSwiftKernel

EXPOSE 8888

RUN mkdir notebooks

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--NotebookApp.token=", "--ip=0.0.0.0", "--notebook-dir=notebooks"]
