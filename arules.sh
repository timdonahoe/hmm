dt=`echo $1 | sed 's/-//g'`
min_len=35
max_len=35
item_sets=0
support=.16

while [ $( echo "$support > .09" | bc) -eq 1 ] && [ "$item_sets" -lt "30" ]
do

echo "Support is " $support

while [ "$item_sets" -lt "30" ] && [ "$min_len" -gt "20" ]
do

echo "min_len is: " $min_len
date
R --save << EOF > eclat$1.log 2>&1 
ls()

library(arules)

candt=read.transactions("extract_files/$1.lst", format="single", cols=c(1,2))
dim(candt)
summary(candt)

candr=eclat(candt, parameter=list(support=$support, minlen=$min_len, maxlen=$max_len, target="maximally frequent itemsets", tidLists=FALSE))
summary(candr)

candrl$dt=as(items(candr), "list")
candtl$dt=as(candt, "list")

rm(candt)
rm(candr)

quit()
EOF

grep "set of" eclat$1.log > item_sets_count$1.txt
item_sets=`awk '{print $3}' item_sets_count$1.txt`
rm item_sets_count$1.txt
echo "item_sets: " $item_sets
if [ "$item_sets" -gt "1000" ] && [ "$min_len" -eq "35" ]; then
   min_len=51
   max_len=50
   item_sets=0
fi
min_len=$[$min_len-1]
done


if [ "$item_sets" -lt "30" ]; then
   support=`echo $support "-.01" | bc`
   min_len=35
fi

done
   

if [ "$item_sets" -ne "0" ]; then
R --save << EOF > tidlists_files/$1.log
ls()

outlist=c()
for (i in 1:length(candrl$dt)) {
  tidlists=c()
  for (j in 1:length(candtl$dt)) {
      misscnt=length(setdiff(candrl$dt[[i]], candtl$dt[[j]]))
      if (misscnt < 5) {
         tidlists=c(tidlists, names(candtl$dt[j]))
      }
  }
  outlist_line=list(item_list=mapply(c, candrl$dt[[i]]), dates=tidlists)
  outlist=c(outlist, outlist_line)
}

outlist

rm(candtl$dt)
rm(candrl$dt)
rm(i)
rm(j)
rm(misscnt)
rm(outlist)
rm(outlist_line)

quit()
EOF

awk -v d="$1" -f sum_eclat_results.awk eclat$1.log >> sum_results.log
echo "Support: " $support >> sum_results.log

else

R --save << EOF
ls()
rm(candtl$dt)
rm(candrl$dt)
quit()
EOF

fi

rm eclat$1.log
