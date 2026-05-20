# Quantile normalization of BrdU-IP Repli-seq profiles

# In terminal
Here, we will combine RT data using bedtools
```
# example
# bedtools unionbedg -i 1.bg 2.bg 3.bg -header -names WT-1 WT-2 KO-1
```

### 1) Define the path that contains your RT data
```
raw="/Users/XXX/XXC"
out="/Users/XXX/XXC/QN"
outputname="XXXX_merge_RT.txt"
mkdir -p $out
mkdir -p $out/00_merged_RT
mkdir -p $out/01_QuantileNormalization
mkdir -p $out/02_QN_correlations
```

### 2) List your files (just copy the names of your files and paste as an example below)
```
list="B6_MEF_WT_male_mm9_1_IP_Aneu_rmdup_w200ks40k_Percent_q0.05.noX.bedGraph
CBMS1_EBD7_ST_mm9_2_IP_Aneu_rmdup_w200ks40k_Percent_q0.05.noX.bedGraph
CBMS1_mESC_ST_mm9_1_IP_Aneu_rmdup_w200ks40k_Percent_q0.05.noX.bedGraph"
```

### 3) Merge RT data
```
cd $raw
echo -e "chr\tstart\tstop\t"`echo $list | grep _` > $out/00_merged_RT/$outputname
#combine with bedGraph data
#for one data set: cat *.bedGraph >> merge_4C.txt
bedtools unionbedg -filler "NA" -i `echo $list` >> $out/00_merged_RT/$outputname
```


## Quantile normalization in R

### 1) Set working directory
```
# Load library
library(preprocessCore)
# Your directory
setwd("/Users/XXX/XXC/QN/01_QuantileNormalization")
```

### 2) Register the quantile-normalized data into bedGraph files by running the following commands:
```
merge<-read.table("/Users/XXX/XXC/QN/00_merged_RT/XXXX_merge_RT.txt" , header=TRUE)
merge_values<-as.matrix(merge[,4:ncol(merge)])
ad<-stack(merge[,4:ncol(merge)])$values
norm_data<-normalize.quantiles.use.target(merge_values,ad)
merge_norm<-data.frame(merge[,1:3],norm_data)
colnames(merge_norm)<-colnames(merge)

for(i in 4:ncol(merge_norm)){write.table( merge_norm[complete.cases(merge_norm[,i]), c(1,2,3,i)], gsub(".bedGraph" , ".qnorm.bedGraph", colnames(merge_norm)[i]), sep= "\t" ,row.names=FALSE, quote=FALSE, col.names = FALSE)}
```
Now you should get new bedGraph files, ended with ".qnorm.bedGraph".
These are quantile-normalized data.


### 3) Double check distribution of your data
```
boxplot(merge_norm[,4:ncol(merge_norm)])
boxplot(merge[,4:ncol(merge)])
```





