mkdir ${mapper}_${sampleID}
kallisto quant --single -l 180 -s 20 -b 100 ${index} -o kallisto_${sampleID} ${reads}
