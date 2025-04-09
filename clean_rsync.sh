#!/usr/bin/bash -l
#SBATCH --time=02:00:00
#SBATCH --mem=10g                                                                                  
#SBATCH --cpus-per-task=1

make -f makefile_wgac cleanedUp_done

origin_dir="/scratch.global/javid017/HPRCasm"
relative_path=$(pwd | sed "s|$origin_dir/||")
destination_dir="/projects/standard/hsiehph/gordo893/samples/multiple_samples/HPRCasm/$relative_path"
origin_dir="/scratch.global/javid017/HPRCasm/$relative_path"

mkdir -p $destination_dir

rsync -avr . $destination_dir

