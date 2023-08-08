#!/bin/bash

path0=$(dirname "$PWD")
jhpath=$path0/mStrain/packages/jdk-20.0.2
shell_name=~/.$(basename "$SHELL")rc

echo -e "******************************** conda installs the following packages: ********************************\n[ r-base=3.6.3  bcftools=1.14  samtools  iqtree  bwa  bedtools  kraken2  imagemagick  pandas  trimmomatic ]\n"
conda install -y r-base=3.6.3 bcftools=1.14 samtools iqtree bwa bedtools kraken2 imagemagick pandas trimmomatic

echo "********************************** Install the R package **********************************"
Rscript $path0/mStrain/install_script/RPackage.r

echo "************** Check if the jdk-20_linux-x64_bin.tar.gz and jdk-20.0.2 exists **************"
if [ -e "jdk-20_linux-x64_bin.tar.gz" ]; then
    echo "File jdk-20_linux-x64_bin.tar.gz exists, delete jdk-20_linux-x64_bin.tar.gz"
    rm -rf jdk-20_linux-x64_bin.tar.gz
fi

if [ -e "jdk-20.0.2" ]; then
    echo "The directory $path0/mStrain/jdk-20.0.2 exists, and it is being deleted."
    rm -rf jdk-20.0.2
fi

if [ -e "$path0/mStrain/packages/jdk-20.0.2" ]; then
    echo "The directory $path0/mStrain/packages/jdk-20.0.2 exists, and it is being deleted."
    rm -rf $path0/mStrain/packages/jdk-20.0.2
fi

echo "*************************** download jdk-20_linux-x64_bin.tar.gz ***************************"
wget https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz -O jdk-20_linux-x64_bin.tar.gz
# Obtain the sha256 checksum provided by the official publisher
expected_checksum="499b59be8e3613c223e76f101598d7c28dc04b8e154d860edf2ed05980c67526"
# Calculate the SHA-256 checksum of downloaded files
calculated_checksum=$(sha256sum jdk-20_linux-x64_bin.tar.gz | awk '{print $1}')

# Compare two checksums for equality
if [ "$expected_checksum" = "$calculated_checksum" ]; then
   echo "sha256sum matching, file jdk-20_linux-x64_bin.tar.gz download completed."
else
   echo "The sha256sum do not match, the file jdk-20_linux-x64_bin.tar.gz may not have downloaded completely or there may be a problem."
   echo "jdk-20_linux-x64_bin.tar.gz download failed!"
   exit 1
fi
# unpack jdk-20_linux-x64_bin.tar.gz and move it to directory mStrain/packages
echo "extracting jdk-20_linux-x64_bin.tar.gz :"
tar -xzvf jdk-20_linux-x64_bin.tar.gz
mv jdk-20.0.2  $path0/mStrain/packages

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


