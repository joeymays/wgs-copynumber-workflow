#!/bin/bash
#SBATCH --partition=cpu_short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=log_copywriter_%j.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=example@gmail.com
#SBATCH --job-name=example_name

## SET EMAIL ADDRESS & JOB NAME ABOVE

##  move this file to WGS folder and run with `sbatch` command

module load nextflow

nextflow run /gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/wgs-copynumber.nf -with-report report-nextflow-copywriter-$(date +"%Y%m%d%H%m").html -resume