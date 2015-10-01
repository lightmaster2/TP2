#!/bin/bash

#***************************************************************************************************
# Nombre Del Script:        @nombre
# Trabajo Práctico Nro.:    @tp
# Ejercicio Nro.:           @ejercicio
# Entrega Nro.:             @entrega
# Integrantes:              @miembros
#***************************************************************************************************

# Función para mostrar texto tabulado.
echot() {
	tabs=""
	# Creamos una cadena con n-tabulaciones al principio.
	for ((i = 0; i < $1; i++)); do
		tabs="$tabs    "
	done
	# Mostramos el mensaje tabulado.
	echo -e "$tabs$2"
}

# Función para mostrar una sugerencia en caso de que los parámetros ingresados
# no sean los esperados.
errorLlamada() {
	# El error siempre contiene la siguiente cadena.
	msg="¡Error en llamada!"
	# Si además existe un mensaje particular, lo incorporamos a la cadena.
	if [[ $# -eq 1 ]]; then
		msg="$msg $1"
	fi
	# Mostramos el mensaje y la sugerencia a utilizar la ayuda.
	echo "$msg" >&2
	echo "Para ver la ayuda, use $0 -?." >&2
	# Salimos.
	exit 1
}

# Función para mostrar errores más generales.
error() {
	echo "$1" >&2
	exit 1
}

# Función para mostrar la ayuda en caso que la solicite el usuario.
ayuda() {
	echo "Se pide generar un script que administre la ejecución de un demonio. La"
	echo "funcionalidad del demonio es crear un backup de un directorio cada un intervalo"
	echo "determinado."
	echo
	echo "Uso: $0 {start <dirIn> <dirOut> <intervalo>|stop|count|clear [<N>]|play}"
	echo "donde <dirIn> es el directorio que se desea resguardar, <dirOut> el directorio"
	echo "donde se guardará la salida del backup, e <intervalo> es cada cuánto se"
	echo "ejecutará el backup en segundos; <N> representa la cantidad de copias que"
	echo "quedarán en el directorio de resguardo (por defecto 0)."
	echo
	echo "Luego de la primer ejecución, es necesario indicar el archivo PID del proceso."
	echo
	echo "Opciones:"
	echot 1 "start: inicia el demonio si no se estaba ejecutando previamente."
	echot 1 "stop: detiene el demonio."
	echot 1 "count: cuenta la cantidad de archivos de resguardo hechos."
	echot 1 "clear: borra los resguardos hechos, deja sólo la cantidad indicada."
	echot 1 "play: crear un resguardo en el momento."
	echo
	echo "Ejemplos:"
	echo "$0 start . ./out 120"
	echo "$0 count "
	echo "$0 clear 5"
}

# Función para validar archivos de entrada.
function validarArchivo() {
	archivo="$1"
	if [[ -z $archivo ]]; then
		# Si nunca se pasó un archivo, mostramos el error y abortamos.
		errorLlamada "Debe proveer al menos un archivo para procesar."
	else
		# ¿No tenemos permisos de lectura sobre el archivo?
		if [[ !(-r $archivo) ]]; then
			# ¿Es porque el archivo no existe?
			if [[ !(-e $archivo) ]]; then
				# No existe, mostramos el error y abortamos.
				error "$archivo no existe."
			else
				# No tenemos permisos de lectura, mostramos el error y abortamos.
				error "No tiene permisos de lectura sobre $archivo."
			fi
		else
			# Tenemos permisos de lectura. Tratamos de obtener el nombre completo del archivo.
			archivo=$(readlink -f $archivo)

			# ¿No es un archivo regular?
			if [[ !(-f $archivo) ]]; then
				# No es un archivo regular, mostramos el error y abortamos.
				error "$archivo no es un archivo."
			else
				# Tratamos de obtener el tipo de archivo.
				tipoArchivo=$(mimetype --output-format %m $archivo)
				regex="^text/"
				# ¿Es un archivo de texto?
				if [[ !($tipoArchivo =~ $regex) ]]; then
					# No es un archivo de texto, mostramos el error y abortamos.
					error "$archivo debe ser un archivo de texto."
				fi
			fi
		fi
	fi
}

# Validar directorio para lectura
function validarDirectorio() {
	directorio="$1"
	# Si nunca se pasó un directorio, mostramos el error y abortamos.
	if [[ -z $directorio ]]; then
		errorLlamada "Debe proveer un directorio para procesar."
	else
		# ¿No tenemos permisos de lectura sobre el directorio?
		if [[ !(-r $directorio) ]]; then
			# ¿Es porque no existe el directorio?
			if [[ !(-e $directorio) ]]; then
				# No existe, mostramos el error y abortamos.
				error $directorio" no existe."
			else
				# No tenemos permisos de lectura, mostramos el error y abortamos.
				error "No tiene permisos de lectura sobre "$directorio"."
			fi
		else
			# Tenemos permisos de lectura. Tratamos de obtener el nombre completo
			# del directorio.
			directorio=$(readlink -e $directorio)

			# ¿Es un directorio?
			if [[ !(-d $directorio) ]]; then
				# No es un directorio, mostramos el error y abortamos.
				error $directorio" no es un directorio."
			fi
		fi
	fi
}

# Validar directorio para lectura/escritura
function validarDirectorioEscritura() {
	directorio="$1"
	validarDirectorio "$directorio"
	# Si nunca se pasó un directorio, mostramos el error y abortamos.
	if [[ !(-w $directorio) ]]; then
		# No tenemos permisos de escritura, mostramos el error y abortamos.
		error "No tiene permisos de escritura sobre "$directorio"."
	fi
}

# Validar llamada sin parámetros
function validarLlamada() {
	# Verificamos que el proceso esté corriendo.
	if [[ !(-r $archivoPID) ]]; then
		# ¿No existe el proceso?
		if [[ !(-e $archivoPID) ]]; then
			# No existe, mostramos el error y abortamos.
			error "El demonio no se encuentra corriendo. Vea la ayuda con -?"
		else
			# No tenemos permisos de lectura, mostramos el error y abortamos.
			error "No tiene acceso al demonio."
		fi
	fi

	# Leemos la información del demonio.
	source $archivoPID
}

# Inicia la ejecución del demonio, debe solicitar por parámetro el directorio a salvar, el directorio donde guardar el
# backup y el intervalo de tiempo entre backups (expresado en minutos o segundos).
# .\ejercicio7.sh start <dirIn> <dirOut> <intervalo>
function doStart() {
	# Verificamos que el proceso no esté corriendo.
	if [[ -r $archivoPID ]]; then
		source $archivoPID
		if [[ -e /proc/"$PID"/exe ]]; then
			# Si existe el archivo de intercambio, verificamos que el proceso esté corriendo realmente.
			error "El proceso ya se encuentra corriendo bajo el PID $PID"
		else
			# Si no está corriendo, borramos el archivo e intentamos volver a ejecutar.
			echo "Parece que la ejecución anterior falló en finalizar, relanzando demonio"
			rm $archivoPID
		fi
	elif [[ !(-r $archivoPID) && (-e $archivoPID) ]]; then
		error "El proceso ya fue iniciado en su nombre, ver $archivoPID"
	fi

	# Verificamos la cantidad de parámetros.
	if [[ $# != 4 ]]; then
		errorLlamada "Número incorrecto de parámetros"
	fi

	# Verificamos el directorio de entrada.
	validarDirectorio "$2"
	dirIn=$(readlink -f "$2")

	# Verificamos el directorio de salida.
	validarDirectorioEscritura "$3"
	dirOut=$(readlink -f "$3")

	# Verificamos que nos hayan pasado un número en segundos o un número + "m" en minutos.
	regexNum='^([0-9]+|[0-9]+(m|M)?)$'
	if [[ !("$4" =~ $regexNum) ]]; then
		errorLlamada "$4 debe ser un número entero seguido opcionalmente de una m para indicar minutos"
	fi

	# Llegado este punto podemos:
	#    1. Crear el directorio de "ejecución".
	#    2. Ejecutar el proceso como demonio como líder de sesión sin E/S.
	#    3. Crear el archivo que contendrá la información de "ejecución".
	mkdir -p "$directorioIntercambio" 2>&1

	setsid ./demonio.sh "$dirIn" "$dirOut" "$4" "$directorioIntercambio" &

	echo "PID=$!" > "$archivoPID"
	echo "DIR_IN=$dirIn" >> "$archivoPID"
	echo "DIR_OUT=$dirOut" >> "$archivoPID"
	echo "INT=$4" >> "$archivoPID"
	echo "DIR_EXC=$DIR_EXC" >> "$archivoPID"

	# Cargamos el archivo en memoria como configuración del script.
	source $archivoPID

	# Mostramos el PID del demonio.
	echo "Lanzado demonio bajo el PID $PID"
}

# Finalizar el demonio.
# .\ejercicio7.sh stop
function doStop() {
	validarLlamada "$@"

	# Verificamos la cantidad de parámetros.
	if [[ $# != 1 ]]; then
		errorLlamada "Número incorrecto de parámetros"
	fi

	# Enviamos la señal al demonio.
	kill -SIGTERM "$PID"
}

# Indica la cantidad de archivos de backup hay en el directorio.
# .\ejercicio7.sh count
function doCount() {
	validarLlamada "$@"

	# Verificamos la cantidad de parámetros.
	if [[ $# != 1 ]]; then
		errorLlamada "Número incorrecto de parámetros"
	fi

	# Obtenemos la cantidad de archivos generados por el demonio y mostramos.
	cantidadArchivos=$(ls $DIR_OUT | grep ^"$PID" | wc -l)
	echo "Hay $cantidadArchivos archivo/s de resguardo disponibles"
}

# Limpia el directorio de backup, recibe por parámetro la cantidad de backup que mantiene en la carpeta, siendo estos
# los últimos generados. Si no se recibe ningún parámetro se toma el valor cero.
# .\ejercicio7.sh clear [<N>]
function doClear() {
	validarLlamada "$@"

	# Verificamos la cantidad de parámetros.
	if [[ $# -gt 3 ]]; then
		errorLlamada "Número incorrecto de parámetros"
	fi

	# Tratamos de obtener la cantidad de archivos a conservar, si se pasó por parámetro.
	cantidadArchivosAConservar=0
	if [[ $# == 2 ]]; then
		# Verificamos que nos hayan pasado un número.
		regexNum='^[0-9]+$'
		if [[ !("$2" =~ $regexNum) ]]; then
			errorLlamada "$4 debe ser un número entero seguido opcionalmente de una m para indicar minutos"
		else
			cantidadArchivosAConservar="$2"
		fi
	fi

	# Obtenemos la cantidad de archivos generados por el demonio.
	cantidadArchivos=$(ls $DIR_OUT | grep ^"$PID" | wc -l)

	# Siempre y cuando se quieran conservar menos archivos que los disponibles.
	if [[ "$cantidadArchivosAConservar" -le "$cantidadArchivos" ]]; then
		cantidadABorrar=$(expr "$cantidadArchivos" - "$cantidadArchivosAConservar")
		archivos="$DIR_OUT/$PID"
		$(ls -aft "$archivos"* | head -n "$cantidadABorrar" | xargs --no-run-if-empty rm -rf)
	fi
}

# El demonio crea el backup, en ese instante.
# .\ejercicio7.sh play
function doPlay() {
	validarLlamada "$@"

	# Verificamos la cantidad de parámetros.
	if [[ $# != 1 ]]; then
		errorLlamada "Número incorrecto de parámetros"
	fi

	# Enviamos señal al demonio.
	kill -SIGUSR1 "$PID"
}

### SCRIPT

# Verificamos si el usuario solicitó ayuda.
if [[ "$1" == "-?" ]]; then
	# Mostramos la ayuda y salimos.
	ayuda
	exit 0
fi

# Si no solicitó ayuda procedemos a procesar los parámetros.

# En primer lugar validamos la cantidad de parámetros mínima.
if [[ -z "$1" ]]; then
	errorLlamada "El script necesita al menos 1 parámetro."
fi

# Creamos algunas variables auxiliares.
scriptUID=$(id -u)
pathCompleto=$(readlink -f "$0")
nombreScript=$(basename "$pathCompleto")
directorioIntercambio="/tmp/$scriptUID/$nombreScript-lock"
archivoPID="$directorioIntercambio/PID"

# Y creamos algunas variables globales a ser llenadas luego.
PID=
DIR_IN=
DIR_OUT=
INT=
DIR_EXC="$directorioIntercambio/PID"

case "$1" in
	start)
		doStart "$@"
		;;
	stop)
		doStop "$@"
		;;
	count)
		doCount "$@"
		;;
	clear)
		doClear "$@"
		;;
	play)
		doPlay "$@"
		;;
	*)
		ayuda
		exit 0
		;;
esac