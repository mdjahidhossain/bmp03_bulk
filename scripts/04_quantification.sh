#!/bin/bash

#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Step 1: Define project directories
# --------------------------------------------------

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

# Salmon index
salmon_index="${PROJECT_DIR}/inputs/human_salmon_index"

# FASTQ directory
fastq_dir="${PROJECT_DIR}/fastq"

# Output directory
output_dir="${PROJECT_DIR}/outputs/salmon_out"

# Number of threads
THREADS=${THREADS:-4}

# --------------------------------------------------
# Step 2: Create output directory
# --------------------------------------------------

mkdir -p "$output_dir"

# --------------------------------------------------
# Step 3: Check Salmon index
# --------------------------------------------------

if [[ ! -f "${salmon_index}/refseq.bin" ]]; then
    echo "ERROR: Salmon index is missing or incomplete."
    exit 1
fi

# --------------------------------------------------
# Step 4: Find R1 FASTQ files
# --------------------------------------------------

shopt -s nullglob
r1_files=("${fastq_dir}"/SRR*_1.fastq.gz)

if [[ ${#r1_files[@]} -eq 0 ]]; then
    echo "ERROR: No R1 FASTQ files found."
    exit 1
fi

# --------------------------------------------------
# Step 5: Run Salmon quantification
# --------------------------------------------------

for r1_file in "${r1_files[@]}"; do

    samp=$(basename "${r1_file%_1.fastq.gz}")
    r2_file="${fastq_dir}/${samp}_2.fastq.gz"

    # Check matching R2 file
    if [[ ! -f "$r2_file" ]]; then
        echo "ERROR: Missing R2 file for ${samp}"
        exit 1
    fi

    echo "--------------------------------------"
    echo "Processing sample: ${samp}"
    echo "--------------------------------------"

    salmon quant \
        -i "$salmon_index" \
        -l A \
        -1 "$r1_file" \
        -2 "$r2_file" \
        -p "$THREADS" \
        -o "${output_dir}/${samp}"

    echo "Finished sample: ${samp}"

done

echo "All Salmon quantifications completed!"

