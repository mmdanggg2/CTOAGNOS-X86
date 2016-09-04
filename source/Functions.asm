;-----	Keyboard Input	-----
;-	Output on key_char
key_inp:
	pusha
	mov ax, 0x0000
	in al, 0x60; read keyboard code
	test al, 80h ;ignore codes with high bit
	jnz .end
	mov bx, 0x0000
	mov bl, al
	mov al, [keymap + bx]; calculate ascii from scancode
	mov [key_char], ax
.end:
	mov al, 61h
	out 20h, al ; Send EOI
	popa
	ret

key_char: dw 0x0000


;----- Setup Keyboard Interrupt -----
;-  arg1 is address of handler
KEYBOARD_INTERRUPT equ 9h

keyboard_int_setup:
	push bp
	mov bp, sp
	push ax
	push ds
	mov ax, [bp+4]; arg1
	push word 0; mov ds, 0
	pop ds
	cli
	mov [4 * KEYBOARD_INTERRUPT], ax
	mov [4 * KEYBOARD_INTERRUPT + 2], cs
	sti
	pop ds
	pop ax
	pop bp
	ret



;----- Keyboard Interrupt Handler -----
;-  Called from keyboard int vector
keyboard_int_handler:
	pusha
	call key_inp
	popa
	iret ;return from interrupt



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
	; and word [char_x], 0x00ff	;prevent overflows
	; and word [char_y], 0x000f
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
	mov ax, SCREEN_WIDTH * 2
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
	mov dx, word [si+SCREEN_WIDTH * 2]
	mov [si], dx
	add si, 0x0002
	cmp si, SCREEN_WIDTH * 2 * SCREEN_HEIGHT
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
	cmp word [char_x], SCREEN_WIDTH - 1
	jne .ifjmp1
	cmp word [bp + 4], 0x0001;first argument
	jne .ifjmp1
	call char_next_line
	jmp .end
.ifjmp1:
	cmp word [char_x], SCREEN_WIDTH - 1
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
	cmp word [char_y], SCREEN_HEIGHT
	je char_btm_screen
	ret
char_btm_screen:
	mov word [char_y], SCREEN_HEIGHT - 1
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
;arg2 = ammount to fill (bytes)
;arg3 = filler (lower byte)
fill_mem:
	push bp
	mov bp, sp
	pusha
	mov cx, 0
	mov di, [bp + 4]; arg1
	mov dx, [bp + 8]; arg3
.loop:
	mov [di], dl; fill current addr
	add di, 1
	add cx, 1
	cmp cx, [bp + 6]; arg2
	jne .loop
	
	popa
	pop bp
	ret



;-----	Copy Memory	-----
;arg1 = copy from
;arg2 = copy to
;arg3 = ammount to copy (bytes)
copy_mem:
	push bp
	mov bp, sp
	pusha
	mov cx, 0
	mov si, [bp + 4]; arg1
	mov di, [bp + 6]; arg2
.loop:
	mov dl, [si]
	mov [di], dl
	add si, 1
	add di, 1
	add cx, 1
	cmp cx, [bp + 8]; arg3
	jg .loop
	
	popa
	pop bp
	ret



;-----	Draw String	-----
;-	arg1 = points to sring
draw_string:
	push bp
	mov bp, sp
	pusha
	mov si, [bp + 4]; arg1
	mov ax, 0x0000
.loop:
	mov al, [si]
	cmp al, 0x00
	je .end
	
	push ax
	call draw_char
	add sp, 2
	
	push 0x0001
	call char_next
	add sp, 2
	
	add si, 0x0001
	jmp .loop
.end:
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
	push cx
	push word [colour_text]
	mov ax, [logo_colour]
	mov [colour_text], ax
	mov bx, [char_x]
	mov ax, logo_str1
	mov cx, 0x0000
.loop:
	mov word [char_x], bx
	push ax; draw_string arg1
	call draw_string
	add sp, 2
	add ax, 0x000B
	add cx, 0x0001
	add word [char_y], 0x0001
	cmp cx, 0x0004
	jne .loop
.end:
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
	push si
	mov si, 0x0000
	mov word [colour_text], 0x0000

.loop1:
	cmp word [colour_list+si], 0x0000
	je .loop1_end
	
	mov word [char_x], 0x0000
	push word [colour_list+si]; draw_string arg1
	call draw_string
	add sp, 2
	add si, 0x0002
	cmp word [colour_list+si], 0x0000
	je .loop1_end
	
	add word [colour_text], 0x0100
	mov word [char_x], 0x0012
	push word [colour_list+si]; draw_string arg1
	call draw_string
	add sp, 2
	add si, 0x0002
	call char_next_line
	add word [colour_text], 0x0100
	jmp .loop1

.loop1_end:
	mov ax, [colour_text_user]
	mov [colour_text], ax
	call char_next_line
	mov word [char_x], 0x0000
	push colour_input
	call draw_string
	add sp, 2
	call draw_cur
	
.get_input:
	mov word [key_char], 0x0000
.get_input_loop:
	cmp word [key_char], 0x0000
	jne .test_input
	jmp .get_input_loop

.test_input:
	mov ax, [key_char]
	cmp ax, 0x003A
	jge .ifjmp1
	cmp ax, 0x002F
	jg .num_inp
.ifjmp1:
	cmp ax, 0x0067
	jge .ifjmp2
	cmp ax, 0x0060
	jg .hex_inp
.ifjmp2:
	cmp ax, 0x0011
	je .no_inp
	jmp .get_input

.hex_inp:
	push ax
	call draw_char
	add sp, 2
	sub ax, 0x0060
	add ax, 0x0009
	jmp .end

.num_inp:
	push ax
	call draw_char
	add sp, 2
	sub ax, 0x0030
	jmp .end

.no_inp:
	call draw_blank
	mov ax, 0xffff
	jmp .end

.end:
	pop si
	ret

;-----  Set Font -----
setup_font:
	pusha
	push es
	push bp
	
	mov bh,16
	mov bl,0
	mov ax,cs
	mov es,ax
	mov bp,sys_font
	mov cx,16
	mov dx,0xC0
	mov ax,1100h
	int 10h
	
	pop bp
	pop es
	popa
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