# RedhatSatellite

All .sh files must be filled with the proper satellite host befores usage.

# Satellite_auto_attach.sh
It auto attache the servers to the satellite host, the hostlist ist downloadaded automatically.

# Satellite_generar_errata.sh
It downloads the host list, all the erratas aplicable to the servers (merged in one file) and the erratas aplicable to each host. It delivers a tar.gz file

# Satellite_filtrar_errata.sh
It consolidates all the data in a single .csv file, servers vs. aplicable errata.
