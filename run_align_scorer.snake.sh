#!/usr/bin/bash -l


# prepare for using conda
source /home/hsiehph/shared/bin/initialize_conda.sh

conda activate snakemake

snakemake -s align_scorer.snake  --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 100 -p -k
