#!/bin/bash

hostname

#-------------------------------------------------------------
# Control de argumentos
#-------------------------------------------------------------
if [[ $# -ne 2 ]]; then
    echo '--------------------------------------------------------------------------------------------------------------'
    echo 'usage: run_trimmomatic.sh <directorio_fastq> <cores>'
    echo 'Ejemplo: nohup bash run_trimmomatic.sh /home/meg/gabi/concat_workspace/concatenados 10 > trimmomatic.log 2>&1 &'
    echo '--------------------------------------------------------------------------------------------------------------'
    exit 1
fi

#-------------------------------------------------------------
# Parámetros de entrada
#-------------------------------------------------------------
fastq_dir=$1
cores=$2
output_dir=~/gabi/il_fag/trimmomatic_results
jar_path="/home/meg/miniconda3/envs/trimmomatic/share/trimmomatic-0.40-0/trimmomatic.jar"
adapters="/home/meg/miniconda3/envs/trimmomatic/share/trimmomatic-0.40-0/adapters/TruSeq3-PE.fa"

echo "📁 Directorio FASTQ: $fastq_dir"
echo "⚙️  Núcleos asignados: $cores"
echo "📦 Carpeta de salida: $output_dir"
echo "📂 Usando archivo de adaptadores: $adapters"
echo "-------------------------------------------------------------"

mkdir -p "$output_dir"

#-------------------------------------------------------------
# Activar entorno Conda
#-------------------------------------------------------------
eval "$(conda shell.bash hook)"
conda activate trimmomatic

startTime=$(date +%s)

#-------------------------------------------------------------
# Ejecución de Trimmomatic
#-------------------------------------------------------------
for file in "$fastq_dir"/*_R1.fastq.gz; do
    base=$(basename "$file" _R1.fastq.gz)
    R1="$fastq_dir/${base}_R1.fastq.gz"
    R2="$fastq_dir/${base}_R2.fastq.gz"

    echo "🧬 Procesando muestra: $base"

    java -jar "$jar_path" PE \
        -threads "$cores" \
        -phred33 \
        "$R1" "$R2" \
        "$output_dir/${base}_R1_paired.fastq.gz" "$output_dir/${base}_R1_unpaired.fastq.gz" \
        "$output_dir/${base}_R2_paired.fastq.gz" "$output_dir/${base}_R2_unpaired.fastq.gz" \
        ILLUMINACLIP:"$adapters":2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

    if [[ $? -eq 0 ]]; then
        echo "✅ $base completado correctamente."
    else
        echo "⚠️  Error procesando $base."
    fi
    echo "-------------------------------------------------------------"
done

#-------------------------------------------------------------
# Finalización
#-------------------------------------------------------------
endTime=$(date +%s)
echo "🏁 Trimmomatic finalizado en $(( (endTime - startTime)/60 )) minutos."
echo "📅 Fecha de finalización: $(date)"
