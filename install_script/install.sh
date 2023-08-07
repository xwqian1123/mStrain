#!/bin/bash

path0=$(dirname "$PWD")
jhpath=$path0/mStrain/packages/jdk-20.0.2
shell_name=~/.$(basename "$SHELL")rc

echo -e "******************************** conda installs the following packages: ********************************\n[ r-base=3.6.3  bcftools=1.14  samtools  iqtree  bwa  bedtools  kraken2  imagemagick  pandas  trimmomatic ]\n"
conda install -y r-base=3.6.3 bcftools=1.14 samtools iqtree bwa bedtools kraken2 imagemagick pandas trimmomatic

echo "********************************** Install the R package **********************************"
Rscript $path0/mStrain/install_script/RPackage.r

#------ Check if the JDK directory exists ------
if [ -e "jdk-20.0.2" ]; then
    echo "The directory $path0/mStrain/jdk-20.0.2 exists, and it is being deleted."
    rm -rf jdk-20.0.2
fi

if [ -e "$path0/mStrain/packages/jdk-20.0.2" ]; then
    echo "The directory $path0/mStrain/packages/jdk-20.0.2 exists, and it is being deleted."
    rm -rf $path0/mStrain/packages/jdk-20.0.2
fi

echo "*************************** download jdk-20_linux-x64_bin.tar.gz ***************************"
if [ -e "jdk-20_linux-x64_bin.tar.gz" ]; then
    echo "File jdk-20_linux-x64_bin.tar.gz exists, delete jdk-20_linux-x64_bin.tar.gz"
    rm -rf jdk-20_linux-x64_bin.tar.gz
    echo "Download jdk-20_linux-x64_bin.tar.gz from https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz"
    wget https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz
    echo "extract jdk-20_linux-x64_bin.tar.gz"
    tar -xzvf jdk-20_linux-x64_bin.tar.gz
    mv jdk-20.0.2  $path0/mStrain/packages
else
    echo "The file jdk-20_linux-x64_bin.tar.gz does not exist. It will be downloaded from https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz"
    wget https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz
    echo "extract jdk-20_linux-x64_bin.tar.gz"
    tar -xzvf jdk-20_linux-x64_bin.tar.gz 
    mv jdk-20.0.2  $path0/mStrain/packages
fi

echo "*********************** Configure environment variables for jdk-20.0.2 ***********************"
# Define the string to search for
sstr1="export JAVA_HOME=\"$jhpath\""
sstr2="export PATH=\"\$JAVA_HOME/bin:\$PATH\""
sstr3="export LD_LIBRARY_PATH=\"\$JAVA_HOME/lib:\$LD_LIBRARY_PATH\""
# Define an array with multiple variables
parr=("$sstr1" "$sstr2" "$sstr3")

# Use a loop to traverse each element in the array and append it to the bashrc file
for index in "${!parr[@]}"; do

    element="${parr[$index]}"  
    echo "The index[$index] is: $element"

    if grep -q "^\s*${parr[$index]}" "$shell_name"; then
        echo "\"${parr[$index]}\" already exists, no longer written to \"$shell_name\""
    else
        echo "The \"${parr[$index]}\" does not exist and will be written to the \"$shell_name\""
        echo "${parr[$index]}" >> "$shell_name"
    fi

done


