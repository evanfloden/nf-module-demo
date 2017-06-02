// Define common input files
params.transcriptome = "data/transcriptome.fa"
params.reads         = "data/reads/*.fastq"

// Create channels for input files
transcriptome_file = file(params.transcriptome)

Channel
    .fromFilePairs( params.reads, size: -1 )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .set { read_files }

// Define which component(s) from the readMapping module we want to use
readMappingComponents = ['kallisto'] //''sailfish', 'kallisto', 'salmon']


// Define which container to use for each component. Could be preset in module config
def readMappingContainers = [:]
    //readMappingContainers["kallisto"]  =  "quay.io/biocontainers/kallisto:0.43.0--hdf51.8.17_2"
    readMappingContainers["salmon"]    =  "quay.io/biocontainers/salmon:0.8.2--1"
    readMappingContainers["sailfish"]  =  "quay.io/biocontainers/sailfish:0.10.1--1"


process index {
    container = params.modules.readMapping.kallisto.execution
   
    input:
    val(mapper) from readMappingComponents
    file transcriptome_file
    
    output:
    set val("${mapper}"), file("${mapper}_index") into indexes
      
    script:
    template "$baseDir/modules/readMapping/components/${mapper}/index_${mapper}.sh"
}

indexes
    .combine(read_files)
    .set { read_files_and_index }

process quantification {
    container = { readMappingContainers["${mapper}"] }
    
    input:
    set val(mapper), file('index'), val(sampleID), file(reads) from read_files_and_index 
    
    output:
    set val("${mapper}"), val("${sampleID}"), file("${mapper}_${sampleID}") into quant
      
    script:
    template "$baseDir/modules/readMapping/components/${mapper}/mapping_${mapper}.sh"
}

process results {
    container = { readMappingContainers["${mapper}"] }

    input:
    set val(mapper), val(sampleID), file(quant_dir) from quant

    output:
    set val("${mapper}"), val("${sampleID}"), file("${mapper}_${sampleID}.quant") into results

    script:
    template "$baseDir/modules/readMapping/components/${mapper}/results_${mapper}.sh"
}

//process figure {
//    container = { readMappingContainers["${mapper}"] }
//
//    input:
//    set val(mapper), val(sampleID), file(quant_dir) from quant
//
//    output:
//    set val(${mapper}), val(${sampleID}), file("${mapper}_${sampleID}.quant") into results
//
//    script:
//    template "$baseDir/modules/readMapping/components/results_${mapper}.sh"
//}
 
