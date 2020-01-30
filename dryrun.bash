#!/bin/bash

snakemake -j 300 \
	--configfile /scr1/users/leej39/kraken2_fungal_snakemake/config.yml \
	--cluster-config /scr1/users/leej39/kraken2_fungal_snakemake/cluster.json \
	-w 180 \
	--notemp \
	-p \
	-c \
	"qsub -cwd -r n -V -l h_vmem={cluster.h_vmem} -l mem_free={cluster.mem_free} -pe smp {threads}" \
    -n
