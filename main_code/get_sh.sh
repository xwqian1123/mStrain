mkdir all_node
mkdir new_node
mkdir empty_node

sh get_all.sh
sh get_new.sh

find -type f -empty -exec mv {} empty_node \;
sh parent.sh

rm -rf node_file.txt

for i in new_node/*.node.txt
do
        b=$(basename $i)
        c=${b%%.*}
        awk -F '\t' -v a=$c '{print $0,a}' $i >> node_file.txt
done

