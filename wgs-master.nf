/*
* WGS Alignment and Copy Number Calling
* Master script, runs `wgs-alignment.nf` and `wgs-copynumber.nf` together
* Nextflow Workflow
* Jan 2024, Joey Mays
*/

params.singularityPath = "/gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/davolilab-copywriter-r4.1.2.sif"
params.scriptsPath = "/gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow"
params.folder = "./"
params.format = "paired"
params.hg38RefPath = "/gpfs/data/davolilab/reference-genomes/ucsc-hg38/hg38.order/genome.fa"

include { TRIMFASTQ; FASTQC; BWA_MEM_ALIGN; MULTIQC } from "./wgs-alignment.nf"
include { COPYWRITER } from "./wgs-copynumber.nf"

workflow {
        ch_fastq = Channel.fromFilePairs("${params.folder}/fastq/*/*_{R1,R2}_*.fastq.gz", checkIfExists: true, size: 2)
        (ch_trimmed, ch_trimmed_filenames, ch_trim_logs) = TRIMFASTQ(ch_fastq)
	(ch_fast_qc_html, ch_fast_qc_zip) = ch_trimmed_filenames.flatten() | FASTQC
	MULTIQC(ch_fast_qc_zip.mix(ch_trim_logs).collect())	
	ch_bam_files = BWA_MEM_ALIGN(ch_trimmed)
	ch_bam_samples = ch_bam_files.map { tuple(it.simpleName, it) }
	COPYWRITER(ch_bam_samples)
}


