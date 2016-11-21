{
 if ($1 == "\$item_list")
    {
      getline;
      IL=""
      while ($0 != "") {
        ILL = $1 ","  $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 "," $9 "," $10 "," $11 ","
        IL = IL ILL
        getline
        getline
      }
  
    }
 if ((substr($2,1,1) == "\"") && (IL != ""))
 {
 if (substr($2,2,9) != "")
    print "insert into hmm_tid_lists values ('" IL "', '" substr($2,2,9) "' );"
 if (substr($3,2,9) != "")
    print "insert into hmm_tid_lists values ('" IL "', '" substr($3,2,9) "' );"
 if (substr($4,2,9) != "")
    print "insert into hmm_tid_lists values ('" IL "', '" substr($4,2,9) "' );"
 if (substr($5,2,9) != "")
    print "insert into hmm_tid_lists values ('" IL "', '" substr($5,2,9) "' );"
 if (substr($6,2,9) != "")
    print "insert into hmm_tid_lists values ('" IL "', '" substr($6,2,9) "' );"
 if (substr($7,2,9) != "")
    print "insert into hmm_tid_lists values ('" IL "', '" substr($7,2,9) "' );"
 }
}
