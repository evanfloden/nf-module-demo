# Script to format Salmon data
sed '1d' ${quant_dir}/quant.sf > tmp;
sort -k 1,1 tmp;
cat tmp | awk '{ print \$1, \$4 }' > "${component}_${sampleID}.quant"
