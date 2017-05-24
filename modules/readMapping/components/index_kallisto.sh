mkdir kallisto_index
kallisto index -i transcriptome.index ${transcriptome_file}
mv transcriptome.index kallisto_index/.
