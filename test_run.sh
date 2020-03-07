#!/bin/bash

NXF_VER=20.01.0 nextflow run main.nf \
--INPUT_FOLDER scratch/ \
--OUTDIR scratch/out/ \
-work-dir scratch/work/ \
-with-trace