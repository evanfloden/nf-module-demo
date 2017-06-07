mkdir ${sampleID}
mkdir salmon_logs
salmon quant ${cmdLineOptions} -i ${index} -r ${reads} -o ${sampleID}
cp -r ${sampleID} salmon_${sampleID}_logs
