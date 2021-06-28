#!/bin/bash

OUT_DIR=/tmp/samba4dir
OUT_SHOWREPL=$OUT_DIR/showrepl.json
OUT_SHOWREPL_STATUS=$OUT_DIR/status
OUT_DB_STATUS=$OUT_DIR/dbcheck.json

if [ $# -eq 0 ]
  then
        echo "No arguments supplied, nothing to do!"
	      echo "Es: ./samba2.ad.sh doJson"
        echo "Es. ./samba2.ad.sh getJsonStatus"
        echo "Es. ./samba2.ad.sh getErrorFrom"
        echo "Es. ./samba2.ad.sh getErrorTo"
        echo "Es. ./samba2.ad.sh getFromErrorDetails"
        echo "Es. ./samba2.ad.sh getToErrorDetails"
        echo "Es. ./samba2.ad.sh getProcessCount"
        echo "Es: ./samba2.ad.sh doDbCheck"
        echo "Es. ./samba2.ad.sh getDbStatus"
        echo "Es. ./samba2.ad.sh getNTDSConnections"
	exit 1
fi

if [ "$1" == "doJson" ]; then 
	# make sure dir exits; else create it
	if [ ! -d $OUT_DIR ]
  then 
    mkdir -p $OUT_DIR
  fi
	#execute  drs showrepl with json output
	RESULT=$(samba-tool drs showrepl --json  )
	#check exit code, if is 0 let's create json files
	if [ $? -eq 0 ] 
	then
    #create a file showrepl.json
    echo "$RESULT" > "$OUT_SHOWREPL"
		echo 1 > $OUT_SHOWREPL_STATUS
	  exit 0
	else
    echo 0 > $OUT_SHOWREPL_STATUS
	  exit 1
	fi	
fi

if [ "$1" == "getJsonStatus" ]; then 
    cat $OUT_SHOWREPL_STATUS
fi

if [ "$1" == "getNTDSConnections" ]; then
    cat $OUT_SHOWREPL | jq '.NTDSConnections | map( with_entries( .key |= ( gsub( " "; "_") | ascii_upcase | "{#\(.)}"  )  | .value |= tostring)  ) '
fi

if [ "$1" == "getNTDSConnectionsDetails" ]; then
    cat $OUT_SHOWREPL | jq --arg key1 $2  '.NTDSConnections | map( select(.name | startswith($key1))   | with_entries( .key |= ( gsub( " "; "_") | ascii_upcase | "{#\(.)}"  )  | .value |= tostring)  ) '
fi

if [ "$1" == "getErrorFrom" ]; then 
    cat $OUT_SHOWREPL | jq '.repsFrom | map( select(.["consecutive failures"] > 0)  | with_entries( .key |= ( gsub( " "; "_") | ascii_upcase | "{#\(.)}"  )  | .value |= tostring)  ) | (.[]["{#NC_DN}"])|=(split(",")|join("_"))'
fi
if [ "$1" == "getErrorTo" ]; then 
    cat $OUT_SHOWREPL | jq '.repsTo | map( select(.["consecutive failures"] > 0)  | with_entries( .key |= ( gsub( " "; "_") | ascii_upcase | "{#\(.)}"  )  | .value |= tostring)  ) | (.[]["{#NC_DN}"])|=(split(",")|join("_"))'
fi

if [ "$1" == "getFromErrorDetails" ]; then 
    cat $OUT_SHOWREPL | jq --arg key1 ${2//_/,} --arg key2 $3 '.repsFrom | map( select(.["consecutive failures"] > 0 and (.["NC dn"] | startswith($key1)) and (.["DSA objectGUID"] | startswith($key2) ) )  |with_entries( .key |= ( gsub( " "; "_") | ascii_upcase | "{#\(.)}" ) | .value |= tostring) ) '
fi

if [ "$1" == "getToErrorDetails" ]; then
    cat $OUT_SHOWREPL | jq --arg key1 ${2//_/,} --arg key2 $3 '.repsTo | map( select(.["consecutive failures"] > 0 and (.["NC dn"] | startswith($key1)) and (.["DSA objectGUID"] | startswith($key2)) )  |with_entries( .key |= ( gsub( " "; "_") | ascii_upcase | "{#\(.)}" ) | .value |= tostring) ) '
fi

if [ "$1" == "getProcessCount" ]; then
     ps aux | grep $2 | wc -l
fi
if [ "$1" == "getDbStatus" ]; then
  cat $OUT_DB_STATUS
fi
if [ "$1" == "doDbCheck" ]; then
    #execute  dbcheck --cross-ncs --fix --yes
    RESULT=$(/usr/bin/samba-tool dbcheck --cross-ncs --fix --yes | /usr/bin/grep Checked )
    if [ $? -eq 0 ] 
	  then
      SAMBA4_DB_OBJ_ERROR=$( echo $RESULT | /usr/bin/awk '{print $4}'  | /usr/bin/cut -d "(" -f 2 )
      SAMBA4_DB_OBJ_TOTAL=$( echo $RESULT | /usr/bin/awk '{print $2}' )
      echo "{\"SAMBA4_DB_OBJ_CHECK\":1,\"SAMBA4_DB_OBJ_TOTAL\":"$SAMBA4_DB_OBJ_TOTAL",\"SAMBA4_DB_OBJ_ERROR\":"$SAMBA4_DB_OBJ_ERROR"}" > $OUT_DB_STATUS
    else
      echo "{\"SAMBA4_DB_OBJ_CHECK\":0,\"SAMBA4_DB_OBJ_TOTAL\":"$SAMBA4_DB_OBJ_TOTAL",\"SAMBA4_DB_OBJ_ERROR\":"$SAMBA4_DB_OBJ_ERROR"}" > $OUT_DB_STATUS
    fi
fi
