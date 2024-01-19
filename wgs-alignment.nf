/*
* WGS Alignment Script
* Uses trimmomatic and bwa to trim and align fastq files
* Uses samtools to sort and remove duplicates from bam files
* Uses fastqc for QC, and multiqc to aggregate QC logs
* Nextflow Workflow
* Jan 2024, Joey Mays
*/

params.folder = "./"
params.format = "paired"
params.refPath = "/gpfs/data/davolilab/reference-genomes/ucsc-hg38/hg38.order/genome.fa"

process TRIMFASTQ {
	
	tag "$sample_prefix"
	
	executor = 'slurm'
	scratch = true
	queue = 'cpu_short'
	time = '2h'
	memory = '4G'

	input:
	tuple val(sample_prefix), path(reads)

	output:
	tuple val(sample_prefix), path("${sample_prefix}_{R1,R2}*.trim.fastq.gz")
	path "${sample_prefix}_{R1,R2}*.trim.fastq.gz"
	path "${sample_prefix}_trim.log"

	shell:
	'''
	module add trimmomatic/0.36

	java -Xms8G -Xmx8G -jar "${TRIMMOMATIC_ROOT}/trimmomatic-0.36.jar" \
	PE \
	-threads 40 \
	!{reads[0]} !{reads[1]} \
	"!{sample_prefix}_R1_001.trim.fastq.gz" "!{sample_prefix}_R1.unpaired.fastq.gz" \
	"!{sample_prefix}_R2_001.trim.fastq.gz" "!{sample_prefix}_R2.unpaired.fastq.gz" \
	ILLUMINACLIP:/gpfs/data/davolilab/reference-genomes/contaminants/trimmomatic.fa:2:30:10:1:true \
	TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:35 \
	2> "!{sample_prefix}_trim.log" 
	'''
}

process FASTQC {

        executor = 'slurm'
	//scratch = true
	queue = 'cpu_short'
	time = '20m'
	memory = '1G'

	input:
	path fastq_file
	
	output:
	path "*_fastqc.html"
	path "*_fastqc.zip"	

	shell:
	'''
	module add fastqc/0.11.7 	

	fastqc --outdir="./" !{fastq_file} 
	'''
	
	stub:
	'''
	echo !{fastq_file}
	'''
}

process BWA_MEM_ALIGN {
	
	tag "$sample_prefix"

	executor = 'slurm'
	//scratch = true
	queue = 'cpu_short'
	time = '4h'
	memory = '40G'
	cpus = 40

	publishDir "${params.folder}/bam", mode: 'copy'

	input:
	tuple val(sample_prefix), val(read_list)

	output:
	path "*.sorted.rmdup.bam"

	shell:
	'''
	module add bwa/0.7.17
	module add samtools/1.9-new

	prefix=$(basename !{read_list} | cut -d'_' -f1)
	
	bwa mem -t 40 !{params.refPath} !{read_list[0]} !{read_list[1]} > aligned.sam
	samtools view -S aligned.sam -b | samtools sort -o sorted.bam
	samtools rmdup sorted.bam "${prefix}.sorted.rmdup.bam"
	
	'''

	stub:
	'''
	echo "hello"
	'''
}

process MULTIQC {

	publishDir "${params.folder}", mode: 'copy', overwrite: true

	input:
	path '*'

	output:
	path 'qc_report.html'

	shell:
	'''
	module load condaenvs/2023/multiqc

	multiqc --filename="qc_report.html" . 
	'''
}		

workflow {
	ch_fastq = Channel.fromFilePairs("${params.folder}/fastq/*/*_{R1,R2}_*.fastq.gz", checkIfExists: true, size: 2) 
	(ch_trimmed, ch_trimmed_filenames, ch_trim_logs) = TRIMFASTQ(ch_fastq)
	(ch_fast_qc_html, ch_fast_qc_zip) = ch_trimmed_filenames.flatten() | FASTQC
	ch_alignment = BWA_MEM_ALIGN(ch_trimmed)
	MULTIQC(ch_fast_qc_zip.mix(ch_trim_logs).collect())
}
