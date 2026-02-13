# MCB Repli-seq Data Analysis Pipeline
This repository contains a suite of scripts for the processing and analysis of Repli-seq data. The workflow is adapted and modified from the protocols established by Miura et al., Nature Protocols 2020.

Original Source: [kuzobuta/scRepliseq-Pipeline](https://github.com/kuzobuta/scRepliseq-Pipeline)

These scripts are designed for scRepli-seq and BrdU-IP Repli-seq libraries prepared via SEQXE-WGA and NGS, as described in:

- Takahashi et al., Nature Genetics 2019
- Miura et al., Nature Protocols 2020

## Key modification points
This version introduces the following updates:

1. Environment: Uses Miniconda3 for easier installation of genomic tools in new Mac
2. Containerization: Uses Docker only to run AneuFinder v1.2.1 to resolve R dependency conflicts


