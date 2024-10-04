#!/usr/bin/bash -l


# needed for Athef because it didn't automatically source ~/.bashrc so couldn't conda activate anything
source initialize_conda.sh




conda activate snakemake

snakemake -s global_align.snake  --jobname "{rulename}.{jobid}" --profile profile \
  --groups run_one_global_alignment=global_aligng --group-components global_aligng=16 \
  -w 100 --jobs 100 -p -k
