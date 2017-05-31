# Kallisto Component
## Part of the readMapping module

#### Nexflow component for quantifying transcripts from short sequecencing reads using kallisto
#### See readMapping module [here]() for details and usage

***This module takes as input:***
* short read sequencing data
* a set of transcripts 

***and provides as output:***
* quantified transcipts on a per sample basis

### Default Container


### Operations and Processes:

|Name           |Process Name   |Component commmand line|
|---            |---            |---        |---      |---       |
|FASTA indexing |`index`        |Genome indexing |operation_3211 |[Link](http://edamontology.org/operation_3211)|
|Mapping/quantification |`quantification`|RNA-Seq quantification|operation_3800 |[Link](http://edamontology.org/operation_3800)|
|Collect results  |`results`|  Aggregation | operation_3436 | [Link](http://edamontology.org/operation_3436) |

### Command Line Options

#### index

#### quantification


### Operations and Processes:

All compoments in this module perform the following operations:

|Name           |Process Name   |EDAM Label |EDAM IRI |EDAM Link|
|---            |---            |---        |---      |---       |
|FASTA indexing |`index`        |Genome indexing |operation_3211 |[Link](http://edamontology.org/operation_3211)|
|Mapping/quantification |`quantification`|RNA-Seq quantification|operation_3800 |[Link](http://edamontology.org/operation_3800)|
|Collect results  |`results`|  Aggregation | operation_3436 | [Link](http://edamontology.org/operation_3436) |


### Component config format

To change the default command line options you can provide a configuration, for example:

    readMapping/kallisto config { 
        kallisto {
            index {
              --index=${index}
              --threads=${task.cpus}
              --single
              --plaintext
            }
        kallisto {
            quantification { 
              --index=${index}
              --threads=${task.cpus}
              --single
              --plaintext
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
readMappingComponents = ['kallisto']

// Define the config for the module/components

module readMapping(id,read_files,transcriptome_file, config, output_ch)

```

