param(
    [Parameter(Mandatory=$true)][string]$GamePath,
    [Parameter(Mandatory=$true)][string]$PatchZip,
    [Parameter(Mandatory=$true)][string]$StatusFile,
    [switch]$InstallDependencies
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$LogPath = Join-Path $env:TEMP 'NormalGolf_Installer_WPF.log'
$gameExe = 'Normal Golf Game.exe'
$hashPatch = '7879d19b78f08be95a909f071756fc6d24e33d3daa2932785ec1241567bc1701'
$dependencies = @(
    @{ Name='BepInEx'; Url='https://github.com/BepInEx/BepInEx/releases/download/v5.4.23.6/BepInEx_win_x64_5.4.23.6.zip'; Sha='6c57a714a892efb4e9e1fef63d608a3391f30ec984031c465404e4ee381a0755' },
    @{ Name='XUnity'; Url='https://github.com/bbepis/XUnity.AutoTranslator/releases/download/v5.6.3.1/XUnity.AutoTranslator-BepInEx-5.6.3.1.zip'; Sha='6c3ff03aafe9708f25c2115c0c04c255b6a9d88e716896ae7bacb590a8777609' }
)
$utf8 = New-Object Text.UTF8Encoding($false)
function Report([int]$progress,[string]$message,[string]$level='info') {
    $row = @{ time=(Get-Date -Format 'HH:mm:ss'); progress=$progress; message=$message; level=$level }
    $line = ConvertTo-Json -InputObject $row -Compress
    [IO.File]::AppendAllText($StatusFile,$line+[Environment]::NewLine,$utf8)
    try { [IO.File]::AppendAllText($LogPath,('[' + (Get-Date -Format s) + '] ' + $message + [Environment]::NewLine),$utf8) } catch {}
}
function Get-ValidPath([string]$dir) {
    if ([string]::IsNullOrWhiteSpace($dir)) { throw 'Seleziona la cartella del gioco.' }
    $dir = [Environment]::ExpandEnvironmentVariables($dir.Trim().Trim('"'))
    if ([IO.File]::Exists($dir) -and [IO.Path]::GetFileName($dir) -ieq $gameExe) { $dir=[IO.Path]::GetDirectoryName($dir) }
    if ([IO.Directory]::Exists($dir) -and [IO.File]::Exists((Join-Path $dir $gameExe))) { return [IO.Path]::GetFullPath($dir) }
    $nested = Join-Path $dir 'Normal'
    if ([IO.Directory]::Exists($nested) -and [IO.File]::Exists((Join-Path $nested $gameExe))) { return [IO.Path]::GetFullPath($nested) }
    throw 'La cartella selezionata non contiene Normal Golf Game.exe.'
}
function Verify-Sha([string]$path,[string]$sha) {
    $got = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($got -ne $sha.ToLowerInvariant()) { throw "Controllo SHA-256 non superato: $([IO.Path]::GetFileName($path))." }
}
function Download-Verified([string]$url,[string]$sha,[string]$to) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $to -MaximumRedirection 5 -UseBasicParsing -ErrorAction Stop
    Verify-Sha $to $sha
}
function Save-Backup([string]$file,[string]$root,[string]$backups) {
    if (![IO.File]::Exists($file)) { return }
    $rel = $file.Substring($root.TrimEnd('\').Length).TrimStart('\')
    $to = Join-Path $backups $rel
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($to)) | Out-Null
    [IO.File]::Copy($file,$to,$true)
}
function Copy-VerifiedZip([string]$zip,[string]$root,[string]$backups) {
    $prefix = [IO.Path]::GetFullPath($root).TrimEnd('\','/') + '\'
    $archive = [IO.Compression.ZipFile]::OpenRead($zip)
    try {
        if ($archive.Entries.Count -gt 5000) { throw 'Archivio con troppi file.' }
        foreach ($entry in $archive.Entries) {
            $rel = $entry.FullName.Replace('/','\')
            if ([string]::IsNullOrWhiteSpace($rel) -or $rel.StartsWith('\') -or $rel.Contains(':')) { throw 'Percorso non valido nello ZIP.' }
            $target = [IO.Path]::GetFullPath((Join-Path $prefix $rel))
            if (!$target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Archivio con percorso esterno alla cartella del gioco.' }
            if ([string]::IsNullOrEmpty($entry.Name)) { [IO.Directory]::CreateDirectory($target) | Out-Null; continue }
            [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target)) | Out-Null
            Save-Backup $target $root $backups
            $src = $entry.Open()
            try {
                $dst = [IO.File]::Open($target,[IO.FileMode]::Create,[IO.FileAccess]::Write,[IO.FileShare]::None)
                try { $src.CopyTo($dst) } finally { $dst.Dispose() }
            } finally { $src.Dispose() }
        }
    } finally { $archive.Dispose() }
}
function Set-IniValue([string]$file,[string]$section,[string]$key,[string]$value) {
    $lines = if ([IO.File]::Exists($file)) { @([IO.File]::ReadAllLines($file)) } else { @() }
    $output = New-Object 'System.Collections.Generic.List[string]'
    $inSection=$false; $sectionFound=$false; $keyFound=$false
    foreach ($line in $lines) {
        if ($line -match '^\s*\[([^\]]+)\]') {
            if ($inSection -and !$keyFound) { $output.Add("$key=$value"); $keyFound=$true }
            $inSection = ($Matches[1] -ieq $section)
            if ($inSection) { $sectionFound=$true }
        }
        if ($inSection -and ($line -match ('^\s*' + [regex]::Escape($key) + '\s*='))) {
            if (!$keyFound) { $output.Add("$key=$value"); $keyFound=$true }
        } else { $output.Add($line) }
    }
    if (!$sectionFound) { $output.Add("[$section]") }
    if (!$keyFound) { $output.Add("$key=$value") }
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($file)) | Out-Null
    [IO.File]::WriteAllLines($file,[string[]]$output,$utf8)
}
$downloadDir = Join-Path $env:TEMP ('NormalGolfInstall-' + [Guid]::NewGuid().ToString('N'))
try {
    Report 0 'Verifico la cartella e i file della traduzione.'
    $game = Get-ValidPath $GamePath
    if (![IO.File]::Exists($PatchZip)) { throw 'Non trovo la patch incorporata nell installer.' }
    Verify-Sha $PatchZip $hashPatch
    [IO.Directory]::CreateDirectory($downloadDir) | Out-Null
    $backup = Join-Path $game ('BepInEx\normal-golf-italian\backup-installer\' + (Get-Date -Format 'yyyyMMdd-HHmmssfff'))
    [IO.Directory]::CreateDirectory($backup) | Out-Null
    Report 12 'Gioco trovato. Cartella di backup preparata.'

    $hasBep = ([IO.File]::Exists((Join-Path $game 'winhttp.dll'))) -and ([IO.File]::Exists((Join-Path $game 'BepInEx\core\BepInEx.dll')))
    if (!$hasBep) {
        if (!$InstallDependencies) { throw 'BepInEx 5 non presente. Attiva l installazione automatica.' }
        Report 20 'Scarico BepInEx 5 dalle release ufficiali.'
        $p=Join-Path $downloadDir 'BepInEx.zip'
        Download-Verified $dependencies[0].Url $dependencies[0].Sha $p
        Copy-VerifiedZip $p $game $backup
        Report 39 'BepInEx installato e verificato.'
    } else { Report 39 'BepInEx rilevato: nessuna modifica.' }

    $xunityPath = Join-Path $game 'BepInEx\plugins\XUnity.AutoTranslator\XUnity.AutoTranslator.Plugin.Core.dll'
    if (![IO.File]::Exists($xunityPath)) {
        if (!$InstallDependencies) { throw 'XUnity.AutoTranslator non presente. Attiva l installazione automatica.' }
        Report 43 'Scarico XUnity.AutoTranslator dalle release ufficiali.'
        $p=Join-Path $downloadDir 'XUnity.zip'
        Download-Verified $dependencies[1].Url $dependencies[1].Sha $p
        Copy-VerifiedZip $p $game $backup
        Report 61 'XUnity installato e verificato.'
    } else { Report 61 'XUnity rilevato: nessuna modifica.' }

    Report 67 'Copio la traduzione italiana e salvo le versioni precedenti.'
    Copy-VerifiedZip $PatchZip $game $backup
    foreach ($rel in @('BepInEx\plugins\NormalGolfItalianI2.dll','BepInEx\normal-golf-italian\i2_terms.tsv','BepInEx\normal-golf-italian\ui_challenges.tsv','BepInEx\Translation\it\Text\ItalianoCompleto.txt')) {
        if (![IO.File]::Exists((Join-Path $game $rel))) { throw "File della traduzione mancante: $rel" }
    }
    Report 82 'File della patch verificati. Configuro la lingua italiana.'
    $configDir = Join-Path $game 'BepInEx\config'
    $configs = @('AutoTranslatorConfig.ini','gravydevsupreme.xunity.autotranslator.ini') | ForEach-Object { Join-Path $configDir $_ } | Where-Object { [IO.File]::Exists($_) }
    if (!$configs) { $configs = @((Join-Path $configDir 'AutoTranslatorConfig.ini')) }
    foreach ($file in $configs) {
        Save-Backup $file $game $backup
        Set-IniValue $file 'Service' 'Endpoint' ''
        Set-IniValue $file 'Service' 'FallbackEndpoint' ''
        Set-IniValue $file 'General' 'Language' 'it'
        Set-IniValue $file 'General' 'FromLanguage' 'en'
    }
    $translated = Join-Path $game 'BepInEx\Translation\it\Text'
    foreach ($old in @('ItalianoAnteprima.txt','_AutoGeneratedTranslations.txt')) {
        $src=Join-Path $translated $old
        if ([IO.File]::Exists($src)) {
            Save-Backup $src $game $backup
            [IO.File]::Move($src,$src+'.disabilitato-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff'))
            Report 93 "Vecchia cache $old disabilitata e salvata nel backup."
        }
    }
    Report 100 'Installazione completata. Avvia il gioco mantenendo la lingua inglese.' 'success'
    Report 100 ("Backup: " + $backup) 'detail'
    exit 0
} catch {
    try { Report 0 ('ERRORE: ' + $_.Exception.Message) 'error' } catch {}
    exit 1
} finally {
    try { if ([IO.Directory]::Exists($downloadDir)) { [IO.Directory]::Delete($downloadDir,$true) } } catch {}
}
