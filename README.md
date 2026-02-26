# MCB Repli-seq Data Analysis Pipeline
This repository contains a set of scripts for the processing and analysis of Repli-seq data. The workflow is adapted and modified from the protocols established by Miura et al., Nature Protocols 2020.

Original Source: [kuzobuta/scRepliseq-Pipeline](https://github.com/kuzobuta/scRepliseq-Pipeline)

These scripts are designed for scRepli-seq and BrdU-IP Repli-seq libraries prepared via SEQXE-WGA and NGS, as described in:

- Takahashi et al., Nature Genetics 2019
- Miura et al., Nature Protocols 2020

## Key modification points
This version introduces the following updates:

### 1. Environment management  
Uses Miniforge for simplified installation and management of genomic analysis tools.

### 2. Containerization (Docker support)
On macOS systems that support Docker, AneuFinder v1.2.1 is executed within a Docker container to resolve R dependency conflicts.

### 3. Local R (non-Docker systems)  
For macOS systems that cannot run Docker, an older compatible version of R and required packages are installed locally to support AneuFinder v1.2.1.

