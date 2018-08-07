.code32
.intel_syntax noprefix
.globl start
start:
	cli #disable interrupts until table is setup...
	call kernel_init
	call kernel_main
	lea esi, retCStr
	mov edi, 0xB8000 + ((24 * 80) + 0) * 2# end line offset
	call printStr
	
end:
	hlt
	jmp end

	
printStr:
	push eax
	push esi
	push edi
1:
	lodsb #load string byte
	cmp al, 0 #if is null byte
	je 2f #end of string
	mov ah, 0x0F # add bright white color byte to top byte
	stosw # store char word to screen
	jmp 1b
2:
	pop edi
	pop esi
	pop eax
	ret

.data
	retCStr: .asciz "RetCode: "
	