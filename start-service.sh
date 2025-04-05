#!/bin/bash
set -e

# Cargar variables desde .env si existe
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

# Repositorio y punto de partida (branch o commit)
REPO_URL=${REPO_URL:-"https://github.com/Ainovis/revisadorCasosClinicos.git"}
SOURCE_BRANCH=${SOURCE_BRANCH:-""}
COMMIT_HASH=${COMMIT_HASH:-"c4cf5166f7445b7983daab12ac0fe0b01886c7f0"}
BRANCH_NAME=${BRANCH_NAME:-"webapp"}

# Generar un nombre único para el branch
# INSTANCE_ID=$(cat /proc/sys/kernel/random/uuid | cut -d'-' -f1)

# Verificar si hay un NAME en .env
# if [ -f .env ] && grep -q "^NAME=" .env; then
#     CUSTOM_NAME=$(grep "^NAME=" .env | cut -d'=' -f2)
#     BRANCH_NAME="docker-instance-${CUSTOM_NAME}-${INSTANCE_ID}"
# else
#     BRANCH_NAME="docker-instance-${INSTANCE_ID}"
# fi

# echo $BRANCH_NAME
# echo "BRANCH_NAME=${BRANCH_NAME}" >> /app/.env;
# exit 0

# Verificar si el repositorio ya fue clonado
if [ ! -d "/app/revisadorCasosClinicos" ]; then
    echo "Clonando repositorio..."
    git clone $REPO_URL revisadorCasosClinicos
    cd revisadorCasosClinicos
    
    # Checkout al branch origen o commit específico
    if [ ! -z "$SOURCE_BRANCH" ]; then
        echo "Usando branch origen: $SOURCE_BRANCH"
        git checkout $SOURCE_BRANCH
    else
        echo "Usando commit específico: $COMMIT_HASH"
        git checkout $COMMIT_HASH
    fi
    
    # Instalar dependencias del proyecto
    echo "Instalando dependencias de Node.js..."
    npm install --force
    
    # Crear y cambiar al nuevo branch
    git checkout -b $BRANCH_NAME
    
    # Configurar credenciales de GitHub si se proporcionan como variables de entorno
    if [ ! -z "$GITHUB_TOKEN" ]; then
        # Configurar las credenciales usando el token
        git config --global credential.helper store
        echo "https://${GITHUB_TOKEN}@github.com" > ~/.git-credentials
        
        # Actualizar la URL del repositorio para usar HTTPS con token
        git remote set-url origin "https://${GITHUB_TOKEN}@github.com/Ainovis/revisadorCasosClinicos.git"
    fi

    # Copiando datos desde reg a pendientes TODO deberia ser desde fuera, y data/ deshardcodear
    mkdir -p data/pendientes data/correctas data/correcciones data/incompletos
    cp data/reg/* data/pendientes
else
    echo "Repositorio ya existe, omitiendo clonación..."
    cd /app/revisadorCasosClinicos
    
    # Verificar si el branch ya existe
    if ! git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
        echo "Creando nuevo branch $BRANCH_NAME..."
        # Checkout al branch origen o commit específico
        if [ ! -z "$SOURCE_BRANCH" ]; then
            echo "Usando branch origen: $SOURCE_BRANCH"
            git checkout $SOURCE_BRANCH
        else
            echo "Usando commit específico: $COMMIT_HASH"
            git checkout $COMMIT_HASH
        fi
        git checkout -b $BRANCH_NAME
        
        # Configurar credenciales de GitHub si se proporcionan como variables de entorno
        if [ ! -z "$GITHUB_TOKEN" ]; then
            # Configurar las credenciales usando el token
            git config --global credential.helper store
            echo "https://${GITHUB_TOKEN}@github.com" > ~/.git-credentials
            
            # Actualizar la URL del repositorio para usar HTTPS con token
            git remote set-url origin "https://${GITHUB_TOKEN}@github.com/Ainovis/revisadorCasosClinicos.git"
        fi
    else
        echo "Usando branch existente $BRANCH_NAME..."
        git checkout $BRANCH_NAME
    fi
fi

echo "Iniciando el monitor de cambios en segundo plano..."
/app/monitor-changes.sh &

echo "Iniciando la aplicación Node.js..."
echo "Branch de GitHub: https://github.com/Ainovis/revisadorCasosClinicos/tree/$BRANCH_NAME"

# Iniciar la aplicación Node.js
node src/server.js