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
    echo "about to execute: source initialize_conda.sh && conda activate biopython && ./longer_to_shorter_lines.py --szInputFile ${szFile} --szOutputFile ${szOutputFile}"
     source initialize_conda.sh && conda activate biopython && ./longer_to_shorter_lines.py --szInputFile ${szFile} --szOutputFile ${szOutputFile}
done <fastawhole.fofn

