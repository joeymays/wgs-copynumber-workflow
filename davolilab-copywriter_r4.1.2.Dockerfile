FROM rocker/r-ver:4.1.2

RUN mkdir home/scripts
COPY copywriter_plot_new_2020.R /home/scripts/copywriter_plot_new_2020.R

RUN apt-get update
RUN apt-get install zlib1g-dev
RUN apt-get -y install libbz2-dev
RUN apt-get -y install liblzma-dev
RUN apt-get -y install libcurl4-openssl-dev

RUN R -e 'install.packages("BiocManager")'
RUN R -e 'BiocManager::install(version="3.14")'
RUN R -e 'install.packages("remotes")'
RUN R -e 'BiocManager::install(c("XVector", "Rhtslib"))'
RUN R -e 'BiocManager::install(c("GenomicRanges", "Biostrings"))'
RUN R -e 'BiocManager::install("CopywriteR")'
RUN R -e 'install.packages("optparse")'
