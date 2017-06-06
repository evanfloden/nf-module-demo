mkdir ${component}_${sampleID}
salmon quant ${cmdLineOptions} -i ${index} -r ${reads} -o ${component}_${sampleID}
cp .command.err salmon_${sampleID}.log
