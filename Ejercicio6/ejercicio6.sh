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
	echo $1 >&2
	exit 1
}

# Función para mostrar la ayuda en caso que la solicite el usuario.
ayuda() {
	echo "Este script toma como parámetros tres archivos, un archivo de entrada con una"
	echo "base de datos de personas, con el formato:"
	echo
	echot 1 "Apellido y Nombre, Documento, Dirección, Acrónimo País/Ciudad"
	echo
	echo "Cada campo es obligatorio, de longitud variable y debe estar separado por comas."
	echo "Por otro lado, un archivo de entrada con una base de datos de países/ciudades,"
	echo "con el formato:"
	echo
	echot 1 "Tipo Código Nombre de la Ciudad/País"
	echo
	echo "Donde todos los campos son obligatorios, el primero indicando el tipo (C para"
	echo "Ciudad y P para País), el segundo campo con el código de dos letras que permite"
	echo "identificar a la ciudad o país, y el último campo, de longitud variable para"
	echo "indicar el nombre de la ciudad o país."
	echo
	echo "Finalmente, el path a un archivo donde se guardará la salida del reporte"
	echo "unificado ordenado por nombre del país y por el nombre de las personas, bajo el"
	echo "formato:"
	echo
	echot 1 "País A"
	echot 2 "Persona A"
	echot 2 "Persona B"
	echot 1 "País B"
	echot 2 "Persona A"
	echot 1 "..."
	echo
	echo "Uso: $0 <personas> <ubicaciones> <salida>"
	echo "Donde <personas> es el archivo que contiene la base de datos de personas con el"
	echo "formato indicado arriba, <ubicaciones> es el archivo que contiene la base de"
	echo "datos de los países/ciudades con el formato indicado arriba, y"
	echo "<salida> contiene el path al archivo de salida del reporte."
	echo
	echo "Opciones:"
	echo "Este script no posee opciones."
	echo
	echo "Ejemplos:"
	echo "$0 DocumentoA.txt DocumentoB.txt salida.out"
}

# Función para validar archivos de entrada.
function validarArchivoEntrada() {
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
				tipoArchivo=`mimetype --output-format %m $archivo` 
				# ¿Es un archivo de texto?
				if [ $tipoArchivo != 'text/plain' ]; then
					# No es un archivo de texto, mostramos el error y abortamos.
					error "$archivo debe ser un archivo de texto."
				fi
			fi
		fi
	fi
}

# Función para validar archivos de entrada.
function validarArchivoSalida() {
	archivo="$1"
	# ¿No tenemos permisos de lectura sobre el archivo?
	if [[ !(-r $archivo) ]]; then
		# ¿Es porque el archivo no existe?
		if [[ -e $archivo ]]; then
			# El archivo existe pero no tenemos permisos de lectura, mostramos el error y abortamos.
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
			# Mostramos una advertencia respecto a la existencia del archivo.
			echo "Advertencia: el archivo existe y será sobreescrito"
		fi
	fi
}

# Verificamos si el usuario solicitó ayuda.
if [[ "$1" == "-h" || "$1" == "-?" || "$1" == "-help" ]]; then
	# Mostramos la ayuda y salimos.
	ayuda
	exit 0
fi

# Si no solicitó ayuda procedemos a procesar los parámetros.

# En primer lugar validamos la cantidad de parámetros ya que es siempre fija.
if [[ $# -ne 3 ]]; then
	errorLlamada "El script necesita exactamente 3 parámetros."
fi

# Tratamos de validar el archivo de datos de las personas y guardamos su ubicación absoluta.
validarArchivoEntrada "$1"
archivoPersonas=$(readlink -f "$1")

# Tratamos de validar el archivo de datos de los paises/ciudades y guardamos su ubicación absoluta.
validarArchivoEntrada "$2"
archivoCodigos=$(readlink -f "$2")

# Finalmente tratamos de obtener el archivo de salida.
	validarArchivoSalida "$3"
	archivoSalida=$(readlink -f "$3")


# Armamos un patrón para que AWK construya la entrada para sed con las siguientes condiciones:
#     1. La línea debe tener más de tres campos;
#     2. El primer campo debe ser exactamente un caracter;
#     3. El segundo campo debe ser exactamente dos carácteres;
#     4. Sólo nos interesan aquéllos que son países.
# NOTA: el ciclo for está sencillamente porque el país es de longitud variable, y el separador es
#       coincidente con el espacio, que separa las palabras del nombre del país.
patronAWK='(NF >= 3) &&
			  (length($1) == 1) &&
			  (length($2) == 2) &&
			  ($1 == "P") {
					codigoPais = $2;
					pais = $3;
					for(i = 4; i <= NF; i++) {
						pais = pais" "$i;
					}
					print "s/\\b"codigoPais"\\b/"pais"/";
				}'

# Creamos un archivo temporal para guardar las cadenas de reemplazo para sed.
patronesSed=$(mktemp)
archivoTemporal=$(mktemp)

# Ejecutamos AWK para obtener las cadenas de reemplazo para sed.
awk -F" " "$patronAWK" "$archivoCodigos" > "$patronesSed" 


# Creamos otro patron de AWK para quedarnos sólo con las líneas "válidas" del archivo de persona.
patronAWK='NF == 3 { 
		sub(/^[ \t]*/,"",$1);
		sub(/[ \t]*$/,"",$1);
		sub(/^[ \t]*/,"",$2);
		sub(/[ \t]*$/,"",$2);
		sub(/^[ \t]*/,"",$3);
		sub(/[ \t]*$/,"",$3);
		print $3","$1; 
	}' #Sacamos los espcios

# Ejecutamos AWK sobre el archivo de personas y lo guardamos temporalmente.
awk -F"," "$patronAWK" "$archivoPersonas" > "$archivoTemporal"

# Ejecutamos sed para que realice los reemplazos en el lugar.
sed -i'' -f "$patronesSed" "$archivoTemporal"

# Creamos un archivo temporal para guardar los resultados intermedios.
archivoTemp=$(mktemp)
# Tomamos dicha la salida y la ordenamos por país y nombre.
cat "$archivoTemporal" | sort -u -d -k1 -k2 > $archivoTemp

# Creamos un último patrón para AWK que modifique la salida del archivo de modo que:
#     1. Si ya está escrito el país, que imprima el nombre de la persona.
#     2. Si es la primera vez que aparece el país, lo guarde e imprima dicho país y el nombre de la
#        persona.
patronAWK='$1 == ultimoPaisVisto {
				print "\t" $2;
			}
			$1 != ultimoPaisVisto {
				ultimoPaisVisto = $1;
				print $1 "\n\t" $2;
			}' 

# Ejecutamos AWK con dicho patrón y guardamos la salida en el archivo especificado.
awk -F"," "$patronAWK" $archivoTemp > "$archivoSalida"

# Finalmente, eliminamos los archivos temporales creados.
rm "$patronesSed"
rm "$archivoTemporal"
rm "$archivoTemp"
# EOF
