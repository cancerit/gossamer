FROM ubuntu:18.04 as builder

USER root

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends \
locales \
g++ \
make \
cmake \
libboost-all-dev \
pandoc \
zlib1g-dev \
libbz2-dev \
libsqlite3-dev

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ENV OPT /opt/local
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN mkdir -p $LD_LIBRARY_PATH

# Build and install gossamer 
ADD . /gossamer
RUN mkdir -p /gossamer/build \
    && cd /gossamer/build \
    && cmake -DCMAKE_INSTALL_PREFIX=$OPT .. \
    && make \
    && make test \
    && make install

FROM ubuntu:18.04

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends \
locales \
libboost-all-dev \
zlib1g \
bzip2 

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ENV OPT /opt/local
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
