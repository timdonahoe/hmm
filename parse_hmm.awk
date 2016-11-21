{
    getline;
    fd = $1 
    fu = $3
    getline;
    getline;
    pd = $1
    pu = $3
    if ( pd != "NaN") 
       print "insert into hmm_results values ('" s "', 'D', " fd ", '" i "', " pd ");"
    if ( pu != "NaN") 
       print "insert into hmm_results values ('" s "', 'U', " fu ", '" i "', " pu ");"
}
