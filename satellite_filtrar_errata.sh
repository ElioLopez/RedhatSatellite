#!/bin/bash
#genera el archivo csv FULL_ERRATA_LIST_MATCH con las erratas vs hosts

HOST_ERRATA_LIST="errata_list_79.csv"

FULL_ERRATA_LIST="full_errata_list.csv" # todas las erratas, filtraddos los duplicados

ERRATA_LIST_MATCH="errata_list_match_79.csv"
FULL_ERRATA_LIST_MATCH="full_errata_list_match.csv"

HOST_ID_FILE="host_id_list.txt"
HOST_NAME_FILE="host_name_list.txt"
CDAD_ERRATAS=$(awk 'END{print NR}' $FULL_ERRATA_LIST)
CDAD_HOSTS=$(awk 'END{print NR}' $HOST_ID_FILE)

#proceso un host en particular
#while IFS='' read -r line_host || [[ -n "$line_host" ]]; do
for (( INDICE_HOST=1; INDICE_HOST<=CDAD_HOSTS; INDICE_HOST++))
	do

#traigo el nombre e ID
	HOST_ID=$(sed "${INDICE_HOST}q;d" $HOST_ID_FILE)
	HOST_NAME=$(sed "${INDICE_HOST}q;d" $HOST_NAME_FILE)

#echo $HOST_ID "," $HOST_NAME

#	los inserto como header en el archivo
	sed -i "1s/$/,${HOST_ID}/" $FULL_ERRATA_LIST_MATCH
	sed -i "2s/$/,${HOST_NAME}/" $FULL_ERRATA_LIST_MATCH
	HOST_ERRATA_LIST="errata_list_"${HOST_ID}".csv"

	#si el archivo es cero paso al siguiente
#	if [[ ! -s $HOST_ERRATA_LIST ]]; then HOST_ID=$((HOST_ID+1))++;  fi

	#recorro las erratas para el host en particular
#	while IFS='' read -r line || [[ -n "$line" ]]; do
	#arranco de la segunda linea porque la 1 es el header
	for (( LINEA_NRO=2; LINEA_NRO<=CDAD_ERRATAS; LINEA_NRO++))
	do
#	echo "linea" $LINEA_NRO
		INDICE_ERRATA=$((LINEA_NRO+2))
	        echo -ne "procesando host""("$INDICE_HOST"/"$CDAD_HOSTS")" "errata""("$LINEA_NRO"/"$CDAD_ERRATAS")  "\\r
#agregar echo -ne
                #traigo la linea que me interesa
	        ERRATA=$(sed "${LINEA_NRO}q;d" $FULL_ERRATA_LIST)
	        #trimeo solo el nombre de la errata
	        ERRATA=$(echo $ERRATA | cut -c-14)
	        #la busco en el archivo del host
	        ENCONTRADO=$(grep $ERRATA $HOST_ERRATA_LIST)
	
	        if [ "$ENCONTRADO" = "" ]
	        then
	            echo "0," >> $ERRATA_LIST_MATCH
		    sed -i "${INDICE_ERRATA}s/$/,0/" $FULL_ERRATA_LIST_MATCH
	        else
	            echo "1," >> $ERRATA_LIST_MATCH
	            sed -i "${INDICE_ERRATA}s/$/,1/" $FULL_ERRATA_LIST_MATCH
		fi
	done
#	done < $FULL_ERRATA_LIST

done

DATE=$(date +%d-%m-%Y"_"%H%M);
cp $FULL_ERRATA_LIST_MATCH "full_errata_list_match_"$DATE".csv"
rm -f errata*
rm -f sed*

