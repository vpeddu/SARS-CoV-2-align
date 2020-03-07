
/*
 * Define the processes used in this workflow
 */

process Trim {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    // should build our own docker image for this 
    container "quay.io/biocontainers/bbmap:38.76--h516909a_0"

    // Define the input files
    input:
      file r1

    // Define the output files
    output:
      file "*trimmed*"

    // Code to be executed inside the task
    script:
      """
#!/bin/bash

set -e

# For logging and debugging, list all of the files in the working directory
ls -lahtr

# Get the sample name from the file name
sample_name=\$(echo ${r1} | sed 's/.R1_001.fastq.gz//')
echo "Processing \$sample_name"

# Rename the input file to make sure we don't use it as the output
mv ${r1} INPUT.${r1}

echo "Trimming ${r1}"
bbduk.sh \
    in=INPUT.${r1} \
    out="\$sample_name.trimmed.fastq.gz" \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    minlength=60 \
    tbo \
    qtrim=r \
    trimq=10 \
    adapters="${baseDir}/adapters.fa"
"""
}



process Align {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    container "quay.io/fhcrc-microbiome/bowtie2:bowtie2-2.2.9-samtools-1.3.1"

    // Define the input files
    input:
      file r1

    // Define the output files
    output:
      file "${r1}"
      file "*.log"

    // Code to be executed inside the task
    script:
      """
#!/bin/bash

set -e

# For logging and debugging, list all of the files in the working directory
ls -lahtr

# Get the sample name from the input FASTQ name
sample_name=\$(echo ${r1} | sed 's/.R1.fastq.gz//')

echo "Starting the alignment of ${r1}"
bowtie2 \
    --no-unal \
    --threads ${task.cpus} \
    -x "${baseDir}/ref" \
    -U <(gunzip -c ${r1}) | \
    samtools view -Sb - > \$sample_name.bam 2>&1 | \
    tee -a \${sample_name}.log

      """
}

