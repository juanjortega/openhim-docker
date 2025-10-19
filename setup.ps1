# Script PowerShell para generar archivos de configuración desde templates con variables de entorno
# Este script debe ejecutarse antes de iniciar los servicios de OpenHIM

param(
    [switch]$Force,
    [switch]$Help
)

# Función para mostrar ayuda
function Show-Help {
    Write-Host "OpenHIM Configuration Setup Script" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Uso: .\setup.ps1 [opciones]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "  -Force    Sobrescribe archivos existentes sin preguntar"
    Write-Host "  -Help     Muestra esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Yellow
    Write-Host "  .\setup.ps1"
    Write-Host "  .\setup.ps1 -Force"
    exit 0
}

if ($Help) {
    Show-Help
}

Write-Host "🚀 Iniciando configuración de OpenHIM..." -ForegroundColor Green

# Función para verificar si el archivo .env existe
function Test-EnvFile {
    if (-not (Test-Path ".env")) {
        Write-Host "⚠️  Archivo .env no encontrado. Copiando desde .env.example..." -ForegroundColor Yellow
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" ".env"
            Write-Host "✅ Archivo .env creado desde .env.example" -ForegroundColor Green
            Write-Host "🔧 Por favor, revisa y ajusta las variables en .env según tu entorno" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Archivo .env.example no encontrado. No se puede crear .env automáticamente." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✅ Archivo .env encontrado" -ForegroundColor Green
    }
}

# Función para cargar variables de entorno desde .env
function Import-EnvFile {
    param([string]$Path = ".env")
    
    Write-Host "📋 Cargando variables de entorno..." -ForegroundColor Yellow
    
    if (Test-Path $Path) {
        $envContent = Get-Content $Path
        foreach ($line in $envContent) {
            # Ignorar comentarios y líneas vacías
            if ($line -match "^\s*#" -or $line -match "^\s*$") {
                continue
            }
            
            # Procesar líneas con formato KEY=VALUE
            if ($line -match "^([^=]+)=(.*)$") {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                
                # Remover comillas si existen
                $value = $value -replace '^"(.*)"$', '$1'
                $value = $value -replace "^'(.*)'$", '$1'
                
                # Establecer variable de entorno
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
        Write-Host "✅ Variables de entorno cargadas" -ForegroundColor Green
    } else {
        Write-Host "❌ Archivo .env no encontrado en: $Path" -ForegroundColor Red
        exit 1
    }
}

# Función para reemplazar variables de entorno en templates
function Expand-Template {
    param(
        [string]$TemplateContent
    )
    
    # Obtener todas las variables de entorno
    $envVars = Get-ChildItem Env:
    
    # Reemplazar variables con formato ${VAR:-default}
    $pattern = '\$\{([^}:]+):-([^}]*)\}'
    $TemplateContent = [regex]::Replace($TemplateContent, $pattern, {
        param($match)
        $varName = $match.Groups[1].Value
        $defaultValue = $match.Groups[2].Value
        
        $envValue = [Environment]::GetEnvironmentVariable($varName)
        if ($null -ne $envValue -and $envValue -ne "") {
            return $envValue
        } else {
            return $defaultValue
        }
    })
    
    # Reemplazar variables con formato ${VAR}
    $pattern = '\$\{([^}]+)\}'
    $TemplateContent = [regex]::Replace($TemplateContent, $pattern, {
        param($match)
        $varName = $match.Groups[1].Value
        $envValue = [Environment]::GetEnvironmentVariable($varName)
        if ($null -ne $envValue) {
            return $envValue
        } else {
            return $match.Value
        }
    })
    
    return $TemplateContent
}

# Función para procesar templates
function Process-Template {
    param(
        [string]$TemplateFile,
        [string]$OutputFile
    )
    
    Write-Host "🔄 Procesando template: $TemplateFile" -ForegroundColor Yellow
    
    if (-not (Test-Path $TemplateFile)) {
        Write-Host "❌ Template no encontrado: $TemplateFile" -ForegroundColor Red
        return $false
    }
    
    # Leer contenido del template
    $templateContent = Get-Content $TemplateFile -Raw -Encoding UTF8
    
    # Expandir variables de entorno
    $processedContent = Expand-Template $templateContent
    
    # Escribir archivo de salida
    $processedContent | Out-File -FilePath $OutputFile -Encoding UTF8 -NoNewline
    
    Write-Host "✅ Generado: $OutputFile" -ForegroundColor Green
    return $true
}

# Función para crear directorios necesarios
function New-Directories {
    Write-Host "📁 Creando directorios necesarios..." -ForegroundColor Yellow
    
    $directories = @("config")
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    Write-Host "✅ Directorios creados" -ForegroundColor Green
}

# Función principal
function Main {
    Write-Host "🎯 OpenHIM Configuration Setup" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    
    try {
        # Verificar y cargar archivo .env
        Test-EnvFile
        Import-EnvFile
        
        # Crear directorios
        New-Directories
        
        # Procesar templates
        $success = $true
        
        if (Test-Path "config\console.json.template") {
            $success = $success -and (Process-Template "config\console.json.template" "config\console.json")
        } else {
            Write-Host "❌ Template config\console.json.template no encontrado" -ForegroundColor Red
            $success = $false
        }
        
        if (Test-Path "config\core.json.template") {
            $success = $success -and (Process-Template "config\core.json.template" "config\core.json")
        } else {
            Write-Host "❌ Template config\core.json.template no encontrado" -ForegroundColor Red
            $success = $false
        }
        
        if ($success) {
            # Mostrar resumen
            Write-Host "================================" -ForegroundColor Green
            Write-Host "✅ Configuración completada" -ForegroundColor Green
            Write-Host "📝 Archivos generados:" -ForegroundColor Yellow
            Write-Host "   - config\console.json"
            Write-Host "   - config\core.json"
            Write-Host ""
            Write-Host "🚀 Ahora puedes iniciar los servicios con:" -ForegroundColor Yellow
            Write-Host "   docker-compose up -d"
            Write-Host ""
            Write-Host "🔧 Para modificar la configuración, edita el archivo .env y ejecuta:" -ForegroundColor Yellow
            Write-Host "   .\setup.ps1; docker-compose restart"
        } else {
            Write-Host "❌ Algunos templates no pudieron procesarse" -ForegroundColor Red
            exit 1
        }
        
    } catch {
        Write-Host "Error durante la configuracion: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Ejecutar función principal
Main