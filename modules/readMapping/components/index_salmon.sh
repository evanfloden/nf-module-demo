mkdir salmon_index
salmon index -t ${transcriptome_file} -i transcriptome.index
mv transcriptome.index salmon_index/.
