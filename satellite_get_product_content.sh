#!/bin/bash

# 01-03-2018
# Ejecuto el auto-attach en los servers
HOST_LIST_CRUDA="host_list_hammer_cruda.txt" #lista de hosts sin filtrar
HOST_NAME_FILE="host_name_list.txt"
HOST_ID_FILE="host_id_list.txt"
SATELLITE_HOST="https://satellite.example.com"
DIRECTORY="/root/.hammer/"
DIRECTORY_PRODUCT_CONTENT="product_content"

#Creo el archivo .yaml para que no me pida password por cada comando del hammer

echo "usando: " $SATELLITE_HOST
echo "ingrese password: "
read -s PASSWORD

if [ ! -d "$DIRECTORY" ]; then
  # Si no existe el directorio se crea
  mkdir /root/.hammer/
fi

if [ ! -d "$DIRECTORY_PRODUCT_CONTENT" ]; then
  # Si no existe el directorio se crea
  mkdir $DIRECTORY_PRODUCT_CONTENT
fi

echo ":foreman:" > /root/.hammer/cli_config.yml
echo " :host: '"$SATELLITE_HOST"'" >> /root/.hammer/cli_config.yml
echo " :username: 'admin'" >> /root/.hammer/cli_config.yml
echo " :password: '"$PASSWORD"'" >> /root/.hammer/cli_config.yml

#actualizo la lista de hosts
echo "Actualizando lista de hosts..."
#hammer host list > $HOST_LIST_CRUDA
echo "Echo."

#extraigo los nombres de los hosts, a partir de la cuarta linea
awk 'NR > 3 {print $1}' $HOST_LIST_CRUDA | head -n -2 >  $HOST_ID_FILE
awk 'NR > 3 {print $3}' $HOST_LIST_CRUDA | head -n -1 >  $HOST_NAME_FILE

LINEA_NRO=0
CDAD_HOSTS=$(awk 'END{print NR}' $HOST_NAME_FILE)

while IFS='' read -r line || [[ -n "$line" ]]; do
        LINEA_NRO=$((LINEA_NRO + 1))
        echo -ne "trayendo product content de host " $line "("$LINEA_NRO"/"$CDAD_HOSTS") "
	HOST_ID=$(sed "${LINEA_NRO}q;d" $HOST_ID_FILE)
	curl -X GET -k -u admin:${PASSWORD} https://ansessatellite.anses.gov.ar/api/hosts/${HOST_ID}/subscriptions/product_content | python -m json.tool > product_content_${HOST_ID}.yaml

done < $HOST_NAME_FILE

#muevo todo al directorio  de product content
cp *.yaml $DIRECTORY_PRODUCT_CONTENT
rm *.yaml

#elimino el .yaml
rm /root/.hammer/cli_config.yml

