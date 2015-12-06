#!/bin/bash
#***********************************************************************************************************************
# Nombre Del Script:        demonio.sh
# Trabajo Practico Nro.:    2
# Ejercicio Nro.:           7
# Entrega Nro.:             REENTREGA
# Integrantes:              
#	Apellidos                     Nombres                       DNI       
#	----------------------------------------------------------------------
#	Gomez Gonzalez                Lucas                         33.192.211
#	Medrano                       Jonatan                       33.557.962
#	Morganella                    Julian                        35.538.469
#	Lucki                         Ariel Nicolas                 33.174.462
#	Sendras                       Bruno Martin                  32.090.370
#***********************************************************************************************************************
# Configuración de señales.
trap "finalizar=1" SIGTERM

# Creamos algunas variables globales para el demonio.
dirIn=
dirOut=
intervalo=
timeStamp=
nombreDir=
nombreZip=
dirIntercambio=

# Función para obtener un nombre relativamente único (por timestamp).
function configurarNombre() {
	timeStamp=$(date +"%d_%m_%Y_%H_%M_%S")
	nombreDir=$(basename "$dirIn")
	nombreZip="$$_$nombreDir_$timeStamp"
}

# Función para realizar el backup.
function comando() {
		# Deshabilitamos temporalmente la posibilidad de realizar otro backup mientras se hace este.
		trap '' SIGUSR1

		# Nos cambiamos al directorio raíz.
		cd /

		# Creamos un directorio temporal para realizar el backup.
		tmpDir=$(mktemp -d --tmpdir="$dirIntercambio")

		# Armamos el nombre del archivo de backup.
		configurarNombre

		# Realizamos el backup.
		rsync -a "$dirIn" "$tmpDir"

		# Nos posicionamos en el directorio de backup.
		cd "$tmpDir"

		# Comprimimos el backup y lo ponemos en el directorio de salida.
		tar -zcf "$dirOut/$nombreZip.tar.gz" *

		# Nos posicionamos nuevamente en el directorio raíz.
		cd /

		# Borramos los archivos temporales creados.
		rm -rf "$tmpDir"

		# Rehabilitamos la posibilidad de hacer un backup bajo demanda.
		trap "comando" SIGUSR1
}

# Inicializamos las variables globales que son fijas.
dirIn="$1"
dirOut="$2"
intervalo="$3"
dirIntercambio="$4"
finalizar=0

# Loop infinito del demonio.
while :
do
	if [[ $finalizar == 1 ]]; then
		break
	fi
	comando
	sleep "$intervalo" & wait
done

rm -rf "$dirIntercambio"
