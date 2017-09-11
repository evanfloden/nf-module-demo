// Define common input files
params.transcriptome = "${baseDir}/data/transcriptome.fa"
params.reads         = "${baseDir}/data/reads/*.fastq"

// Define email to send results
params.email = "evanfloden@gmail.com"

// Create channels for input files
transcriptome_file = file(params.transcriptome)

Channel
    .fromFilePairs( params.reads, size: -1 )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .into { read_filesA; read_filesB }

// Define which component(s) from the readMapping module we want to use
params.readMappingComponents = "kallisto,salmon,sailfish"
readMappingComponents        = params.readMappingComponents.tokenize(",") 

// Define a function for parsing component commandline options
def cmdLineArgParse(argObj) {
  def cmdLineArg = ''
  argObj.each {
    if (it.value[0] == true && it.value[1] == true ) {
      cmdLineArg = cmdLineArg + " "+ it.value[2]
    }
    else if (it.value[0] == true ) {
        cmdLineArg = cmdLineArg + " "+ it.value[2] + "=" + it.value[1]
    }
  }
  return cmdLineArg
}

// Define multiqc config dir
def multiqc = file(params.multiqc)


process fastqc {
    container = "genomicpariscentre/fastqc"
    tag { "FASTQC on ${sampleID}" }

    input:
    set val(sampleID), file(reads) from read_filesB

    output:
    file("fastqc_${sampleID}_logs") into fastqc_multiQC_ch


    script:
    """
    mkdir fastqc_${sampleID}_logs
    fastqc -o fastqc_${sampleID}_logs -f fastq -q ${reads}
    """  
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
    .combine(read_filesA)
    .set { read_files_and_index }

process quantification {
    container = { params.modules.readMapping."${component}".container }   
    tag { "Quantifying ${sampleID} with ${component}" }
 
    input:
    set val(component), file('index'), val(sampleID), file(reads) from read_files_and_index 

    output:
    set val("${component}"), val("${sampleID}"), file("${sampleID}") into quant
    file("${component}_${sampleID}_logs") into quantification_multiQC_ch

      
    script:
    argObj = params.modules.readMapping."${component}".quantification.commandlineOptions
    cmdLineOptions = cmdLineArgParse(argObj)
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


quantification_multiQC_ch
  .mix(fastqc_multiQC_ch)
  .collect()
  .set {multiQC_ch}

process multiQC {
    publishDir = "$baseDir/results"
    container = "quay.io/biocontainers/multiqc:1.0--py35_4"

    input:
    file (multiqcDir) from multiqc 
    file('*') from multiQC_ch

    output:
    file ("multiqc_report.html") into multiQCreport
    file ("multiqc_data") into multiQCdata

    script:
    """
    cp ${multiqc}/* .

    multiqc . 
    """
}

workflow.onComplete {
    def subject = 'NF Modules Demo'
    def recipient = "${params.email}"
    def qc_report = "${baseDir}/results/multiqc_report.html"

    ['mail', '-a', qc_report, '-s', subject, recipient ].execute() << """

    Pipeline execution summary
    ---------------------------
    Completed at: ${workflow.complete}
    Duration    : ${workflow.duration}
    Success     : ${workflow.success}
    workDir     : ${workflow.workDir}
    exit status : ${workflow.exitStatus}
    Error report: ${workflow.errorReport ?: '-'}
    """
}
