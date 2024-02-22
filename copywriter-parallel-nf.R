#!/usr/bin/env Rscript

#Adapted from Xin's script.
#Runs CopywriteR at 1000kb and 200kb  resolution.
#Edited Jan 2024, Joey Mays


## --------------------------------------------------------------------------------------------
library(optparse)

option_list <- list(
	make_option("--bam.file", help="BAM file to analyse"),
	make_option("--threads", default="default", help="number of threads to use."),
	make_option("--species", default="human", help="human (hg38) or mouse (mm10)."),
	make_option("--res", default="1000kb", help="resolution, 1000kb [default] or 200kb.")
)

opt <- parse_args(OptionParser(option_list=option_list))

## ------------------------------------------------------------------------------------------------
library(gtools)
library(matrixStats)
library(CopywriteR)

#source call points inside copywriter Docker container
source("/home/scripts/copywriter_plot_new_2020.R")
## -----------------------------------------------------------------------------------------------
threads.use <- opt$threads
if(threads.use == "default"){
	#bp.param <- SnowParam(workers = 10, type = "SOCK")
	#bp.param <- MulticoreParam(workers = 10)
	bp.param <- SerialParam()
} else {
	#bp.param <- SnowParam(workers = threads.use, type = "SOCK")
	#bp.param <- MulticoreParam(workers = threads.use)
	bp.param <- SerialParam()
}

sample.control <- data.frame(case = opt$bam.file, controls = opt$bam.file)

species <- tolower(opt$species)
if(species == "mouse"){
	species.ref <- "mm10"
} else {
	species.ref <- "hg38"
}

resolution <- tolower(opt$res)
if(resolution == "200kb"){
	win.size <- "200kb"
	bin.size <- 200000
} else {
	win.size <- "1000kb"
	bin.size <- 1000000
}


dir.create(paste0("./copywriter/results-",win.size), recursive = T)
data.folder <- paste0("./copywriter/results-",win.size)
preCopywriteR(output.folder = file.path(data.folder),
              bin.size = bin.size,
              ref.genome = species.ref, prefix = "chr")

g<-CopywriteR(sample.control = sample.control,
           destination.folder = data.folder,
           reference.folder = file.path(paste0("./copywriter/results-",win.size,"/", species.ref, "_",win.size,"_chr/")),
           bp.param = bp.param)

plotCNA(destination.folder = data.folder,y.max=1.5,y.min=-1.5)
save.image()
