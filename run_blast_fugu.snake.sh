#!/usr/bin/bash -l



conda activate snakemake


snakemake -s blast_fugu.snake  --jobname "{rulename}.{jobid}" --profile profile  -w 100 --jobs 300 -p -k --restart-times 1 --rerun-incomplete
