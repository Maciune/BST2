#!/bin/bash

DIR="/home/bioinformatikai/HW2"
threads=6
for i in ${DIR}/dataQC/*1.fq.gz;
do
    R1=${i};
    R2=" ${DIR}/val/"$(basename ${i} 1_val_1.fq.gz)"2_val_2.fq.gz";

    spades.py -1 ${R1} -2 ${R2} -o ${DIR}/spades/$(basename ${i} _1_val_1.fq.gz);
    velveth ${DIR}/velvet/$(basename ${i} _1_val_1.fq.gz)/ 31 -fastq -shortPaired -separate ${R1} ${R2};
    velvetg ${DIR}/velvet/$(basename ${i} _1_val_1.fq.gz)/;
done

wget -P ${DIR}/ref https://www.ebi.ac.uk/ena/browser/api/fasta/CP015498
quast -o ${DIR}/quast -r ${DIR}/ref/CP015498.1.fasta ${DIR}/spades/ERR204044/contigs.fasta ${DIR}/spades/SRR15131330/contigs.fasta ${DIR}/spades/SRR18214264/contigs.fasta ${DIR}/velvet/ERR204044/contigs.fa ${DIR}/velvet/SRR15131330/contigs.fa ${DIR}/velvet/SRR18214264/contigs.fa
#quast results (In report spades results on the left, velvet on the right):
#Spades did a fine job, all results had genome coverage 70-75%, not the best results but workable.
#Velvet did a lot worse, SRR15131330 isn't represented in report at all as none of it's contigs were over 500bp, SRR18214264 has a genome coverage of 1%
#ERR204044 by velvet is somewhat ok, here's comparison to ERR204044 by spades:
# spades assembly has >20% more genome fraction than velvet one, velvet assembly has 4 times more fully unaligned length but almost 2 times less mismatches(overall spades better) 

for i in ${DIR}/dataQC/*1.fq.gz;
do
    ragtag.py correct -o ${DIR}/ragtag/correct/spades/$(basename ${i} _1_val_1.fq.gz)/ ${DIR}/ref/CP015498.fasta ${DIR}/spades/$(basename ${i} _1_val_1.fq.gz)/contigs.fasta;
    ragtag.py correct -o ${DIR}/ragtag/correct/velvet/$(basename ${i} _1_val_1.fq.gz)/ ${DIR}/ref/CP015498.fasta ${DIR}/velvet/$(basename ${i} _1_val_1.fq.gz)/contigs.fa;
    ragtag.py scaffold -o ${DIR}/ragtag/scaffold/spades/$(basename ${i} _1_val_1.fq.gz) -r ${DIR}/ref/CP015498.fasta ${DIR}/ragtag/correct/spades/$(basename ${i} _1_val_1.fq.gz)/ragtag.correct.fasta;
    ragtag.py scaffold -o ${DIR}/ragtag/scaffold/velvet/$(basename ${i} _1_val_1.fq.gz)/ -r ${DIR}/ref/CP015498.fasta ${DIR}/ragtag/correct/velvet/$(basename ${i} _1_val_1.fq.gz)/ragtag.correct.fasta;
done

quast -o ${DIR}/quast2 -r ${DIR}/ref/CP015498.fasta ${DIR}/ragtag/scaffold/spades/ERR204044/ragtag.scaffold.fasta ${DIR}/ragtag/scaffold/velvet/ERR204044/ragtag.scaffold.fasta ${DIR}/ragtag/scaffold/spades/SRR15131330/ragtag.scaffold.fasta ${DIR}/ragtag/scaffold/velvet/SRR15131330/ragtag.scaffold.fasta ${DIR}/ragtag/scaffold/spades/SRR18214264/ragtag.scaffold.fasta ${DIR}/ragtag/scaffold/velvet/SRR18214264/ragtag.scaffold.fasta
#Quast results after making scaffolds (In report spades results on the left, velvet on the right):
#SRR* results by velvet became better (20%/25% instead of 0%/1% genome fraction), but still a lot worse than SRR* by spades, so I chose spades for both SRR samples
#When comparing 2 ERR sample assemblies, they both had they pros/cons. 
#Even though spades assembly has more of it's lenght partially unalligned, has a little bit more mismatches and it's largest allignment is smaller I chose spades,
# because it has a bit more genome fraction alligned, less duplication ratio, less fully unaligned lenght and I simply didn't trust velvet assemblies because of it's work with other samples
#I chose all samples assembled by spades

for i in ${DIR}/raw/*1.fastq.gz;
do
    R1=${i};
    R2=" ${DIR}/raw/"$(basename ${i} _1.fastq.gz)"_2.fastq.gz";

    bwa index ${DIR}/ragtag/scaffold/spades/$(basename ${i} _1.fastq.gz)/ragtag.scaffold.fasta
    bwa mem -t ${threads} ${DIR}/ragtag/scaffold/spades/$(basename ${i} _1.fastq.gz)/ragtag.scaffold.fasta ${R1} ${R2} > ${DIR}/bwa/spades/$(basename ${i} _1.fastq.gz)/alignments.sam
    bwa index ${DIR}/ragtag/scaffold/velvet/$(basename ${i} _1.fastq.gz)/ragtag.scaffold.fasta
    bwa mem -t ${threads} ${DIR}/ragtag/scaffold/spades/$(basename ${i} _1.fastq.gz)/ragtag.scaffold.fasta ${R1} ${R2} > ${DIR}/bwa/velvet/$(basename ${i} _1.fastq.gz)/alignments.sam
done



