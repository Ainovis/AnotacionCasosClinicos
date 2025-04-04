#!/bin/bash

# while no definido "BRANCH_NAME" se espera a que se genere el nombre del branch
while [ -z "$BRANCH_NAME" ]; do
    if [ -f /app/.env ]; then
        export $(grep -v '^#' /app/.env | xargs)
    fi
    echo "Esperando a que se genere el nombre del branch..."
    sleep 10
done


# Verificar si BRANCH_NAME está definido PORSIACASO, con errores raros por \243 o asi a rita la pollera
if [ -z "$BRANCH_NAME" ]; then
    echo "Error: BRANCH_NAME no está definido. Finalizando el servicio."
    exit 0
fi

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

exit 0
# Mantener el servicio en ejecución mostrando el enlace cada minuto
# while true; do
#     sleep 60
#     echo "ENLACE AL BRANCH DE GITHUB: $BRANCH_LINK"
# done