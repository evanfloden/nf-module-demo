# Script to format Kallisto data
sed '1d' ${quant_dir}/abundance.tsv > tmp;
sort -k 1,1 tmp;
cat tmp | awk '{ print \$1, \$5 }' > "${mapper}_${sampleID}.quant"
