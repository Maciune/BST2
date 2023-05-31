#!/bin/bash

DIR="/home/bioinformatikai/HW2"

awk '/^>/{print > "ERR204044.fasta"; p=1; next} p==1{print > "ERR204044.fasta"; exit}' ${DIR}/ragtag/scaffold/spades/ERR204044/ragtag.scaffold.fasta
awk '/^>/{print > "SRR15131330.fasta"; p=1; next} p==1{print > "SRR15131330.fasta"; exit}' ${DIR}/ragtag/scaffold/spades/SRR15131330/ragtag.scaffold.fasta
awk '/^>/{print > "SRR18214264.fasta"; p=1; next} p==1{print > "SRR18214264.fasta"; exit}' ${DIR}/ragtag/scaffold/spades/SRR18214264/ragtag.scaffold.fasta
mv SRR18214264.fasta SRR15131330.fasta ERR204044.fasta scaffolds

#gepard done using GUI with files in scaffolds directory
#gepard between ERR204044 and SRR15131330:   line has a lot of small breaks, some bigger breaks and it is really uneven
#gepard between ERR204044 and SRR18214264:   has break at the middle, but apart from that it is even
#gepard between SRR15131330 and SRR18214264: has the same break at the middle and line is uneven again
#ERR204044 and SRR18214264 are more similar between themselves than compared to SRR15131330

makeblastdb -in ${DIR}/ref/CP015498.fasta -dbtype nucl -out ${DIR}/blast/db/nucldb
for i in ${DIR}/scaffolds/*fasta;
do
    busco -i ${i} -l lactobacillales_odb10 --out_path ${DIR}/busco/ -o $(basename ${i} .fasta) -m genome
    blastn -query ${i} -evalue 1e-20 -db ${DIR}/blast/db/nucldb -outfmt 6 -out ${DIR}/blast/$(basename ${i} .fasta).txt
done
#BUSCO for ERR204044:   Out of 402 BUSCO groups 2 were missing and 2 fragmented which seems like a good result
#BUSCO for SRR15131330: Out of 402 BUSCO groups 4 were missing and 2 fragmented which is still decent
#BUSCO for SRR18214264: Out of 402 BUSCO groups 2 were missing and 2 fragmented which seems like a good result

#GeneMarkS-2 and RAST were done using GUI with files in scaffolds directory
#GeneMarkS-2: ERR204044 - 1960 genes, SRR15131330 - 2010 genes, SRR18214264 - 1933 genes
#RAST:        ERR204044 - 2259 genes, SRR15131330 - 2360 genes, SRR18214264 - 2225 genes
#Local BLAST: ERR204044 - 2003 genes, SRR15131330 - 6807 genes, SRR18214264 - 4705 genes (Amounts may differ greatly based on evalue threshold chosen, mine was 1e-20)
#Overall SRR15131330 has most genes in all predictions, RAST generated more predictions than GeneMarkS-2

#Ring plot - ERR204044 compared to SRR15131330(inner ring) and SRR18214264(outer ring)
#Outer ring has most of it covered in dark blue/purple color which means 100% protein sequence identity
#Inner ring is covered in green and cyan colors at best which mean 98-99.5% protein sequence identity
#This shows more similarity between ERR204044 and SRR18214264, less between ERR204044 and SRR15131330

#Based on quast number similarity, gepard dotplot and ring plot, #ERR204044 and SRR18214264 are more similar between themselves than compared to SRR15131330