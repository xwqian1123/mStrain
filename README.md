# mStrain
High-resolution target pathogen detection using metagenomic sequence data represents a major challenge due to the low concentration of target pathogens in samples. We introduced mStrain, a novel Yesinia pestis strain or lineage-level identification tool that utilizes metagenomic data. mStrain successfully identified Y. pestis at the strain/lineage level by extracting sufficient information regarding single nucleotide polymorphisms (SNPs), which can therefore be an effective tool for identification and source tracking of Y. pestis based on metagenomic data during plague outbreak.<br/>

# Software requirements <br/>
Kraken2 >=2.0.9 <br/>
Trimmomatic >=0.38 <br/>
samtools >=1.9 <br/>
bwa >=0.7.17 <br/>
bcftools =1.14 <br/>
bedtools =2.31.0 <br/>
pandas >=2.0.3 <br/>
picard =3.1.0<br/>
iqtree >=1.6.5 <br/>
ImageMagick =7.1.0_27 <br/>
jdk-20.0.2 <br/> 
R =3.6.3 <br/>
R: ggtree =2.0.4, ggplot2 =3.3.1, treeio, ape, tidyr, geiger, tibble <br/>

# Installation
### 1. Create a new environment <br/>
To create a new environment, you should use the conda command.<br/>
```
conda create -n py39 python=3.9.16
```
Activate the created environment.<br/>
```
conda activate py39
```
### 2. Clone this project <br/>
You can clone it to your local computer using Git<br/>
```
git clone https://github.com/xwqian1123/mStrain.git
```
### 3. Install the required dependencies software <br/>
You can run the script(run_install.sh) to install r-base=3.6.3, bcftools=1.14, samtools, iqtree, bwa, bedtools, kraken2, imagemagick, pandas, trimmomatic.<br/>
```
cd mStrain
chmod +x run_install.sh
./run_install.sh
```
NODE: Make sure that the dependent software is installed successfully.The software package "picard(https://github.com/broadinstitute/picard)" and some R packages on which this project depends, has been packaged and placed in the packages directory.

# Usage Examples

### Test data
You can  extract the local file "sim.fas.bz."<br/>
```
bzip2 -d sim.fastq.bz
```
You can also download test data from NCBI and put sim.fastq in the mStrain folder.<br/>
test_data:PRJNA941032 (https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA941032)；<br/>

### Folder structure
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
### example：
```
chmod +x run_mStrain.sh
./run_mStrain.sh
```
Explanation of parameters
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


