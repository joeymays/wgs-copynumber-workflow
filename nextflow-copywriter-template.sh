#!/bin/bash
#SBATCH --partition=cpu_short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=log_copywriter_%j.log
#SBATCH --mail-type=ALL

## SET EMAIL ADDRESS & RUN ID

#SBATCH --mail-user=<youremailaddress>
#SBATCH --job-name=<short run identifier>

##  move this file to WGS folder and run with `sbatch` command

module load nextflow

nextflow run /gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/wgs-copynumber.nf -with-report nextflow-copywriter-report-%j.html
