$ErrorActionPreference = "Stop"

# Repo root
$Repo = Split-Path -Parent $PSScriptRoot

# Flutter project
$FlutterProj = Join-Path $Repo "apps\flutter_app\etiquetas_bodega"

# Output of flutter build
$FlutterReleaseOut = Join-Path $FlutterProj "build\windows\x64\runner\Release"

# Final portable package folder
$PackageRoot = Join-Path $Repo "dist_release"
$PackageBridges = Join-Path $PackageRoot "bridges"
$PackageConfig = Join-Path $PackageRoot "config"

# Bridges projects & dist exes
$MkCsproj = Join-Path $Repo "bridges\mk_bridge\src\mk_bridge\mk_bridge.csproj"
$PrtCsproj = Join-Path $Repo "bridges\print_bridge\src\print_bridge\print_bridge.csproj"

$MkExe = Join-Path $Repo "bridges\mk_bridge\dist\mk_bridge.exe"
$PrtExe = Join-Path $Repo "bridges\print_bridge\dist\print_bridge.exe"

# Config sources
$AppConfigSrc = Join-Path $FlutterProj "app_config.json"
$CatalogSampleSrc = Join-Path $Repo "bridges\mk_bridge\config\catalog.sample.json"
$SqlConfigSrc = Join-Path $Repo "bridges\mk_bridge\config\config.xml"   # NO en git (local)

Write-Host "== 1) Publish bridges =="

dotnet publish $MkCsproj `
  -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
  -o (Join-Path $Repo "bridges\mk_bridge\dist")

dotnet publish $PrtCsproj `
  -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
  -o (Join-Path $Repo "bridges\print_bridge\dist")

if (!(Test-Path $MkExe)) { throw "mk_bridge.exe no encontrado en $MkExe" }
if (!(Test-Path $PrtExe)) { throw "print_bridge.exe no encontrado en $PrtExe" }

Write-Host "== 2) Build Flutter Windows Release =="

Push-Location $FlutterProj
flutter build windows --release
Pop-Location

if (!(Test-Path $FlutterReleaseOut)) { throw "Output Release de Flutter no encontrado: $FlutterReleaseOut" }

Write-Host "== 3) Prepare package folder =="

if (Test-Path $PackageRoot) { Remove-Item $PackageRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $PackageRoot | Out-Null
New-Item -ItemType Directory -Force -Path $PackageBridges | Out-Null
New-Item -ItemType Directory -Force -Path $PackageConfig  | Out-Null

Write-Host "== 4) Copy Flutter Release output =="

# Copia TODO el runner Release (exe + dlls)
Copy-Item -Path (Join-Path $FlutterReleaseOut "*") -Destination $PackageRoot -Recurse -Force

Write-Host "== 5) Copy bridges =="

Copy-Item $MkExe (Join-Path $PackageBridges "mk_bridge.exe") -Force
Copy-Item $PrtExe (Join-Path $PackageBridges "print_bridge.exe") -Force

Write-Host "== 6) Copy configs =="

if (!(Test-Path $AppConfigSrc)) { throw "app_config.json no encontrado en $AppConfigSrc" }
Copy-Item $AppConfigSrc (Join-Path $PackageRoot "app_config.json") -Force

if (Test-Path $CatalogSampleSrc) {
  Copy-Item $CatalogSampleSrc (Join-Path $PackageConfig "catalog.sample.json") -Force
}
else {
  Write-Warning "catalog.sample.json no encontrado; modo offline podría fallar en release."
}

# config.xml real es opcional (si no existe, el paquete queda offline-only)
if (Test-Path $SqlConfigSrc) {
  Copy-Item $SqlConfigSrc (Join-Path $PackageConfig "config.xml") -Force
}
else {
  Write-Warning "config.xml no encontrado. El paquete quedará solo para OFFLINE hasta que agregues config/config.xml en el PC destino."
}

Write-Host "== OK: Package generado =="
Write-Host $PackageRoot
Write-Host ""
Write-Host "Ejecuta: $(Join-Path $PackageRoot 'etiquetas_bodega.exe')"