#!/bin/bash

# Cargar variables desde .env si existe
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

# Obtener el nombre del branch desde variables de entorno
# if [ -z "$BRANCH_NAME" ]; then
#     echo "Error: BRANCH_NAME no está definido. Finalizando el servicio de monitoreo."
#     exit 0
# fi
BRANCH_NAME=${BRANCH_NAME:-"webapp"}

cd /app/revisadorCasosClinicos

# Función para hacer commit y push de cambios
commit_change() {
    local directory="$1"
    local filename="$2"
    
    # Construir la ruta completa
    local file_path="${directory}${filename}"
    
    # Extraer subdirectorio relativo a data/
    local relative_dir="${directory#data/}"
    local subdirectory="${relative_dir%/}"
    
    # Si el subdirectorio está vacío, lo manejamos de forma especial
    if [ -z "$subdirectory" ]; then
        local commit_message="[/]: $filename"
    else
        local commit_message="[$subdirectory]: $filename"
    fi
    
    echo "Realizando commit: $commit_message"
    
    # Añadir todos los cambios en data/
    git add data/
    
    # Realizar commit con el formato especificado
    git commit -m "$commit_message"
    
    # Realizar push al branch
    git push origin $BRANCH_NAME
    
    echo "Cambios subidos a GitHub en el branch: $BRANCH_NAME"
    echo "URL del branch: https://github.com/Ainovis/revisadorCasosClinicos/tree/$BRANCH_NAME"
}

echo "Monitoreando cambios en la carpeta data/..."

# Usar inotifywait para monitorear cambios y procesarlos uno a uno
inotifywait -m -r -e moved_to,create,modify data/ | while read dir event file; do
    # Sólo procesar archivos JSON
    if [[ "$file" == *.json ]]; then
        echo "Detectado cambio en ${dir}${file}"
        commit_change "$dir" "$file"
    else
        echo "Ignorando cambio en archivo no JSON: ${dir}${file}"
    fi
done