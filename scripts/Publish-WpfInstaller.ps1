# Carica sulla release GitHub un EXE gia' provato, usando tag e SHA256 espliciti.
# Richiede GitHub CLI: https://cli.github.com/
param(
    [Parameter(Mandatory=$true)][string]$InstallerPath,
    [Parameter(Mandatory=$true)][string]$Tag,
    [Parameter(Mandatory=$true)][ValidatePattern('^[a-fA-F0-9]{64}$')][string]$ExpectedSha256,
    [string]$Repository = 'Trigger117/normal-golf-game-italian-translation'
)
$ErrorActionPreference = 'Stop'
$exe = (Resolve-Path -LiteralPath $InstallerPath -ErrorAction Stop).Path
$actual = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash.ToLowerInvariant()
$expected = $ExpectedSha256.ToLowerInvariant()
if ($actual -ne $expected) { throw "SHA-256 diverso: previsto $expected, effettivo $actual" }
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'Installa GitHub CLI da https://cli.github.com/ e accedi con: gh auth login'
}
& gh auth status
if ($LASTEXITCODE -ne 0) { throw 'Accesso GitHub CLI non valido: gh auth login' }
& gh release view $Tag --repo $Repository | Out-Null
if ($LASTEXITCODE -ne 0) { throw "La release $Tag non esiste. Creala prima di caricare gli allegati." }
& gh release upload $Tag $exe --repo $Repository
if ($LASTEXITCODE -ne 0) { throw 'Caricamento non riuscito' }
Write-Host "Installer caricato su: https://github.com/$Repository/releases/tag/$Tag" -ForegroundColor Green
