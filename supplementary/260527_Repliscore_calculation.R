# ==============================================================================
# Script Name: DNA replication score (Repliscore) analysis
# Author:      Rawin Poonperm
# Date:        2026-05-27
# Version:     260527
#
# Description:
# Calculate replicated and unreplicated bins in scRepli-seq data
#
# Original Author: Hisashi Miura <hisashi.miura[at]riken.jp>
# Original Version: ?
# ==============================================================================

# Load library
library(data.table)

## (1) Calculate replication scores (Repliscore)

## Merge Binarized data
# List all bedGraph files in the folder
in_path="YOUR FOLDER CONTAINING DATA"
out_path="YOUR RESULT's FOLDER"

# Load data
files <- list.files(path = in_path, pattern = "\\.bedGraph", full.names = TRUE)

# Function to read each bedGraph file
read_bedGraph <- function(file) {
  dt <- fread(file, header = FALSE)
  # Name the columns: chrom, start, end, value
  setnames(dt, c("chrom", "start", "end", basename(file)))
  return(dt)
}

# Read all files into a list
bed_list <- lapply(files, read_bedGraph)

# Merge all files by the first 3 columns
merged_bedgraph <- Reduce(function(x, y) merge(x, y, by = c("chrom", "start", "end"), all = TRUE), bed_list)

# Export a merge file
mergebg=paste0(out_path,"/","merged_binary.txt")
write.table(merged_bedgraph, file = mergebg, 
            sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = T)

## Define functions

# Calculate Repliscore:
# proportion of bins with value = 1 among non-zero bins
repscore <- function(x) {
  sum(x == 1) / sum(x != 0)
}

# Count zero-value bins
count_zero_bins <- function(x) {
  sum(x == 0)
}

# Calculate Repliscore excluding chrX and chrY
cal_repli_woXY <- function(x) {
  
  # Remove sex chromosomes
  data <- x[x$chrom != "chrX" & x$chrom != "chrY", ]
  
  # Calculate Repliscore
  repscores_woXY <- apply(
    data[, 4:ncol(data)],
    2,
    repscore
  )
  
  # Rank samples by Repliscore
  repscores_rank <- repscores_woXY[order(repscores_woXY)]
  
  # Sort columns according to Repliscore ranking
  sorted_cols <- c(1:3, order(repscores_woXY) + 3)
  repscores_sorted <- data[, sorted_cols]
  
  # Output
  out <- list()
  out[["Repliscore"]] <- repscores_woXY
  out[["rank_by_score"]] <- repscores_rank
  out[["sorted_data"]] <- repscores_sorted
  
  return(out)
}


# Run the functions
merged_bedgraph_df <- as.data.frame(merged_bedgraph)
cal_repli_woXY_df <- cal_repli_woXY(merged_bedgraph_df)
repscore_all <- data.frame(cbind(Repliscore = cal_repli_woXY_df$Repliscore))
repscore_all_srt <- data.frame(cbind(Repliscore = cal_repli_woXY_df$rank_by_score))


# Export data
mergerepliscore=paste0(out_path,"/","merged_Repliscore.txt")
write.table(repscore_all, file = mergerepliscore, sep= "\t", row.names=T, quote=FALSE, col.names = T)

mergerepliscore_srt=paste0(out_path,"/","merged_Repliscore_sort.txt")
write.table(repscore_all_srt, file = mergerepliscore_srt, sep= "\t" ,row.names=T, quote=FALSE, col.names = T)

mergerepliscore_srt_df <- cal_repli_woXY_df$sorted_data
bedGraph_Repliscore_sort_dir <- paste0(out_path,"/","bedGraph_Repliscore_sort")
dir.create(bedGraph_Repliscore_sort_dir, recursive = T)
for(i in 4:ncol(mergerepliscore_srt_df)){
  
  outfile <- file.path(bedGraph_Repliscore_sort_dir,
    paste0(sprintf("%03d", i-3), "_", colnames(mergerepliscore_srt_df)[i]))
  
  write.table(mergerepliscore_srt_df[complete.cases(mergerepliscore_srt_df[, i]),c(1,2,3,i)],
    outfile,sep = "\t",row.names = FALSE,quote = FALSE, col.names = FALSE)
}
