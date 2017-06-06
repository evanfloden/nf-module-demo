mkdir ${component}_${sampleID}
kallisto quant ${cmdLineOptions} -i ${index}/transcriptome.index -o kallisto_${sampleID} ${reads}
cp .command.err kallisto_${sampleID}.log
