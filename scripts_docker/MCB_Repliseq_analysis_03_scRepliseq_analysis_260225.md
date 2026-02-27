# MCB Repli-seq analysis: (3) scRepli-seq Processing Pipeline
**Date:** 2026-02-25   
**Source:** Adapted from Miura et al. (2020)     
**Environment:** `mcbrepliseq` (Conda) + `mcbrepliseq:v1` (Docker)

This guide details the workflow for analyzing scRepli-seq data, from raw FASTQ files to binarized replication profiles.

---

## 1. Prepare Directory Structure
First, we activate the environment and download the example mESC dataset from SRA.

```bash
# 1. Define your base results directory
result_dir="~/Documents/result_dir"

# 2. Create the full directory tree at once
mkdir -p $result_dir/{fastq,fastqc,trim_fastq,bam,logs}
mkdir -p $result_dir/Aneu_analysis/{MAD_score,Log2_Med,bins,fragment,G1_control}
mkdir -p $result_dir/Aneu_analysis/HMM/{1-somy/{Rdata,binary,plot},2-somy/{Rdata,binary,plot},repliscores}
```

---

## 2. Data and Enviroment Preparation
- Move your raw `.fastq.gz` files into ${result_dir}/fastq

- Note: If your files use a different extension (e.g., .fq.gz), update scripts as neccessary

- If needed, below are the example mouse neural stem cell scRepli-seq dataset from SRA.

    ```bash
    # Activate sratools environment
    conda activate sratools
    
    # WT JB4/EI7HZ2 NSCs G1 cells: 001,002,003,004
    fasterq-dump --progress SRR21129217   
    fasterq-dump --progress SRR21129216
    fasterq-dump --progress SRR21129215
    fasterq-dump --progress SRR21129214

    # WT JB4/EI7HZ2 NSCs S cells: S 030, S 031
    fasterq-dump --progress SRR21129167
    fasterq-dump --progress SRR21129168

    # Count reads per file
    for file in *.fastq; do
        echo -n "$file: "
        echo "$(cat "$file" | wc -l) / 4" | bc
    done

    # Output
    SRR21129167.fastq.gz: 3328320
    SRR21129168.fastq.gz: 3396396
    SRR21129214.fastq.gz: 3681502
    SRR21129215.fastq.gz: 3404804
    SRR21129216.fastq.gz: 4450316
    SRR21129217.fastq.gz: 3659944

    # gz these files
    gzip *.fastq
    ```
    
## Before running the next step, activate `mcbrepliseq` environment

```bash
conda activate mcbrepliseq
```

---

## 3. Check fastq files using `fastqc`

```bash
fastqc $result_dir/fastq/*.fastq.gz -o $result_dir/fastqc/
```
---
## 4. Adapter Removal & SEQXE Filtering
We use `trim_galore` for standard adapters, followed by `cutadapt` to remove specific SEQXE sequences.

```bash
# 1. Set paths
fastq_dir="${result_dir}/fastq"
trim_dir="${result_dir}/trim_fastq"

# 2. Loop through the files
SEQXE_SEQ="TGGTGTGTTGGGTGTGTTTCTGAAGNNNNNNNNN"

for file in ${fastq_dir}/*.fastq.gz; do
    #prefix=$(basename "$file" .fastq.gz)
    prefix=`basename $file`
    prefix=${prefix%.*fastq.gz}
    #echo "Processing sample: $prefix"

    # Step 1: Trim Illumina adapters
    trim_galore --cores 4 --phred33 -q 30 --length 30 -o "${trim_dir}" --illumina "$file"

    # Step 2: Cut SEQXE sequences
    in_trim="${trim_dir}/${prefix}_trimmed.fq.gz"
    out_final="${trim_dir}/${prefix}.adapter_filtered2.fastq.gz"
    
    cutadapt --cores 4 -b "${SEQXE_SEQ}" -e 0.09 -O 19 -m 30 \
        -o "${out_final}" "${in_trim}" > "${out_final}.report.txt"
    
    # Step 3: Remove intermediate file to save space
    rm "${in_trim}"
done
```

## 5. Alignment and BAM Processing
We align to the reference genome using `bwa`, then clean and mark duplicates using `Picard`.

```bash
# 1. Set paths
index="~/Documents/references/mm9/mm9.fa.gz"
genome="mm9"
THREAD=4

# 2. Loop through the files
for fq in ${result_dir}/trim_fastq/*.adapter_filtered2.fastq.gz; do
    #prefix=$(basename "$fq" .adapter_filtered2.fastq.gz)
    prefix=`basename $fq`
    prefix=${prefix%.*fastq.gz}
    out_prefix="${result_dir}/bam/${prefix}"
    
    # Step 1: BWA Alignment
    bwa aln -t ${THREAD} ${index} ${fq} | \
    bwa samse ${index} - ${fq} | \
    samtools view -Sb - > "${out_prefix}.${genome}.bam"

    # Step 2: Picard: Clean and Sort
    picard CleanSam -I "${out_prefix}.${genome}.bam" -O "${out_prefix}.clean.bam"
    samtools sort -@ ${THREAD} "${out_prefix}.clean.bam" -o "${out_prefix}.sorted.bam"
    
    # Step 3: Picard: Mark Duplicates
    picard MarkDuplicates \
        -I "${out_prefix}.sorted.bam" \
        -O "${out_prefix}.${genome}.clean_srt_markdup.bam" \
        -METRICS_FILE "${out_prefix}.markdup_metrics.txt" \
        -REMOVE_DUPLICATES false

    samtools index "${out_prefix}.${genome}.clean_srt_markdup.bam"
    
    # Step 4: Clean up temp files
    rm "${out_prefix}.clean.bam" "${out_prefix}.sorted.bam"

    # Step 5: Quality control of the mapped reads by SAMStat
    samstat "${out_prefix}.${genome}.clean_srt_markdup.bam"
done
```


## 6. Load mapped reads and stored in Rdata format by AneuFinder v1.2.1

Here we will use docker image. This script will generate Rdata files saved in
-`${result_dir}/Aneu_analysis/bins` 
-`${result_dir}/Aneu_analysis/fragment`

```bash
# 1. Set paths
reference_dir="~/Documents/references/mm9" # Location of genome reference files
chrsize="mm9.chrom.sizes.clean.sort" # Name of Chromosome Size File 
blacklist_dir="~/Documents/references/blacklist" # Location of the blacklist file 
blacklist="mm9-blacklist-v1_id.bed" # Name of blacklist file


# 2. Define Mount Points for Docker
docker_version=mcbrepliseq:v1
data=/data
ref=/ref
black=/black
    
# 3. Check if mounting is OK? [Optional]
docker run --rm -it \
    --platform linux/amd64 \
    -v ${result_dir}:${data}:rw \
    -v ${reference_dir}:${ref}:ro \
    -v ${blacklist_dir}:${black}:ro \
    ${docker_version} \
    ls ${data}/bam

# 4. Run R script inside container
# Loop within the container
bam_dir=${result_dir}/bam
for bamfile in "${bam_dir}"/*.clean_srt_markdup.bam; do
    file=`basename $bamfile`
    prefix=`basename $bamfile`
    name=${prefix%.bam}

    docker run --rm -it \
        --platform linux/amd64 \
        -v ${result_dir}:${data}:rw \
        -v ${reference_dir}:${ref}:ro \
        -v ${blacklist_dir}:${black}:ro \
        ${docker_version} \
        Rscript --vanilla \
            util/Step3_R-Aneu-Fragment-bins.R \
            ${data}/bam/${file} \
            ${data}/Aneu_analysis \
            ${name} \
            ${black}/${blacklist} \
            ${ref}/${chrsize}
done
```

---

## 7. Calculate MAD scores
Here we will use docker image. This script will generate a txt file saved in
-`${result_dir}/Aneu_analysis/MAD_score` 

```bash
# 1. Specify the name of this analysis
# output name ([out_name]_MAD_scores_log2.txt) ----
out_name="JB4_mNSC"   

# 2. Run R script inside container
docker run --rm -it \
    --platform linux/amd64 \
    -v ${result_dir}:${data}:rw \
    ${docker_version} \
    Rscript --vanilla \
        util/Step4_R_MAD_score.R \
        ${data}/Aneu_analysis/bins \
        ${data}/Aneu_analysis/MAD_score \
        $out_name
```

---

## 8. Check karyotype of G1 cells
Here we will use docker image. This script will generate Rdata and pdf files saved in
-`${result_dir}/Aneu_analysis/G1_control` 

```bash
# 1. Specify the file corresponding to G1 cells.
# These files are stored in `${result_dir}/Aneu_analysis/bins` folder
# ---- List of G1 files ----
list="SRR21129214.mm9.clean_srt_markdup_mapq10_blacklist_bin.Rdata
SRR21129215.mm9.clean_srt_markdup_mapq10_blacklist_bin.Rdata
SRR21129216.mm9.clean_srt_markdup_mapq10_blacklist_bin.Rdata
SRR21129217.mm9.clean_srt_markdup_mapq10_blacklist_bin.Rdata"

# 2. Run R script inside container
bins_data_dir=${main_dir}/${in_dir}/Aneu_analysis/bins
for G1 in $list; do
    prefix=`basename $G1`
    name=${prefix%.Rdata}
    
    docker run --rm -it \
        --platform linux/amd64 \
        -v ${result_dir}:${data}:rw \
        ${docker_version} \
        Rscript --vanilla \
            util/Step5_R_G1_karyotype.R \
            ${data}/Aneu_analysis/bins/${G1} \
            ${data}/Aneu_analysis/G1_control

done
```

---


## 9. Merged G1 cells that show good karyotypes
Here we will use docker image. This script will generate a Rdata file and saved in
-`${result_dir}/Aneu_analysis/G1_control` 

```bash
# 1. Specify the selected G1 cells.
# These files are stored in `${result_dir}/Aneu_analysis/fragment` folder
# ---- List of selected G1 files [use files in fragment folder]----
list_merge="SRR21129214.mm9.clean_srt_markdup_mapq10_blacklist_fragment.Rdata
SRR21129215.mm9.clean_srt_markdup_mapq10_blacklist_fragment.Rdata
SRR21129216.mm9.clean_srt_markdup_mapq10_blacklist_fragment.Rdata
SRR21129217.mm9.clean_srt_markdup_mapq10_blacklist_fragment.Rdata"

# 2. Run following commands to make the above list as array for the next step
# Initialize an empty array and Fill the array using +=
list_files=()
for files in $list_merge; do
    list_files+=("${data}/Aneu_analysis/fragment/$files")
done
echo ${list_files[@]}

# 3. Run R script inside container
docker run --rm -it \
    --platform linux/amd64 \
    -v ${result_dir}:${data}:rw \
    ${docker_version} \
    Rscript --vanilla \
        util/Merge_fragment_Rdata.R \
        ${list_files[@]} \
        -o ${data}/Aneu_analysis/G1_control/Merge_data.Rdata
```
---

## 10. Compute log2median replication timing scores
Here we will use docker image. This script will generate bedGraph files and saved in
-`${result_dir}/Aneu_analysis/Log2_Med` 

```bash
# 1. Run R script inside container
fragment_dir=${result_dir}/Aneu_analysis/fragment

# loop inside container
for fragmentfile in "${fragment_dir}"/*.Rdata; do
    file=`basename $fragmentfile`
    prefix=`basename $fragmentfile`
    name=${prefix%.bam}

    docker run --rm -it \
        --platform linux/amd64 \
        -v ${result_dir}:${data}:rw \
        -v ${reference_dir}:${ref}:ro \
        ${docker_version} \
        Rscript --vanilla \
            util/Step6_R_log2_median_RT_scores.R \
            ${data}/Aneu_analysis/fragment/${file} \
            ${data}/Aneu_analysis/Log2_Med \
            ${data}/Aneu_analysis/G1_control/Merge_data.Rdata \
            ${black}/${blacklist} \
            ${ref}/${chrsize}

done
```
---

## 11. Binarization
Here we will use docker image. This script will generate bedGraph files and saved in
-`${result_dir}/Aneu_analysis/HMM` depending on mode you selected

```bash
# 1. Specify the selected bin size and somy you want to analyze
## bin size (normally 80000 (80kb))
binsize=100000 

# 2. Specify somy mode (2-somy or 1-somy) ----
## For mid-S sample, default: 2-somy.
## For others, try 1-somy
somy="2-somy" 

# 2. Run R script inside container
bin_dir=${result_dir}/Aneu_analysis/bins
for binfile in "${bin_dir}"/*.Rdata; do
    file=`basename $binfile`
    prefix=`basename $binfile`
    name=${prefix}

    docker run --rm -it \
        --platform linux/amd64 \
        -v ${result_dir}:${data}:rw \
        -v ${reference_dir}:${ref}:ro \
        ${docker_version} \
        Rscript --vanilla \
            util/Step7_R_Binarization.R \
            ${data}/Aneu_analysis/bins/${file} \
            ${data}/Aneu_analysis/HMM/${somy} \
            ${data}/Aneu_analysis/G1_control/Merge_data.Rdata \
            ${ref}/${chrsize} \
            $binsize \
            $somy
        
done
```
---


