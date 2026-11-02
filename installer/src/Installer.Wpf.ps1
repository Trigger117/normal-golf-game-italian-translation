param([Parameter(Mandatory=$true)][string]$ArchivioPatch)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$patchHash='7879d19b78f08be95a909f071756fc6d24e33d3daa2932785ec1241567bc1701'
$actualHash=(Get-FileHash -LiteralPath $ArchivioPatch -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $patchHash) { throw 'La patch incorporata non ha superato il controllo di integrita.' }

$modernFolderPicker = @"
using System;
using System.IO;
using System.Runtime.InteropServices;
namespace NormalGolfWpf {
  [ComImport, Guid("DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7"), ClassInterface(ClassInterfaceType.None)]
  internal class FileOpenDialogClass {}
  [ComImport, Guid("D57C7288-D4AD-4768-BE02-9D969532D960"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  internal interface IFileOpenDialog {
    [PreserveSig] int Show(IntPtr owner);
    void SetFileTypes(uint count, IntPtr specs);
    void SetFileTypeIndex(uint index);
    void GetFileTypeIndex(out uint index);
    void Advise(IntPtr eventsObject, out uint cookie);
    void Unadvise(uint cookie);
    void SetOptions(uint options);
    void GetOptions(out uint options);
    void SetDefaultFolder(IShellItem folder);
    void SetFolder(IShellItem folder);
    void GetFolder(out IShellItem folder);
    void GetCurrentSelection(out IShellItem selection);
    void SetFileName([MarshalAs(UnmanagedType.LPWStr)] string name);
    void GetFileName([MarshalAs(UnmanagedType.LPWStr)] out string name);
    void SetTitle([MarshalAs(UnmanagedType.LPWStr)] string title);
    void SetOkButtonLabel([MarshalAs(UnmanagedType.LPWStr)] string text);
    void SetFileNameLabel([MarshalAs(UnmanagedType.LPWStr)] string text);
    void GetResult(out IShellItem item);
    void AddPlace(IShellItem place, uint position);
    void SetDefaultExtension([MarshalAs(UnmanagedType.LPWStr)] string extension);
    void Close(int errorCode);
    void SetClientGuid(ref Guid guid);
    void ClearClientData();
    void SetFilter(IntPtr filter);
    void GetResults(IntPtr results);
    void GetSelectedItems(IntPtr items);
  }
  [ComImport, Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  internal interface IShellItem {
    void BindToHandler(IntPtr context, ref Guid handler, ref Guid iid, out IntPtr result);
    void GetParent(out IShellItem parent);
    void GetDisplayName(uint kind, [MarshalAs(UnmanagedType.LPWStr)] out string name);
    void GetAttributes(uint mask, out uint attributes);
    void Compare(IShellItem other, uint hint, out int order);
  }
  public static class FolderPicker {
    [DllImport("shell32.dll", CharSet=CharSet.Unicode, PreserveSig=false)]
    private static extern void SHCreateItemFromParsingName(
      [MarshalAs(UnmanagedType.LPWStr)] string path, IntPtr context, ref Guid iid,
      [MarshalAs(UnmanagedType.Interface)] out IShellItem item);
    public static string Pick(string initialPath,IntPtr owner) {
      IFileOpenDialog dlg=(IFileOpenDialog)new FileOpenDialogClass();
      try {
        uint flags;
        dlg.GetOptions(out flags);
        dlg.SetOptions(flags|0x00000020u|0x00000040u);
        dlg.SetTitle("Seleziona la cartella di Normal Golf Game");
        dlg.SetOkButtonLabel("Seleziona cartella");
        if(!String.IsNullOrWhiteSpace(initialPath)&&Directory.Exists(initialPath)) {
          IShellItem start=null;
          try {
            Guid iid=new Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE");
            SHCreateItemFromParsingName(initialPath,IntPtr.Zero,ref iid,out start);
            if(start!=null) dlg.SetDefaultFolder(start);
          } finally { if(start!=null) Marshal.ReleaseComObject(start); }
        }
        int result=dlg.Show(owner);
        if(result==unchecked((int)0x800704C7)) return null;
        if(result!=0) Marshal.ThrowExceptionForHR(result);
        IShellItem selected=null;
        try {
          dlg.GetResult(out selected);
          string path;
          selected.GetDisplayName(0x80058000u,out path);
          return path;
        } finally { if(selected!=null) Marshal.ReleaseComObject(selected); }
      } finally { Marshal.ReleaseComObject(dlg); }
    }
  }
}
"@
Add-Type -TypeDefinition $modernFolderPicker -ErrorAction Stop

# Identita Windows distinta da PowerShell: evita il raggruppamento con l'icona PS.
$taskbarApi = @"
using System;
using System.Runtime.InteropServices;
namespace NormalGolfWpf {
 public static class TaskbarIdentity {
  [DllImport("shell32.dll", CharSet=CharSet.Unicode)]
  public static extern int SetCurrentProcessExplicitAppUserModelID(string id);
  [DllImport("user32.dll", CharSet=CharSet.Auto)]
  public static extern IntPtr SendMessage(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam);
 }
}
"@
try {
    Add-Type -TypeDefinition $taskbarApi -ErrorAction Stop
    [void][NormalGolfWpf.TaskbarIdentity]::SetCurrentProcessExplicitAppUserModelID('Trigger117.NormalGolfGame.ItalianInstaller')
} catch {
    # La GUI resta utilizzabile anche se il sistema ignora il nuovo AppUserModelID.
}

# Questi dati vengono inseriti durante la creazione del singolo EXE.
$xamlText=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('__XAML_BASE64__'))
$workerText=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('__WORKER_BASE64__'))
$bannerBytes=[Convert]::FromBase64String('__BANNER_BASE64__')
$iconBytes=[Convert]::FromBase64String('__ICON_BASE64__')
$icoBytes=[Convert]::FromBase64String('__ICO_BASE64__')
$xml=[xml]$xamlText
$reader=New-Object System.Xml.XmlNodeReader($xml)
try { $window=[Windows.Markup.XamlReader]::Load($reader) } finally { $reader.Close() }

$names=@('HeaderImage','PathText','BrowseButton','PathHint','AutoDeps','Progress',
         'ProgressTitle','ProgressPercent','ProgressHint','LogText','OpenFolderButton','InstallButton')
$controls=@{}
foreach ($name in $names) {
    $element=$window.FindName($name)
    if ($null -eq $element) { throw "Controllo WPF mancante: $name" }
    $controls[$name]=$element
}
$header=$controls['HeaderImage']; $path=$controls['PathText']; $browse=$controls['BrowseButton']
$hint=$controls['PathHint']; $deps=$controls['AutoDeps']; $progress=$controls['Progress']
$progressTitle=$controls['ProgressTitle']; $percent=$controls['ProgressPercent']
$progressHint=$controls['ProgressHint']; $log=$controls['LogText']
$openFolder=$controls['OpenFolderButton']; $install=$controls['InstallButton']

$stream=[IO.MemoryStream]::new([byte[]]$bannerBytes)
$bmp=New-Object Windows.Media.Imaging.BitmapImage
$bmp.BeginInit()
$bmp.CacheOption=[Windows.Media.Imaging.BitmapCacheOption]::OnLoad
$bmp.StreamSource=$stream
$bmp.EndInit()
$bmp.Freeze()
$stream.Dispose()
$header.Source=$bmp

$iconStream=[IO.MemoryStream]::new([byte[]]$iconBytes)
$iconBmp=New-Object Windows.Media.Imaging.BitmapImage
$iconBmp.BeginInit()
$iconBmp.CacheOption=[Windows.Media.Imaging.BitmapCacheOption]::OnLoad
$iconBmp.StreamSource=$iconStream
$iconBmp.EndInit()
$iconBmp.Freeze()
$iconStream.Dispose()
$window.Icon=$iconBmp
# Invia esplicitamente a Windows le icone grande e piccola dell'HWND.
# Il launcher non deve usare l'identita della barra delle applicazioni di PowerShell.
$script:win32Icon=$null
try {
    $icoStream=[IO.MemoryStream]::new([byte[]]$icoBytes)
    try { $script:win32Icon=[System.Drawing.Icon]::new($icoStream) }
    finally { $icoStream.Dispose() }
} catch {}
$window.Add_ContentRendered({
    if ($script:win32Icon) {
        try {
            $handle=(New-Object System.Windows.Interop.WindowInteropHelper($window)).Handle
            $hico=$script:win32Icon.Handle
            [void][NormalGolfWpf.TaskbarIdentity]::SendMessage($handle,[uint32]0x80,[IntPtr]1,$hico)
            [void][NormalGolfWpf.TaskbarIdentity]::SendMessage($handle,[uint32]0x80,[IntPtr]0,$hico)
        } catch {}
    }
})

$script:state='idle'
$script:currentGame=$null
$script:workerProcess=$null
$script:lastCount=0
$script:statusFile=$null
$script:runtimeDir=$null
$script:hadError=$false
$script:timer=New-Object Windows.Threading.DispatcherTimer
$script:timer.Interval=[TimeSpan]::FromMilliseconds(350)
$ink=[Windows.Media.BrushConverter]::new()
$good=$ink.ConvertFromString('#087A58')
$bad=$ink.ConvertFromString('#BC4650')
$muted=$ink.ConvertFromString('#617A83')

function Find-GameDir([string]$text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    try {
        $dir=[Environment]::ExpandEnvironmentVariables($text.Trim().Trim('"'))
        if ([IO.File]::Exists($dir) -and [IO.Path]::GetFileName($dir) -ieq 'Normal Golf Game.exe') {
            $dir=[IO.Path]::GetDirectoryName($dir)
        }
        if ([IO.Directory]::Exists($dir) -and [IO.File]::Exists((Join-Path $dir 'Normal Golf Game.exe'))) {
            return [IO.Path]::GetFullPath($dir)
        }
        $inner=Join-Path $dir 'Normal'
        if ([IO.Directory]::Exists($inner) -and [IO.File]::Exists((Join-Path $inner 'Normal Golf Game.exe'))) {
            return [IO.Path]::GetFullPath($inner)
        }
    } catch {}
    return $null
}
function Detect-Steam {
    try {
        $roots = @()
        foreach ($reg in @('HKCU:\Software\Valve\Steam','HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
            try {
                $v=Get-ItemProperty -Path $reg -ErrorAction Stop
                foreach ($r in @($v.SteamPath,$v.InstallPath)) { if ($r -and [IO.Directory]::Exists($r)) { $roots+= $r } }
            } catch {}
        }
        $pf86=[Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
        if ($pf86) { $roots+= (Join-Path $pf86 'Steam') }
        foreach ($root in ($roots | Select-Object -Unique)) {
            if (![IO.Directory]::Exists($root)) { continue }
            $libraries=@((Join-Path $root 'steamapps'))
            $libFile=Join-Path $root 'steamapps\libraryfolders.vdf'
            if ([IO.File]::Exists($libFile)) {
                foreach ($line in [IO.File]::ReadAllLines($libFile)) {
                    if ($line -match '"path"\s+"([^"]+)"') { $libraries+=(Join-Path ($Matches[1] -replace '\\\\','\') 'steamapps') }
                }
            }
            foreach ($steamapps in $libraries) {
                $manifest=Join-Path $steamapps 'appmanifest_3510740.acf'
                if ([IO.File]::Exists($manifest)) {
                    $content=[IO.File]::ReadAllText($manifest)
                    if ($content -match '"installdir"\s+"([^"]+)"') {
                        $candidate=Find-GameDir (Join-Path (Join-Path $steamapps 'common') $Matches[1])
                        if ($candidate) { return $candidate }
                    }
                }
            }
        }
    } catch {}
    return $null
}
function Log-Ui([string]$message) {
    $log.AppendText($message+[Environment]::NewLine)
    $log.ScrollToEnd()
}
function Refresh-Path {
    if ($script:state -ne 'idle' -and $script:state -ne 'error') { return }
    $script:currentGame=Find-GameDir $path.Text
    if ($script:currentGame) {
        $hint.Text='Gioco trovato nella cartella selezionata.'
        $hint.Foreground=$good
        $install.IsEnabled=$true
    } else {
        $hint.Text='Seleziona la cartella Normal che contiene Normal Golf Game.exe.'
        $hint.Foreground=$muted
        $install.IsEnabled=$false
    }
}
function Set-ErrorState([string]$message) {
    $script:state='error'
    $progressTitle.Text='Installazione non completata'
    $progressTitle.Foreground=$bad
    $progressHint.Text='Controlla i dettagli e riprova.'
    $percent.Text='Errore'
    $percent.Foreground=$bad
    $install.Content='Riprova installazione'
    $path.IsEnabled=$true; $browse.IsEnabled=$true; $deps.IsEnabled=$true
    Log-Ui ('ERRORE: ' + $message)
    Refresh-Path
}
function Set-SuccessState {
    $script:state='done'
    $progress.Value=100
    $progressTitle.Text='Installazione completata'
    $progressTitle.Foreground=$good
    $progressHint.Text='Traduzione pronta. Avvia Normal Golf Game in inglese.'
    $percent.Text='100%'
    $percent.Foreground=$good
    $install.Content='Chiudi'
    $install.IsEnabled=$true
    $openFolder.Visibility=[Windows.Visibility]::Visible
    $path.IsEnabled=$false; $browse.IsEnabled=$false; $deps.IsEnabled=$false
}

$path.Add_TextChanged({ Refresh-Path })
$browse.Add_Click({
    if ($script:state -eq 'running') { return }
    try {
        $initial=$null
        if ($script:currentGame) { $initial=$script:currentGame }
        elseif ([IO.Directory]::Exists($path.Text)) { $initial=$path.Text }
        $helper=New-Object System.Windows.Interop.WindowInteropHelper($window)
        $selected=[NormalGolfWpf.FolderPicker]::Pick($initial,$helper.Handle)
        if ($selected) { $path.Text=$selected }
    } catch {
        [void][System.Windows.MessageBox]::Show($window,('Non riesco ad aprire il selettore moderno: '+$_.Exception.Message),
            'Selezione cartella',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)
    }
})
$openFolder.Add_Click({
    if ($script:currentGame -and [IO.Directory]::Exists($script:currentGame)) {
        Start-Process -FilePath explorer.exe -ArgumentList ('"'+$script:currentGame+'"')
    }
})

$script:timer.Add_Tick({
    if ($script:state -ne 'running') { return }
    try {
        if ([IO.File]::Exists($script:statusFile)) {
            try { $lines=@([IO.File]::ReadAllLines($script:statusFile)) }
            catch [System.IO.IOException] { return }
            while ($script:lastCount -lt $lines.Count) {
                $line=$lines[$script:lastCount]
                if (![string]::IsNullOrWhiteSpace($line)) {
                    try {
                        $item=ConvertFrom-Json $line -ErrorAction Stop
                        $progress.Value=[Math]::Max(0,[Math]::Min(100,[int]$item.progress))
                        $percent.Text=([string]$progress.Value+'%')
                        if ($item.level -eq 'error') { $script:hadError=$true }
                        Log-Ui ('['+$item.time+'] '+$item.message)
                    } catch { Log-Ui ('[INFO] '+$line) }
                }
                $script:lastCount++
            }
        }
        if ($script:workerProcess -and $script:workerProcess.HasExited) {
            $code=$script:workerProcess.ExitCode
            $script:timer.Stop()
            if ($code -eq 0 -and !$script:hadError) { Set-SuccessState }
            else { Set-ErrorState 'Il processo di installazione si e concluso con un errore. Consulta il registro sopra.' }
        }
    } catch {
        $script:timer.Stop()
        Set-ErrorState $_.Exception.Message
    }
})
$install.Add_Click({
    if ($script:state -eq 'done') { $window.Close(); return }
    if ($script:state -eq 'running') { return }
    Refresh-Path
    if (!$script:currentGame) { return }
    try {
        $script:state='running'; $script:hadError=$false; $script:lastCount=0
        $path.IsEnabled=$false; $browse.IsEnabled=$false; $deps.IsEnabled=$false
        $install.IsEnabled=$false; $install.Content='Installazione in corso...'
        $progress.Value=0; $percent.Text='0%'; $progressTitle.Text='Installazione in corso'
        $progressTitle.Foreground=$ink.ConvertFromString('#19393E')
        $progressHint.Text='Scarico solo i componenti mancanti e preparo il backup.'
        $log.Clear()
        $script:runtimeDir=Join-Path $env:TEMP ('NormalGolf-Wpf-'+[Guid]::NewGuid().ToString('N'))
        [IO.Directory]::CreateDirectory($script:runtimeDir) | Out-Null
        $worker=Join-Path $script:runtimeDir 'Installer.Worker.ps1'
        [IO.File]::WriteAllText($worker,$workerText,[Text.UTF8Encoding]::new($true))
        $script:statusFile=Join-Path $script:runtimeDir 'status.jsonl'
        $powershell=Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $commandLine='-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{0}" -GamePath "{1}" -PatchZip "{2}" -StatusFile "{3}"' -f $worker,$script:currentGame,$ArchivioPatch,$script:statusFile
        if ($deps.IsChecked -eq $true) { $commandLine+=' -InstallDependencies' }
        $psi=New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName=$powershell
        $psi.Arguments=$commandLine
        $psi.UseShellExecute=$false
        $psi.CreateNoWindow=$true
        $script:workerProcess=[Diagnostics.Process]::Start($psi)
        if ($null -eq $script:workerProcess) { throw 'Impossibile avviare il processo di installazione.' }
        $script:timer.Start()
    } catch {
        $script:timer.Stop()
        Set-ErrorState $_.Exception.Message
    }
})
$window.Add_Closing({
    param($sender,$e)
    if ($script:state -eq 'running' -and $script:workerProcess -and !$script:workerProcess.HasExited) {
        $choice=[Windows.MessageBox]::Show($window,
          'Installazione ancora in corso. Attendi il completamento prima di chiudere.',
          'Installazione in corso',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
        $e.Cancel=$true
    }
})
$window.Add_Closed({
    try { if ($script:win32Icon) { $script:win32Icon.Dispose() } } catch {}
    $script:timer.Stop()
    try { if ($script:workerProcess) { $script:workerProcess.Dispose() } } catch {}
    try { if ($script:runtimeDir -and [IO.Directory]::Exists($script:runtimeDir)) { [IO.Directory]::Delete($script:runtimeDir,$true) } } catch {}
})
Log-Ui '[INFO] Installer WPF pronto. Seleziona la cartella del gioco.'
$found=Detect-Steam
if ($found) { $path.Text=$found } else { Refresh-Path }
[void]$window.ShowDialog()
