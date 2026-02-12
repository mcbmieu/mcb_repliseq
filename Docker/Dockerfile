FROM ubuntu:16.04
## Modified from https://github.com/kuzobuta/scRepliseq-Pipeline

RUN apt update -y && DEBIAN_FRONTEND=noninteractive apt install -y \
    apt-utils \
    bzip2 \
    gcc \
    git \
    less \
    dialog \
    libncurses-dev \
    make \
    time \
    unzip \
    vim \
    wget \
    zlib1g-dev \
    software-properties-common \
    apt-transport-https \
    language-pack-en \
    libxml2-dev \
    autoconf

RUN apt update -y && apt install -y \
    libcurl4-gnutls-dev \
    libssl-dev

##Install R version 3.4.4 (2018-03-15) -- "Someone to Lean On"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial/'
RUN apt update -y && apt install -y r-base=3.4.4-1xenial0

##Install "AneuFinder_1.2.1"
# Use a specific date-based snapshot for R 3.4.4 compatibility

RUN R -e 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2019-01-01")); \
    install.packages("BiocInstaller", repos="http://bioconductor.org/packages/3.4/bioc"); \
    BiocInstaller::biocLite(c("AneuFinder", "ReorderCluster"), ask=FALSE)'

RUN R -e 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2019-01-01")); \
    install.packages("pracma")'

RUN R -e 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2019-01-01")); \
    install.packages("optparse")'
    

WORKDIR /usr/local/bin

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN mkdir -p util
COPY util/ util/

#ENV PATH=/usr/local/bin/scripts/:$PATH
#RUN chmod +x util/*.sh
