#!/bin/bash

#leo la lista de hosts bajada del satelite y genero dos archivos separados con host Id y hostname 
# la reemplaza si existe
# se alimenta de "host_list_hammer_cruda.txt" 
SATELLITE_HOST="https://satellite.example.com"
HOST_ID_FILE="host_id_list.txt"
HOST_NAME_FILE="host_name_list.txt"
FULL_HOST_ERRATA_LIST="full_host_errata_list.csv" # errata de todos los hosts, ordenados y sin filtrar
FULL_ERRATA_LIST="full_errata_list.csv" # todas las erratas, filtraddos los duplicados
FULL_ERRATA_LIST_MATCH="full_errata_list_match.csv"
HOST_LIST_CRUDA="host_list_hammer_cruda.txt" #lista de hosts sin filtrar
TEMP_FILE="errata_temp.csv"
DIRECTORY="/root/.hammer/"
LINEA_NRO=0

#Creo el archivo .yaml para que no me pida password por cada comando del hammer

echo "usando: " $SATELLITE_HOST
echo -n "ingrese password: "
read -s PASSWORD

if [ ! -d "$DIRECTORY" ]; then
  # Si no existe el directorio se crea
  mkdir /root/.hammer/
fi

echo ":foreman:" > /root/.hammer/cli_config.yml
echo " :host: '"$SATELLITE_HOST"'" >> /root/.hammer/cli_config.yml
echo " :username: 'admin'" >> /root/.hammer/cli_config.yml
echo " :password: '"$PASSWORD"'" >> /root/.hammer/cli_config.yml

#actualizo la lista de hosts
echo "Actualizando lista de hosts..."
hammer host list > $HOST_LIST_CRUDA
echo "Echo."

#extraigo los nombres e ID de los hosts, a partir de la cuarta linea
awk 'NR > 3 {print $1}' $HOST_LIST_CRUDA | head -n -2 >  $HOST_ID_FILE
awk 'NR > 3 {print $3}' $HOST_LIST_CRUDA | head -n -1 >  $HOST_NAME_FILE

CDAD_HOSTS=$(awk 'END{print NR}' $HOST_ID_FILE)

#remuevo los archivos si existen
if [ -f "$FULL_HOST_ERRATA_LIST" ]; then
	rm $FULL_HOST_ERRATA_LIST
fi

#genero FULL_HOST_ERRATA_LIST
while IFS='' read -r line || [[ -n "$line" ]]; do
	LINEA_NRO=$((LINEA_NRO + 1))
	echo -ne "procesando host" $line "("$LINEA_NRO"/"$CDAD_HOSTS") "\\r 
	echo -n $line"," >> $FULL_HOST_ERRATA_LIST
	sed "${LINEA_NRO}q;d" $HOST_NAME_FILE >> $FULL_HOST_ERRATA_LIST	
        hammer host errata list --host-id $line | awk 'BEGIN{print "Erratum ID,URL-ID,Type,Details, ,"}NR>3{print $3","$1","$5","$7" "$8}' | head -n -1 | tee >> $FULL_HOST_ERRATA_LIST errata_list_$line.csv
done < $HOST_ID_FILE

#genero FULL_ERRATA_LIST
#remuevo duplicados
awk '!/./ || !seen[$0]++' $FULL_HOST_ERRATA_LIST > $FULL_ERRATA_LIST
#elimina las lineas que epiezan con numeros y lo guarda
sed -i -e '/^[0-9]/d' $FULL_ERRATA_LIST
#trimeo hasta la 4ta columna
awk -F, '{$5=""}1' OFS=, $FULL_ERRATA_LIST  | sed "s/^,//;s/,$//;s/,,/,/" > $TEMP_FILE
#saco 3er coma si existe
awk '{gsub(/,$/,""); print}' $TEMP_FILE > $FULL_ERRATA_LIST

#preparo el archivo para procesarlo
cp $FULL_ERRATA_LIST $FULL_ERRATA_LIST_MATCH
#agrego dos lineas con comas al principio
sed -i '1s/^/,, \n/' $FULL_ERRATA_LIST_MATCH
sed -i '1s/^/,, \n/' $FULL_ERRATA_LIST_MATCH

#elimino el .yaml
rm /root/.hammer/cli_config.yml
