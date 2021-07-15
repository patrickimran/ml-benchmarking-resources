#!/bin/bash

TARGET="age"
LEVELS="16S MG" 
DATASET="imsms"
DISCRETE=True 
METADATA="iMSMS_metadata_1152samples_for_sum_replicates_binary2.tsv"
RAW_DATA_PATH="/projects/ibm_aihl/ML-benchmark/raw/"
PROCESSED_DATA_PATH="/projects/ibm_aihl/ML-benchmark/processed/"

for LEVEL in ${LEVELS}
do

    echo ${LEVEL} $DATASET $TARGET $METADATA
    mkdir ${PROCESSED_DATA_PATH}/${DATASET}/${LEVEL}
    
    TABLE=${RAW_DATA_PATH}/${DATASET}/${LEVEL}.qza
    
    # Convert biom table to qza
    if [[ -f "$TABLE" ]]; then
        echo "$TABLE exists as a .qzv"
    else
        qiime tools import \
            --input-path ${RAW_DATA_PATH}/${DATASET}/${LEVEL}.biom \
            --type "FeatureTable[Frequency]" \
            --input-format BIOMV210Format \
            --output-path ${TABLE}
    fi
    
    # Preprocess biom table
    qiime mlab preprocess \
        --i-table ${TABLE} \
        --m-metadata-file ${RAW_DATA_PATH}/${DATASET}/${METADATA} \
        --p-sampling-depth 1000 \
        --p-min-frequency 10 \
        --p-target-variable ${TARGET} \
        --p-discrete ${DISCRETE} \
        --verbose \
        --output-dir ${PROCESSED_DATA_PATH}/${DATASET}/${LEVEL}/${TARGET}


done

