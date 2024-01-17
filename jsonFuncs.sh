# Get json structure (generic).
get_json_struc() { fold -w1 $1 | awk '
 BEGIN{level=0;cc=0;sb=0;qt=0}
 (qt==0)&&(sb==0)&&(/{/){level++;next}
 (qt==0)&&(sb==0)&&(/}/){if(cc==level)cc--;level--;next}
 (qt==0)&&(sb==0)&&(/:/){cc++;next}
 (qt==0)&&(sb==0)&&(/,/){cc--;next}
 (qt==0)&&(/\[/){sb++;next}
 (qt==0)&&(/\]/){sb--;next}
 (qt==0)&&(/"/){qt++;if(cc==(level-1))for(i=1;i<level;i++)printf "\t";next}
 (qt==1)&&(/\\/){
  if(cc==(level-1))printf "%s",$0;
  getline;
  if(cc==(level-1))printf "%s",$0;
  next}
 (qt==1)&&(/"/){qt--;if(cc==(level-1))printf "\n";next}
 (qt==1)&&(cc==(level-1)){printf "%s",$0}'; }
# Potential bug: backslash followed by end-of-line.
# End-of-line is ignored in every context because of "fold -w1".

# Extract json data (generic).
get_json_data() { fold -w1 $1 | awk '
 BEGIN{level=0;cc=0;sb=0;qt=0;fl=1}
 (qt==0)&&(/[ \t]/){next}
 (qt==0)&&(sb==0)&&(/{/){level++;next}
 (qt==0)&&(sb==0)&&(/}/){if(cc==level)cc--;level--;next}
 (qt==0)&&(sb==0)&&(/:/){cc++;printf ":";next}
 (qt==0)&&(sb==0)&&(/,/){cc--;next}
 (qt==0)&&(/\[/){sb++}
 (qt==0)&&(/\]/){sb--}
 (qt==0)&&(/"/){qt++;if(cc==(level-1)){
   if(fl==0)printf "\n";else fl--;
   for(i=1;i<level;i++)printf "\t"}
  else printf "\"";next}
 (qt==1)&&(/\\/){printf "%s",$0;getline;printf "%s",$0;next}
 (qt==1)&&(/"/){qt--;if(cc==(level-1))next}
 {printf "%s",$0}
 END{printf "\n"}'; }
# Potential bug: backslash followed by end-of-line.
# End-of-line is ignored in every context because of "fold -w1".

# Extract json values (generic).
get_json_values() { get_json_data $1 | awk '
 BEGIN{FS="\t";m=0;n=split("'"$2"'",tf,":");
  for(i=1;i<=n;i++)if(tf[i]=="*"){m++;s[i];ss[m]=i}}
 {split($NF,v,":");a[NF]=v[1]}
 NF!=n{next}
 {for(i=1;i<=n;i++){if(i in s)continue;if(a[i]!=tf[i])next}}
 {for(i=1;i<=m;i++)printf a[ss[i]]"\t";print v[2]}'; }
# Bug: ":" within quotes.

# Converte a three-columned 2-D data ((x,y)=value) to a matrix.
#	Tab-delimited for both input and output.
3col2mat() { awk 'BEGIN{FS="\t";m=0;n=0}
 {if(!($1 in x)){m++;x[$1];xx[m]=$1}
  if(!($2 in y)){n++;y[$2];yy[n]=$2}
  v[$1][$2]=$3}
 END{for(j=1;j<=n;j++)printf "\t"yy[j];printf "\n";
  for(i=1;i<=m;i++){
   printf xx[i];
   for(j=1;j<=n;j++)printf "\t"v[xx[i]][yy[j]];
   printf "\n"}}'; }
