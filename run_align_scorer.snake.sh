#!/usr/bin/bash -l


# prepare for using conda
source /home/hsiehph/shared/bin/initialize_conda.sh

conda activate snakemake

snakemake -s align_scorer.snake  --jobname "{rulename}.{jobid}" --profile profile \
  --groups run_align_scorer_on_all_in_subdir=align_scorerg --group-components align_scorerg=16 \
  -w 300 --jobs 100 -p -k
