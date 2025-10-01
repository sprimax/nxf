params.SRR = "SRR1777174"
params.out = "${projectDir}/output"
params.store = "${projectDir}/downloads"
params.with_stats = false
params.with_fastqc = false
params.with_fastp = false
params.accessionNs ="${projectDir}/accessions.txt"
/*
params.cut_window_size = 
params.cut_mean_quality
params.length_required
params.average_qual

*/

process prefetch {
	storeDir params.store
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
	//input:
	//	val accession
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


process fastp {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A1.0.1--heae3180_0"
	input:
		path fastqfile
	output:
		path "SRRpout.fastq"
		//path "${fastqfile.getSimpleName}_fastp.html"
		//path "${fastqfile.getSimpleName}_fastp.json"
		path "fastp.html"
		path "fastp.json"
	"""
		fastp -i ${fastqfile} -o SRRpout.fastq
	"""

// fastp -i ${fastqfile} -o SRRpout.fastq -h ${fastqfile.getSimpleName}_fastp.html j- ${fastqfile.getSimpleName}_fastp.json

// fastp -i in.fq -o out.fq
}

process fastp2 {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A1.0.1--heae3180_0"
	input:
		path fastqfile
	output:
		path "SRRpout.fastq"
		path "${fastqfile}_fastp.html"
		path "${fastqfile}_fastp.json"
	"""
		fastp -i ${fastqfile} -o SRRpout.fastq -h ${fastqfile}_fastp.html -j ${fastqfile}_fastp.json
	"""

// fastp -i ${fastqfile} -o SRRpout.fastq --html ${fastqfile.getSimpleName}_fastp.html --json ${fastqfile.getSimpleName}_fastp.json
}


process fastp3 {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A1.0.1--heae3180_0"
	input:
		path fastqfiles
	output:
		path "${fastqfile.getSimpleName()}*"
	"""
		python ${projectDir}/scripts/parallel.py -i ${fastqfiles} -o /path/to/output/folder -r /path/to/reports/folder -a '-f 3 -t 2'
	"""

}


workflow {

// accessions = channel.fromPath(params.accessionNs).splitText().map{it -> it.trim()}

	c1 = (prefetch | fastDump2)

/*
if (params.with_fastp){
	if (params.with_stats && params.with_fastqc){
		fastqp_ch = fastp(c1)
		both_ch = c1.concat(channel2)
		ngsUtils(both_ch)
	}
		fastp(c1)
	} else {
		print("No FastP - Add --with_fastp to nextflow command")
	}
*/
	fastp2(c1)

}

// singularity.runOptions = "--writable-tmpfs"

//Luis Version
/*
    if (params.with_fastqc == false && params.with_stats != false){
       c_run = ngsutils //without brackets
    } else if (params.with_fastqc != false && params.with_stats == false){
        c_run = fastqc
    } else {
        print ("Error: Please provide either --with_fastqc or --with_stats")
        System.exit(1)
    }
   
   prefetch | split | c_run
   */

