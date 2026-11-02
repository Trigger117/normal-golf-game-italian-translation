// Avviatore Windows 64 bit di un installer PowerShell con archivio ZIP incorporato.
// Nessuna libreria esterna, nessun componente di gioco incluso.
// Formato overlay: [script PowerShell UTF-16LE BOM][patch ZIP]["NGIP2026" + lenPS u32LE + lenZIP u32LE]
using DWORD = unsigned long;
using WORD = unsigned short;
using BYTE = unsigned char;
using BOOL = int;
using HANDLE = void*;
using LPVOID = void*;
using LPCVOID = const void*;
struct SECURITY_ATTRIBUTES;
struct STARTUPINFOW {DWORD cb; wchar_t *lpReserved, *lpDesktop, *lpTitle; DWORD dwX,dwY,dwXSize,dwYSize,dwXCountChars,dwYCountChars,dwFillAttribute,dwFlags; WORD wShowWindow,cbReserved2; BYTE* lpReserved2; HANDLE hStdInput,hStdOutput,hStdError;};
struct PROCESS_INFORMATION {HANDLE hProcess,hThread; DWORD dwProcessId,dwThreadId;};
extern "C" {
__declspec(dllimport) DWORD __stdcall GetModuleFileNameW(HANDLE, wchar_t*,DWORD);
__declspec(dllimport) HANDLE __stdcall CreateFileW(const wchar_t*,DWORD,DWORD,SECURITY_ATTRIBUTES*,DWORD,DWORD,HANDLE);
__declspec(dllimport) BOOL __stdcall CloseHandle(HANDLE);
__declspec(dllimport) BOOL __stdcall GetFileSizeEx(HANDLE,long long*);
__declspec(dllimport) BOOL __stdcall SetFilePointerEx(HANDLE,long long,long long*,DWORD);
__declspec(dllimport) BOOL __stdcall ReadFile(HANDLE,LPVOID,DWORD,DWORD*,LPVOID);
__declspec(dllimport) BOOL __stdcall WriteFile(HANDLE,LPCVOID,DWORD,DWORD*,LPVOID);
__declspec(dllimport) DWORD __stdcall GetTempPathW(DWORD,wchar_t*);
__declspec(dllimport) DWORD __stdcall GetTempFileNameW(const wchar_t*,const wchar_t*,DWORD,wchar_t*);
__declspec(dllimport) BOOL __stdcall DeleteFileW(const wchar_t*);
__declspec(dllimport) BOOL __stdcall CreateDirectoryW(const wchar_t*,SECURITY_ATTRIBUTES*);
__declspec(dllimport) BOOL __stdcall RemoveDirectoryW(const wchar_t*);
__declspec(dllimport) BOOL __stdcall CreateProcessW(const wchar_t*,wchar_t*,SECURITY_ATTRIBUTES*,SECURITY_ATTRIBUTES*,BOOL,DWORD,LPVOID,const wchar_t*,STARTUPINFOW*,PROCESS_INFORMATION*);
__declspec(dllimport) DWORD __stdcall WaitForSingleObject(HANDLE,DWORD);
__declspec(dllimport) void __stdcall ExitProcess(DWORD);
__declspec(dllimport) int __stdcall MessageBoxW(HANDLE,const wchar_t*,const wchar_t*,DWORD);
}
static wchar_t exePath[4096],tmpRoot[4096],tmpFolder[4096],psPath[4096],zipPath[4096],cmd[12000];
static BYTE buffer[8192],trailer[16];
static const HANDLE BAD=(HANDLE)(-1);
static int add(wchar_t *dst,int pos,int cap,const wchar_t *s){while(*s){if(pos+1>=cap)return -1;dst[pos++]=*s++;}dst[pos]=0;return pos;}
static void fail(const wchar_t* why){MessageBoxW(0,why,L"Installer traduzione italiana - errore",0x10);ExitProcess(1);}
static DWORD u32(const BYTE *b){return (DWORD)b[0] | ((DWORD)b[1]<<8) | ((DWORD)b[2]<<16) | ((DWORD)b[3]<<24);}
static BOOL transfer(HANDLE input,const wchar_t* output,unsigned long long count){
  HANDLE out=CreateFileW(output,0x40000000,0,0,2,0x80,0);
  if(out==BAD)return 0;
  while(count){
    DWORD n=(count<sizeof(buffer))?(DWORD)count:(DWORD)sizeof(buffer),got=0,wrote=0;
    if(!ReadFile(input,buffer,n,&got,0)||got!=n||!WriteFile(out,buffer,n,&wrote,0)||wrote!=n){CloseHandle(out);return 0;}
    count-=n;
  }
  CloseHandle(out);return 1;
}
extern "C" void mainCRTStartup(){
  DWORD n=GetModuleFileNameW(0,exePath,4096);
  if(!n||n>=4095)fail(L"Impossibile determinare il percorso del programma.");
  HANDLE me=CreateFileW(exePath,0x80000000,1,0,3,0x80,0);
  if(me==BAD)fail(L"Impossibile leggere il pacchetto d'installazione.");
  long long size=0;
  if(!GetFileSizeEx(me,&size)||size<16||!SetFilePointerEx(me,size-16,0,0)){CloseHandle(me);fail(L"Pacchetto non valido (dimensione).");}
  DWORD got=0;
  if(!ReadFile(me,trailer,16,&got,0)||got!=16){CloseHandle(me);fail(L"Pacchetto non valido (intestazione).");}
  const char magic[8]={'N','G','I','P','2','0','2','6'};
  for(int i=0;i<8;i++)if(trailer[i]!=(BYTE)magic[i]){CloseHandle(me);fail(L"Dati d'installazione mancanti o danneggiati.");}
  DWORD psLen=u32(trailer+8),zipLen=u32(trailer+12);
  if(!psLen||!zipLen||psLen>2*1024*1024||zipLen>100*1024*1024||(long long)psLen+zipLen+16>size){CloseHandle(me);fail(L"Dati d'installazione non validi.");}
  DWORD tmpLen=GetTempPathW(4096,tmpRoot);
  if(!tmpLen||tmpLen>3900) {CloseHandle(me);fail(L"Cartella temporanea non disponibile.");}
  if(!GetTempFileNameW(tmpRoot,L"NGI",0,tmpFolder)){CloseHandle(me);fail(L"Impossibile creare la cartella temporanea.");}
  DeleteFileW(tmpFolder);
  if(!CreateDirectoryW(tmpFolder,0)){CloseHandle(me);fail(L"Impossibile creare la cartella di installazione temporanea.");}
  int a=add(psPath,0,4096,tmpFolder);a=add(psPath,a,4096,L"\\Installer.ps1");
  int b=add(zipPath,0,4096,tmpFolder);b=add(zipPath,b,4096,L"\\Patch.zip");
  if(a<0||b<0||!SetFilePointerEx(me,size-16-(long long)psLen-zipLen,0,0)||!transfer(me,psPath,psLen)||!transfer(me,zipPath,zipLen)){
    CloseHandle(me);fail(L"Impossibile estrarre i file temporanei dell'installer.");
  }
  CloseHandle(me);
  int p=add(cmd,0,12000,L"powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File \"");
  p=add(cmd,p,12000,psPath);p=add(cmd,p,12000,L"\" -ArchivioPatch \"");p=add(cmd,p,12000,zipPath);p=add(cmd,p,12000,L"\"");
  if(p<0)fail(L"Percorso di installazione troppo lungo.");
  STARTUPINFOW si={};si.cb=sizeof(si);
  PROCESS_INFORMATION proc={};
  if(!CreateProcessW(0,cmd,0,0,0,0x08000000,0,0,&si,&proc)){
    fail(L"Impossibile avviare PowerShell. Verifica le impostazioni di sicurezza di Windows.");
  }
  WaitForSingleObject(proc.hProcess,0xffffffffu);
  CloseHandle(proc.hThread);CloseHandle(proc.hProcess);
  DeleteFileW(psPath);DeleteFileW(zipPath);RemoveDirectoryW(tmpFolder);
  ExitProcess(0);
}
extern "C" void* memset(void* ptr,int value,unsigned long long n){volatile unsigned char *p=(volatile unsigned char*)ptr;while(n--)*p++=(unsigned char)value;return ptr;}
