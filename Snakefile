# Adapted from https://github.com/sunbeam-labs/sunbeam/blob/dev/rules/classify/kraken.rules
# For fungal classification using kraken2

import os

PROJECT_DIR = config['PROJECT_DIR']
DECONTAM_DIR = PROJECT_DIR + '/sunbeam_output/qc/decontam'
CLASSIFY_FP = PROJECT_DIR + '/sunbeam_output/classify/fungal_kraken2'
SAMPLES_FP = PROJECT_DIR + "/samples.csv"

SAMPLES = []
with open(SAMPLES_FP) as f:
    lines = f.readlines()

for line in lines:
    SAMPLES.append(line.split(',')[0])

workdir: PROJECT_DIR

rule all:
    input:
        CLASSIFY_FP + '/all_samples.tsv'

rule classic_k2_biom:
    input:
        CLASSIFY_FP + '/all_samples.biom'
    output:
        CLASSIFY_FP + '/all_samples.tsv'
    shell:
        """
        biom convert -i {input} -o {output} \
        --to-tsv --header-key=taxonomy --process-obs-metadata=taxonomy \
        --output-metadata-id="Consensus Lineage"
        """

rule kraken_biom:
    input:
        expand(CLASSIFY_FP + '/{sample}-taxa.tsv', sample = SAMPLES)
    output:
        CLASSIFY_FP + '/all_samples.biom'
    shell:
        """
        kraken-biom --max D -o {output} {input}
        """

rule kraken2_classify:
    input:
        expand(DECONTAM_DIR + '/{{sample}}_{rp}.fastq.gz', rp = ['1', '2'])
    output:
        raw = CLASSIFY_FP + '/raw/{sample}-raw.tsv',
        report = CLASSIFY_FP + '/{sample}-taxa.tsv'
    params:
        db = config['FUNGAL_DB']
    threads:
        config['THREADS']
    shell:
        """
        kraken2 --gzip-compressed \
                --db {params.db} \
                --report {output.report} \
                --threads {threads} \
                --paired {input} \
                > {output.raw}
        """

onsuccess:
    print('Workflow finished, no error')
    shell('mail -s "Workflow finished successfully" ' + config['ADMIN_EMAIL'] + ' < {log}')

onerror:
    print('An error occurred')
    shell('mail -s "An error occurred" ' + config['ADMIN_EMAIL'] + ' < {log}')
