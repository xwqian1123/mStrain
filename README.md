## mStrain
[mStrain](https://academic.oup.com/bioinformaticsadvances/article/3/1/vbad115/7274857), a novel Yesinia pestis strain or lineage-level identification tool that utilizes metagenomic data, is written in python with a small amount of R and linux shell. mStrain successfully identified Y. pestis at the strain/lineage level by extracting sufficient information regarding single nucleotide polymorphisms (SNPs), which can therefore be an effective tool for identification and source tracking of Y. pestis based on metagenomic data during plague outbreak.<br/>

## Requirements
### 1. conda packages:
r-base =3.6.3 <br/>
bcftools =1.14 <br/>
samtools >=1.15 <br/>
iqtree >=2.2.2.7 <br/>
bwa >=0.7.17 <br/>
bedtools >=2.31.0 <br/>
Kraken2 >=2.0.9 <br/>
ImageMagick =7.1.0_27 <br/>
pandas >=2.0.3 <br/>
Trimmomatic >=0.39 <br/>
### 2. r packages:
ggtree =2.0.4,  ggplot2 =3.3.1,  treeio, ape,  tidyr, geiger,  tibble <br/>
### 3. source code:
[jdk-20.0.2](https://www.oracle.com/java/technologies/downloads/), [picard =3.1.0](https://github.com/broadinstitute/picard) <br/>

## Installation
### 1. A conda environment named ```mStrain``` can be created and activated with:
```
conda create -n mStrain python=3.9.16
conda activate mStrain
```
NOTE:
- mStrain is a customizable name for a new environment created using the conda command
- Installation, validation and usage are performed in this environment
### 2. Install dependencies required for mStrain
Clone this repository to local using git
```
git clone https://github.com/xwqian1123/mStrain.git
```
Add executable permission to the script 'run_install.sh' in the mStrain directory <br/>
```
cd mStrain
chmod +x run_install.sh
```
Run the script 'run_install.sh' in the mStrain directory to install conda packages, R packages and jdk-20.0.2<br/>
```
./run_install.sh
```
NOTE: 
- Make sure the dependencies are installed successfully.
- R packages and picard this project depends on have been packaged and placed in the mStrain/packages directory.
 
## Validation
The following validation of the mStrain was performed on the Ubuntu 23.0.4 operating system.
### 1. Dataset
In this work, sim.fastq, a simulated sequencing data set randomly extracted and mixed after simulated sequencing by Yesinia pestis [EV76](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/324/805/GCF_000324805.2_EV76-CN/GCF_000324805.2_EV76-CN_genomic.fna.gz) and human genome [hg38](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz), is used as a data set to validate mStrain. This repository already contains [sim.fastq](https://figshare.com/articles/dataset/mStrain_--_Strain-level_Identification_of_i_Yersinia_pestis_i_Using_Metagenomic_Data/23911053) data set you can unpack the file 'sim.fastq.bz2' in the mStrain directory using the bzip2 command to obtain.<br/>
```
cd mStrain
bzip2 -d sim.fastq.bz2
```

Package 'sim.fastq.bz2' successfully unpacked, the tree structure of the mStrain directory is as follows:
```
mStrain
├── install_script
│   ├── install.sh
│   ├── list.txt
│   └── RPackage.r
├── main_code
│   ├── get_node.py
│   ├── get_sh.sh
│   ├── get_target_gene.py
│   ├── ggtee_plot.R
│   ├── ggtree_node_table.r
│   ├── process.py
│   └── trantofa.py
├── packages
│   ├── jdk-20.0.2
│   ├── picard.jar
│   └── RPackages
├── README.md
├── ref
│   ├── 133s_2298p.txt
│   ├── 133strain_branch_type.list
│   ├── CO92.chr.fasta
│   ├── CO92.chr.fasta.amb
│   ├── CO92.chr.fasta.ann
│   ├── CO92.chr.fasta.bwt
│   ├── CO92.chr.fasta.fai
│   ├── CO92.chr.fasta.pac
│   ├── CO92.chr.fasta.sa
│   └── trimmomatic.fa
├── run_install.sh
├── run_mStrain.sh
├── sim.fastq
└── test.fq.ls
```
### 2. Run mStrain with dataset：
Add executable permission to the script 'run_mStrain.sh' in the mStrain directory <br/>
```
chmod +x run_mStrain.sh
```
Run the script 'run_mStrain.sh' in the mStrain directory with data set <br/>
```
./run_mStrain.sh
```
## Usage
mStrain is an extensible tool that allows the user to change the i, o, d, t, k, and k_db parameters to customize the run of mStrain.<br/>
### 1.

### 2. 

### 3.

Explanation of parameters in run_mStrain.sh
```
``python ./main_code/process.py -i test.fq.ls -r ./ref/CO92.chr.fasta -o sim -m ./ref/133s_2298p.txt -f ./ref/133strain_branch_type.list -g IP32953_outgroup -trim_db ./ref/trimmomatic.fa -d 3 -picardpath ./packages/picard.jar -t 4 -javapath ./packages/jdk-20.0.2/bin/java``

-r,  "--ref_seq",    help="reference genome file name"
-i,  "--input_file", help="input file name,inclue reads path sample name;eg:sample1\tsampe_1.fq\tsample_2.fq"
-o,  "--out_dir",    help="output folder name"
-n,  "--num",        default=4, type=int,help="samtools view filtering flag,default:4"
-m,  "--snp_matrix", help="the SNP loci of reference strain,outgroup is placed in the last column"
-f,  "--typefile",   help="the type list of reference strain"
-g,  "--outgroup",   help="customized outgroup_name"
-d,  "--deep",       default=3, type=int, help="sequencing deep,default:3"
-k,  "--kraken",     default=0, type=int, help="species identification,default:0,no running kraken;1,running kraken"
-t,  "--thread",     default=2,help="thread"
-k_db,  "--kraken_database",  help="kraken_database"
-trim_db, "--trim_database",  help="trim_database,this file can be obtained from https://github.com/usadellab/Trimmomatic/tree/main/adapters"
-picardpath, "--picardpath",  help="picardpath"
-javapath,  "--javapath",     help="javapath"

```


