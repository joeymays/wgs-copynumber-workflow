# wgs-copynumber-workflow
Nextflow workflow for Copy Number detection in WGS data using CopywriteR

## CopywriteR Notes

Xin made modifications to the plotting function in CopywriteR, coded in `copywriter_plot_new_2020.R`. 
This script is loaded and sourced (i.e. made availble in R) from the CopywriteR Docker image. 

### Docker Image for CopywriteR

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

