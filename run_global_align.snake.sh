#!/usr/bin/bash -l


conda activate snakemake

snakemake -s global_align.snake  --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 100 -p -k
