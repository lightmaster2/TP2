#!/bin/bash

#**************************************************************************************************
# Nombre Del Script:		ejercicio1.ps1
# Trabajo Práctico Nro.:	1
# Ejercicio Nro.:			1
# Entrega Nro:				ENTREGA
# Integrantes:
#
#	APELLIDOS		NOMBRES			DNI
#   ------------------------------------------
#	@integrante1
#	@integrante2
#	@integrante3
#	@integrante4
#
#**************************************************************************************************

#**************************************************************************************************
# CODIGO ORIGINAL COMENTADO.
#**************************************************************************************************

##	ErrorS()
##	{
##	echo "Error. La sintaxis del script es la siguiente:"
##	echo "......................: $0 nombre_archivo L" #COMPLETAR
##	echo "......................: $0 nombre_archivo C" #COMPLETAR
##	echo "......................: $0 nombre_archivo M" #COMPLETAR
##	}
##	
##	ErrorP()
##	{
##	echo "Error. nombre_archivo ....................." #COMPLETAR
##	}
##	
##	if test $# -lt 2; then
##		ErrorS
##	fi
##	if !test $1 -r; then
##		ErrorP
##	elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then
##		if test	$2 = "L"; then
##			res=`wc -l $1`
##			echo "...............................: $res" #COMPLETAR
##		elif test $2 = "C"; then
##			res=`wc -m $1`
##			echo "...............................: $res" #COMPLETAR
##		elif test $2 = "M"; then
##			res=`wc -L $1`
##			echo "...............................: $res" #COMPLETAR
##		fi
##	else
##		ErrorS
##	fi

#**************************************************************************************************
# NUESTRAS MODIFICACIONES.
#**************************************************************************************************

ErrorS() {
	# Se informa la naturaleza del error cometido en la llamada y se dan ejemplos de uso del script.
	echo "Error. La sintaxis del script es la siguiente:"
	echo "Para ver el numero de lineas que contiene el archivo 			: $0 nombre_archivo L" # COMPLETADO
	echo "Para ver el numero caracteres que contiene el archivo 		: $0 nombre_archivo C" # COMPLETADO
	echo "Para ver la longitud de la linea mas larga del archivo 		: $0 nombre_archivo M" # COMPLETADO
}

ErrorP() {
	# Se informa la naturaleza del error.
	echo "Error. $1 no existe o no tiene permisos de lectura." # COMPLETADO
}

# Validamos la cantidad de parametros recibidos.
if test $# -lt 2; then
	# Informamos al usuario que cometio un error sintactico en la llamada al script.
	ErrorS
fi
# Verificamos la existencia del archivo y los permisos de lectura sobre el.
if !(test -r $1); then
	# Informamos al usuario que el archivo no existe o bien que el no tiene los permisos
	# necesarios sobre el archivo para poder leerlo.
	ErrorP $1
# Validamos que el archivo proporcionado por parametro exista y sea un archivo regular.
# Adicionalmente, validamos que el valor del segundo parametro pertenezca al conjunto de
# opciones admitidas. Si alguna condicion no es satisfactoria evitamos el proceso principal.  
elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then
	# Averiguamos si el valor del segundo parametro es un 'L'
	if test	$2 = "L"; then
		# Ejecutamos el analisis correspondiente y almacenamos su salida.
		res=`wc -l $1`
		# Informamos el resultado de la operacion indicando su significado.
		echo "Numero de lineas que contiene el archivo: $res" # COMPLETADO
	# Averiguamos si el valor del segundo parametro es un 'C'
	elif test $2 = "C"; then
		# Ejecutamos el analisis correspondiente y almacenamos su salida.
		res=`wc -m $1`
		# Informamos el resultado de la operacion indicando su significado.
		echo "Numero caracteres que contiene el archivo: $res" # COMPLETADO
	# Averiguamos si el valor del segundo parametro es un 'M'
	elif test $2 = "M"; then
		# Ejecutamos el analisis correspondiente y almacenamos su salida.
		res=`wc -L $1`
		# Informamos el resultado de la operacion indicando su significado.
		echo "Longitud de la linea mas larga del archivo: $res" # COMPLETADO
	fi
else
	# Habiendo evitado procesar con datos erroneos, al usuario que cometio un error
	# sintactico en la llamada al script.
	ErrorS
fi

#**************************************************************************************************
# RESPUESTAS
#**************************************************************************************************

##	a)	¿Cual es el objetivo de este script?
##
##		El objetivo del script es encapsular el uso del comando "wc" para facilitar el uso de algunas
##		de sus opciones sobreescribiendo los nombres de sus parametros por otros mas descriptivos 
##		para la funcion que realizan. Es decir:
##		- En lugar de 'l' se utiliza 'L' para idicar que el resultado sera el numero de LINEAS
##		- En lugar de 'm' se utiliza 'C' para idicar que el resultado sera el numero de CARACTERES
##		- En lugar de 'L' se utiliza 'M' para idicar que el resultado sera el la longitud MAXIMA
##		  de entre todas las lineas del archivo.
##		
##	b)	¿Que parametros recibe?
##
##		Los parametros que el script recibe son:
##		- La ruta del archivo a analizar como primer parametro.
##		- El caracter que representa la funcion a realizar 'L' o 'C' o 'M' como segundo parametro.
##
##	c) 	Comentar linea a linea especificando que hace cada sentencia (no describa los
##		comandos, indique la logica de cada linea completa)
##
##		Resuelto en el codigo del script arriba de esta seccion.
##
##	d) 	Completar los “echo” con el mensaje correspondiente.
##		
##		Resuelto en el codigo del script arriba de esta seccion.
##
##	e) 	¿Que informacion brinda la variable “$#”? ¿Que otras variables similares conoce?
##		Expliquelas.
##
##		La variable $# provee el numero de parametros provistos en la linea de comandos al llamar al
##		script. Otras variables son:
##
##		- $0 Se expande en el nombre del script como fue tipeado en la linea de comandos.
##
##		- $@ Se expande en la lista de valores de los parametros posicionales. Si se escribe entre
##			 comillas dobles expande cada parametro posicional en una palabra independiente entre
##			 comillas dobles.
##
##		- $* Se expande en la lista de valores de los parametros posicionales. Si se escribe entre
##			 comillas dobles se expande en un unica linea de texto entre comillas dobles que contiene
##			 todos los valores de los parametros posicionales separados por el primer caracter de la
##			 variable del shell IFS que por omision es un espacio.
##
##		- $$ Se expande en el ProcessID del proceso shell que ejecuta al script.
##
##	f) 	Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar
##		en Shell scripts.
## 
##		Los tipos de comilla que pueden utiizarse son '', "", y ``. La diferencia estre ellos es:
##
##		- '' representa al tipo de comilla "fuerte", debido a que lo que se escribe entre
##			 ellas no sera inspeccionado y expandido por el shell, es decir, hacen que el texto
##			 entre ellas permanezca estatico y literal.
##
##		- "" representa al tipo de comillas "debil", debido a que permite que el shell inspeccione
##			 el texto entre ellas y expanda las expresiones que reconozca como variables o caracteres
##			 especiales reemplazandolos por sus valores. Es necesario el uso de caracteres de escape
##			 para evitar el reemplazo de un valor especifico.
##
##		- `` representan el tipo de comillas de "ejecusion", debido a que el shell intentara interpretar
##			 el texto entre ellas como una secuencia de comandos.  

# EOF