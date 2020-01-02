.386
.model flat,stdcall

.code 

masm_add proc num1:dword, num2:dword
	
	mov eax, num1
	mov ecx, num2
	add eax, ecx
	ret

masm_add endp

end
