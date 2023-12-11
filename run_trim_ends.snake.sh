#!/usr/bin/bash -l

conda activate snakemake

snakemake -s trim_ends.snake  --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 200 -p -k
