
# Modified from 220321_B6JF1_haplotype_RT_domain_classification_final_Rpart_update1.R

## Merge QN data
# List all bedGraph files in the folder
in_path="YOUR QN PATH"
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
mergeqnfile=paste0(in_path,"/","YOUR FILE NAME","merged_QN.txt")
write.table(merged_bedgraph, file = mergeqnfile, 
            sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = T)

# Read QN files
merged_qn_RT <- read.table(mergeqnfile , header=TRUE)
head(merged_qn_RT)
dim(merged_qn_RT) #confirm line number

# Remove rows with NA
merged_qn_RT_clean <- na.omit(merged_qn_RT)
head(merged_qn_RT_clean)
dim(merged_qn_RT_clean)


# Generate Average RT profiles from biological replicates
dfavr <- data.frame(merged_qn_RT_clean[,1:3])
head(dfavr)
dfavr$avr_WT <- rowMeans(merged_qn_RT_clean[,c('WT1', 'WT2')], na.rm=TRUE)
dfavr$avr_mutant <- rowMeans(merged_qn_RT_clean[,c('mutant1', 'mutant2','mutant3')], na.rm=TRUE)

# Export merged average data as txt file
mergeqnfile_avr=paste0(in_path,"/","YOUR FILE NAME","merged_QN_avr.txt")
write.table(merged_bedgraph, file = mergeqnfile, 
            sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = T)

# Export merged average data as bedGraph
for(i in 4:ncol(dfavr)){write.table(dfavr[complete.cases(dfavr[,i]), c(1,2,3,i)], file = paste0(in_path,"/",colnames(dfavr)[i],".bedGraph"), 
                                    sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = FALSE)}


# Find RT switching domains or RT states
library(dplyr)

# Get RT domains
dfavr <- dfavr %>% mutate(RT_domain =
                            case_when(avr_WT > 0 & avr_mutant < 0 & abs(avr_WT-avr_mutant) > 0.4 ~ "EtoL",
                                      avr_WT > 0 & avr_mutant > 0  ~ "EtoE",
                                      avr_WT < 0 & avr_mutant < 0  ~ "LtoL",
                                      avr_WT < 0 & avr_mutant > 0 & abs(avr_WT-avr_mutant) > 0.4 ~ "LtoE",
                                      TRUE ~ "n/a"),
                          RT_state =
                            case_when(avr_WT > 0 & avr_mutant < 0 & avr_WT < avr_mutant & abs(avr_WT-avr_mutant) > 0.4 ~ "switchEtoL",
                                      avr_WT > 0 & avr_mutant > 0 & avr_WT < avr_mutant & abs(avr_WT-avr_mutant) > 0.2 ~ "earlier",
                                      avr_WT < 0 & avr_mutant < 0 & avr_WT > avr_mutant & abs(avr_WT-avr_mutant) > 0.2 ~ "later",
                                      avr_WT < 0 & avr_mutant > 0 & avr_WT > avr_mutant & abs(avr_WT-avr_mutant) > 0.4 ~ "switchLtoE",
                                      TRUE ~ "n/a"))

head(dfavr)
dfavr_2 <- dfavr %>% mutate(color = case_when(RT_domain == "EtoL" ~ "255,0,255", 
                                              RT_domain == "EtoE" ~ "0,0,204",
                                              RT_domain == "LtoL" ~ "255,204,0",
                                              RT_domain == "LtoE" ~ "204,0,0",
                                              TRUE ~ "255,255,255"))
head(b6_allele_df_2)

dfavr_3 <- dfavr %>% mutate(color = case_when(RT_state == "switchEtoL" ~ "255,0,255", 
                                              RT_state == "earlier" ~ "0,0,204",
                                              RT_state == "later" ~ "255,204,0",
                                              RT_state == "switchLtoE" ~ "204,0,0",
                                              TRUE ~ "255,255,255"))
head(dfavr_3)

dfavr_2_bed <- data.frame(dfavr_2[,1:3], dfavr_3$RT_domain,"0","0",dfavr_2[,2:3],dfavr_2$color)
dfavr_3_bed <- data.frame(dfavr_3[,1:3], dfavr_3$RT_state,"0","0",dfavr_3[,2:3],dfavr_3$color)


# Export merged average data as txt file
mergeqnfile_avr_RTdomain=paste0(in_path,"/","YOUR FILE NAME","merged_QN_avr_IdentifyRTdomain.txt")
mergeqnfile_avr_RTstate=paste0(in_path,"/","YOUR FILE NAME","merged_QN_avr_IdentifyRTstate.txt")

write.table(dfavr_2_bed, file = mergeqnfile_avr_RTdomain, sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = T)
write.table(dfavr_3_bed, file = mergeqnfile_avr_RTstate, sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = T)

# Done

