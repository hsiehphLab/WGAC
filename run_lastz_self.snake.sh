#!/usr/bin/bash -l


conda activate snakemake

mkdir -p log

snakemake -s lastz_self.snake --jobname "{rulename}.{jobid}" --profile profile -w 100 --jobs 300 -p -k

