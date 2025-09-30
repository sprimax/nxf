
process prefetch {
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	output:
		path "SRR1777174"
	"""
		prefetch SRR1777174
	"""
}


workflow {
	prefetch()

}