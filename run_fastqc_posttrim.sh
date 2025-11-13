#!/bin/bash

hostname

#-------------------------------------------------------------
# Configuración de rutas y núcleos
#-------------------------------------------------------------
fastq_dir=~/gabi/il_fag/trimmomatic_results
output_dir=~/gabi/il_fag/fastqc_posttrim
cores=${1:-10}  # Si no se especifica, usa 10 núcleos

echo "📁 Directorio FASTQ (entrada): $fastq_dir"
echo "📁 Directorio de salida: $output_dir"
echo "⚙️  Núcleos asignados: $cores"
echo "⏳ Esperando 10 segundos antes de iniciar..."
sleep 10

#-------------------------------------------------------------
# Activar entorno Conda
#-------------------------------------------------------------
eval "$(conda shell.bash hook)"
conda activate fastqc

#-------------------------------------------------------------
# Crear carpeta de resultados
#-------------------------------------------------------------
mkdir -p "$output_dir"

#-------------------------------------------------------------
# Ejecutar FastQC solo en archivos *_paired.fastq.gz
#-------------------------------------------------------------
startTime=$(date +%s)

echo "🚀 Ejecutando FastQC (solo paired reads)..."
fastqc -t "$cores" "$fastq_dir"/*_paired.fastq.gz -o "$output_dir"

endTime=$(date +%s)
echo "✅ FastQC finalizado en $(( (endTime - startTime)/60 )) minutos."
echo "📅 Fecha de finalización: $(date)"
