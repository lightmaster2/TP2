#! /bin/bash
##############################################################################
# Script: 	 	ejercicio3.sh
# TP:     	 	2
# Ejercicio: 	3
# Integrantes:	
#   
#   
#	
#
#
# ENTREGA
#############################################################################


#FUNCIONES
AyudaScript(){
    echo -e "\nVERSION:\t $BASH_VERSION\n" 
    echo -e "USO: \t   $1 ruta_del_archivo/carpeta $2 ruta_archivo_log\n"
    echo -e "OPCIONES:\t -?, -help, -h  Muestra la informacion de uso del script.\n"
    echo -e "EJEMPLOS:\t   $0 /home/lgomez/Documentos/prueba1.sh $1 /home/lgomez/Documentos/logEjercicio3.log"
}

errorParam1(){
echo No se envio el parametro1, ruta_del_archivo/carpeta.
echo Para mas ayuda\: $0 -h
}

errorParam2(){
echo No se envio el parametro2, ruta_archivo_log
echo Para mas ayuda\: $0 -h
}


#Validacion de Parametros

#Parametro1
if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]
 then
	AyudaScript
	exit 1
fi

if [[ ! $1 ]]
then
	errorParam1
	exit 1
fi

#if [ ! -f $1 ]; then
 #   echo "El archivo/carpeta no existe."
 #   exit 1
#fi

# - Validacion de permisos de lectura sobre el archivo
if [ ! -r $1 ]; then
    echo "El archivo no posee permisos de lectura."
    exit 1
fi

#4 - Chequear que el archivo sea de texto plano
#tipoArchivo=$(file $1 | cut -d' ' -f2)
#if [ $tipoArchivo != "ASCII" ]; the
 #   echo "El archivo indicado no se puede procesar, no es un archivo de texto."
  #  exit 1
#fi

#Parametro2
if [[ ! $2 ]]
then
	errorParam2
	exit 1
fi


##COMIENZA SCRIPT

#Verifico que el directorio o archivo sean scripts
ES_SCRIPT=$(grep -lir "#!" $1)


OLDIFS=$IFS   # Valor original del IFS
A=-1          # Indice
 
IFS=$'\n'
for LINEA in $ES_SCRIPT ; do
  IFS=' '  # Separador
  for VALOR in $LINEA ; do
    let A=$A+1
    #Ruta completa
	RUTA[$A]=${VALOR}
	#Nombre con extension
	NOMBREEXTENSION[$A]=$(basename ${VALOR})
	#Extension del archivo
	EXTENSION[$A]=${NOMBREEXTENSION[$A]:${#NOMBREEXTENSION[$A]} -3}
	#Longitud de la ruta completa mas el nombre del archivo
	LONGITUDRUTA[$A]=${#RUTA[$A]}
	#Longitud del nombre
	LONGITUDNOMBRE[$A]=${#NOMBREEXTENSION[$A]}
	#Ruta sin nombre de archivo
	RUTASINNOMBRE[$A]=${RUTA[$A]::${LONGITUDRUTA[$A]}-${LONGITUDNOMBRE[$A]}}
	#Nombre del archivo en matusculas
	NOMBRE[$A]=$(basename ${VALOR%.*} | tr [:lower:] [:upper:])
  done
  IFS=$'\n'
done

#Creo las variables Dia y Hora para agregar al final del archivo.
DIA=`date +"%d/%m/%Y"`
HORA=`date +"%H:%M"`

IFS=$OLDIFS # Restablezco el IFS a su valor original
 
# Realizo las modificaciones a los archivos.
if [ $A -ge 0 ] ; then
  for B in `seq 0 $A` ; do
	#Se cambia el nombre del archivo, concatenando la ruta, el nombre y la extension en minusculas
	mv ${RUTA[B]} ${RUTASINNOMBRE[B]}${NOMBRE[B]}${EXTENSION[B]} 2>> $2
	
	#NO ESTA REDIRECCIONANDO EL ERROR DE PERMISO DENEGADO - REVISAR
	#Agrego dia y hora al final del archivo modificado
	echo "$DIA $HORA" >> ${RUTASINNOMBRE[B]}${NOMBRE[B]}${EXTENSION[B]} 2>> $2
	#Logueo la modificacion y los errores.
	echo "$DIA $HORA - Se modifico el archivo ${NOMBREEXTENSION[$B]}" >> $2 2>> $2
  done
fi

#FIN SCRIPT
