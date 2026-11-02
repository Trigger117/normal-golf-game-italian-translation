# Normal Golf Game — Italiano: compilazione del plugin BepInEx 5 (Unity Mono / netstandard 2.1)
# Sostituire BepInEx\normal-golf-italian\CompilaPatch.ps1 con questo file.
param([string]$GameDir = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))

$ErrorActionPreference = 'Stop'
$GameDir = (Resolve-Path -LiteralPath $GameDir).Path
$source = Join-Path $PSScriptRoot 'NormalGolfItalianI2.cs'
$bepinexDll = Join-Path $GameDir 'BepInEx\core\BepInEx.dll'
$managed = Join-Path $GameDir 'Normal Golf Game_Data\Managed'
$unityCore = Join-Path $managed 'UnityEngine.CoreModule.dll'
$unityDll = Join-Path $managed 'UnityEngine.dll'
$outDir = Join-Path $GameDir 'BepInEx\plugins'
$outDll = Join-Path $outDir 'NormalGolfItalianI2.dll'

foreach ($file in @($source, $bepinexDll, $unityCore)) {
    if (-not (Test-Path -LiteralPath $file)) { throw "File necessario non trovato: $file" }
}
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# Un SDK moderno e il target netstandard2.1 evitano il CS0012 del csc.exe di .NET Framework 4.x.
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
$hasSdk = $false
if ($dotnet) {
    $sdkLines = & $dotnet.Source --list-sdks 2>$null
    $hasSdk = ($LASTEXITCODE -eq 0 -and $null -ne $sdkLines -and @($sdkLines).Count -gt 0)
}

if ($hasSdk) {
    $buildDir = Join-Path $PSScriptRoot '_build'
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    $project = Join-Path $buildDir 'NormalGolfItalianI2.csproj'
    $srcXml = [System.Security.SecurityElement]::Escape($source)
    $bepXml = [System.Security.SecurityElement]::Escape($bepinexDll)
    $coreXml = [System.Security.SecurityElement]::Escape($unityCore)
    $extra = ''
    if (Test-Path -LiteralPath $unityDll) {
        $unityXml = [System.Security.SecurityElement]::Escape($unityDll)
        $extra = "<Reference Include=`"UnityEngine`"><HintPath>$unityXml</HintPath><Private>false</Private></Reference>"
    }

    $xml = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <AssemblyName>NormalGolfItalianI2</AssemblyName>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
    <Nullable>disable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="$srcXml" />
    <Reference Include="BepInEx"><HintPath>$bepXml</HintPath><Private>false</Private></Reference>
    <Reference Include="UnityEngine.CoreModule"><HintPath>$coreXml</HintPath><Private>false</Private></Reference>
    $extra
  </ItemGroup>
</Project>
"@
    [System.IO.File]::WriteAllText($project, $xml, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Compilazione con .NET SDK (netstandard2.1): $outDll" -ForegroundColor Cyan
    & $dotnet.Source build $project --configuration Release --nologo --output $outDir
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outDll)) {
        throw 'Compilazione .NET SDK fallita: copia gli errori completi in chat.'
    }
} else {
    # Tentativo senza installare programmi: usa il compilatore Windows aggiungendo netstandard.dll.
    # Questo percorso dipende dalle DLL di Unity e potrebbe non funzionare con tutti i giochi.
    $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
    if (-not (Test-Path -LiteralPath $csc)) { throw 'Compilatore Windows non trovato. Installa il .NET SDK 8 o successivo.' }
    $candidates = @(
        (Join-Path $managed 'netstandard.dll'),
        (Join-Path $managed 'Facades\netstandard.dll'),
        (Join-Path $GameDir 'BepInEx\core\netstandard.dll')
    )
    $netstandard = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $netstandard) {
        throw 'netstandard.dll non trovato nella cartella del gioco. Installa un .NET SDK moderno (https://dotnet.microsoft.com/download) ed esegui di nuovo questo script.'
    }
    Write-Host "Compilazione con csc.exe e netstandard: $netstandard" -ForegroundColor Cyan
    $arguments = @('/nologo', '/target:library', '/optimize+', ('/out:' + $outDll), ('/reference:' + $bepinexDll), ('/reference:' + $unityCore), ('/reference:' + $netstandard))
    if (Test-Path -LiteralPath $unityDll) { $arguments += ('/reference:' + $unityDll) }
    $arguments += $source
    & $csc @arguments
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outDll)) {
        throw 'Il vecchio compilatore Windows non riesce a compilare il plugin: usa il .NET SDK 8+ (https://dotnet.microsoft.com/download), poi rilancia questo script.'
    }
}

Write-Host "OK: plugin compilato in $outDll" -ForegroundColor Green
Write-Host 'Avvia il gioco e controlla BepInEx\LogOutput.log.' -ForegroundColor Green
