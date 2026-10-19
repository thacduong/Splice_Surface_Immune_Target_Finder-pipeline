#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=thac.duong@moffitt.org

# Load samtools module (if on cluster)
ml SAMtools/1.19.2-GCC-13.2.0

# Set input and output directories
INPUT_DIR="/share/.scratch/thac/HISAT2_scratch_20250604/output_BAM_full_20250610"  # Change to your BAM input directory if needed
OUTPUT_DIR="/share/.scratch/thac/HISAT2_scratch_20250604/output_BAM_merged_full_20250610"  # Change this to your preferred output location

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through all s1 BAMs
for BAM1 in "${INPUT_DIR}"/*_s1_*.bam; do
    # Construct the matching s2 BAM file
    BAM2="${BAM1/_s1_/_s2_}"

    # Check if both BAM1 and BAM2 exist
    if [[ -f "$BAM2" ]]; then
        # Get base filenames
        BAM1_BASE=$(basename "$BAM1")

        # Extract clean filename by removing _s1 or _s2
        COMMON_SUFFIX=$(basename "$BAM1" | sed -E 's/(.*)_s[12](.*)/\2/')
        PREFIX=$(basename "$BAM1" | sed -E 's/(.*)_s[12](.*)/\1/')
        CLEAN_FILENAME="${PREFIX}${COMMON_SUFFIX}"


        # Full path to output merged BAM
        MERGED_BAM="${OUTPUT_DIR}/${CLEAN_FILENAME}"

        echo "Merging:"
        echo " - $BAM1"
        echo " - $BAM2"
        echo " → $MERGED_BAM"

        # Merge and index
        samtools merge -@ 8 -o "$MERGED_BAM" "$BAM1" "$BAM2"
        samtools index "$MERGED_BAM"
    else
        echo "Warning: Matching s2 BAM not found for: $BAM1. Skipping..."
    fi
done


