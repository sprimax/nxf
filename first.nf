nextflow.enable.dsl = 2

// This is a comment

// tells nextflow that this is a process with the name "downloadFile"
process downloadFile {

	// tells nextflow where the results directory is
	// publishDir "/home/dministrator/temp/fastaexample", mode: "copy", overwrite: true
	// publishDir "/home/dministrator/nxf/output", mode: "copy", overwrite: true
	//publishDir projectDir, mode: "copy", overwrite: true
	// projectDir is an output, variable and text need to be combined
	// ${} is like python's f-String, it keeps the variable inside a string
	publishDir "${projectDir}/output", mode: "copy", overwrite: true
	output:
		path "batch1.fasta"
	"""
		wget https://tinyurl.com/cqbatch1 -O batch1.fasta
	"""

}

workflow {
	downloadFile()
}