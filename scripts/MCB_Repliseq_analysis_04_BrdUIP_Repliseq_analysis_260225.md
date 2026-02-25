# MCB Repli-seq analysis: (4) BrdU-IP E/L Repli-seq Processing Pipeline
**Date:** 2026-02-25   
**Source:** Adapted from Miura et al. (2020)     
**Environment:** `mcbrepliseq` (Conda) + `mcbrepliseq:v1` (Docker)

---

## 1. Environment & Data Acquisition
First, we activate the environment and download the example mESC dataset from SRA.

```bash
# Activate environment
conda activate mcbrepliseq
```

## 2. Generate directory for results
This ensures all output subdirectories are ready before the loops begin.

```bash
# Specify where to export your results
result_dir="~/Documents/result_dir"

# Copy and paste
mkdir -p ${result_dir}/{fastqc,trim_fastq,bam,BrdUIP}
```

## 3. Prepare fastq data
### [Option 1] If using example data

```bash
# Access fastq Directory
cd ${result_dir}/fastq

# Download example data: WT JB4 mESCs Early (SRR21125046) and Late (SRR21125045) Rep1
fasterq-dump --progress SRR21125046
fasterq-dump --progress SRR21125045

# Verify read counts
for file in *.fastq; do
    echo -n "$file: "
    echo "$(cat "$file" | wc -l) / 4" | bc
done

# Compress files
gzip *.fastq
```
### [Option 2] If using your own data, copy and paste them to `fastq` folder

```bash
#[source_directory]: The full path to the folder you want to copy
cp -r $source_directory ${result_dir}/fastq
```

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
    echo "Processing sample: $prefix"

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
We align to the reference genome using BWA, then clean and mark duplicates using Picard.

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

## 6. Repli-seq Analysis via Docker
We use a Docker container to run `AneuFinder v1.2.1` and calculate replication timing.
```bash
# Docker mount
docker_version="mcbrepliseq:v1"
data=/data
ref=/ref
black=/black

# Here you have to set your own parameters
# Configuration Paths
reference_dir="~/Documents/references/mm9" # Location of genome reference files
chrsize="mm9.chrom.sizes.clean.sort" # Name of Chromosome Size File 

blacklist_dir="~/Documents/references/blacklist" # Location of the blacklist file
blacklist="mm9-blacklist-v1_id.bed" # Name of blacklist file


# Analysis Parameters
bam_E="SRR21125046.adapter_filtered2.mm9.clean_srt_markdup.bam" # Early-S data
bam_L="SRR21125045.adapter_filtered2.mm9.clean_srt_markdup.bam" # Late-S data
name="JB4mESCs_rep1"
window=200000
sliding=40000

# Execute Docker Analysis
bam_dir=${result_dir}/bam
docker run --rm -it \
    --platform linux/amd64 \
    -v ${result_dir}:${data}:rw \
    -v ${reference_dir}:${ref}:ro \
    -v ${blacklist_dir}:${black}:ro \
    ${docker_version} \
    Rscript --vanilla \
        util/mcb_BrdUIP_Repliseq_from_bam_input.r \
        ${data}/bam/${bam_E} \
        ${data}/bam/${bam_L} \
        ${name} \
        ${data}/BrdUIP \
        ${black}/${blacklist} \
        ${ref}/${chrsize} \
        ${window} \
        ${sliding}
echo "Pipeline finished successfully for $name"
```

Now you should get RT profiles as bedGraph file.
Open to check the file in IGV.

---
