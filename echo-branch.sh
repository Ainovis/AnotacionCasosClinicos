#!/bin/bash

# Esperar a que el archivo con el nombre del branch exista
while [ ! -f /app/branch_name.txt ]; do
    echo "Esperando a que se genere el nombre del branch..."
    sleep 10
done

# Leer el nombre del branch
BRANCH_NAME=$(cat /app/branch_name.txt)

# Obtener el repositorio desde .env si existe
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

REPO_URL=${REPO_URL:-"https://github.com/Ainovis/revisadorCasosClinicos.git"}
REPO_BASE=${REPO_URL%.git}

# Construir y mostrar el enlace
BRANCH_LINK="${REPO_BASE}/tree/${BRANCH_NAME}"

echo "============================================"
echo "ENLACE AL BRANCH DE GITHUB:"
echo $BRANCH_LINK
echo "============================================"

# Mantener el servicio en ejecución mostrando el enlace cada minuto
while true; do
    sleep 60
    echo "ENLACE AL BRANCH DE GITHUB: $BRANCH_LINK"
done