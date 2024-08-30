mkdir -p ${TMPDIR}/wgac_shorter_lines

szShorter="fastawhole_shorter_lines.fofn"

rm -f $szShorter
touch $szShorter

while read szFile
do
    echo ${szFile}
    szBasename=$(basename ${szFile})
    szBasenameNoGz=`echo $szBasename | sed 's/\.gz//'`
    szOutputFile=${TMPDIR}/wgac_shorter_lines/${szBasenameNoGz}
    echo ${szOutputFile} >>${szShorter}
    #echo "about to check which python is being using before conda:"
    #which python
    # fixed a problem here in which biopython was not found due to 
    # an anaconda module being loaded by autosubmitter and for some reason
    # it overrode the conda activate biopython
    echo "about to check which python is being using:"
    module purge && source initialize_conda.sh && conda activate biopython && which python
    echo "about to execute: module purge && source initialize_conda.sh && conda activate biopython && ./longer_to_shorter_lines.py --szInputFile ${szFile} --szOutputFile ${szOutputFile}"
    module purge && source initialize_conda.sh && conda activate biopython && ./longer_to_shorter_lines.py --szInputFile ${szFile} --szOutputFile ${szOutputFile}
done <fastawhole.fofn

