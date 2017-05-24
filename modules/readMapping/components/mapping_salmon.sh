mkdir ${mapper}_${sampleID}
salmon quant -i ${index} -l MSF -r ${reads} -o ${mapper}_${sampleID}
