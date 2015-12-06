#! /bin/bash

#***********************************************************************************************************************
# Nombre Del Script:        ejercicio3.ps1
# Trabajo Practico Nro.:    2
# Ejercicio Nro.:           3
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

#----------------------- FUNCIONES --------------------------------------------------------------------------------------------
AyudaScript()
{
       
	echo -e "DESCRIPCION: El siguiente script busca en directorio/s o archivo/s pasado por parametros la existencia de scripts BASH. Caso existan, se pasa a mayusculas solo su nombre. Deja notificado en un archivo de log los cambios modificados."
	echo -e "Debe ser pasado por parametro el nombre del archivo Log y la/s carpetas/archivos para analizar."
	echo -e "En caso que no tenga Permiso de lectura o escritura, el archivo no será modificado y m ostrará el error en el log."
	echo -e "En caso que un archivo o carpeta no exista o no tenga permisos sufucientes, sera notificado y continuara procesando con los demas"
    	echo -e "OPCIONES:-?, -help,-h Muestra la informacion de uso del script."
	echo -e "EJEMPLO:\t   $0 ./[archivo_log.log] [./directorio] [./archivo.sh] [./test/ejer.old] [...]"
    	echo -e "EJEMPLO:\t   $0 /home/lgomez/Documentos/logEjercicio3.log /home/lgomez/Documentos/prueba1.sh"
	echo -e "EJEMPLO:\t   $0 ./archivo_log.log ./prueba ./archivo.sh ./test"
	echo " "
}

errorParam1()
{
	echo "No se envio el archivo de Log."
	echo "Para mas ayuda\: $0 -h"
}

errorParam2()
{
	echo "No se envio el parametro2, ruta_archivo carpeta"
	echo "Para mas ayuda\: $0 -h"
}
#-----------------------------------------------------------------------------------------------------------------------------

#----------------------- VALIDACIONES ----------------------------------------------------------------------------------------
#Validacion de Parametros

#Si se ingreso un parametro de ayuda, se llama a la funcion correcta
if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]
 then
	AyudaScript
	exit 1
fi

#se valida la cantidad de parametros enviada.
if [[ $# < 2 ]]
then
	echo "La cantidad de parametros minima enviada es incorrecta."
	echo "Para mas ayuda\: "$0" -h"
	exit 1
fi



if [[ ! "$1" ]]
then
	errorParam1
	exit 1
fi


#Si no existe el archivo de log lo creo
if [ ! -f "${1}" ]
then
	touch "${1}" 2>/dev/null
	#verifico que se halla creado el archivo de log, de lo contrario informo un error
	if [[ $? != 0 ]]
	then
		echo "La ruta $1 del archivo de log ingresada es incorrecta."
		exit 1
	fi
fi

#Validacion de permisos de lectura/escritura sobre el archivo de log
if [ ! -r "${1}" ] || [ ! -w "${1}" ]
 then
    echo "El archivo $1 no posee los permisos necesarios."
    exit 1
fi

#Creo archivos tmp para procesar
errores=$(mktemp)
arrayPath=$(mktemp)

#Guardo el archivo de log ya validado
archivoLog="$1"
shift

for param in "$@"
do

#Valido cada uno de los parametros ingresados
if [[ ! "$param" ]]
then
	errorParam2
	continue
else
	if [[ ! -f "${param}" && ! -d "${param}" ]]
	then
		echo "El archivo/carpeta $param no existe."
		continue
	else
		#Validacion de permisos de lectura sobre el archivo
		if [ ! -r "${param}" ]
		 then
		    echo "El archivo $param no posee permisos de lectura."
		    continue
		fi
	fi
fi


#Verifico que el archivo sea un script o si el directorio contiene scripts
#y lo guardo en un archivo temporal
grep -lir -e "#!.*/bin/bash" "${param}" 2>"$errores"  >> "$arrayPath"

done

#-----------------------------------------------------------------------------------------------------------------------------

##COMIENZA SCRIPT

#Creo las variables Dia y Hora para agregar al final del archivo.
DIA=`date +"%d/%m/%Y"`
HORA=`date +"%H:%M"`

#ANALIZO LOS ERRORES Y LOS AGREGO AL LOG
errorees=`cat "$errores"`

IFS=$'\n'
for ERROR in $errorees ; do
	arch=`echo "$ERROR" | cut -d':' -f2`
	
	#Eliminamos los espacuios de la ruta del archivo despues del grep
	arch=`echo "$arch" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	arch=`readlink -f "$arch"`
	
	#Validacion de permisos de lectura/escritura sobre el archivo de log. Si hubo un problema por falta de permisos
	if [ ! -r "${arch}" ] && [ ! -w "${arch}" ]; then
	    echo " $DIA $HORA - El archivo $arch  No posee permisos de lectura y escritura necesarios.">> "$archivoLog"
	else
		if [ ! -r "${arch}" ]; then
			echo " $DIA $HORA - El archivo $arch  No posee permiso de lectura necesario." >> "$archivoLog"
		fi
		if [ ! -w "${arch}" ]; then
			echo " $DIA $HORA - El archivo $arch  No posee permiso de escritura necesario." >> "$archivoLog"
		fi
	fi
done


# Valor original de la variable de entorno IFS
OLDIFS=$IFS
# Indice
A=-1          
 
IFS=$'\n'
RUTAS_PARAM=`cat "$arrayPath"`

for LINEA in $RUTAS_PARAM ; do
  IFS=$'\t'

  for VALOR in $LINEA ; do
    #Ruta completa
	RUTAA=`readlink -f "${VALOR}"`
	
	if [ ! -r "$RUTAA" ]; then
		echo " $DIA $HORA - El archivo $RUTAA   No posee permiso de lectura necesario." >> "$archivoLog"
	else
		if [ ! -w "${RUTAA}" ]; then
			echo " $DIA $HORA - El archivo $RUTAA   No posee permiso de escritura necesario." >> "$archivoLog"
		else
			let A=$A+1
			RUTA[$A]="$RUTAA"
			#Nombre con extension
			NOMBREEXTENSION[$A]=$(basename "${VALOR}")
			#Extension del archivo
			EXTENSION[$A]=`basename "${VALOR}" | cut -d'.' -f2`
			#Ruta sin nombre de archivo
			RUTASINNOMBRE[$A]=`dirname "${RUTA[$A]}"`
			#Nombre del archivo en matusculas
			NOMBRE[$A]=`basename "${VALOR}" | cut -d'.' -f1 | tr [:lower:] [:upper:]`
		fi 
	fi 
  done
  IFS=$'\n'
done

# Restablezco el valor original del IFS
IFS=$OLDIFS
 
# Realizo las modificaciones a los archivos.
if [ $A -ge 0 ] ; then
  for B in `seq 0 $A` ; do
	RUTA_ARCHIVO_MODIFICADO="${RUTASINNOMBRE[B]}/${NOMBRE[B]}.${EXTENSION[B]}"
	#Se cambia el nombre del archivo, concatenando la ruta, el nombre y la extension en minusculas
	mv "${RUTA[B]}" "${RUTA_ARCHIVO_MODIFICADO}" 2>/dev/null

	#Agrego dia y hora al final del archivo modificado
	echo "# El archivo se renombro el dia $DIA $HORA" >> "${RUTA_ARCHIVO_MODIFICADO}"
	
	#Logueo la modificacion y los errores.
	echo " $DIA $HORA - Se modifico el nombre del archivo ${RUTA_ARCHIVO_MODIFICADO}" >> "$archivoLog"
  done
fi

#Se eliminan los archivos temporales
rm $errores
rm $arrayPath
#FIN SCRIPT
