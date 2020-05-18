module purge
module load modules modules-init modules-gs/prod modules-eichler/prod

module load miniconda/4.5.12



snakemake -s blast_fugu.snake  --jobname "{rulename}.{jobid}" --drmaa " -V -cwd -e ./log -o ./log {params.sge_opts}  -S /bin/bash -l testing=true" -w 100 --jobs 100 -p -k --restart-times 1