# Script PowerShell simplificado para generar archivos de configuracion
Write-Host "Iniciando configuracion de OpenHIM..." -ForegroundColor Green

# Verificar archivo .env
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "Archivo .env creado desde .env.example" -ForegroundColor Green
    } else {
        Write-Host "Archivo .env.example no encontrado" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Archivo .env encontrado" -ForegroundColor Green
}

# Crear directorio config si no existe
if (-not (Test-Path "config")) {
    New-Item -ItemType Directory -Path "config" -Force | Out-Null
    Write-Host "Directorio config creado" -ForegroundColor Green
}

# Cargar variables de entorno desde .env
$envContent = Get-Content ".env"
foreach ($line in $envContent) {
    if ($line -match "^\s*#" -or $line -match "^\s*$") {
        continue
    }
    if ($line -match "^([^=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $value = $value -replace '^"(.*)"$', '$1'
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

Write-Host "Variables de entorno cargadas" -ForegroundColor Green

# Función para expandir variables
function Expand-EnvVars {
    param([string]$Content)
    
    # Reemplazar ${VAR:-default}
    $Content = [regex]::Replace($Content, '\$\{([^}:]+):-([^}]*)\}', {
        param($match)
        $varName = $match.Groups[1].Value
        $defaultValue = $match.Groups[2].Value
        $envValue = [Environment]::GetEnvironmentVariable($varName)
        if ($envValue) { return $envValue } else { return $defaultValue }
    })
    
    # Reemplazar ${VAR}
    $Content = [regex]::Replace($Content, '\$\{([^}]+)\}', {
        param($match)
        $varName = $match.Groups[1].Value
        $envValue = [Environment]::GetEnvironmentVariable($varName)
        if ($envValue) { return $envValue } else { return $match.Value }
    })
    
    return $Content
}

# Procesar templates
if (Test-Path "config\console.json.template") {
    $content = Get-Content "config\console.json.template" -Raw -Encoding UTF8
    $processed = Expand-EnvVars $content
    $processed | Out-File "config\console.json" -Encoding UTF8 -NoNewline
    Write-Host "Generado: config\console.json" -ForegroundColor Green
}

if (Test-Path "config\core.json.template") {
    $content = Get-Content "config\core.json.template" -Raw -Encoding UTF8
    $processed = Expand-EnvVars $content
    $processed | Out-File "config\core.json" -Encoding UTF8 -NoNewline
    Write-Host "Generado: config\core.json" -ForegroundColor Green
}

Write-Host "Configuracion completada!" -ForegroundColor Green
Write-Host "Ejecuta: docker-compose up -d" -ForegroundColor Yellow