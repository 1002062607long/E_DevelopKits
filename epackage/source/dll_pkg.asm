; #########################################################################
;
;           E-DLL �� windows ��װ����
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

    ITL_LOAD_DLL_APP		equ 1001		; �ɵ�����DLL�����Գ���Ľӿڴ��룬����EDX������
    ITL_NOTIFY_DLL_EXIT		equ 1002		; ������DLL֪ͨ�伴���˳�
    ITL_LOAD_DLL_APP2		equ 1003		; �µ�����DLL�����Գ���Ľӿڴ��룬��EDX������
    ENTRY_POINTER_OFFSET    equ 12345678H	; �����Գ������ƫ����ֵ�����λ�õı�־�����ɸ��ġ�

    .data

	; ������ĸ���������˳�򲻿ɸ��ģ���������ͬһ�ṹ�����Ѿ��ں��Ŀ���DLL_LOAD_INF�ṹ�б�ʹ�á�
    nDllLoadPrgID			dd	-1	; ��DLL�ں���֧�ֿ��е�����ID��-1��ʾ��Ч��
    dwFreeCodeAddress		dd  0	; �����Գ����˳������ַ
	dwDllExitNotifyAddress	dd	0	; ֪ͨ��DLL�����˳��ĺ�����ַ
    hKrnlLib				dd	0	; ���汻����ĺ���֧�ֿ�����

    dwAppHeadereAddress		dd  0	; �����Գ���ͷ��ַ��־�����ɸ��ġ�

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

	;  ���������
	;  eax: �ӳ������λ����Գ���ͷ��ƫ��

ESub_Caller proc

	dd 86543210H  ; ������Ѱ��ǣ����ɸ��ġ�

	; �����Ƿ��Ѿ������룿
	cmp dwAppHeadereAddress, 0
	jne prg_loaded
	; �������
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
    ; ������������ļ�����Ŀ¼�е�krnln.fnr����֧�ֿ⡣
    invoke GetAppPath, ADDR buf
    invoke lstrcat, ADDR buf, ADDR krnln_fnr$
    invoke LoadLibrary, eax
    test eax, eax
    jne loadlibok

    ; ���ʧ����ȥ����������ϵͳ�е�krnln.fne����֧�ֿ⡣
	; �ȼ�C++����Ϊ��
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

