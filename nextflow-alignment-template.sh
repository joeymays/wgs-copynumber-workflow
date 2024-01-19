#!/bin/bash
#SBATCH --partition=cpu_short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00
#SBATCH --output=log_alignment_%j.log
#SBATCH --mail-type=ALL


## SET EMAIL ADDRESS & RUN ID

#SBATCH --mail-user=<youremailaddress>
#SBATCH --job-name=<short run identifier>

##  move this file to WGS folder and run with `sbatch` command

module load nextflow

nextflow run /gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/wgs-alignment.nf -with-report nextflow-alignment-report-%j.html
