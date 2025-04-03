FROM node:18

# Instalar git y herramientas de monitoreo
RUN apt-get update && apt-get install -y git inotify-tools

# Directorio de trabajo
WORKDIR /app

# Copiar scripts de configuración
COPY start-service.sh /app/
COPY monitor-changes.sh /app/

# Dar permisos de ejecución a los scripts
RUN chmod +x /app/start-service.sh /app/monitor-changes.sh

# Configurar git
ARG GIT_EMAIL="docker-instance@example.com"
ARG GIT_NAME="Docker Instance"
RUN git config --global user.email "$GIT_EMAIL" && \
    git config --global user.name "$GIT_NAME"

# Iniciar el servicio
CMD ["/app/start-service.sh"]