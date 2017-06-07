mkdir ${sampleID}
mkdir kallisto_logs
kallisto quant ${cmdLineOptions} -i ${index}/transcriptome.index -o ${sampleID} ${reads}
cp .command.err kallisto_${sampleID}_logs
