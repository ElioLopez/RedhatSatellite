#!/bin/bash

# 01-03-2018
# Ejecuto el auto-attach en los servers
HOST_LIST_CRUDA="host_list_hammer_cruda.txt" #lista de hosts sin filtrar
HOST_NAME_FILE="host_name_list.txt"
SATELLITE_HOST="https://satellite.examplecom"
DIRECTORY="/root/.hammer/"

#Creo el archivo .yaml para que no me pida password por cada comando del hammer

echo "usando: " $SATELLITE_HOST
echo "ingrese password: "
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

#extraigo los nombres de los hosts, a partir de la cuarta linea
awk 'NR > 3 {print $3}' $HOST_LIST_CRUDA | head -n -1 >  $HOST_NAME_FILE

LINEA_NRO=0
CDAD_HOSTS=$(awk 'END{print NR}' $HOST_NAME_FILE)

while IFS='' read -r line || [[ -n "$line" ]]; do
        LINEA_NRO=$((LINEA_NRO + 1))
        echo -ne "auto-attach host" $line "("$LINEA_NRO"/"$CDAD_HOSTS") "
        hammer host subscription auto-attach --host $line

done < $HOST_NAME_FILE

#elimino el .yaml
rm /root/.hammer/cli_config.yml


