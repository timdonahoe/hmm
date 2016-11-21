sqlplus stock/stock @extract1 $1

date

awk -f extract1.awk ex$1.lst > ex2$1.lst
mv ex2$1.lst extract_files/$1.lst
rm ex$1.lst
