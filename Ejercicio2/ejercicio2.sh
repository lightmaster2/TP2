#! /bin/bash
declare -A palabra #declaro un array asociativo
declare -A ordenado #declaro un vector

#FUNCIONES
MensajeAyuda(){
    echo -e "VERSION:\t $BASH_VERSION" 
    echo -e "USO: \t   $0 ruta_del_archivo"
    echo -e "OPCIONES:\t -?, -help, -h  Muestra la informacion de uso del script y sale."
    echo -e "EJEMPLOS:\t   $0 /home/user/files/prueba.txt -c"
	echo -e "Analiza un script mostrando por mantalla la cant. de ocurrencias de todas las palabras del archivo. No distingue Mayuscula y Minuscula."
	echo ""	
	echo -e "EJEMPLOS:\t   $0 /home/user/files/prueba.txt"
	echo -e "Analiza un script mostrando por mantalla la cant. de ocurrencias de todas las palabras del archivo. Distingue Mayuscula y Minuscula."
	
}

error(){
echo No se enviaron parametros.
echo Para mayor ayuda\: $0 -h
}

error2(){
echo Se enviaron mas de dos parámetros, y no puede recibir más de dos
echo Para mayor ayuda\: $0 -h
}


#VALIDACIONES
if [[ $# == 0 ]]
then
	echo error
	exit 1
fi

if [[ $# > 2 ]]
then
	error2
	exit 1
fi

if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]
 then
	MensajeAyuda 
	exit 1
fi

 if [ ! -f $1 ]; then
   echo "La Ruta del archivo indicado no existe o no es un archivo ordinario."
   exit 1
 fi

csentive=0  #si esta en 0 es case sensitive, distingue mayusculas y minusculas.

if [[ $2 == "-c" || $2 == "-C" ]]
 then
	csentive=1
fi


#Programa
cant_pal=`cat $1 | wc -l`  #cuento cant de lineas..

for ((linea=1;linea<=$cant_pal;linea++));do
	registro=`head -$linea $1 | tail -1`  #me quedo de a una linea.
	registro=`echo "$registro" | sed -e 's/^ *//' -e 's/ *$//'` #saco espacios de adelante y atras.


	if [[ $registro != "" ]]; then # si es una linea no vacia, la agrego.

		#Setea para que sea no case sensitive(no distinga)
		if [[ $csentive == 1 ]];then
			registro=`echo "$registro" | tr [:lower:] [:upper:]`
		fi


		if [[ ${palabra[$registro]} == "" ]];then  ##Me fijo si esta en mi array.
		 palabra[$registro]=1 #si no esta, lo agrego.

		else
		let valor=`expr ${palabra[$registro]}`	
		(( valor+=1 ))
		palabra[$registro]="$valor"

		fi
	fi
done

#ORDENO ARRAY
cant="${#palabra[@]}"   #numero de claves en este array a ordenar.
#echo "cantidad: $cant"
rep=0

for((i=1;i<=$cant;i++));do

	#Busco el mayor	
	for regi in "${!palabra[@]}" ;do #obtengo "palabra"	
		if [[ ${palabra["$regi"]} > "$rep" ]];then  #si num es mayor que cero
		mayor="$regi"	#palabra
		rep=${palabra["$mayor"]}	#rep	
		#echo "pal: $mayor "
		#echo "rep: ${palabra["$mayor"]}"	
		fi	
	done

	# copio a otro vector
	pal[$i]=$mayor
	rep[$i]=$rep

	unset palabra["$mayor"]   #elimino el mayor.
	rep=0
		
done

###MUESTRO POR PANTALLA
for((j=1;j<=$cant;j++));do
	echo "${rep[$j]}. ${pal[$j]}"
done
