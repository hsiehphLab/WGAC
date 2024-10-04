#!/usr/bin/bash -l


#SBATCH --time=24:00:00
#SBATCH --mem=10g                                                                                  
#SBATCH --cpus-per-task=1

if [ -f makefile_wgac.out ]
then
    mv makefile_wgac.out makefile_wgac.out$(date -d "today" +"%Y.%m%d.%H%M%S")
fi

make -f makefile_wgac -j 200 >makefile_wgac.out 2>&1
