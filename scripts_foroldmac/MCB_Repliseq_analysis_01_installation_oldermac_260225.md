# MCB Repli-seq analysis: (1) Program Installation for old mac (intel)
**Date:** 2026-02-25  
**Source:** Adapted from Miura et al. (2020)  
**Main installations:**
- Miniforge → manages Python and conda packages
- R 3.3.3 → runs R and pipeline scripts in a consistent environment

---
**Example: Mac Pro (Mid 2010)**  
macOS High Sierra Version 10.13.6  
Processor 2x2.93 GHz 6-core Itel Xeon  
Memory 64 GB 1333 MHz DDR3

## 1. Install Miniforge

Since new programs do not support the old macOS, we alternatively use Miniforge.

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
# MD5 (Miniforge3-Darwin-x86_64.sh) = 00f112fe19207cbec0297ee0b6fa51c6

# 4. Install
bash Miniforge3-Darwin-x86_64.sh

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

## 2. Create Conda Environment for Repli-seq analysis & Install Packages
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
---

## 3. Create Conda Environment for SRA-tools & Install Packages
To avoid disrupting `mcbrepliseq` environment, we installed SRA-tools in a separate enviroment.

```bash
# 1. Create environment
conda create -y -n sratools
conda activate sratools

# 2. Install sra-tools using mamba
mamba install bioconda::sra-tools

# 3. Test version, by running the following command
conda list sra-tools

# The following should appear
# Name                     Version          Build            Channel
#sra-tools                  3.2.1            h5fa12a8_1       bioconda


# 4. Test that the toolkit is functional (following https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit):
fastq-dump --stdout -X 2 SRR390728

#Within a few seconds, the command should produce this exact output (and nothing else):
#Read 2 spots for SRR390728
#Written 2 spots for SRR390728
#@SRR390728.1 1 length=72
#CATTCTTCACGTAGTTCTCGAGCCTTGGTTTTCAGCGATGGAGAATGACTTTGACAAGCTGAGAGAAGNTNC
#+SRR390728.1 1 length=72
#;;;;;;;;;;;;;;;;;;;;;;;;;;;9;;665142;;;;;;;;;;;;;;;;;;;;;;;;;;;;;96&&&&(
#@SRR390728.2 2 length=72
#AAGTAGGTCTCGTCTGTGTTTTCTACGAGCTTGTGTTCCAGCTGACCCACTCCCTGGGTGGGGGGACTGGGT
#+SRR390728.2 2 length=72
#;;;;;;;;;;;;;;;;;4;;;;3;393.1+4&&5&&;;;;;;;;;;;;;;;;;;;;;<9;<;;;;;464262
```
---

## 4. Install R 
Follow directions from the following website according to your system and chip architecture 
`https://cran.r-project.org/`

In our case, we download `R-3.3.3.pkg` from https://cran.r-project.org/bin/macosx/  
`MD5-hash: 893ba010f303e666e19f86e4800f1fbf`


## 5. Install R Packages and AneuFinder v1.2.1 in R (manually)
```bash
# 1. Open R in terminal
R

# The following messeges should appear
# R version 3.3.3 (2017-03-06) -- "Another Canoe"

# 2. Install BiocInstaller version 3.4
install.packages("BiocInstaller", repos="http://bioconductor.org/packages/3.4/bioc")
library(BiocInstaller)
    
# 3. Install the following packages and its dependencies manually
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/ggplot2_2.2.1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/munsell_0.4.3.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/scales_0.5.0.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/gtable_0.2.0.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/Rcpp_0.12.14.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/Rcpp_0.12.14.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/colorspace_1.3-2.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/Rcpp_0.12.14.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/plyr_1.8.4.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/lazyeval_0.2.1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/tibble_1.3.4.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/rlang_0.1.6.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/ReorderCluster_1.0.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/gplots_3.0.1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/bitops_1.0-6.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/cowplot_0.9.2.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/caTools_1.17.1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/ggdendro_0.1-20.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/stringr_1.2.0.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/withr_2.1.1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/reshape2_1.4.3.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/ggrepel_0.7.0.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/mclust_5.4.tgz", type = "source", dependencies = T, repos = NULL)

# 4. Install AneuFinder v1.2.1 and its dependencies manually
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/pracma_2.1.1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/optparse_1.4.4.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/XML_3.98-1.9.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/zoo_1.8-1.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/stringi_1.1.6.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/magrittr_1.5.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/gtools_3.5.0.tgz", type = "source", dependencies = T, repos = NULL)
install.packages("https://cran-archive.r-project.org/bin/macosx/mavericks/contrib/3.3/gdata_2.18.0.tgz", type = "source", dependencies = T, repos = NULL)
biocLite("AneuFinder")


# 5. Test if AneuFinder is installed properly
library(AneuFinder)
```
----

## 6. Download Rscipts from mcb_git

```bash
# 1. Create folders
mkdir -p ~/Programs
mkdir -p ~/Programs/repliseq_pipelines

# 2. Download pipeline repository
cd ~/Programs/repliseq_pipelines
git clone https://github.com/mcbmieu/mcb_repliseq.git
```


     
