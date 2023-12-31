import sys
import os
import datetime
import argparse
import pandas as pd
import trantofa
import get_node
import get_target_gene

Kraken_PATH='kraken2'
Kraken2_db='kraken2_db'
TRIM='trimmomatic'
f2path = os.path.abspath(__file__)
fd2path = os.path.dirname(f2path)
fd3path = os.path.dirname(fd2path)

# map raw to ref
def map_refseq(input_file,out_dir,ref_seq,n,thread,k=0,kraken_db=0):
    try:
        fidpath = os.path.join(fd3path, input_file)
        with open ('step_1.sh','w') as d:
            with open (fidpath,'r') as f:
                for num, line in enumerate(f):
                    arr=line.strip().split('\t')
                    path_name=os.path.dirname(arr[1])
                    sample_dir=os.path.join(out_dir,arr[0])
                    if os.path.exists(sample_dir):
                        print (sample_dir,'q')
                    else:
                        os.system('mkdir -p {}'.format(sample_dir))
                    sample_file=sample_dir+'/'+arr[0]+'_'+str(num)
                    os.system('bwa index {} '.format(ref_seq))
                    if len(arr) == 3:
                        if k==1:
                            d.write('kraken2 -db {} --output {} --report {}.report --classified-out {}.out --threads 50 {} {} \n'.format(kraken_db,sample_file,sample_file,sample_file,arr[1],arr[2]))
                            d.write("awk -F '\\t' '$3==632 {}' {} > {}.txt\n".format('{print $2}',sample_file,sample_file))
                            d.write('seqkit grep -f {}.txt {} {}> {}.fq \n'.format(sample_file,arr[1],arr[2],sample_file))
                            d.write('bwa mem -t {} {} {}.fq |samtools sort -@ {} - | samtools view -bF {} - > {}.map.bam\n'.format(thread,ref_seq,sample_file,thread,n,sample_file))
                            d.write('rm -rf {}.out\n'.format(sample_file))
                            d.write('rm -rf {}\n'.format(sample_file))
                        else:
                            d.write('bwa mem -t {} {} {} {} |samtools sort -@ {} - | samtools view -bF {} - > {}.map.bam \n'.format(thread,ref_seq,arr[1],arr[2],thread,n,sample_file))
                    if len(arr) == 2:
                        if k==1:
                            d.write('kraken2 -db {} --output {} --report {}.report --classified-out {}.out --threads 50 {} \n'.format(kraken_db,sample_file,sample_file,sample_file,arr[1]))
                            d.write("awk -F '\\t' '$3==632 {}' {} > {}.txt\n".format('{print $2}',sample_file,sample_file))
                            d.write('seqkit grep -f {}.txt {}> {}.fq\n'.format(sample_file,arr[1],sample_file))
                            d.write('bwa mem -t {} {} {}.fq |samtools sort -@ {} - | samtools view  -bF {} - > {}.map.bam \n'.format(thread,ref_seq,sample_file,thread,n,sample_file))
                            d.write('rm -rf {}\n'.format(sample_file))
                            d.write('rm -rf {}.out\n'.format(sample_file))
                        else:
                            d.write('bwa mem -t {} {} {} |samtools sort -@ {} - | samtools view -bF {} - > {}.map.bam \n'.format(thread,ref_seq,arr[1],thread,n,sample_file))
        os.system('sh {}'.format('step_1.sh'))
    except Exception as e:
        raise e
        sys.exit(1)

    
def call_snp(out_dir,ref_seq,javapath,picardpath,trim_db,thread):
    try:
        with open ('step_2.sh','w') as d:
            dirs = os.listdir(out_dir )
            for i in dirs:
                sample_dir=os.path.join(out_dir,i)
                sample_file=sample_dir+'/'+i
                d.write('samtools merge -@ {} -f {}.merge.bam {}/*.map.bam\n '.format(thread,sample_file,sample_dir))
                d.write('{} -Xmx2G -jar {} MarkDuplicates -REMOVE_DUPLICATES true -I {}.merge.bam -O {}.picard.rmdup.bam -M {}.rmdup.txt\n'.format(javapath,picardpath,sample_file,sample_file,sample_file))
                d.write('samtools view -h -F 256 {}.picard.rmdup.bam |grep -v XA:Z |grep -v SA:Z |samtools view -b - > {}.picard.rmdup.uniq.bam\n'.format(sample_file,sample_file))
                d.write('bamToFastq -i {}.picard.rmdup.uniq.bam -fq {}.picard.rmdup.uniq.tran.fq\n'.format(sample_file,sample_file))
                d.write('trimmomatic SE -threads {} {}.picard.rmdup.uniq.tran.fq {}.picard.rmdup.uniq.tran.trim.fq.gz ILLUMINACLIP:{}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:5:20 MINLEN:100 AVGQUAL:20 TOPHRED33\n'.format(thread,sample_file,sample_file,trim_db))
                d.write('bwa mem -t {} {} {}.picard.rmdup.uniq.tran.trim.fq.gz |samtools sort -@ {} -o  {}.sec.bam\n'.format(thread,ref_seq,sample_file,thread,sample_file))
                d.write('bcftools mpileup --fasta-ref {} {}.sec.bam -a"DP,AD,INFO/AD" -Q 30 |bcftools view -V indels > {}.bcf\n'.format(ref_seq,sample_file,sample_file))
                d.write("sed -n '28,$p' {}.bcf > {}.tmp.bcf\n".format(sample_file,sample_file))

        os.system('sh {}'.format('step_2.sh'))      
    except Exception as e:
        raise e
        sys.exit(1)


def visual_result(out_dir,deep,out_group,type_list):
    try:
        dirs = os.listdir(out_dir )
        for i in dirs:
            sample_dir=os.path.join(out_dir,i)
            sample_file=sample_dir+'/'+i
            get_target_gene.main(sample_dir,i,deep)
            filt_snp=sample_file+'.filt.txt'
            size_b = os.path.getsize(filt_snp)
            if os.path.exists(filt_snp):
                os.system("R --slave --file={}/ggtee_plot.R --args {} {} {}".format(fd2path,out_group,sample_file,type_list))
            else:
                if size_b == 0:
                    print (sample_file + 'no SNP')
    except Exception as e:
        raise e
        sys.exit(1)

def strain_type(a,b):
    try:
        snp=pd.read_csv(a,header=0,sep='\t',index_col=0,encoding='unicode_escape')
        strain=pd.read_csv(b,sep='\t',header=None)
        cOlumns={}
        for row in strain.itertuples():
            cOlumns[row._1]=row._1+'_'+row._2
        snp.rename(columns=cOlumns,inplace=True)
        snp.to_csv('SNP.matrix.txt',sep='\t')
    except Exception as e:
        raise e
    

def get_nodefile(matrix,outgroup,typefile):
    try:
        fa_file = 'SNP.matrix.fa'
        strain_type(matrix,typefile)
        trantofa.main ('SNP.matrix.txt',fa_file)
        os.system('iqtree -s {} -o {} '.format(fa_file,outgroup))
        get_node.main('SNP.matrix.fa.treefile','SNP.matrix.txt',outgroup)
    except Exception as e:
        raise e

def parameters():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--ref_seq", help="reference genome file name")
    parser.add_argument("-i", "--input_file", help="input file name,inclue reads path sample name")
    parser.add_argument("-o", "--out_dir", help="output folder name")
    parser.add_argument("-n", "--num", default=4, type=int,help="samtools view filtering flag,default:4")
    parser.add_argument("-m", "--snp_matrix", help="the SNP loci of reference strain,outgroup is placed in the last column")
    parser.add_argument("-f", "--typefile", help="the type list of reference strain")
    parser.add_argument("-g", "--outgroup", help="customized outgroup_name")
    parser.add_argument("-d", "--deep",default=3, type=int,  help="sequencing deep,default:3")
    parser.add_argument("-k", "--kraken",default=0, type=int, help="species identification,default:0,no running kraken;1,running kraken")
    parser.add_argument("-k_db", "--kraken_database", help="kraken_database")
    parser.add_argument("-trim_db", "--trim_database", help="trim_database")
    parser.add_argument("-picardpath","--picardpath",help="picardpath")
    parser.add_argument("-javapath","--javapath",help="javapath")
    parser.add_argument("-t","--thread",default=2,help="thread")
    args = parser.parse_args()
    help = parser.format_help()

    return args, help

def main():
    args, help = parameters()
    print ("\n----- Step0: get_nodefile and tree ----\n")
    if os.path.exists('SNP.matrix.fa.treefile') and os.path.exists('node_file.txt') :
        print ('file exit')
    else:   
        if args.snp_matrix:
            get_nodefile(args.snp_matrix,args.outgroup,args.typefile)
        else:
            print (help)
            sys.exit(1)
 
    print ("\n----- Step1: mapping raw to reference  -----\n")
    if args.ref_seq and args.input_file and args.out_dir:
        map_refseq(args.input_file,args.out_dir,args.ref_seq,args.num,args.thread,args.kraken,args.kraken_database)
    else:
        print (help)
        sys.exit(1)
    
    print ("\n----- Step2: mul-step call SNPs -----\n")
    call_snp(args.out_dir,args.ref_seq,args.javapath,args.picardpath,args.trim_database,args.thread)

    print ("\n----- step3: visual result -----\n")
    visual_result(args.out_dir,args.deep,args.outgroup,args.typefile)
    
    now = datetime.datetime.now()
    print ('endnowtima：'+now.strftime("%y-%m-%d %h:%m:%s"))



if __name__ == '__main__':
    now = datetime.datetime.now()
    print ('startnowtima：'+now.strftime("%Y-%m-%d %H:%M:%S"))
    main()

