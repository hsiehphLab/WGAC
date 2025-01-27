#!/usr/bin/bash -l


# needed for Athef because it didn't automatically source ~/.bashrc so couldn't conda activate anything
source initialize_conda.sh


conda activate snakemake

snakemake -s trim_ends.snake  --jobname "{rulename}.{jobid}" --profile profile \
   --groups trim_one_file=trimg --group-components trimg=16 \
   -w 300 --jobs 100 -p -k --nolock
