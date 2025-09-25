nextflow.enable.dsl = 2



process downloadFile {
	publishDir "${projectDir}/output", mode: "copy", overwrite: true
	output:
		path "batch1.fasta"
	"""
		wget https://tinyurl.com/cqbatch1 -O batch1.fasta
	"""
}




process countSeq {
	publishDir "${projectDir}/output", mode: "copy", overwrite: true
	input:
		path fastafile // creates a link to the original input file. it is not a copy
	output:
		path "numseqs.txt"
	"""
		grep ">" ${fastafile} | wc -l > numseqs.txt
	"""
}

process getFirstSeq {
	publishDir "${projectDir}/output", mode: "copy", overwrite: true
	input:
		path inputfile
	output:
		path "firstSeq.fasta"
	"""
		head -n 2 ${inputfile} > firstSeq.fasta
	"""
}

workflow {

    /// downloadFile | countSeqs
    /// channel1 = ( process1 | process2 | process3)
	downloadChannel = downloadFile()
	countSeq(downloadChannel)
    getFirstSeq(downloadChannel)
}