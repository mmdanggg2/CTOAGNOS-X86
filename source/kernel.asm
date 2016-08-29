[BITS 16]

start:
	mov ax, cs		; set data segment to the same as code segment
	mov ds, ax
	
	mov ax, 0xB800		; setup extra segment to the screen ram
	mov es, ax
	
	mov ax, 4000h		; Set up 4K stack space after this bootloader
	add ax, 288		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096
	
	mov ax, 0
	mov bx, 0
	mov dx, 0
	mov ah, 02h
	mov bh, 00h
	mov dh, -1
	mov dl, 0
	int 10h; remove cursor
	
	jmp console
	
	%include "Console.asm"
	%include "Functions.asm"
	%include "OSCommands.asm"
	%include "Data.asm"
	
	mov dword [es:0h], 07690748h
	
end:
	jmp $			; Jump here - infinite loop!