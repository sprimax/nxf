nextflow.enable.dsl = 2
params.out = "${projectDir}/output"
params.downloadurl = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam?inline=false"
params.store = "${projectDir}/downloads"
params.prefix = "SamSeq"
params.fileformat = ".fasta"
params.indir = "input/"


process downloadFile {
	storeDir params.store
	output:
		path "sam1.sam"
	"""
		wget "${params.downloadurl}" -O sam1.sam
	"""
}

process removeTwoLines {
    input:
        path inputfile
	output:
		path "allLines.sam"
	"""
		tail -n +3 ${inputfile} > allLines.sam
	"""
}

process splitSeqs {
    input:
        path inputfile
	output:
		// path "Seq_*.fasta"
		path "${params.prefix}*${params.fileformat}"
	"""
		split -l 1 -d --additional-suffix ${params.fileformat} ${inputfile} ${params.prefix}
	"""
}

process countStart{
	input:
	path inputfiles
	output:
	path "${inputfiles.getSimpleName()}_startcount.txt"
	"""
		grep -o ATG ${inputfiles} | wc -l > ${inputfiles.getSimpleName()}_startcount.txt
	"""
}

process countStop{
	input:
	path inputfiles
	output:
	path "${inputfiles.getSimpleName()}_stopcount.txt"
	"""
		grep -o TAA ${inputfiles} | wc -l > ${inputfiles.getSimpleName()}_stopcount.txt
	"""
}

process countAllStop{
	input:
	path inputfiles
	output:
	path "${inputfiles.getSimpleName()}_stopAllcount.txt"
	"""
		grep -o -E "TAA|TGA|TAG" ${inputfiles} | wc -l > ${inputfiles.getSimpleName()}_stopAllcount.txt
	"""

}

process makeSummary{
	publishDir params.out, mode: 'copy', overwrite: true
	input:
	path inputfiles
	output:
	path "codons.csv"
	"""
		for f in \$(ls *count.txt); do echo -n "\$f, "; cat \$f; done > codons.csv
	"""
// for f in \$(ls ${inputfiles}); do echo -n "\$f, "; cat \$f; done > codons.csv


}

workflow {

	c1 = (downloadFile | removeTwoLines | splitSeqs | flatten)


	cStart = countStart(c1)
	cStop = countStop(c1)
	cAllStop = countAllStop(c1)

	cMerge = cStart.concat(cStop,cAllStop) | collect
/*
	cStart = countStart(c1) | collect
	cStop = countStop(c1) | collect
	cAllStop = countAllStop(c1) | collect

	cMerge = cStart
				.combine(cStop)
				.combine(cAllStop)
*/

	makeSummary(cMerge)

}