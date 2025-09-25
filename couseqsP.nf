nextflow.enable.dsl = 2
params.out = "${projectDir}/output"
params.downloadurl = "https://tinyurl.com/cqbatch1"
params.store = "${projectDir}/downloads"

// nextflow couseqsP.nf --downloadurl xxxx
// run like this to change download url in shell

process downloadFile {
    storeDir params.store
	publishDir "${projectDir}/output", mode: "copy", overwrite: true
	output:
		path "batch1.fasta"
	"""
		wget "${params.downloadurl}" -O batch1.fasta
	"""
}


//params.out
process countSeq {
    publishDir params.out, mode: "copy", overwrite: true
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
	downloadChannel = downloadFile()
	countSeq(downloadChannel)
    getFirstSeq(downloadChannel)
}