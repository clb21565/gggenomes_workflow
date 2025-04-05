#!/bin/bash

# script for generating files needed to quickly visualize multiple genetic contexts using gggenomes 
# need seq-gc (https://github.com/thackl/seq-scripts/bin)
# need cluster-ids (https://github.com/thackl/seq-scripts/bin)
module load Perl
conda activate kairos1
# Default values
fasta_file=""
cov_id="0.7"
script_path="."
window_length="50"

# Function to display usage
usage() {
    echo "Usage: $0 [--fasta_file value]"
    exit 1
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fasta_file)
            if [[ -n "$2" && "$2" != --* ]]; then
                fasta_file="$2"
                shift 2
            else
                echo "Error: --fasta_file requires a value"
                usage
            fi
            ;;
        --cov_id)
            if [[ -n "$2" && "$2" != --* ]]; then
                cov_id="$2"
                shift 2
            else
                echo "Error: --cov_id requires a value"
                usage
            fi
            ;;
        --script_path)
            if [[ -n "$2" && "$2" != --* ]]; then
                script_path="$2"
                shift 2
            else
                echo "Error: --script_path requires a value"
                usage
            fi
            ;;
        --window_length)
            if [[ -n "$2" && "$2" != --* ]]; then
                window_length="$2"
                shift 2
            else
                echo "Error: --window_length requires a value"
                usage
            fi
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Print parsed options
echo "processing fasta...: $fasta_file"

# predict proteins 
echo "predicting proteins ..."
prodigal -i ${fasta_file} -a proteins.faa -f gff -o proteins.gff -p meta 

# cluster proteins
echo "clustering proteins at e 1e-5 and coverage ...: $cov_id"
mmseqs easy-cluster proteins.faa clusts-mmseqs tmp -e 1e-5 -c $cov_id

# write cog file based on cluster file 
perl $script_path/cluster-ids -t "cog%03d" < clusts-mmseqs_cluster.tsv > cogs.tsv  

# All-vs-all alignment | https://github.com/lh3/minimap2
minimap2 -X -N 50 -p 0.1 -c $fasta_file $fasta_file > self_map.paf

# get gc-content by window length
echo "get gc-content with window length ...: $window_length"
bash $script_path/seq-gc -Nbw $window_length $fasta_file > gc.tsv

# annotate MGEs/ARGs ... 
#echo "annotate MGEs/ARGs"
#diamond blastp -q proteins.faa -d $database --outfmt 6 qtitle stitle pident bitscore evalue -o mge-arg-annotations.tsv --id 0.7
