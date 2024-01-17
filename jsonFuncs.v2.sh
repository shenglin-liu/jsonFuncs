# Bash functions for parsing json files and fetching values.
# By Shenglin Liu, on Jul 25, 2022.

# Release note of v2:
# Improvement from v1:
#	Render array as object; particularly useful when elements are objects containing a lot of information.
#	Colon problem in get_json_values is fixed; replace "print v[2]".
#	gawk convention in 3col2mat.

# Syntax requirements for json input:
#	No line-breaking within quotes; otherwise ignored; "\n" is allowed. ("fold -w1" ignores line-breaking.)
#	No TABs within quotes; "\t" is allowed. (Output is tab-delimited.)
#	No colons within object names. (Object names are not quoted in output, and colon delimits name and value.)
#	No empty string for a name or value in a "name:value" pair. (Emptiness represents non-existence by the script.)
#	Do not use single character of "*" for a name. ("*" has syntactic meaning in get_json_values.)

# To improve: a function for checking the syntactic validity of a json file.

get_json_data() { fold -w1 $1 | awk '
 BEGIN{lo=0;la=0;qt=0;nm="";vl=""}
 function myprint(){
  for(i=1;i<(lo+la);i++)printf "\t";
  print nm":"vl;
  nm="";vl=""}
 qt==0{
  if(/[ \t]/){next}
  if($0=="{"){if(lo!= 0){if(nm==""){nm="["ia[la]"]";ia[la]++}myprint()}lo++;next}
  if($0=="}"){if(vl!="")                                     myprint();lo--;next}
  if($0=="["){           if(nm==""){nm="["ia[la]"]";ia[la]++}myprint();la++;ia[la]=0;next}
  if($0=="]"){if(vl!=""){if(nm==""){nm="["ia[la]"]";ia[la]++}myprint()}la--;next}
  if($0==","){if(vl!=""){if(nm==""){nm="["ia[la]"]";ia[la]++}myprint()}next}
  if($0==":"){nm=vl;vl="";gsub(/^\"|\"$/,"",nm);next}
  if($0=="\""){qt++}
  vl=vl$0;next}
 {vl=vl$0;
  if($0=="\\"){getline;vl=vl$0;next}
  if($0=="\""){qt--}
 }'; }

get_json_struc() { fold -w1 $1 | awk '
 BEGIN{lo=0;la=0;qt=0;nm="";vl=""}
 function myprint(){
  for(i=1;i<(lo+la);i++)printf "\t";
  print nm;
  nm="";vl=""}
 qt==0{
  if(/[ \t]/){next}
  if($0=="{"){if(lo!= 0){if(nm==""){nm="["ia[la]"]";ia[la]++}myprint()}lo++;next}
  if($0=="}"){if(vl!="")                                     myprint();lo--;next}
  if($0=="["){           if(nm==""){nm="["ia[la]"]";ia[la]++}myprint();la++;ia[la]=0;next}
  if($0=="]"){if(vl!=""){if(nm==""){nm="["ia[la]"]";ia[la]++}myprint()}la--;next}
  if($0==","){if(vl!=""){if(nm==""){nm="["ia[la]"]";ia[la]++}myprint()}next}
  if($0==":"){nm=vl;vl="";gsub(/^\"|\"$/,"",nm);next}
  if($0=="\""){qt++}
  vl=vl$0;next}
 {vl=vl$0;
  if($0=="\\"){getline;vl=vl$0;next}
  if($0=="\""){qt--}
 }'; }
# get_json_data and get_json_struc only differ at "print".

get_json_values() { get_json_data $1 | awk '
 BEGIN{FS="\t";n_star=0;n_col=split("'"$2"'",to_fetch,":");
  for(i=1;i<=n_col;i++)if(to_fetch[i]=="*"){n_star++;star_col[i];stars[n_star]=i}}
 {split($NF,v,":");a[NF]=v[1]}
 NF!=n_col{next}
 {for(i=1;i<=n_col;i++){if(i in star_col)continue;if(a[i]!=to_fetch[i])next}}
 {for(i=1;i<=n_star;i++)printf a[stars[i]]"\t";gsub(/^[^:]*:/,"",$NF);print $NF}'; }

# Converte a three-columned 2-D data (rowname, colname, value) to a matrix.
#	Tab-delimited for both input and output.
3col2mat() { gawk 'BEGIN{FS="\t";m=0;n=0}
 {if(!($1 in x)){m++;x[$1];xx[m]=$1}
  if(!($2 in y)){n++;y[$2];yy[n]=$2}
  v[$1][$2]=$3}
 END{for(j=1;j<=n;j++)printf "\t%s",yy[j];printf "\n";
  for(i=1;i<=m;i++){
   printf "%s",xx[i];
   for(j=1;j<=n;j++)printf "\t%s",v[xx[i]][yy[j]];
   printf "\n"}}'; }
