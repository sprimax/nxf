nextflow.enable.dsl = 2
params.out = "${projectDir}/output"
params.downloadurl = "https://tinyurl.com/cqbatch1"
params.store = "${projectDir}/downloads"
params.prefix = "Seq_"

process downloadFile {
	storeDir params.store
	publishDir "${projectDir}/output", mode: "copy", overwrite: true
	output:
		path "batch1.fasta"
	"""
		wget "${params.downloadurl}" -O batch1.fasta
	"""
}

process splitSequences {
    
	publishDir params.out, mode: "copy", overwrite: true
    input:
        path infile
	output:
		path "Seq_*.fasta"
	"""
		split -l 2 -d --additional-suffix .fasta ${infile} params.prefix
	"""
}

// split -l 2 -d --additional-suffix .fasta batch1.fasta sequence_ 
// split -l 2 -d --additional-suffix .fasta batch1.fasta ${prefix}

workflow {

    /// downloadFile | countSeqs
    /// channel1 = ( process1 | process2 | process3)
	downloadChannel = downloadFile()
	splitSequences(downloadChannel)
}