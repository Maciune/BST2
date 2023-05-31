#!/bin/bash

DIR="/home/bioinformatikai/HW2"
threads=6
for i in  ${DIR}/raw/*1.fastq.gz;
do
    R1=${i};
    R2="${DIR}/raw/"$(basename ${i} _1.fastq.gz)"_2.fastq.gz";

    fastqc -t ${threads} -o  ${DIR}/dataQC/ ${R1} ${R2};
    trim_galore -o  ${DIR}/dataQC/ --paired ${R1} ${R2};
done
#Raw data
#All reads have sequence duplications
#ERR204044 had bad quality for the first position
#SRR18214264 had significant quality drops for the last positions

for i in  ${DIR}/dataQC/*1.fq.gz;
do
    R1=${i};
    R2="${DIR}/dataQC/"$(basename ${i} 1_dataQC_1.fq.gz)"2_dataQC_2.fq.gz";

    fastqc -t ${threads} -o  ${DIR}/dataQC/ ${R1} ${R2};
done
#Trimmed data
#Trimming didn't change the duplication levels, all files were trimmed for less then 1%
#Quality scores increased for the last positions, it's a significant change in SRR18214264 reads

multiqc  ${DIR}/dataQC/ -o  ${DIR}/dataQC/;