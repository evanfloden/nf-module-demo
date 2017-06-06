mkdir ${component}_${sampleID}
sailfish quant ${cmdLineOptions} -i ${index} -r ${reads} -o ${component}_${sampleID}
cp .command.err sailfish_${sampleID}.log
