#! /bin/bash
#***********************************************************************************************************************
# Nombre Del Script:        ejercicio2.sh
# Trabajo Practico Nro.:    2
# Ejercicio Nro.:           2
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
	error
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
 
 if [ ! -r $1 ]; then
   echo "El Archivo indicado no posee permiso de lectura.."
   exit 1
 fi

csentive=0  #si esta en 0 es case sensitive, distingue mayusculas y minusculas.

if [[ $2 == "-c" || $2 == "-C" ]]
 then
	csentive=1
elif [[ $2 != "" ]];then
echo "El segundo parametro ingreado no es valido."
exit 1
fi

#Programa
cant_pal=`cat $1 | wc -l`  #cuento cant de lineas..

for ((linea=1;linea<=$cant_pal;linea++));do
	registro=`head -$linea $1 | tail -1`  #me quedo de a una linea.
	registro=`echo "$registro" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'` #saco espacios de adelante y atras.

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
rep=0
let ulti=0
let i=0
let j=0
#for((i=1;i<=$cant;i++));do
while [[ $i -lt $cant ]]; do	
	#Busco el mayores(iguales) de rep
	for regi in "${!palabra[@]}" ;do #obtengo "palabra"	
		if [[ "${palabra["$regi"]}" > "$rep" ]];then  #si num es mayor que cero
			unset igual
			ulti=0
			igual[$ulti]="$regi"	#palabra		
			rep=${palabra["$regi"]}	#rep
			(( ulti+=1 ))	
		elif [[ "${palabra["$regi"]}" = "$rep" ]];then		
			igual[$ulti]="$regi"
			(( ulti+=1 ))
	
		fi	
	done

	####ORDENO ALFABETICAMENTE IGUAL si hay mas de un elemento
	#busco palabra menor A a Z de mayores
	let cantid="${#igual[@]}"   #numero de claves en este array a ordenar.
	if [[ $cantid -eq 1 ]]; then
		ordenado_pal[$i]="${igual[0]}" #guardo la palabra menor.
		ordenado_rep[$i]="${palabra[${igual[0]}]}" 
		unset palabra["${igual[0]}"]   #elimino el mayor.		
		unset igual #borro la palabra menor asii sigue con las que quedan.
		(( i+=1 ))
	else
		for((j=0;j<$cantid;j++));do
			posi=`echo ${!igual[*]} | cut -d" " -f1`
			menor="${igual[$posi]}"
			can="${#igual[@]}"
			for((pos=1;pos<=$can;pos++));do
				num=`echo ${!igual[*]} | cut -d" " -f$pos`
				if [[ "${igual[$num]}" < "$menor" ]]; then  #si num es mayor que cero
					menor="${igual[$num]}"	#palabra
					posi="$num"
				fi	
			done
		
			ordenado_pal[$i]="$menor" #guardo la palabra menor.
			ordenado_rep[$i]="${palabra[$menor]}" 
			unset palabra["$menor"]   #elimino el mayor.			
			unset igual["$posi"] #borro la palabra menor asii sigue con las que quedan.
			(( i+=1 ))
		done
	fi
	##FIN ORDENAMIENTO ALFA
	rep=0
	ulti=0	
done

###MUESTRO POR PANTALLA
for((z=0;z<$cant;z++));do
	echo "${ordenado_rep[$z]}. ${ordenado_pal[$z]}"
done
