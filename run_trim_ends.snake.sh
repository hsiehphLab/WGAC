#!/usr/bin/bash -l


# needed for Athef because it didn't automatically source ~/.bashrc so couldn't conda activate anything
source ~/.bashrc



conda activate snakemake

snakemake -s trim_ends.snake  --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 300 -p -k
