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



/*
 * Import the processes used in this workflow
 */


include Trim from './modules/clomp_modules.nf'
include Align from './modules/clomp_modules.nf' 


// Run the workflow
workflow {


        input_read_ch = Channel
            .fromPath("${params.INPUT_FOLDER}*.fastq.gz")
            //.ifEmpty { error "Cannot find any FASTQ pairs in ${params.INPUT_FOLDER} ending with ${params.INPUT_SUFFIX}" }


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
