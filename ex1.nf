nextflow.enable.dsl = 2
params.out = "${projectDir}/output"
params.downloadurl = "https://tinyurl.com/cqbatch1"
params.store = "${projectDir}/downloads"
params.prefix = "Seq_"
params.fileformat = ".fasta"


process unsedPro {
    input:
        path inputfile
	output:
		path "${params.prefix}*${params.fileformat}"
	"""
	"""
}


process downloadFile {
	storeDir params.store
	output:
		path "batch1.fasta"
	"""
		wget "${params.downloadurl}" -O batch1.fasta
	"""
}

process splitSequences {
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
	input:
		path fastafile
	output:
		path "numseqs.txt"
	"""
		grep ">" ${fastafile} | wc -l > numseqs.txt
	"""
}

process countBases {
	input:
	path infasta
	output:
	path "${infasta.getSimpleName()}_basecount.txt"
	"""
		tail -n 1 ${infasta} | wc -m > ${infasta.getSimpleName()}_basecount.txt
	"""
}


process countRepeats{
	input:
	path inputfile
	output:
	path "repeatcount.txt"
	"""
		grep -o GCCGCG ${inputfile} | wc -l > repeatcount.txt
	"""
}

process countRepeats2{
	input:
	path inputfiles
	output:
	path "${inputfiles.getSimpleName()}_repeatcount.txt"
	"""
		grep -o GCCGCG ${inputfiles} | wc -l > ${inputfiles.getSimpleName()}_repeatcount.txt
	"""
}

process makeSummary{
	publishDir params.out, mode: 'copy', overwrite: true
	input:
	path inputfiles
	output:
	path "summary.csv"
	"""
		for f in \$(ls *.txt); do echo -n "\$f, "; cat \$f; done > summary.csv
	"""

}

process makeSummary2{
	publishDir params.out, mode: 'copy', overwrite: true
	input:
	path inputfiles
	output:
	path "summary2.csv"
	"""
		rm -f summary2.csv; for f in \$(ls split*_count.txt); do echo -n "\$f, " >> summary2.csv; cat \$f >> summary2.csv; done
	"""

}



workflow {
	downloadFile | splitSequences | flatten | countRepeats2 | collect | makeSummary
}