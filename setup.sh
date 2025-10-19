#!/bin/bash

# Script para generar archivos de configuración desde templates con variables de entorno
# Este script debe ejecutarse antes de iniciar los servicios de OpenHIM

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando configuración de OpenHIM...${NC}"

# Función para verificar si el archivo .env existe
check_env_file() {
    if [ ! -f .env ]; then
        echo -e "${YELLOW}⚠️  Archivo .env no encontrado. Copiando desde .env.example...${NC}"
        if [ -f .env.example ]; then
            cp .env.example .env
            echo -e "${GREEN}✅ Archivo .env creado desde .env.example${NC}"
            echo -e "${YELLOW}🔧 Por favor, revisa y ajusta las variables en .env según tu entorno${NC}"
        else
            echo -e "${RED}❌ Archivo .env.example no encontrado. No se puede crear .env automáticamente.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Archivo .env encontrado${NC}"
    fi
}

# Función para cargar variables de entorno
load_env() {
    echo -e "${YELLOW}📋 Cargando variables de entorno...${NC}"
    set -a  # Automatically export all variables
    source .env
    set +a
    echo -e "${GREEN}✅ Variables de entorno cargadas${NC}"
}

# Función para procesar templates
process_template() {
    local template_file="$1"
    local output_file="$2"
    
    echo -e "${YELLOW}🔄 Procesando template: ${template_file}${NC}"
    
    # Usar envsubst para reemplazar variables de entorno
    if command -v envsubst >/dev/null 2>&1; then
        envsubst < "$template_file" > "$output_file"
        echo -e "${GREEN}✅ Generado: ${output_file}${NC}"
    else
        echo -e "${RED}❌ envsubst no está disponible. Instalando gettext...${NC}"
        # En sistemas basados en Debian/Ubuntu
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y gettext-base
        # En sistemas basados en CentOS/RHEL
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y gettext
        # En sistemas basados en Alpine
        elif command -v apk >/dev/null 2>&1; then
            sudo apk add --no-cache gettext
        else
            echo -e "${RED}❌ No se pudo instalar gettext automáticamente${NC}"
            exit 1
        fi
        envsubst < "$template_file" > "$output_file"
        echo -e "${GREEN}✅ Generado: ${output_file}${NC}"
    fi
}

# Función para crear directorios necesarios
create_directories() {
    echo -e "${YELLOW}📁 Creando directorios necesarios...${NC}"
    mkdir -p config
    echo -e "${GREEN}✅ Directorios creados${NC}"
}

# Función principal
main() {
    echo -e "${GREEN}🎯 OpenHIM Configuration Setup${NC}"
    echo -e "${GREEN}================================${NC}"
    
    # Verificar y cargar archivo .env
    check_env_file
    load_env
    
    # Crear directorios
    create_directories
    
    # Procesar templates
    if [ -f "config/console.json.template" ]; then
        process_template "config/console.json.template" "config/console.json"
    else
        echo -e "${RED}❌ Template config/console.json.template no encontrado${NC}"
    fi
    
    if [ -f "config/core.json.template" ]; then
        process_template "config/core.json.template" "config/core.json"
    else
        echo -e "${RED}❌ Template config/core.json.template no encontrado${NC}"
    fi
    
    # Mostrar resumen
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}✅ Configuración completada${NC}"
    echo -e "${YELLOW}📝 Archivos generados:${NC}"
    echo -e "   - config/console.json"
    echo -e "   - config/core.json"
    echo ""
    echo -e "${YELLOW}🚀 Ahora puedes iniciar los servicios con:${NC}"
    echo -e "   docker-compose up -d"
    echo ""
    echo -e "${YELLOW}🔧 Para modificar la configuración, edita el archivo .env y ejecuta:${NC}"
    echo -e "   ./setup.sh && docker-compose restart"
}

# Ejecutar función principal
main "$@"