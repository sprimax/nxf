params.SRR = "SRR1777174"
params.out = "${projectDir}/output"
params.store = "${projectDir}/downloads"
params.with_stats = false
params.with_fastqc = false
params.with_fastp = false



process prefetch {
	storeDir params.store
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.2.1--h4304569_1"
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
		path "fastp.html"
		path "fastp.json"
	"""
		fastp -i ${fastqfile} -o SRRpout.fastq
	"""

// fastp -i in.fq -o out.fq
}

process fastp2 {
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
	c1 = (prefetch | fastDump2)

	if (params.with_stats){
		ngsUtils(c1)
	} else {
		print("No Stats - Add --with_stats to nextflow command")
	}
	


	if (params.with_fastqc){
		fastQC(c1)
	} else {
		print("No FastQC - Add --with_fastqc to nextflow command")
	}


if (params.with_fastp){
		fastp(c1)
	} else {
		print("No FastP - Add --with_fastp to nextflow command")
	}

	fastp(c1)

}

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