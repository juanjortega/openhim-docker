# OpenHIM Docker Environment

Este proyecto configura OpenHIM (Open Health Information Mediator) usando Docker Compose con configuración completamente basada en variables de entorno.

## 🚀 Inicio Rápido

### 1. Configuración Inicial

```bash
# 1. Clonar o descargar el proyecto
# 2. Navegar al directorio del proyecto
cd openhim

# 3. Ejecutar el script de configuración (Linux/Mac)
./setup.sh

# O en Windows PowerShell
.\setup.ps1

# 4. Iniciar los servicios
docker-compose up -d
```

### 2. Acceso a los Servicios

- **OpenHIM Console**: http://localhost:9000
- **OpenHIM Core API**: https://localhost:8080
- **MongoDB**: localhost:27017 (interno)

## 📁 Estructura del Proyecto

```
openhim/
├── .env.example              # Ejemplo de variables de entorno
├── .env                      # Variables de entorno (generado automáticamente)
├── docker-compose.yml        # Configuración de Docker Compose
├── setup.sh                  # Script de configuración (Linux/Mac)
├── setup.ps1                 # Script de configuración (Windows)
├── config/
│   ├── console.json.template # Template para configuración de consola
│   ├── core.json.template    # Template para configuración del core
│   ├── console.json          # Configuración generada de consola
│   └── core.json            # Configuración generada del core
└── README.md                 # Este archivo
```

## ⚙️ Variables de Entorno Principales

### Configuración General
- `OPENHIM_HOST`: Host principal de OpenHIM
- `OPENHIM_EXTERNAL_HOST`: Host externo para conexiones
- `NODE_ENV`: Entorno de ejecución (development/production)

### Base de Datos
- `MONGO_HOST`: Host de MongoDB
- `MONGO_DATABASE`: Nombre de la base de datos
- `MONGO_URL`: URL completa de conexión a MongoDB

### Puertos
- `CORE_API_PORT`: Puerto de la API del core (default: 8080)
- `CONSOLE_PORT`: Puerto de la consola web (default: 9000)
- `CORE_HTTP_PORT`: Puerto HTTP del core (default: 5001)
- `CORE_HTTPS_PORT`: Puerto HTTPS del core (default: 5000)

### Autenticación
- `JWT_SECRET`: Secreto para tokens JWT
- `JWT_ALGORITHM`: Algoritmo para JWT (default: HS256)
- `API_SESSION_KEY`: Clave de sesión de la API

### SSO/OpenID
- `SSO_ENABLED`: Habilitar SSO (true/false)
- `KEYCLOAK_URL`: URL del servidor Keycloak
- `KEYCLOAK_CLIENT_ID`: ID del cliente OAuth
- `KEYCLOAK_CLIENT_SECRET`: Secreto del cliente OAuth

Ver `.env.example` para la lista completa de variables disponibles.

## 🔧 Configuración Personalizada

### 1. Modificar Variables de Entorno

```bash
# Editar el archivo .env
nano .env

# Regenerar configuraciones
./setup.sh  # Linux/Mac
# o
.\setup.ps1  # Windows

# Reiniciar servicios
docker-compose restart
```

### 2. Diferentes Entornos

Puedes crear diferentes archivos de entorno:

```bash
# Desarrollo
cp .env.example .env.development

# Producción
cp .env.example .env.production

# Cargar entorno específico
export $(cat .env.development | xargs) && ./setup.sh
```

### 3. Configuración Avanzada

Los templates en `config/` permiten personalización avanzada:

- `config/console.json.template`: Configuración de la consola web
- `config/core.json.template`: Configuración del core de OpenHIM

## 🐳 Comandos Docker Útiles

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Reiniciar servicios
docker-compose restart

# Parar servicios
docker-compose down

# Parar y eliminar volúmenes
docker-compose down -v

# Ver estado de servicios
docker-compose ps

# Acceder al contenedor del core
docker-compose exec openhim-core bash

# Acceder a MongoDB
docker-compose exec mongo-db mongo
```

## 🔍 Troubleshooting

### Problemas Comunes

1. **Puerto ya en uso**
   ```bash
   # Cambiar puertos en .env
   CORE_API_PORT=8081
   CONSOLE_PORT=9001
   ```

2. **Problemas de conectividad**
   ```bash
   # Verificar que los hosts sean correctos
   OPENHIM_HOST=tu-ip-local
   CONSOLE_HOST=tu-ip-local
   ```

3. **Regenerar configuración**
   ```bash
   # Eliminar archivos generados y regenerar
   rm config/console.json config/core.json
   ./setup.sh
   ```

### Logs y Debugging

```bash
# Ver logs del core
docker-compose logs -f openhim-core

# Ver logs de la consola
docker-compose logs -f openhim-console

# Ver logs de MongoDB
docker-compose logs -f mongo-db

# Verificar health checks
docker-compose ps
```

## 📚 Documentación Adicional

- [Documentación Oficial de OpenHIM](http://openhim.org/docs/)
- [Guía de Instalación](http://openhim.org/docs/installation/docker)
- [Configuración del Core](http://openhim.org/docs/configuration/core-config)
- [API Documentation](http://openhim.org/docs/api/overview)

## 🛡️ Seguridad

### Recomendaciones de Producción

1. **Cambiar secretos por defecto**:
   ```bash
   JWT_SECRET=tu-secreto-super-seguro-aqui
   API_SESSION_KEY=tu-clave-de-sesion-unica
   KEYCLOAK_CLIENT_SECRET=tu-secreto-oauth-seguro
   ```

2. **Usar HTTPS en producción**:
   ```bash
   CORE_PROTOCOL=https
   CONSOLE_PROTOCOL=https
   ```

3. **Configurar certificados SSL**:
   ```bash
   CERT_PATH=/ruta/a/tu/certificado.pem
   CERT_KEY_PATH=/ruta/a/tu/clave-privada.pem
   ```

4. **Configurar firewall apropiado**
5. **Usar bases de datos con autenticación**
6. **Regular backups de la base de datos**

## 🤝 Contribución

Para contribuir al proyecto:

1. Fork el repositorio
2. Crear una rama para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crear un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisar la documentación oficial de OpenHIM
2. Buscar en los issues del repositorio
3. Crear un nuevo issue con detalles del problema
4. Incluir logs relevantes y configuración (sin secretos)

---

## Changelog

### v1.0.0
- ✅ Configuración inicial con variables de entorno
- ✅ Scripts de setup para Linux/Mac y Windows
- ✅ Templates configurables para todos los servicios
- ✅ Documentación completa
- ✅ Soporte para múltiples entornos