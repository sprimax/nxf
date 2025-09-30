params.SRR = "SRR1777174"
params.out = "${projectDir}/output"
params.store = "${projectDir}/downloads"


process prefetch {
	publishDir params.store, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	output:
		path "${params.SRR}"
	"""
		prefetch ${params.SRR}
	"""
}

process fastDump {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	input:
		path input
	output:
		path "${input}*.fastq"
	"""
		fastq-dump --split-files ${input}
	"""
}


process fastDump2 {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	input:
		path input
	output:
		path "${input}"
	"""
		fastq-dump --split-3 ${input}
	"""
}


process ngsUtils {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
	input:
		path input
	output:
		path "${input.baseName}*_stats.txt"
	"""
		fastqutils stats ${input} > ${input.baseName}_stats.txt
	"""
}


process ngsUtils2 {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
	input:
		path fastq_file from params.input_fastq
	output:
		path "stats/*.txt"
	"""
		fastq-utils stats $fastq_file > stats/${fastq_file.baseName}.stats.txt
	"""
}


workflow {
	(prefetch | fastDump2 | ngsUtils)

}