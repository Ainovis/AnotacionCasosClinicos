# REVISADOR CASOS CLÍNICOS

Configuracion Docker para el servicio de revision de casos clinicos.
Monitorizacion y actualizacion automatica en github del estado de las revisiones.

## Requisitos
* Docker y Docker Compose instalados
* Token de GitHub con permisos repo:status y public_repo

## Instructivos

### Iniciar app:
```bash
cp .env.example .env
nano .env #Edita con los valores reales
chmod +x start-service.sh monitor-changes.sh
docker compose up -d
```

## Ver link al repositorio con los resultados a tiempo real:
``

### Apagar app:
`docker compose stop`

### Matar app (elimina datos):
`docker compose down --rmi all --volumes --remove-orphans`
