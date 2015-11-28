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
AyudaScript(){
       
	echo -e "DESCRIPCION: El siguiente script busca en un directorio o archivo la existencia de scripts. Caso existan, se pasa a mayusculas solo su nombre. Deja notificado en un archivo de log los cambios modificados."
	echo -e "Debe ser pasado por parametro la carpeta/archivo para analizar y el nombre del archivo log."
    	echo -e "OPCIONES:-?, -help,-h Muestra la informacion de uso del script."
    	echo -e "EJEMPLOS:\t   $0 /home/lgomez/Documentos/prueba1.sh $1 /home/lgomez/Documentos/logEjercicio3.log"
		echo -e "EJEMPLOS:\t   $0 ./prueba ./archivo_log.log"
	echo " "
}

errorParam1(){
echo No se envio el parametro1, ruta_del_archivo/carpeta.
echo Para mas ayuda\: $0 -h
}

errorParam2(){
echo No se envio el parametro2, ruta_archivo_log
echo Para mas ayuda\: $0 -h
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
if [[ $# != 2 ]]
then
	echo "La cantidad de parametros enviada es incorrecta."
	echo "Para mas ayuda\: "$0" -h"
	exit 1
fi



if [[ ! $1 ]]
then
	errorParam1
	exit 1
fi

#Valido si existe la carpeta o el archivo
if [[ ! -f "${1}" && ! -d "${1}" ]]
then
	echo "El archivo/carpeta "$1" no existe."
	exit 1
fi

#Validacion de permisos de lectura sobre el archivo
if [ ! -r "${1}" ]
 then
    echo "El archivo "$1" no posee permisos de lectura."
    exit 1
fi

#Parametro2
if [[ ! $2 ]]
then
	errorParam2
	exit 1
fi

#Si no existe el archivo de log lo creo
if [ ! -f "${2}" ]
then
	touch "${2}" 2>/dev/null
	#verifico que se halla creado el archivo de log, de lo contrario informo un error
	if [[ $? != 0 ]]
	then
		echo "La ruta "$2" del archivo de log ingresada es incorrecta."
		exit 1
	fi
fi

#Validacion de permisos de lectura/escritura sobre el archivo de log
if [ ! -r "${2}" ] || [ ! -w "${2}" ]
 then
    echo "El archivo "$2" no posee los permisos necesarios."
    exit 1
fi
#-----------------------------------------------------------------------------------------------------------------------------

##COMIENZA SCRIPT
errores=$(mktemp)
#Creo las variables Dia y Hora para agregar al final del archivo.
DIA=`date +"%d/%m/%Y"`
HORA=`date +"%H:%M"`

#Verifico que el archivo sea un script o si el directorio contiene scripts
ES_SCRIPT=$(grep -lirs "#!" "${1}")
grep -lir "#!" "${1}" 2>$errores >/dev/null

#ANALIZO LOS ERRORES Y LOS AGREGO AL LOG
errorees=`cat $errores`
IFS=$'\n'
for ERROR in $errorees ; do
arch=`echo $ERROR | cut -d' ' -f2 | cut -d':' -f1`
arch=`readlink -f $arch`

#Validacion de permisos de lectura/escritura sobre el archivo de log. Si hubo un problema por falta de permisos
if [ ! -r "${arch}" ] && [ ! -w "${arch}" ]; then
    echo " $DIA $HORA - El archivo "$arch" no posee permisos de lectura y escritura necesarios.">> $2
else
	if [ ! -r "${arch}" ]; then
		echo " $DIA $HORA - El archivo "$arch" no posee permiso de lectura necesario." >> $2
	fi
	if [ ! -w "${arch}" ]; then
		echo " $DIA $HORA - El archivo "$arch" no posee permiso de escritura necesario." >> $2
	fi
fi
done


# Valor original de la variable de entorno IFS
OLDIFS=$IFS
# Indice
A=-1          
 
IFS=$'\n'
for LINEA in $ES_SCRIPT ; do
  #IFS=' '  # Separador
  IFS=$'\t'
  for VALOR in $LINEA ; do
    let A=$A+1
    #Ruta completa
	RUTA[$A]=`readlink -f ${VALOR}`
	#Nombre con extension
	NOMBREEXTENSION[$A]=$(basename ${VALOR})
	#Extension del archivo
	EXTENSION[$A]=`basename ${VALOR} | cut -d'.' -f2`
	#Ruta sin nombre de archivo
	RUTASINNOMBRE[$A]=`dirname ${RUTA[$A]}`
	#Nombre del archivo en matusculas
	NOMBRE[$A]=`basename "${VALOR}" | cut -d'.' -f1 | tr [:lower:] [:upper:]`
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
	echo " $DIA $HORA - Se modifico el nombre del archivo ${RUTA_ARCHIVO_MODIFICADO}" >> "${2}"
  done
fi
rm $errores
#FIN SCRIPT
