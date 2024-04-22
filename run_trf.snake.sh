#!/usr/bin/bash -l

# needed for Athef because it didn't automatically source ~/.bashrc so couldn't conda activate anything
source initialize_conda.sh

module purge

conda activate snakemake


snakemake -s trf.snake populate_trf_with_links -j 300 

# added Feb 9, 2022 (DG):
# restart-times was necessary since occasionally got this error:
# Error recording metadata for finished job ([Errno 2] No such file or directory: 'fugu_trf/chr2_274.fugu'). Please ensure write permissions for the directory /net/eichler/vol27/projects/hprc/nobackups/chm13v2_wgac3/.snakemake

snakemake -s trf.snake --jobname "{rulename}.{jobid}" --profile profile  -j 300 -k --rerun-incomplete --restart-times 1
