#!/bin/bash

#-------------------------------------------------------------
# concat_samples_v2.sh
# ------------------------------------------------------------
# Crea un entorno de trabajo para concatenar archivos FASTQ.gz
# provenientes de múltiples lanes o flowcells, unificando por muestra biológica.
# ------------------------------------------------------------
# Uso:
#   bash concat_samples_v2.sh <directorio_raw_data> <cores>
# Ejemplo:
#   bash concat_samples_v2.sh /home/meg/gabi/raw_data 8
# -------------------------------------------------------------

#-------------------------------------------------------------
# Control de argumentos
#-------------------------------------------------------------
if [[ $# -ne 2 ]]; then
    echo '--------------------------------------------------------------------------------------------------------------'
    echo 'usage: concat_samples_v2.sh <directorio_raw_data> <cores>'
    echo 'Ejemplo: bash concat_samples_v2.sh /home/meg/gabi/raw_data 8'
    echo '--------------------------------------------------------------------------------------------------------------'
    exit 1
fi

#-------------------------------------------------------------
# Parámetros de entrada
#-------------------------------------------------------------
raw_dir=$1
cores=$2
workspace_dir="${raw_dir}/../concat_workspace_v2"

echo "🖥️  Iniciando proceso en $(hostname)"
echo "📁 Directorio original: $raw_dir"
echo "🧪 Directorio de trabajo: $workspace_dir"
echo "⚙️  Usando $cores cores"
echo "-------------------------------------------------------------"

#-------------------------------------------------------------
# Crear directorio de trabajo y enlaces simbólicos
#-------------------------------------------------------------
mkdir -p "$workspace_dir"
echo "🔗 Creando enlaces simbólicos en $workspace_dir..."
find "$raw_dir" -maxdepth 1 -name "*.fastq.gz" -exec ln -sf {} "$workspace_dir" \;
echo "✅ Enlaces creados"
echo "-------------------------------------------------------------"

#-------------------------------------------------------------
# Activar entorno Conda
#-------------------------------------------------------------
eval "$(conda shell.bash hook)"
conda activate base   # Cambiar si se usa otro entorno

startTime=$(date +%s)

#-------------------------------------------------------------
# Verificación de integridad (MD5)
#-------------------------------------------------------------
echo "🔍 Verificando integridad de los archivos .fastq.gz..."
if [[ -f "$raw_dir/md5s.txt" ]]; then
    md5sum -c "$raw_dir/md5s.txt" > "$workspace_dir/md5_check.log" 2>&1
    echo "✅ Revisión de MD5 completada. Ver '$workspace_dir/md5_check.log'"
else
    echo "⚠️  No se encontró archivo de checksums, se omite la verificación."
fi
echo "-------------------------------------------------------------"

#-------------------------------------------------------------
# Mapeo entre identificadores Illumina y nombres de muestra
#-------------------------------------------------------------
declare -A sample_map
sample_map["UDP0022"]="MCHA-MB-1-VIRFC"
sample_map["UDP0023"]="MCHA-DE-14-VIRFC"
sample_map["UDP0024"]="MCHA-OR-22-VIRFC"
sample_map["UDP0124"]="MCHA-EL-19-VIRFC"
sample_map["UDP0125"]="MCHA-MB-1-LIS"
sample_map["UDP0126"]="MCHA-DE-14-LIS"
sample_map["UDP0127"]="MCHA-OR-22-LIS"
sample_map["UDP0128"]="MCHA-EL-19-LIS"

#-------------------------------------------------------------
# Crear carpeta de salida
#-------------------------------------------------------------
mkdir -p "$workspace_dir/concatenados"
echo "📦 Archivos concatenados se guardarán en: $workspace_dir/concatenados"
echo "-------------------------------------------------------------"

#-------------------------------------------------------------
# Concatenación por muestra biológica
#-------------------------------------------------------------
for id in "${!sample_map[@]}"; do
    sample="${sample_map[$id]}"
    echo "🧬 Procesando muestra: $sample (ID Illumina: $id)"

    files_R1=$(ls "$workspace_dir"/*${id}_1.fastq.gz 2>/dev/null)
    files_R2=$(ls "$workspace_dir"/*${id}_2.fastq.gz 2>/dev/null)

    if [[ -z "$files_R1" || -z "$files_R2" ]]; then
        echo "⚠️  No se encontraron archivos para $sample ($id)"
        echo "-------------------------------------------------------------"
        continue
    fi

    out_R1="$workspace_dir/concatenados/${sample}_R1.fastq.gz"
    out_R2="$workspace_dir/concatenados/${sample}_R2.fastq.gz"

    echo "  ➕ Concatenando R1..."
    cat $files_R1 > "$out_R1"

    echo "  ➕ Concatenando R2..."
    cat $files_R2 > "$out_R2"

    echo "  ✅ Muestra $sample concatenada correctamente"

    #---------------------------------------------------------
    # Generar y verificar MD5 de archivos concatenados
    #---------------------------------------------------------
    echo "  🔍 Generando y verificando checksum MD5..."
    md5sum "$out_R1" > "$out_R1.md5"
    md5sum "$out_R2" > "$out_R2.md5"

    md5sum -c "$out_R1.md5" > "$out_R1.md5check.log" 2>&1
    md5sum -c "$out_R2.md5" > "$out_R2.md5check.log" 2>&1

    echo "  ✅ MD5 generado y verificado:"
    echo "     - $(basename "$out_R1.md5") → log: $(basename "$out_R1.md5check.log")"
    echo "     - $(basename "$out_R2.md5") → log: $(basename "$out_R2.md5check.log")"
    echo "-------------------------------------------------------------"
done

#-------------------------------------------------------------
# Finalización
#-------------------------------------------------------------
endTime=$(date +%s)
echo "🏁 Proceso finalizado en $(( (endTime - startTime)/60 )) minutos."
echo "📅 Fecha de finalización: $(date)"
echo "-------------------------------------------------------------"
