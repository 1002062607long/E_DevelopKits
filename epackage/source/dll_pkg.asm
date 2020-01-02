; #########################################################################
;
;           E-DLL 的 windows 包装程序
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

    ITL_LOAD_DLL_APP		equ 1001		; 旧的载入DLL易语言程序的接口代码，不带EDX参数。
    ITL_NOTIFY_DLL_EXIT		equ 1002		; 易语言DLL通知其即将退出
    ITL_LOAD_DLL_APP2		equ 1003		; 新的载入DLL易语言程序的接口代码，带EDX参数。
    ENTRY_POINTER_OFFSET    equ 12345678H	; 易语言程序代码偏移量值所存放位置的标志，不可更改。

    .data

	; 下面的四个变量定义顺序不可更改，它们属于同一结构，并已经在核心库中DLL_LOAD_INF结构中被使用。
    nDllLoadPrgID			dd	-1	; 本DLL在核心支持库中的载入ID，-1表示无效。
    dwFreeCodeAddress		dd  0	; 易语言程序退出代码地址
	dwDllExitNotifyAddress	dd	0	; 通知本DLL即将退出的函数地址
    hKrnlLib				dd	0	; 保存被载入的核心支持库句柄。

    dwAppHeadereAddress		dd  0	; 易语言程序头地址标志，不可更改。

    .code

; ##########################################################################

LibMain proc hInstDLL:DWORD, reason:DWORD, unused:DWORD

    cmp reason, DLL_PROCESS_ATTACH
    jne @F
    mov eax, 1
    ret

@@:
    cmp reason, DLL_PROCESS_DETACH
    jne quit
	cmp dwFreeCodeAddress, 0
    je @F
	call dwFreeCodeAddress
@@:
	cmp dwDllExitNotifyAddress, 0
	je @F
	push nDllLoadPrgID
	call dwDllExitNotifyAddress
@@:
	cmp hKrnlLib, 0
	je quit
    invoke FreeLibrary, hKrnlLib

quit:
    ret

LibMain Endp


; #########################################################################

	;  进入参数：
	;  eax: 子程序代码位置相对程序头的偏移

ESub_Caller proc

	dd 86543210H  ; 用作搜寻标记，不可更改。

	; 程序是否已经被载入？
	cmp dwAppHeadereAddress, 0
	jne prg_loaded
	; 载入程序
	pushad
	call EEXE_Loader
	popad

prg_loaded:
	add eax, dwAppHeadereAddress
    jmp eax

ESub_Caller Endp

; #########################################################################

EEXE_Loader proc

    LOCAL buf [MAX_PATH]:BYTE
    LOCAL hkey :DWORD
    LOCAL dwDataBufSize :DWORD 

    jmp @F

	krnln_fnr$				db "krnln.fnr", 0
	szFailedtext$			db "Not found the kernel library or the kernel library is invalid or the kernel library of this edition does not support DLL!", 0
	e_system_path$			db "Path", 0
	lib_sock_name$			db "GetNewSock", 0
	e_system_install_key$	db "Software\FlySky\E\Install", 0
	szFailedCaption$		db "Error", 0
	krnln_fne$				db "krnln.fne", 0

@@:
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
	; 		hKrnlLib = LoadLibrary (buf);
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
    mov hKrnlLib, eax
    invoke GetProcAddress, eax, ADDR lib_sock_name$
    test eax, eax
    je run_failed
	push eax
	push ITL_NOTIFY_DLL_EXIT
	call eax
	pop edx
    test eax, eax
    je run_failed
	mov dwDllExitNotifyAddress, eax
    push ITL_LOAD_DLL_APP2
	mov ebx, offset nDllLoadPrgID
    call edx
    test eax, eax
    je run_failed
	mov nDllLoadPrgID, edx
    call label1
label1:
    add dword ptr [esp], ENTRY_POINTER_OFFSET
    call eax
    mov dwFreeCodeAddress, eax
	sub	esp, 4
    pop dwAppHeadereAddress
    ret

run_failed:
    invoke FreeLibrary, hKrnlLib
failed:
	mov hKrnlLib, 0
	mov nDllLoadPrgID, -1
	mov dwAppHeadereAddress, 0
	mov dwFreeCodeAddress, 0
	mov dwDllExitNotifyAddress, 0
    invoke MessageBox, 0, ADDR szFailedtext$, ADDR szFailedCaption$, MB_OK + MB_ICONERROR
    invoke ExitProcess, -1
    ret

EEXE_Loader endp

; #########################################################################

end LibMain

