#! /bin/bash

#***********************************************************************************************************************
# Nombre Del Script:        ejercicio5.ps1
# Trabajo Practico Nro.:    2
# Ejercicio Nro.:           5
# Entrega Nro.:             ENTREGA
# Integrantes:              
#	Apellidos                     Nombres                       DNI       
#	----------------------------------------------------------------------
#	Gomez Gonzalez                Lucas                         33.192.211
#	Medrano                       Jonatan                       33.557.962
#	Morganella                    Julian                        35.538.469
#	Lucki                         Ariel Nicolas                 33.174.462
#	Sendras                       Bruno Martin                  32.090.370
#***********************************************************************************************************************


#----------------------- FUNCIONES -------------------------------------------------------------------------------------
mensaje_en_pantalla()
{
	clear    
	echo -e "DESCRIPCION: El siguiente script lista el archivo de productos ingresado segun el filtro de busqueda que se ingreso.\n $0 ruta_archivo Letra_desde Letra_hasta"
    echo -e "OPCIONES:-?, -help,-h Muestra la informacion de uso del script y sale."
    echo -e "EJEMPLOS:\n(1)$0 productos.txt b e \n(2)$0 /home/user/files/productos.txt"
	echo " "
}

mensaje_de_error()
{	
	echo "No se enviaron los parametros correctamente."
	echo "Para mayor ayuda: $0 -h"
}

crear_archivo_filtrado()
{
	NOMBRE=$(basename $1 | cut -d"." -f1)
	ARCHIVO="./${NOMBRE}_filtrado.txt"
	touch $ARCHIVO
}

#----------------------- VALIDACIONES -------------------------------------------------------------------------------------

#se valida la cantidad de parametros enviada.
#se pueden enviar 1 , 2 o 3 parametros
if [[ $# < 1 ]]
then
	mensaje_de_error
	exit 1
fi

#se valida que no se envien parametros de mas
if [[ $# > 3 ]]
then
	mensaje_de_error
	exit 1
fi

#Si se ingreso un parametro de ayuda, se llama a la funcion correcta
if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]
then
	mensaje_en_pantalla
	exit 1
fi

#Se valida que el archivo de productos exista
if [ ! -f $1 ] 
then
    echo "El archivo de productos ingresado no existe."
    exit 1
fi

#Se verifican los permiso de lectura del archivo
if [ ! -r $1 ]
then
    echo "El archivo de productos ingresado no tiene permisos de lectura."
    exit 1
fi

TIPO_ARCHIVO=$(file --mime-type $1 | cut -d' ' -f2)
#se valida que el archivo de productos no este vacio
if [[ $TIPO_ARCHIVO == "inode/x-empty" ]]
then
    echo "El archivo de productos se encuentra vacio."
    exit 1
fi

#se valida que el archivo de productos sea de texto plano
if [[ $TIPO_ARCHIVO != "text/plain" ]]
then
    echo "El archivo de productos no corresponde a un archivo de texto plano."
    exit 1
fi

#valido que el parametro 2 o 3 se halla ingresado solo una letra
LARGO_PARAM2=$(expr length "$2")
if [[ $#==2 ]]
then
	if [[ $LARGO_PARAM2 > 1 ]]
	then
		echo "El parametro 2 ingresado no es una letra."
		exit 1
	fi
fi
if [[ $#==3 ]]
then	
	LARGO_PARAM3=$(expr length "$3")
	if [[ $LARGO_PARAM3 > 1 ]]
	then
		echo "El parametro 3 ingresado no es una letra."
		exit 1
	fi
fi	

#valido que no se ingrese un numero en el parametro 2 o 3
if [[ $#==2 ]]
then
	if [ "$2" -eq "$2" ] 2>/dev/null
	then
		echo "El parametro 2 ingresado no es una letra valida."
		exit 1
	fi
fi
if [[ $# == 3 ]]
then		
	if [ "$3" -eq "$3" ] 2>/dev/null
	then
		echo "El parametro 3 ingresado no es una letra valida."
		exit 1
	fi
	#Valido el orden alfabetico de los dos parametros.
	if [[ $2 > $3 ]] 
	then
		echo "Orden alfabetico incorrecto de las letras del filtrado."
		exit 1
	fi
fi

#---------------------------------------------------------------------------------------------------------------------------
#Se crea el archivo para guardar la salida del filtrado
crear_archivo_filtrado $1

#Si no se indican opciones de filtrado, listo todo el archivo completo y lo guardo en un archivo
if [[ $# == 1 ]]
then
	echo " "	
	cat $1 | tee $ARCHIVO
	echo " "
	echo -e "Se genero el archivo $ARCHIVO con el Listado anterior.\n"
	exit 1
fi

#si se pasa una sola letra listo ese contenido, sino filtro por el par de letras pasadas
#En ambos casos sed filtra y muestra las lineas que coinciden con un patron determinado
#sin tener en cuenta las mayusculas y las minisculas
if [[ $# == 2 ]]
then
	echo " "
	#Se usa tee para mostrar en pantalla y a su vez guardar el filtrado en el archivo
	FILTRADO_1=$(sed -n "s/^$2/&/Ip" $1 | tee $ARCHIVO)
	if [ -z "$FILTRADO_1" ] #Compruebo si esta vacio el filtrado que devolvio sed
	then
		echo "No hay productos con la letra $2" | tee $ARCHIVO
	else	
		echo "$FILTRADO_1"	
		echo " "
	fi
else
	echo " "	
	FILTRADO_2=$(sed -n "s/^[$2-$3]/&/Ip" $1 | tee $ARCHIVO)
	if [ -z "$FILTRADO_2" ] #Compruebo si esta vacio el filtrado que devolvio sed
	then
		echo "No hay productos desde la letra $2 hasta la letra $3" | tee $ARCHIVO
	else	
		echo "$FILTRADO_2"	
		echo " "
	fi	
fi

echo -e "Se genero el archivo $ARCHIVO con el Listado anterior.\n"
