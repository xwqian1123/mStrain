#/bin/bash
mpath=$(cd $(dirname $0); pwd)

#bash $mpath/install_script/install.sh

python $mpath/main_code/process.py -i test.fq.ls  -r $mpath/ref/CO92.chr.fasta -o sim -m $mpath/ref/133s_2298p.txt -f $mpath/ref/133strain_branch_type.list -g IP32953_outgroup -trim_db $mpath/ref/trimmomatic.fa -d 3 -javapath $mpath/packages/jdk-20.0.2/bin/java -picardpath $mpath/packages/picard.jar -t 4 

