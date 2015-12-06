#!/bin/bash
#***********************************************************************************************************************
# Nombre Del Script:        ejercicio4.sh
# Trabajo Practico Nro.:    2
# Ejercicio Nro.:           4
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

ayuda() {
	echo "Este script permite fichar los horarios de entrada y"
	echo "salida de un empleado. Ademas permite la consulta de"
	echo "los registros generados."
	echo
	echo "	Uso: $0 <opción> [<arg>]"
	echo "	Donde <opción> especifica la funcion deseada y <arg>"
	echo "	es una fecha (opcionalmente con la hora, por defecto 00:00:00)."
	echo
	echo "Opciones:"
	echo "	-i: Ficha el ingreso con la hora y fecha actuales."
	echo "	-f: Ficha la salida con la hora y fecha actuales."
	echo "	-r: Recibe el numero de mes en <arg> y muestra el registro de dicho mes."
	echo "	-y: Recibe el numero de año en <arg> y muestra los registros mensuales de dicho año."
	echo ""
	echo "Ejemplos:"
	echo "	$0 -i"
	echo "	$0 -f"
	echo "	$0 -r 09"
	echo "	$0 -y 2015"
}

function errorEnLlamada () {
	msg=$1
	echo "$0: $msg"
	echo ""
	ayuda
}

function validarArchivoDeRegistro() {
	# Existe el archivo?
	if !(test -f $1); then
		if [[ $2 == "crear" ]]; then
			# No, lo creamos.
			echo "0|00:00:00|0" > $1
		else
			echo "El archivo de registro mensual $1 no existe."
			exit
		fi
	fi
	# Tenemos permiso de lectura?
	if !(test -r $1); then
		echo "No tiene permisos de lectura sobre el archivo de registro $1"
		exit
	fi
	# Tenemos permiso de escritra?
	if !(test -w $1); then
		echo "No tiene permisos de escritura sobre el archivo de registro $1"
		exit
	fi
}

function ficharIngreso() {

	# Existe el archivo de registro mensual?
	validarArchivoDeRegistro $1 "crear"

	# Separamos fecha y hora actuales.
	fecha=`date --date="$2" +%d/%m/%Y`
	horaIngreso=
	if [[ $# -eq 2 ]]; then
		horaIngreso=`date --date="$2" +%H:%M:%S`
	else
		horaIngreso=`date --date="$2 $3" +%H:%M:%S`
	fi

	# Verificamos si ya se ficho el ingreso.
	registro=$(grep -c -m 1 $fecha $1)
	if [[ $registro -ne 0 ]]; then
		echo "No se puede proceder, ya se ha registrado el ingreso para el dia indicado."
		exit
	fi

	# Registramos fecha y hora. Insertamos siempre antes de la ultima linea.
	sed -i "$ i\\$fecha\|$horaIngreso" $1

	# Avisamos al usuario que todo salio bien.
	echo "Ingreso registrado con exito."
}

function ficharSalida() {

	# Existe el archivo de registro mensual?
	validarArchivoDeRegistro $1

	# Separamos fecha y hora actuales.
	fecha=`date --date="$2" +%d/%m/%Y`
	horaSalida=
	if [[ $# -eq 2 ]]; then
		horaSalida=`date --date="$2" +%H:%M:%S`
	else
		horaSalida=`date --date="$2 $3" +%H:%M:%S`
	fi

	# Verificamos que se haya registrado el ingreso previamente.
	registro=`grep -m 1 $fecha $1`
	if [[ $registro == "" ]]; then
		echo "No se puede proceder, debe registrar el ingreso previamente."
		exit
	fi

	# Ya fichamos la salida?
	error=${registro:19:1}
	# echo $error
	if [[ $error == "|" ]]; then
		echo "No se puede proceder, ya se ha registrado la salida para el dia indicado."
		exit
	fi
	# Obtenemos la hora de ingreso.
	horaIngreso=`echo $registro | cut -d '|' -f 2`

	# Calculamos la diferencia en segundos.
	diferenciaSegundos=$(($(date -d $horaSalida +%s) - $(date -d $horaIngreso +%s)))

	diferenciaHoraria=`date -u -d @$diferenciaSegundos +%H:%M:%S`

	# Generamos el registro diario completo.
	registroDiario=$registro\|$horaSalida\|$diferenciaHoraria

	# Reemplazamos el registro parcial por el nuevo.
	sed -i "s#$registro#$registroDiario#g" $1

	# diferenciaSegundos=$((`date -u -d $diferenciaHoraria +%s`))

	# Leemos el ultimo registro y lo parseamos.
	registroMensual=`sed -n '$p' $1`

	# Tomamos el acumulado de dias y le sumamos el dia actual.
	diasTrabajadosAcumulados=$((`echo $registroMensual | cut -d '|' -f 1`))
	diasTrabajados=$(($diasTrabajadosAcumulados+1))

	# calculamos las horas que deberiamos haber trabajado.
	horasTeoricas=$(($diasTrabajados*8))

	#Tomamos el acumulado de horas que llevamos y le sumamos las horas trabajadas hoy.
	horasRealesAcumuladas=`echo $registroMensual | cut -d '|' -f 2`

	Hor=$( expr `echo $horasRealesAcumuladas | cut -d ':' -f 1` + 0)
	Min=$( expr `echo $horasRealesAcumuladas | cut -d ':' -f 2` + 0)
	Sec=$( expr `echo $horasRealesAcumuladas | cut -d ':' -f 3` + 0)

	horasRealesAcumuladasSegundos=$((($Hor*3600)+($Min*60)+($Sec)))
	horasRealesSegundos=$((horasRealesAcumuladasSegundos + $diferenciaSegundos))
	saldoDeHorasSegundos=$((($horasTeoricas*3600) - $horasRealesSegundos))

	# FORMATEO HORAS ACUMULADAS
	# Obtengo las horas y el resto en segundos.
	Hor=$( expr $horasRealesSegundos / 3600)
	resto=$( expr $horasRealesSegundos % 3600)

	# Con el resto en segundos obtengo los minutos.
	Min=$( expr $resto / 60)

	# El resto de la division anterior representa los segundos.
	Sec=$( expr $resto % 60)

	HorasAcumuladas=`printf "%02d:%02d:%02d" $Hor $Min $Sec`

	# FORMATEO LA DIFERENCIA (SALDO DE HORAS)
	# Si el saldo es negativo, se trabajó demás; si el saldo es positivo faltan horas.
	signo=""
	if [ $saldoDeHorasSegundos -lt 0 ]; then
		saldoDeHorasSegundos=$( expr 0 - $saldoDeHorasSegundos)
	elif [ $saldoDeHorasSegundos -gt 0 ]; then
		signo="-"
	fi

	# Obtengo las horas y el resto en segundos.
	Hor=$( expr $saldoDeHorasSegundos / 3600)
	resto=$( expr $saldoDeHorasSegundos % 3600)

	# Con el resto en segundos obtengo los minutos.
	Min=$( expr $resto / 60)

	# El resto de la division anterior representa los segundos.
	Sec=$( expr $resto % 60)

	saldoDeHoras=`printf "%02d:%02d:%02d" $Hor $Min $Sec`

	# Ahora actualizamos el registro mensual, representado por la ultima linea.
	nuevoRegistroMensual=$diasTrabajados\|$HorasAcumuladas\|$signo$saldoDeHoras

	# Actualizamos el registro.
	sed -i "s#$registroMensual#$nuevoRegistroMensual#g" $1

	# Avisamos al usuario que todo salio bien.
	echo "Salida registrada con exito."
}

function reporteMensual() {
	validarArchivoDeRegistro $1

	cantidad=$((`wc -l < $1`))
	if test $cantidad -lt 2; then
		echo "No hay registros para el mes $2"
		exit
	fi

	cat $1 | awk -F "|" -v archivo=$1 '
		BEGIN {
			Meses["01"] = "Enero"
			Meses["02"] = "Febrero"
			Meses["03"] = "Marzo"
			Meses["04"] = "Abril"
			Meses["05"] = "Mayo"
			Meses["06"] = "Junio"
			Meses["07"] = "Julio"
			Meses["08"] = "Agosto"
			Meses["09"] = "Septiembre"
			Meses["10"] = "Octubre"
			Meses["11"] = "Noviembre"
			Meses["12"] = "Diciembre"

			Mes=substr(archivo,6,2)
		}

		END {
			print "Mes: ",Mes 	" " Meses[Mes]
			print "Dias Trabajados: ",$1
			print "Horas estimadas: ",$1*8
			print "Horas reales: ",$2
			print "Diferencia: "$3

			print ""
			print ""
		}
	'
}

# Obtenemos las opciones ingresadas.
getopts "i:f:r:y:h" OPT 2>/dev/null

# Significa que esperamos lo siguiente:
# -i sin argumentos
# -r sin argumentos
# -f donde ':' indica que se espera un argumento
# -y donde ':' indica que se espera un argumento

# Las validamos y obtenemos sus valores
case $OPT in
	i)
		# Fichamos el inicio de la jornada laboral.
		fecha=
		horaActual=`date "+%H:%M:%S" 2>&1`
		if [[ $# -eq 2 ]]; then # Si vino solamente la fecha.
			shift
			fechaParam=`echo "$*" | awk '{print substr($0,7,4)"-"substr($0,4,2)"-"substr($0,1,2)}' 2>&1`
			fechaIn=`date --date="$fechaParam $horaActual" "+%Y-%m-%d %H:%M:%S" 2>&1`
			if [[ $? -eq 0 ]]; then
				fecha="$fechaIn"
			fi
		elif [[ $# -eq 3 ]]; then  # Si vino la fecha y la hora.
			shift
			fechaParam=`echo "$*" | awk '{print substr($0,7,4)"-"substr($0,4,2)"-"substr($0,1,2)""substr($0,11)}' 2>&1`
			fechaIn=`date --date="$fechaParam" "+%Y-%m-%d %H:%M:%S" 2>&1`
			if [[ $? -eq 0 ]]; then
				fecha="$fechaIn"
			fi
		else
			echo "Debe indicar una fecha"
			exit
		fi

		# Creamos el nombre del archivo de registro.
		archivoDeRegistroMensual=`date --date="$fecha" +%Y.%m.ch`

		ficharIngreso $archivoDeRegistroMensual $fecha
		;;
	f)
		# Fichamos el final de la jornada.
		fecha=
		horaActual=`date "+%H:%M:%S" 2>&1`
		if [[ $# -eq 2 ]]; then # Si vino solamente la fecha.
			shift
			fechaParam=`echo "$*" | awk '{print substr($0,7,4)"-"substr($0,4,2)"-"substr($0,1,2)}' 2>&1`
			fechaIn=`date --date="$fechaParam $horaActual" "+%Y-%m-%d %H:%M:%S" 2>&1`
			if [[ $? -eq 0 ]]; then
				fecha="$fechaIn"
			fi
		elif [[ $# -eq 3 ]]; then  # Si vino la fecha y la hora.
			shift
			fechaParam=`echo "$*" | awk '{print substr($0,7,4)"-"substr($0,4,2)"-"substr($0,1,2)""substr($0,11)}' 2>&1`
			fechaIn=`date --date="$fechaParam" "+%Y-%m-%d %H:%M:%S" 2>&1`
			if [[ $? -eq 0 ]]; then
				fecha="$fechaIn"
			fi
		else
			echo "Debe indicar una fecha"
			exit
		fi

		# Creamos el nombre del archivo de registro.
		archivoDeRegistroMensual=`date --date="$fecha" +%Y.%m.ch`

		ficharSalida $archivoDeRegistroMensual $fecha
		;;
	r)
		# Mostramos el reporte mensual.
		anio=`date +%Y`
		mes=$2
		archivoDeRegistroMensual="$anio.$mes.ch"
		reporteMensual $archivoDeRegistroMensual
		;;
	y)
		# Mostramos el reporte anual.
		anio=$2
		encontrados=`ls | grep -e $anio | wc -l`
		if [[ $encontrados == "0" ]]; then
			echo "No hay registros para el año $anio"
			exit
		fi
		archivos=`ls | grep -e $anio`
		for archivo in $archivos; do

			reporteMensual $archivo
		done
		;;
	h)
		# Mostramos la ayuda solicitada
		ayuda
		;;
	\?)
		# Informamos del error sintactico y mostramos la ayuda.
		errorEnLlamada "Opcion invalida."
		;;
esac

# EOF
