# readMapping Module

#### Nexflow module for quantifying transcripts from short sequecencing reads


***This module takes as input:***
* short read sequencing data
* a set of transcripts 

***and provides as output:***
* quantified transcipts on a per sample basis

### Available components (tools)

|Name      |External Link   |Default Container   | Component Page | Publication | Licence |
|---       |---|---|---|---|---|
|kallisto |[Kallisto Website](https://pachterlab.github.io/kallisto/)| [docker biocontainer](https://quay.io/repository/biocontainers/kallisto) |[components/kallisto](./components/kallisto/README.md)|[PubMed](https://www.ncbi.nlm.nih.gov/pubmed/27043002)| [Link](https://github.com/pachterlab/kallisto/blob/master/license.txt)|
|salmon    |[Salmon Website](https://combine-lab.github.io/salmon/) | [docker biocontainers](https://quay.io/repository/biocontainers/salmon) |[components/salmon](./components/kallisto/README.md)|[PubMed](https://www.ncbi.nlm.nih.gov/pubmed/28263959)|[GNU GPL v3.0](https://github.com/COMBINE-lab/salmon/blob/master/LICENSE)|
|sailfish  |[Sailfish Website](http://www.cs.cmu.edu/~ckingsf/software/sailfish/) | [docker biocontainers](https://quay.io/repository/biocontainers/sailfish) |[components/sailfish](./components/kallisto/README.md)|[PubMed](https://www.ncbi.nlm.nih.gov/pubmed/24752080)|[GNU GPL v3.0](https://github.com/kingsfordgroup/sailfish/blob/master/LICENSE)|



### Operations and Processes:

All compoments in this module perform the following operations:

|Name           |Process Name   |EDAM Label |EDAM IRI |EDAM Link|
|---            |---            |---        |---      |---       |
|FASTA indexing |`index`        |Genome indexing |operation_3211 |[Link](http://edamontology.org/operation_3211)|
|Mapping/quantification |`quantification`|RNA-Seq quantification|operation_3800 |[Link](http://edamontology.org/operation_3800)|
|Collect results  |`results`|  Aggregation | operation_3436 | [Link](http://edamontology.org/operation_3436) |



### Module Input:
* Short reads (FASTQ)
* Set of Transcripts (FASTA)

This component supports [EDAM](http://edamontology.org/page) input data formats.

|Common Name |Common Extensions   |EDAM Name | EDAM IRI | EDAM Description| Nextflow Data Plugin |
|---         |---|---|---|---|---|
|Short Sequencing Reads | `.fastq/gz` `.fq/gz` | `FASTQ` | `format_1930` | [Link](http://edamontology.org/format_1930) |[Link]()|
|Transcripts | `.fasta/gz` `.fq/.gz`  |`FASTA`|`format_1929`| [Link](http://edamontology.org/operation_3436) | [Link]() |


### Module Output:
* A channel containing quantified trascripts in (CSV)

To use the resulting output channel in downstream operations or processes

`set val(id), file(abundancesCSV) from outputChannel`

This component generates the following [EDAM](http://edamontology.org/page) data formats as output.

|Common Name |Common Extensions   |EDAM Name | EDAM IRI | EDAM Description| 
|---         |---|---|---|---|
|Quantified transcripts |`.csv`/`.tsv`| `DSV: Delimiter-separated values` | `format_3751` | [Link](http://edamontology.org/format_3751) |



### Module Usage

From within a Nextflow pipeline, you can specify the following:

```
module readMapper(id, readsChannel, transcriptomeChannel, moduleConfig, outputChannel)
```

### moduleConfig Format

See each component page for the default command line parameters and arguments.

To change the default command line options you can provide a configuration, for example:

    readMapping config { 
        kallisto {
            quantification { 
              --index=${index}
              --threads=${task.cpus}
              --single
              --plaintext
            }
        sailfish {
            quantification { 
              --index=${index}
              --numThreads=${task.cpus}
              -r ${reads}
              --useVBOpt
            }
        } 
    }



### Example Usage
```
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
readMappingComponents = ['sailfish', 'kallisto', 'salmon']

// Define the config for the module/components



module readMapping(id,read_files,transcriptome_file, config, output_ch)

```

### *Internal Module Code Block*

```
process index {
    container = { readMappingContainers["${mapper}"] }
    
    input:
    val(mapper) from readMappingComponents
    file transcriptome_file
    
    output:
    set val("${mapper}"), file("${mapper}_index") into indexes
      
    script:
    template "$baseDir/modules/readMapping/components/index_${mapper}.sh"
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
    template "$baseDir/modules/readMapping/components/mapping_${mapper}.sh"
}

process results {
    container = { readMappingContainers["${mapper}"] }

    input:
    set val(mapper), val(sampleID), file(quant_dir) from quant

    output:
    set val("${mapper}"), val("${sampleID}"), file("${mapper}_${sampleID}.quant") into results

    script:
    template "$baseDir/modules/readMapping/components/results_${mapper}.sh"
}
````




