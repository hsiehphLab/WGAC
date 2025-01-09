#!/usr/bin/bash -l


# needed for Athef because it didn't automatically source ~/.bashrc so couldn't conda activate anything
source initialize_conda.sh



conda activate snakemake


snakemake -s global_align_110k.snake  --jobname "{rulename}.{jobid}" --profile profile \
  --groups run_one_global_alignment=110kg --group-components 110kg=16 \
  -w 300 --jobs 100 -p -k
