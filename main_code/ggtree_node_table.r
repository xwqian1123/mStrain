
library("ggplot2")
library("ggtree")
library('treeio')
library('ape')
library('tibble')
library('geiger')
library('tidyr')

args <- commandArgs(T)

tree = read.tree(args[1])
treedata=fortify(tree)

istruenum = length(subset(treedata,treedata$isTip == TRUE)$isTip)+1
dd<-treedata
all_lenth = length(treedata$isTip)
n=all_lenth - istruenum

ccc <- c(paste0('t',0:n))
dd[istruenum:all_lenth,]$label <- ccc

treenode <- read.table(args[2],header=T,sep='\t',check.names=F)
#treedata <- treedata %>%separate(label,c("strain","label"),"_")
nodeparent = unique (treedata$parent)
istruenume = length(subset(treedata,treedata$isTip == TRUE)$isTip)
tree$tip.label <-treedata$label[1:istruenume]
nodehead <- colnames(treenode) 

#aa <- list()
mydata <- data.frame()
get_loc<-function(a,b){
    child_name<-child(tree, a)
#    print(a)
   
    for (i in child_name){
        node_tip <- tips(tree, node=i)
	node_name<-match(node_tip,nodehead)
        dd<- paste('$',node_name,sep='')
        ss<- paste(dd,root_label,collapse = " && ",sep='')
	ANc_row<-paste('$',root_name,sep='')
	out_row<-paste('$1',dd[1],ANc_row,sep=',')
	ss<- paste(ss,out_row,root_name,a,i,sep='\t')
	ss<-noquote(ss)
	mydata <<- append( ss,mydata)
        get_loc(i)
    }
}

outgrup=args[3]
 
root_name<-match(outgrup,nodehead)
print (root_name)
root_label<-paste('!=$',root_name,sep='')
get_loc(root_name)

write.table(mydata,"result.csv",sep="\n",col.names = FALSE,row.names = FALSE)

#outgrup_node<-match('root',treedata$strain)
outgrup_node<-subset(treedata,treedata$label==outgrup)
tmp<-paste(outgrup_node$parent,outgrup_node$node,sep='_')
tmp_fl<-paste('mv ','new_node/',tmp,'.node.txt',' ./empty_node/',sep='')
write(tmp_fl, file = "parent.sh",stdout())
