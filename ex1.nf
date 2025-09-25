nextflow.enable.dsl = 2
params.out = "${projectDir}/output"
params.downloadurl = "https://tinyurl.com/cqbatch1"
params.store = "${projectDir}/downloads"
params.prefix = "Seq_"
params.fileformat = ".fasta"

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
        path inputfile
	output:
		// path "Seq_*.fasta"
		path "${params.prefix}*${params.fileformat}"
	"""
		split -l 2 -d --additional-suffix ${params.fileformat} ${inputfile} ${params.prefix}
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

process countBases {
publishDir params.out, mode: 'copy', overwrite: true
input:
path infasta
output:
path "${infasta.getSimpleName()}_basecount.txt"
"""
tail -n 1 ${infasta} | wc -m > ${infasta.getSimpleName()}_basecount.txt
"""
}



workflow {

    /// downloadFile | countSeqs
    /// channel1 = ( process1 | process2 | process3)
	downloadChannel = downloadFile()
	countSeq(downloadChannel)
	
	// gives an error when not commented out
	// splitSequences(downloadChannel)

	// singlefastas = splitSequences(downloadChannel)
	// .flatten() enables to go through every single file
	// without flatten it will go through all the documents and gives out the sum
	singlefastas = splitSequences(downloadChannel).flatten()
	countBases(singlefastas)
}