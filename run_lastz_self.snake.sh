#!/usr/bin/bash -l

# needed for Athef because it didn't automatically source ~/.bashrc so couldn't conda activate anything
source initialize_conda.sh



conda activate snakemake

mkdir -p log

snakemake -s lastz_self.snake --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 300 -p -k

