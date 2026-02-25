# MCB Repli-seq analysis: (1.1) Program Installation for newer mac that can run docker
**Date:** 2026-02-16  
**Source:** Adapted from Miura et al. (2020)   
**Main installations:**
- Miniconda3 → manages Python and conda packages
- Homebrew → system package manager
- Docker → runs R and pipeline scripts in a consistent environment

---
**Example: MacBook Pro 2023 with Apple M2 Max chip**  
macOS Ventura 13.2.1
Memory 96 GB

## 1. Install Miniconda3

The original scRepli-seq pipeline used Miniconda2, which is hard to install on modern Macs. We now use Miniconda3 for easier installation.

Follow instructions for your system:
https://www.anaconda.com/docs/getting-started/miniconda/install



```bash
# 1. Go to home directory
cd

# 2. Make folder for Miniconda3
mkdir -p ~/miniconda3

# 3. Download Miniconda installer
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh

# 4. Install
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3

# 5. Accept conda terms
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# 6. Configure channels
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# 7. Close and reopen your terminal for changes to take effect.

# 8. Initialize conda in all shells
conda init --all

# 9. Close and reopen your terminal for changes to take effect.
```
---

## 2. Create Conda Environment & Install Packages
Here, we create an environment named `mcbrepliseq` and install conda packages inside the enviroment
```bash

# 1. Create the environment named `mcbrepliseq`
conda create -y -n mcbrepliseq

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

R 3.4.4 version should appear
     
