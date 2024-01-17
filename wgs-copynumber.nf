/*
* CopywriteR Script
* for copy number calling from .bam files
* Nextflow Workflow
* Uses Singularity image containing CopywriteR and R 4.1.2
* Jan 2024, Joey Mays
*/

params.singularityPath = "/gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow/davolilab-copywriter-r4.1.2.sif"
params.scriptsPath = "/gpfs/data/davolilab/data/WGS/01-scripts/wgs-copynumber-workflow"

process COPYWRITER {
	
	tag "$sample_id"
	
	debug true
	
	executor = 'slurm'
        queue = 'cpu_short'
        time = '4h'
        memory = '10G'

	publishDir 'copywriter-output/copynumber-1000kb', mode: 'copy', pattern: '*/results-1000kb/**/*.pdf', saveAs: { "${file(it).name}" }
        publishDir 'copywriter-output/copynumber-200kb', mode: 'copy', pattern: '*/results-200kb/**/*.pdf', saveAs: { "${file(it).name}" }	
	
	stageInMode 'copy'
	
	input:
	tuple val(sample_id), path(bam)

	output:
	path 'copywriter/results-*/CNAprofiles/plots/*.vs.none/*.pdf'
	
	shell:
	'''
	module load singularity/3.9.8

	singularity exec --home $PWD:/mnt/ --bind !{params.scriptsPath}:/mnt/scripts/ !{params.singularityPath} Rscript scripts/copywriter-nf.R --bam.file=!{bam}
	'''

	stub:
        '''
        mkdir -p copywriter/results-1000kb/CNAprofiles/plots/test.vs.none
        mkdir -p copywriter/results-200kb/CNAprofiles/plots/test.vs.none
        echo "hello" > copywriter/results-1000kb/CNAprofiles/plots/test.vs.none/test-1000.pdf
        echo "hello" > copywriter/results-200kb/CNAprofiles/plots/test.vs.none/test-200.pdf
        '''
}

workflow {
	ch_bam_files = Channel.fromPath("bam/*.sorted.rmdup.bam", checkIfExists: true).view()
	ch_bam_samples = ch_bam_files.map { tuple(it.simpleName, it) }
	COPYWRITER(ch_bam_samples)	
}
