find matrix_files_$1/* -not -name "*.lst" -exec mv {} {}.lst \;
find matrix_files_$1/* -name "o*.lst" -exec ./tail_obs.sh {} \;

