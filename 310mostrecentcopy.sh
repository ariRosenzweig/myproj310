getSearch () {
#echo "enter first name"
fname="$1"
#echo "enter last"
lname="$2"
str="$3"
#echo "enter location"
#read location
search=$(curl -s "https://www.legacy.com/obituaries/legacy/obituary-search.aspx?daterange=99999&lastname=${lname}&keyword=${fname^}&countryid=1&stateid=all&affiliateid=all")
numresults=$(echo "$search" | pup '#ctl00_ctl00_ContentPlaceHolder1_ContentPlaceHolder1_uxSearchLinks_Message span text{}')
apiurl=$(echo "$search"| pup '#aspnetForm'| grep 'wsUrl'| tr -d ','| awk  '{print $2}'| tr -d "'")
}

getApi () {
api=$(curl -s $apiurl)
}
getApistats() {
pagesleft=$(echo "$api" | jq '.NumPageRemaining')
resultspp=$(echo "$api" | jq '.EntriesPerPage')
total=$(echo "$api" | jq '.Total')
}

transform () { while read line; do  echo $line|sed 's/&pid/-obituary?pid/g'|  awk -F/ '{print $6 }'| sed 's;obituary.aspx?n=;"https://www.legacy.com/obituaries/name/;g'; done; }


extractLinks () { 
echo "$api" | jq  ".Entries[]| select(.obithtml| contains(\"${str^}\")).obitlink"| transform| grep 'www.legacy.com'| tr -d '"'
}

getLinks () {
n=1
list=' '
page=$apiurl
until [ $pagesleft -eq 0 ]
do
 apiurl="$page&Page=$n"
 getApi
 lnkz=$(extractLinks)
 list+="$lnkz"$'\n' 
 getApistats
 ((n=$n+1))
done
#echo "$list"| sed '/^$/d'
}


extractText () {
el=$(curl -s -L $line | pup 'script:nth-child(11) text{}'| sed 's/  window.__INITIAL_STATE__ = //g'| sed 's/;//g')
tex=$(echo "$el"| jq ".personStore.displayText.fullSanitized"| sed 's/<[^>]*>/ /g')
nms=$(echo "$el"| jq ".personStore.name"| sed 's/<[^>]*>/ /g')
loc=$(echo "$el"| jq ".personStore.location"| sed 's/<[^>]*>/ /g')
}



func3 () {  
getSearch $1 $2 $3 
getApi
getApistats
if (($pagesleft==0))
then
   extractLinks | sed '/^$/d'| while read line
   do
    extractText
    echo "{\"text\": $tex, \"name\": $nms, \"location\": $loc}"
   done
else
  getLinks
  echo "$list"| sed '/^$/d'| while read line
  do
   extractText
   echo "{\"text\": $tex, \"name\": $nms, \"location\": $loc}"
  done
fi      
}