{if ((substr($1,3,1) == "-") && (substr($2,1,1) != "-"))
     print $1 " " $2}
