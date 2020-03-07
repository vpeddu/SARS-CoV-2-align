#!/usr/bin/env nextflow
/*
========================================================================================
                         SARS-CoV-2-align
========================================================================================
wow it works
----------------------------------------------------------------------------------------
*/

// Using the Nextflow DSL-2 to account for the logic flow of this workflow
nextflow.preview.dsl=2



/*
 * SET UP CONFIGURATION VARIABLES
 */

// Show help message
params.help = false
if (params.help){
    helpMessage()
    exit 0
}

// Set defaults
// These values are overridden by what the user specifies (e.g. with --R1)

// Check to make sure that the required parameters have been set
if (!params.INPUT_FOLDER){ exit 1, "Must provide folder containing input files with --INPUT_FOLDER" }
if (!params.OUTDIR){ exit 1, "Must provide output directory with --OUTDIR" }

// Make sure the output directory has a trailing slash
if (!params.OUTDIR.endsWith("/")){
    params.OUTDIR = "${params.OUTDIR}/"
}

// Identify some resource files
TRIMMOMATIC_JAR = file(params.TRIMMOMATIC_JAR_PATH)
TRIMMOMATIC_ADAPTER = file(params.TRIMMOMATIC_ADAPTER_PATH)


/*
 * Import the processes used in this workflow
 */


include Trim from './modules/clomp_modules'
include Align from './modules/clomp_modules' 


// Run the workflow
workflow {


        input_read_ch = Channel
            .fromFilePairs("${params.INPUT_FOLDER}*_R{1,2}*${params.INPUT_SUFFIX}")
            .ifEmpty { error "Cannot find any FASTQ pairs in ${params.INPUT_FOLDER} ending with ${params.INPUT_SUFFIX}" }
            .map { it -> [it[0], it[1][0], it[1][1]]}

        // Validate that the inputs are paired-end gzip-compressed FASTQ
        // This will also enforce that all read pairs are named ${sample_name}.R[12].fastq.gz
        Trim(
            input_read_ch
        )
        Align(
        Trim.out
        )

        
    
    publish:
        Align.out to: "${params.OUTDIR}"
}
