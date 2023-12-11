#!/usr/bin/bash -l


conda activate snakemake


snakemake -s global_align_110k.snake  --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 100 -p -k
