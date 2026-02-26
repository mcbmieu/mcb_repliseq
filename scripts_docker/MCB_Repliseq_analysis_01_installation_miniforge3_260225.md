# MCB Repli-seq analysis: (1.2) Program Installation for newer macs that can run docker
**Date:** 2026-02-25  
**Source:** Adapted from Miura et al. (2020)   
**Main installations:**
- Miniforge → manages Python and conda packages
- Homebrew → system package manager
- Docker → runs R and pipeline scripts in a consistent environment

---
**Example:**
(1) MacBook Pro 2019 with Intel chip (2.8 GHz Quad-Core Intel Core i7): macOS Ventura 13.5.2 Memory 16GB
(2) MacBook Pro 2023 with Apple M2 Max chip: macOS Ventura 13.2.1 Memory 96 GB

## 1. Install Miniforge

The original scRepli-seq pipeline used Miniconda2, which is hard to manage on modern Macs. 
We alternatively use Miniforge.

Follow instructions for your system:  
- https://conda-forge.org/
- https://github.com/conda-forge/miniforge

In our case, we downloaded and install `Miniforge3-Darwin-x86_64.sh` from https://conda-forge.org/download/ as follow:


```bash
# 1. Go to home directory
cd

# 2. Make folder for Miniforge3
mkdir -p ~/miniforge3
cd ~/miniforge3

# 3. Download compatible miniforge from https://conda-forge.org/download/
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

# In our case: 
# MD5 (Miniforge3-Darwin-x86_64.sh) = 00f112fe19207cbec0297ee0b6fa51c6 # for MacBook Pro 2019 with Intel chip
# MD5 (Miniforge3-Darwin-arm64.sh) = 7c59e2e520813fa2d4bcdefe2ad7bc03 # for MacBook Pro 2023 with Apple M2 Max chip

# 4. Install
# For intel mac
bash Miniforge3-Darwin-x86_64.sh

# For M-chip mac
bash Miniforge3-Darwin-arm64.sh

# 5. Check conda version
conda -V
# conda 26.1.0

# 6. Configure channels
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# 7. Close and reopen your terminal for changes to take effect.

# 8. Initialize conda in all shells [optional]
conda init --all

# 9. Close and reopen your terminal for changes to take effect.
```
---

## 2. Create Conda Environment & Install Packages
Here, we create an environment named `mcbrepliseq` and install conda packages inside the enviroment
```bash
# 1. Create the environment named `mcbrepliseq`
conda create -y -n mcbrepliseq
conda activate mcbrepliseq

# 2. Install conda packages
conda install \
bwa=0.7.19 \
samtools=1.23 \
fastqc=0.12.1 \
cutadapt=5.2 \
seqtk=1.5 \
picard=2.27.5 \
bedtools=2.31.1 \
trim-galore=0.6.10
```

To avoid disrupting `mcbrepliseq` environment, we installed SRA-tools in a separate enviroment.

```bash
# 1. Create the environment named `sratools`
conda create -y -n sratools
conda activate sratools

# 2. Install sra-tools using mamba
mamba install bioconda::sra-tools
```

---

## 3. Install Homebrew
Follow directions from the following website according to your system and chip architecture https://brew.sh/

```bash
# 1. Go to home directory
cd
    
# 2. Download and install the lastest homebrew: 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install wget (if needed)*
brew install wget
```

----



## 4. Install Docker
Follow directions from the following website according to your system and chip architecture.
Here, we followed: https://docs.docker.com/desktop/setup/install/mac-install/

----

## 5. Create Docker image


```bash

# 1. Create folders
mkdir -p ~/Programs
mkdir -p ~/Programs/repliseq_pipelines

# 2. Download pipeline repository
cd ~/Programs/repliseq_pipelines
git clone https://github.com/mcbmieu/mcb_repliseq.git
cd mcb_repliseq/
cd Docker

# 3. Build image (Intel or M-series Mac)
docker build --platform linux/amd64 --progress=plain -t mcbrepliseq:v1 . 2>&1 | tee build_log.txt
   
# ---- Test the image ----
docker run --platform linux/amd64 -it mcbrepliseq:v1 R --version
```

The following messeges should be appeared
```
R version 3.4.4 (2018-03-15) -- "Someone to Lean On"
Copyright (C) 2018 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)
```
     
