# Carica l'installer WPF sulla pre-release GitHub gia esistente.
# Richiede GitHub CLI (gh) autenticato: https://cli.github.com/
param(
    [Parameter(Mandatory=$true)][string]$InstallerPath,
    [string]$Repository = 'Trigger117/normal-golf-game-italian-translation',
    [string]$Tag = 'v0.9.0-beta'
)
$ErrorActionPreference='Stop'
$expected='1592ce46d31e299e03d7376c0a5a549842735c606cc960aa0c160cae95aa40c7'
$resolved=(Resolve-Path -LiteralPath $InstallerPath -ErrorAction Stop).Path
$actual=(Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash.ToLowerInvariant()
if($actual -ne $expected) {throw "SHA-256 non valido: $actual"}
if(-not (Get-Command gh -ErrorAction SilentlyContinue)) {throw 'GitHub CLI non installato: https://cli.github.com/'}
& gh auth status
if($LASTEXITCODE -ne 0) {throw 'Esegui gh auth login prima di procedere'}
& gh release view $Tag --repo $Repository | Out-Null
if($LASTEXITCODE -ne 0) {throw "Release $Tag non trovata"}
& gh release upload $Tag $resolved --repo $Repository --clobber
if($LASTEXITCODE -ne 0) {throw 'Upload non riuscito'}
Write-Host "Installer pubblicato: https://github.com/$Repository/releases/tag/$Tag" -ForegroundColor Green
