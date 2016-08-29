;-----	Keyboard Input	-----
;-	Output on C
key_inp:
	pusha
	mov ax, 0x0000
	in al, 0x60; read keyboard code
	test al, 80h ;ignore codes with high bit
	jnz .end
	mov bx, 0x0000
	mov bl, al
	mov al, [keymap + bx]
	mov [key_char], ax
.end:
	mov al, 61h
	out 20h, al ; Send EOI
	popa
	ret

key_char: dw 0x0000



;-----	Draw Character	-----
;-	char_x and char_y set pos
;-	Cx arg1 is character
draw_char:
	push bp
	mov bp, sp
	pusha; 
	mov cx, [bp+4]; arg1
	cmp word [draw_type], 0x0000
	jne .ifjmp1
	or cx, [colour_text]
.ifjmp1:
	and word [char_x], 0x00ff	;prevent overflows
	and word [char_y], 0x000f
	call get_screen_offset
	mov bx, [char_offset]
	mov word [es:bx], cx
	popa
	pop bp
	ret



;-----	Get Screen Offset	-----
;-	outputs on char_offset
get_screen_offset:
	pusha
	mov cx, [char_y]
	mov ax, 0x00A0
	mul cx
	mov cx, ax
	add cx, [char_x]
	add cx, [char_x]
	;add cx, [es:0x0000]
	mov [char_offset], cx
	popa
	ret



;-----	Scroll Screen Up	-----
scroll_up:
	pusha
	push ds
	push es ; mov ds, es
	pop ds
	mov si, 0x0000
.loop:
	mov dl, [si+0xA0]
	mov [si], dl
	add si, 0x0001
	cmp si, 0x0FA0
	jne .loop
	pop ds
	popa
	ret



;-----	Draw Cursor	-----
draw_cur:
	push cx
	push word [draw_type]
	mov word [draw_type], 0x0001
	mov cx, [style_cur]
	or cx, word [colour_cur]
	push cx
	call draw_char
	add sp, 2
	pop word [draw_type]
	pop cx
	ret



;-----	Draw Blank	-----
draw_blank:
	push 0x0020
	call draw_char
	add sp, 2
	ret



;-----	Draw Cmd Line	-----
draw_cmd_line:
	push new_cmd
	call draw_string
	add sp, 2
	call draw_cur
	ret



;-----	Character Movement	-----
;-	Move character to next pos/line
;-	If z/bx = AAAA, moves to nxt line w/ char_next
char_next:
	push bp
	mov bp, sp
	pusha
	cmp word [char_x], 0x001F
	jne .ifjmp1
	cmp word [bp + 4], 0x0001;first argument
	jne .ifjmp1
	call char_next_line
	jmp .end
.ifjmp1:
	cmp word [char_x], 0x001F
	je .end
	add word [char_x], 0x0001
.end:
	popa
	pop bp
	ret
char_next_line:
	push ax
	mov ax, [char_x_start]
	mov [char_x], ax
	pop ax
	add word [char_y], 0x0001
	cmp word [char_y], 0x000C
	je char_btm_screen
	ret
char_btm_screen:
	mov word [char_y], 0x000B
	call scroll_up
	ret



;-----	Clear Screen	-----
clear_screen:
	pusha
	push ds
	push es ;Roundabout way of doing mov ds, es
	pop ds
	push 0x0000
	push 0xFA0
	push 0x0000;[es:0x0000]; fill_mem arg1
	call fill_mem
	add sp, 6
	pop ds
	popa
	ret



;-----	Fill Memory	-----
;arg1 = address to fill
;arg2 = ammount to fill
;arg3 = filler
fill_mem:
	push bp
	mov bp, sp
	pusha
	mov cx, 0
	mov di, [bp + 4]; arg1
	mov dx, [bp + 8]; arg3
fill_mem_loop:
	mov [di], dx; fill current addr
	add di, 1
	add cx, 1
	cmp cx, [bp + 6]; arg2
	jne fill_mem_loop
	popa
	pop bp
	ret



;-----	Copy Memory	-----
;i/ax = copy from
;j/cx = copy to
;z/bx = ammount to copy
copy_mem:
	pusha
	mov di, bx
	mov si, ax
copy_mem_loop:
	mov dx, [si]
	mov [di], dx
	add si, 1
	add cx, 1
	sub di, 1
	cmp di, 0
	jg copy_mem_loop
copy_mem_end:
	popa
	ret



;-----	Draw String	-----
;-	arg1 = points to sring
draw_string:
	push bp
	mov bp, sp
	pusha
	mov si, [bp + 4]; arg1
	mov ax, 0x0000
draw_string_loop:
	mov al, [si]
	cmp al, 0x00
	je draw_string_end
	
	push ax
	call draw_char
	add sp, 2
	
	push 0x0001
	call char_next
	add sp, 2
	
	add si, 0x0001
	jmp draw_string_loop
draw_string_end:
	popa
	pop bp
	ret



;-----	Compare String	-----
;-	arg1, arg2 = strings to cmp
;-	al = 1 if equal
cmp_string:
	push bp
	mov bp, sp
	pusha
	mov si, [bp + 4]; arg1
	mov di, [bp + 6]; arg2
.loop:
	mov dl, [di]
	cmp [si], dl
		jne .no
	cmp byte [si], 0x0000
		je .yes
	add si, 0x0001
	add di, 0x0001
	jmp .loop
.yes:
	popa
	mov al, 0x01
	jmp .end
.no:
	popa
	mov al, 0x00
	jmp .end
.end:
	pop bp
	ret



;-----	Draw Logo	-----
;-	[char_x] & [char_y] set pos
draw_logo:
	push ax
	push bx
	push dx
	push word [colour_text]
	mov ax, [logo_colour]
	mov [colour_text], ax
	mov bx, [char_x]
	mov ax, logo_str1
	mov dx, 0x0000
draw_logo_loop:
	mov word [char_x], bx
	call draw_string
	add ax, 0x0009
	add dx, 0x0001
	add word [char_y], 0x0001
	cmp dx, 0x0004
	jne draw_logo_loop
draw_logo_end:
	pop word [colour_text]
	pop dx
	pop bx
	pop ax
	ret



;-----	Set Border Colour	-----
;-	Sets border to colour_border
border_colour:
	push ax
	push bx
	mov ax, 3
	mov bx, [colour_border]
	; hwi [dev_screen]
	pop bx
	pop ax
	ret



;-----	Colour Choice	------
;-	draws all the colours
;-	returns user choice on C/dx
;-	returns 0xffff if none chosen
colour_choices:
	push dx ;a/dx
	push cx ;i/cx
	mov cx, 0x0000
	mov si, cx
	mov word [colour_text], 0x0000

colour_choices_loop1:
	cmp word [colour_list+si], 0x0000
	je colour_choices_loop1_end
	
	mov dx, [colour_list+si]
	mov word [char_x], 0x0000
	call draw_string
	add si, 0x0001
	cmp word [colour_list+si], 0x0000
	je colour_choices_loop1_end
	
	mov dx, [colour_list+si]
	add word [colour_text], 0x1000
	mov word [char_x], 0x0012
	call draw_string
	add si, 0x0001
	call char_next_line
	add word [colour_text], 0x1000
	jmp colour_choices_loop1

colour_choices_loop1_end:
	mov dx, [colour_text_user]
	mov [colour_text], dx
	call char_next_line
	mov word [char_x], 0x0000
	mov dx, colour_input
	call draw_string
	call draw_cur

colour_choices_loop2:
	call key_inp
	cmp dx, 0x003A
	jl .ifjmp1
	cmp dx, 0x002F
	jg colour_choices_num_inp
.ifjmp1:
	cmp dx, 0x0067
	jl .ifjmp2
	cmp dx, 0x0060
	jg colour_choices_hex_inp
.ifjmp2:
	cmp dx, 0x0011
	je colour_choices_no_inp
	jmp colour_choices_loop2

colour_choices_hex_inp:
	call draw_char
	sub dx, 0x0060
	add dx, 0x0009
	pop cx
	pop dx
	ret

colour_choices_num_inp:
	call draw_char
	sub dx, 0x0030
	pop cx
	pop dx
	ret

colour_choices_no_inp:
	call draw_blank
	mov dx, 0xffff
	pop cx
	pop dx
	ret



;-----	Floppy State	-----
;b = state
;c = error
fdd_status:
	push ax
	mov ax, 0x0000
	mov bx, 0x0000
	mov cx, 0x0000
	; hwi [dev_fdd]
	pop ax
	ret