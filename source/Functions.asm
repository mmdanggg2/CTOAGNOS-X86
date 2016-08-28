;-----	Keyboard Input	-----
;-	Output on C
key_inp:
	cmp ax, 0xbeef
	jne key_inp_old
	push cx
	push ax
	mov ax, 0x0001
	; hwi [dev_keyboard]
	pop ax
	mov [key_char], cx
	pop cx
	ret

key_inp_old:
	push ax
	mov ax, 0x0001
	; hwi [dev_keyboard]
	pop ax
	cmp cx, 0x001B
	je restart
	ret

key_char: dw 0x0000



;-----	Draw Character	-----
;-	char_x and char_y set pos
;-	Cx is character
draw_char:
	push cx
	push bx
	cmp word [draw_type], 0x0000
	jne .ifjmp1
	or cx, [colour_text]
.ifjmp1:
	and word [char_x], 0x00ff	;prevent overflows
	and word [char_y], 0x000f
	call get_screen_offset
	mov bx, [char_offset]
	mov word [es:bx], cx
	pop bx
	pop cx
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
	push ax
	push bx
	push cx
	mov ax, 0x0000
	mov bx, 0x0000;[es:0x0000]
scroll_up_loop:
	mov cx, [es:bx+0x20]
	mov [es:bx], cx
	add ax, 0x0001
	add bx, 0x0001
	cmp ax, 0x0180
	jne scroll_up_loop
	pop cx
	pop bx
	pop ax
	ret



;-----	Draw Cursor	-----
draw_cur:
	push cx
	push word [draw_type]
	mov word [draw_type], 0x0001
	mov cx, [style_cur]
	or cx, [colour_cur]
	call draw_char
	pop word [draw_type]
	pop cx
	ret



;-----	Draw Blank	-----
draw_blank:
	push cx
	mov cx, 0x0020
	call draw_char
	pop cx
	ret



;-----	Draw Cmd Line	-----
draw_cmd_line:
	push ax
	mov ax, new_cmd
	call draw_string
	;call draw_cur
	pop ax
	ret



;-----	Character Movement	-----
;-	Move character to next pos/line
;-	If z/bx = AAAA, moves to nxt line w/ char_next
char_next:
	cmp word [char_x], 0x001F
	jne .ifjmp1
	cmp bx, 0xAAAA
	jne .ifjmp1
	jmp char_next_line
.ifjmp1:
	cmp word [char_x], 0x001F
	je .ifjmp2
	add word [char_x], 0x0001
.ifjmp2:
	ret
char_next_line:
	push ax
	mov ax, [char_x_start]
	mov [char_x], ax
	pop ax
	;ife z, 0xAAAA
	;	set [char_x], 0x0000
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
	mov bx, 0x0000;[es:0x0000]
	mov ax, 0x180
	mov cx, 0
	call fill_mem
	popa
	ret



;-----	Fill Memory	-----
;i/bx = address to fill
;z/ax = ammount to fill
;y/cx = filler
fill_mem:
	push bx
	push dx ; j/dx
	mov dx, 0
fill_mem_loop:
	mov [bx], cx
	add bx, 1
	add dx, 1
	cmp dx, ax
	jne fill_mem_loop
	pop dx
	pop bx
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
;-	A/ax points to sring
draw_string:
	; push dx ;a/dx
	; push ax ;c/ax
	; push bx ;z/bx
	pusha
	mov si, ax
	mov bx, 0xAAAA
draw_string_loop:
	mov ax, 0x0000
	mov al, [si]
	cmp al, 0x00
	je draw_string_end
	mov cx, ax
	call draw_char
	call char_next
	add si, 0x0001
	jmp draw_string_loop
draw_string_end:
	popa
	; pop bx
	; pop ax
	; pop dx
	ret



;-----	Compare String	-----
;-	A, B = strings to cmp
;-	Z/dx = 1 if equal
cmp_string:
	push ax ;a/ax
	push bx ;b/bx
cmp_string_loop:
	mov dx, [bx]
	mov si, ax
	cmp [si], dx
		jne cmp_string_no
	cmp word [si], 0x0000
		je cmp_string_yes
	add ax, 0x0001
	add bx, 0x0001
	jmp cmp_string_loop
cmp_string_yes:
	pop bx
	pop ax
	mov dx, 0x0001
	ret
cmp_string_no:
	pop bx
	pop ax
	mov dx, 0x0000
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