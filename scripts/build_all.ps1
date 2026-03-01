$ErrorActionPreference = "Stop"

$Repo = Split-Path -Parent $PSScriptRoot

$FlutterProj = Join-Path $Repo "apps\flutter_app\etiquetas_bodega"
$OutRelease = Join-Path $FlutterProj "build\windows\x64\runner\Release"

$MkSrc = Join-Path $Repo "bridges\mk_bridge\dist\mk_bridge.exe"
$PrtSrc = Join-Path $Repo "bridges\print_bridge\dist\print_bridge.exe"

Write-Host "== Publish bridges =="

dotnet publish (Join-Path $Repo "bridges\mk_bridge\src\mk_bridge\mk_bridge.csproj") `
  -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
  -o (Join-Path $Repo "bridges\mk_bridge\dist")

dotnet publish (Join-Path $Repo "bridges\print_bridge\src\print_bridge\print_bridge.csproj") `
  -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true `
  -o (Join-Path $Repo "bridges\print_bridge\dist")

Write-Host "== Build Flutter Windows release =="

Push-Location $FlutterProj
flutter build windows --release
Pop-Location

Write-Host "== Copy bridges into Release output =="

$BridgeOutDir = Join-Path $OutRelease "bridges"
New-Item -ItemType Directory -Force -Path $BridgeOutDir | Out-Null

Copy-Item $MkSrc (Join-Path $BridgeOutDir "mk_bridge.exe") -Force
Copy-Item $PrtSrc (Join-Path $BridgeOutDir "print_bridge.exe") -Force

Write-Host "OK -> $OutRelease"