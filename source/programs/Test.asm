test:
	pusha
	push es
	push bp
	
	mov bh,16
	mov bl,0
	mov ax,cs
	mov es,ax
	mov bp,sys_font
	mov cx,256
	mov dx,80h
	mov ax,1100h
	int 10h
	
	
	pop bp
	pop es
	popa
	
	jmp console_new_cmd