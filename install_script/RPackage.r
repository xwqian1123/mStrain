r1path=getwd()
r2path=dirname(r1path)
fullpath=paste(r1path,"packages/RPackages",sep="/")
sprintf("R packages are stored in: %s", fullpath)
print("------------------------Installing R packages------------------------")
list_path=paste(r1path,"install_script/list.txt",sep="/")
sprintf("list.txt file are stored in: %s", list_path)
file_content <- readLines(list_path)
print("Prepare to install the following R packages:")
print(file_content)
#sprintf("Prepare to install the following R packages: %s", file_content)
file_content_list <- as.list(file_content)

for (i in file_content_list) {	
	tmp_path=paste(fullpath,i,sep="/")
	print(tmp_path)
	install.packages(tmp_path)
}
