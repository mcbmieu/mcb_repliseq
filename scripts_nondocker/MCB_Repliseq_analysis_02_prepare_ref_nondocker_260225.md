# MCB Repli-seq analysis: (2) Prepare Reference Genome and Blacklist
**Date:** 2026-02-25  
**Source:** Adapted from Miura et al. (2020)
**Main tasks:**
- Prepare reference genome → Here, example is for mm9
- Prepare blacklist → Here, example is for mm9

---
**Example: Mac Pro (Mid 2010)**  
macOS High Sierra Version 10.13.6  
Processor 2x2.93 GHz 6-core Itel Xeon  
Memory 64 GB 1333 MHz DDR3

## 1. Prepare Reference Genome

```bash
# 1. Create folders
reference_dir=~/reference_dir
mkdir -p $reference_dir
mkdir -p $reference_dir/mm9
mkdir -p $reference_dir/blacklist

# 2. Download reference genome
cd $reference_dir/mm9
curl -L -O https://hgdownload.cse.ucsc.edu/goldenPath/mm9/bigZips/mm9.fa.gz

# 3. Generate BWA index (this step may take a long time)
bwa index -6 mm9.fa.gz
gzip -dc mm9.fa.gz > mm9.fa
samtools faidx mm9.fa
```

Other useful genome paths

`https://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz`
`https://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz`
`https://hgdownload.cse.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz`

---

## 2. Prepare Chromosome Size File

```bash
# 1. Download chromosome size from UCSC
curl -L -O https://hgdownload.cse.ucsc.edu/goldenpath/mm9/bigZips/mm9.chrom.sizes

# 2. Sort chromosomes and remove unneccesary ones [optional]
grep -v -e "_" -e "M" mm9.chrom.sizes | sort -V -k1,1 > mm9.chrom.sizes.clean.sort
```

---

## 3. Prepare blacklist
Download desired blacklists from the following sites:
`https://github.com/Boyle-Lab/Blacklist/tree/master/lists`

```bash
# 1. Example file location and content:
head $reference_dir/blacklist/mm9-blacklist.bed

chr1	3128700	3129800
chr1	12633900	12635800
chr1	12949000	12950000
chr1	14949500	14950600
chr1	24617600	24623800
chr1	24863800	24865700

# 2. Adjust format of blacklist to compatible with AneuFinder v1.2.1
# ---- Change column 4 information to id ----
bl=$reference_dir/blacklist/mm9-blacklist.bed
awk 'BEGIN {OFS="\t"} {print $1, $2, $3, NR, "1000", "."}' $bl > ${bl%.*}-v1_id.bed

# 3. Check the converted file
head $reference_dir/blacklist/mm9-blacklist-v1_id.bed

chr1	3128700	3129800	1	1000	.
chr1	12633900	12635800	2	1000	.
chr1	12949000	12950000	3	1000	.
chr1	14949500	14950600	4	1000	.
chr1	24617600	24623800	5	1000	.
chr1	24863800	24865700	6	1000	.
```

---

## Notes

- Always ensure the genome version matches your experiment (hg19, hg38, mm10, etc.).

- Keep all reference files in the same directory structure for reproducibility.

- Indexing the genome may take significant time and disk space.

- The converted blacklist file must be used for AneuFinder v1.2.1.
