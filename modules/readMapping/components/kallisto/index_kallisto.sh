mkdir kallisto_index
kallisto index ${cmdLineOptions} -i transcriptome.index ${transcriptome_file}
mv transcriptome.index kallisto_index/.
