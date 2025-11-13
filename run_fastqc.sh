#!/bin/bash

#-------------------------------------------------------------
# Mostrar hostname
#-------------------------------------------------------------
hostname

#-------------------------------------------------------------
# Control de argumentos
#-------------------------------------------------------------
if [[ $# -ne 2 ]]; then
    echo '--------------------------------------------------------------------------------------------------------------'
    echo 'usage: run_fastqc.sh <directorio_concatenados> <cores>'
    echo 'Ejemplo: bash run_fastqc.sh /home/meg/gabi/il_fag/concat_workspace/concatenados 12'
    echo '--------------------------------------------------------------------------------------------------------------'
    exit 1
fi

#-------------------------------------------------------------
# Parámetros de entrada
#-------------------------------------------------------------
fastq_dir=$1
cores=$2

echo "📁 Directorio de FASTQ concatenados: $fastq_dir"
echo "⚙️  Núcleos asignados: $cores"
echo "⏳ Esperando 10 segundos..."
sleep 10

#-------------------------------------------------------------
# Activar entorno Conda
#-------------------------------------------------------------
eval "$(conda shell.bash hook)"
conda activate fastqc   # Cambiar si tu entorno tiene otro nombre

#-------------------------------------------------------------
# Crear carpeta de resultados
#-------------------------------------------------------------
out_dir=~/gabi/fastqc_results
mkdir -p "$out_dir"
echo "📦 Resultados se guardarán en: $out_dir"
echo "-------------------------------------------------------------"

#-------------------------------------------------------------
# Verificar que haya archivos .fastq.gz
#-------------------------------------------------------------
fastq_files=("$fastq_dir"/*.fastq.gz)
if [[ ${#fastq_files[@]} -eq 0 ]]; then
    echo "⚠️  No se encontraron archivos .fastq.gz en $fastq_dir"
    exit 1
fi

#-------------------------------------------------------------
# Ejecutar FastQC
#-------------------------------------------------------------
startTime=$(date +%s)
echo "🚀 Ejecutando FastQC en todos los archivos concatenados..."
fastqc -t "$cores" "${fastq_files[@]}" -o "$out_dir"

endTime=$(date +%s)
echo "✅ FastQC finalizado en $(( (endTime - startTime)/60 )) minutos."
echo "📅 Fecha de finalización: $(date)"
