mkdir ${sampleID}
mkdir sailfish_logs
sailfish quant ${cmdLineOptions} -i ${index} -r ${reads} -o ${sampleID}
cp -r ${sampleID} sailfish_${sampleID}_logs
