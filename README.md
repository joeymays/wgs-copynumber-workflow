# wgs-copynumber-workflow
Internal nextflow workflow for Copy Number detection in WGS data using CopywriteR.
See details below.

# Usage
Full copy number analysis of whole genome seqeucning is done in two steps, 1) alignment and 2) copy number calling.

## Alignment 
`wgs-alignment.nf` handles the trimming, QC, and alignment of `fastq` files.
The script can be run using the `nextflow-alignment-template.sh` shell script on BigPurple.
Copy the template file to the sequencing run directory. The script expects there to be a 
folder called `fastq` within that directory. The `fastq` folder should contain a 
folder for each sample, and those folders should contain `fastq.gz` files.

### Single-End Reads
The script expects paired end reads by default. 
To alignt single end reads, use the `--format single` flag in the template file.

```
nextflow run /gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/wgs-alignment.nf -with-report report-nextflow-alignment-$(date +"%Y%m%d%H%m").html -resume --format single
```

### Different Species or Reference Genome
The script aligns to the human hg38 genome by default. 
To align to a different genome (e.g. the mouse mm10 genome), use the `--refPath <filepath>` flag in the template file.

```
nextflow run /gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/wgs-alignment.nf -with-report report-nextflow-alignment-$(date +"%Y%m%d%H%m").html -resume --refPath /gpfs/data/davolilab/reference-genomes/mm10/mm10.fa
```


## Copy Number Calling
`wgs-copynumber.nf` handles copy number calling at 200kb and 1000kb resolution. 
For mouse, use the `--species mouse` flag in the template file.

# Details

## CopywriteR

Xin made modifications to the plotting function in CopywriteR, coded in `copywriter_plot_new_2020.R`. 
This script is loaded and sourced (i.e. made availble in R) from the CopywriteR Docker image. 

## Docker Image for CopywriteR

Copy number plots are created using the CopywriteR package for R.
To ensure reproducibility for the future, the package has been installed 
in a Docker container running R version 4.1.2 and all the necessary
dependencies so you don't have to wrestle with setting up older R packages.
This Docker container is run in the Nextflow workflow using the Singularity software. 

The original Docker image was built from the file `davolilab-copywriter_r4.1.2.Dockerfile`. 
The pre-built Docker image can be found on Docker Hub: `https://hub.docker.com/repository/docker/joeymays/davolilab-copywriter/general`

BigPurple uses Singularity to load Docker containers instead of the Docker software itself.
To download and convert the re-built Docker image to a Singularity file:
(note: use singularity v3.9.8, newer versions throw errors for whatever reason)

```bash
module load singularity/3.9.8
singularity build davolilab-copywriter-r4.1.2.sif docker://joeymays/davolilab-copywriter
```

