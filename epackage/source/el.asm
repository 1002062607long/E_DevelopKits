; #########################################################################
;
;           EPK的启动程序
;
; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

      EEXE_Loader PROTO

; #########################################################################

      include \tools\masm32\include\windows.inc
      include \tools\masm32\include\user32.inc
      include \tools\masm32\include\kernel32.inc
      include \tools\masm32\include\masm32.inc
      include \tools\masm32\include\advapi32.inc

      includelib \tools\masm32\lib\user32.lib
      includelib \tools\masm32\lib\kernel32.lib
      includelib \tools\masm32\lib\masm32.lib
      includelib \tools\masm32\lib\advapi32.lib

; #########################################################################

    .code

start:

    invoke EEXE_Loader
    invoke ExitProcess, eax

; #########################################################################

	krnln_fnr$				db "krnln.fnr", 0
	szFailedText$			db "Not found the kernel library or the kernel library is invalid!", 0
	e_system_install_key$	db "Software\FlySky\E\Install", 0
	e_system_path$			db "Path", 0
    szLoadFailedText$       db "Load EPK data invalid!", 0
	szFailedCaption$		db "Error", 0
	krnln_fne$				db "krnln.fne", 0

    ; 载入指定内存地址中的EPK数据的接口代码. 原型: BOOL WINAPI LoadEPKData (const char* szEPKName, const void* pEPKData, INT nEPKDataSize), 成功返回真,失败返回假.
	; szLoadEPKData$  db "LoadEPKData", 0
    ; 载入指定名称文件中的EPK数据的接口代码.  原型: BOOL WINAPI LoadEPKFile (const char* szEPKFileName, const char* szEPKName), szEPKName可以为NULL. 成功返回真,失败返回假.
	; szLoadEPKFile$  db "LoadEPKFile", 0
    ; 载入命令行中给出的epk文件的接口代码.  原型: BOOL WINAPI LoadEPKFromCmdLine (), 成功返回真,失败返回假.
	szLoadEPKFromCmdLine$  db "LoadEPKFromCmdLine", 0

EEXE_Loader proc

    LOCAL buf [MAX_PATH]:BYTE
    LOCAL hLib :HINSTANCE
    LOCAL hkey :DWORD
    LOCAL dwDataBufSize :DWORD 

    ; 首先载入程序文件运行目录中的krnln.fnr核心支持库。
    invoke GetAppPath, ADDR buf
    invoke lstrcat, ADDR buf, ADDR krnln_fnr$
    invoke LoadLibrary, eax
    test eax, eax
    jne loadlibok

    ; 如果失败则去载入易语言系统中的krnln.fne核心支持库。
	; 等价C++代码为：
	; char buf [MAX_PATH]
	; HKEY hkey;
	; if (RegOpenKeyEx (HKEY_CURRENT_USER, "Software\\FlySky\\E\\Install",
	; 		0, KEY_READ, &hkey) == ERROR_SUCCESS)
	; {
	; 	DWORD dwDataBufSize = sizeof (buf) - 1;
	; 	if (RegQueryValueEx (hkey, "Path", NULL, NULL,
	; 			(LPBYTE)path, &dwDataBufSize) == ERROR_SUCCESS)
	; 	{
	; 		if (path [strlen (path) - 1] != '\\')
	; 			strcat (path, "\\");
	; 		strcpy (buf, path);
	; 		strcat (buf, "krnln.fne");
	; 		hLib = LoadLibrary (buf);
	; 	}
	; 
	; 	RegCloseKey (hkey);
	; }

    invoke RegOpenKeyEx, HKEY_CURRENT_USER, ADDR e_system_install_key$, 0, KEY_READ, ADDR hkey
    cmp eax, ERROR_SUCCESS
    jne failed
    mov dwDataBufSize, SIZEOF buf - 1;
    invoke RegQueryValueEx, hkey, ADDR e_system_path$, 0, 0, ADDR buf, ADDR dwDataBufSize
    push eax
    invoke RegCloseKey, hkey
    pop eax
    cmp eax, ERROR_SUCCESS
    jne failed
    invoke lstrlen, ADDR buf
	lea ebx, buf
	add ebx, eax
    dec ebx
    cmp byte ptr [ebx], '\'
    je next
    mov word ptr [ebx], '\'
next:
    invoke lstrcat, ADDR buf, ADDR krnln_fne$
    invoke LoadLibrary, eax
    test eax, eax
    je failed

loadlibok:
    mov hLib, eax
    invoke GetProcAddress, eax, ADDR szLoadEPKFromCmdLine$
    test eax, eax
    je failed
    call eax
    test eax, eax
    je load_failed
    invoke ExitProcess, 0

load_failed:
    invoke FreeLibrary, hLib
    invoke MessageBox, 0, ADDR szLoadFailedText$, ADDR szFailedCaption$, MB_OK + MB_ICONERROR
    mov eax, -1
    ret

failed:
    invoke MessageBox, 0, ADDR szFailedText$, ADDR szFailedCaption$, MB_OK + MB_ICONERROR
    mov eax, -1
    ret

EEXE_Loader endp

; #########################################################################

end start

