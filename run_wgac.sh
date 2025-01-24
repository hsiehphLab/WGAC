#!/usr/bin/bash -l

# many jobs were killed at 24 hours, 2025.01.24 (DG)
#SBATCH --time=72:00:00
#SBATCH --mem=10g                                                                                  
#SBATCH --cpus-per-task=1

if [ -f makefile_wgac.out ]
then
    mv makefile_wgac.out makefile_wgac.out$(date -d "today" +"%Y.%m%d.%H%M%S")
fi

make -f makefile_wgac -j 200 >makefile_wgac.out 2>&1
