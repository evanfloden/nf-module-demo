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

// Define a function for parsing component commandline options
def cmdLineArgParse(argObj) {
  def cmdLineArg = ''
  argObj.each {
    if (it.value[0] == true) {
      cmdLineArg = cmdLineArg + " "+ it.value[1]
    }
    else if (it.value[0] != false) {
        cmdLineArg = cmdLineArg + " "+ it.value[1] + "=" + it.value[0]
    }
  }
  return cmdLineArg
}

process index {
    container = { params.modules.readMapping."${component}".container }
    tag { "Indexing ${transcriptome_file.getName()} with ${component}" }
   
    input:
    val(component) from readMappingComponents
    file transcriptome_file
    
    output:
    set val("${component}"), file("${component}_index") into indexes
      
    script:
    argObj = params.modules.readMapping."${component}".index.commandlineOptions
    cmdLineOptions = cmdLineArgParse(argObj)
    template "$baseDir/modules/readMapping/components/${component}/index_${component}.sh"
}

indexes
    .combine(read_files)
    .set { read_files_and_index }



process quantification {
    container = { params.modules.readMapping."${component}".container }   
    tag { "Quantifying ${sampleID} with ${component}" }
 
    input:
    set val(component), file('index'), val(sampleID), file(reads) from read_files_and_index 
    
    output:
    set val("${component}"), val("${sampleID}"), file("${component}_${sampleID}") into quant
      
    script:
    cmdLineOptions = cmdLineArgParse(params.modules.readMapping.kallisto.quantification.commandlineOptions)
    template "$baseDir/modules/readMapping/components/${component}/quantification_${component}.sh"
}

process results {
    container = { params.modules.readMapping."${component}".container }
    tag { "Parsing sample ${sampleID} results from ${component}" }

    input:
    set val(component), val(sampleID), file(quant_dir) from quant

    output:
    set val("${component}"), val("${sampleID}"), file("${component}_${sampleID}.quant") into results

    script:
    template "$baseDir/modules/readMapping/components/${component}/results_${component}.sh"
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
 
