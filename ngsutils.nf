params.SRR = "SRR1777174"
params.out = "${projectDir}/output"
params.store = "${projectDir}/downloads"
params.with_fastqc = false
params.with_stats = false


process prefetch {
	storeDir params.store
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	output:
		path "${params.SRR}"
	"""
		prefetch ${params.SRR}
	"""
}

process fastDump {
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	input:
		path inputsrr
	output:
		path "${inputsrr.getSimpleName()}*.fastq"
	"""
		fastq-dump --split-files ${inputsrr}
	"""
}


process fastDump2 {
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	input:
		path inputsrr
	output:
		path "${inputsrr.getSimpleName()}.fastq"
	"""
		fastq-dump --split-3 ${inputsrr}
	"""
}


process ngsUtils {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
	input:
		path fastqfile
	output:
		path "SRRstats.txt"
	"""
		fastqutils stats ${fastqfile} > SRRstats.txt
	"""
}


process fastQC {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
	input:
		path fastqfile
	output:
		path "${fastqfile.getSimpleName()}*"
	"""
		fastqc ${fastqfile}
	"""
}




workflow {
	c1 = (prefetch | fastDump2)

	if (params.with_stats){
		ngsUtils(c1)
	}
	
	if (params.with_fastqc){
		fastQC(c1)
	}
}