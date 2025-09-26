nextflow.enable.dsl = 2
params.out = "${projectDir}/output"
params.downloadurl = "https://tinyurl.com/cqbatch1"
params.store = "${projectDir}/downloads"
params.prefix = "Seq_"
params.fileformat = ".fasta"
params.indir = "input/"


process unUsedPro {
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
		rm -f summary2.csv; for f in \$(ls Seq_*_repeatcount.txt); do echo -n "\$f, " >> summary2.csv; cat \$f >> summary2.csv; done
	"""

}

// Luise Version with cut and sort
process makeSummary3{
	publishDir params.out, mode: 'copy', overwrite: true
	input:
	path inputfiles
	output:
	path "summary3.csv"
	"""
		for i in ${inputfiles}; do
			echo -n "\$i" | cut -d "_" -f 2 | tr -d "\n"
			echo -n ", "
			cat \$i
		done > summary_unsorted.csv
		cat summary_unsorted.csv | sort > summary3.csv
	"""

}
// cut out number of file
// , space behind number
//content of file

workflow {
	// fastafile = Channel.fromPath("${params.indir}*${params.fileformat}")
	c1 = (downloadFile | splitSequences | flatten | countRepeats2 | collect)
	makeSummary(c1)
	makeSummary2(c1)
	// downloadFile | splitSequences | flatten | countRepeats2 | collect | makeSummary
}