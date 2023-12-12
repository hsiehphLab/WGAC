#!/usr/bin/bash -l


#SBATCH --time=48:00:00
#SBATCH --mem=10g                                                                                  
#SBATCH --cpus-per-task=1

make -f makefile_wgac >makefile_wgac.out 2>&1
