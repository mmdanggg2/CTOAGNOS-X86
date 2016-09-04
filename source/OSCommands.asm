clear:
	call clear_screen
	mov word [char_x], 0x0000
	mov word [char_y], 0x0000
	call draw_cmd_line
	jmp console_loop_start



restart:
	mov ax, 0x0000
	mov bx, 0x0000
	mov cx, 0x0000
	mov dx, 0x0000
	mov si, 0x0000
	mov di, 0x0000
	; mov i, 0x0000
	; mov j, 0x0000
	mov sp, 0x0000
	; iaq 0x0000
	; ias 0x0000
	jmp 0x0000



shutdown:
	call clear_screen
	mov word [colour_border], 0x0000
	call border_colour
	mov word [char_x], 0x000C
	mov word [char_y], 0x0004
	call draw_logo
	jmp end_secret



help:
	pusha
	push word [char_x_start]
	mov word [char_x_start], 0x0000
	mov si, 0x0000
	cmp word [cmd_list+si], 0x0000
	je .end
	push word [cmd_list+si]; draw_string arg1
	call draw_string
	add sp, 2
	add si, 0x0002
.loop:
	cmp word [cmd_list+si], 0x0000
	je .end
	push 0x002C; draw_char arg1
	call draw_char
	add sp, 2
	push 1; char_next arg1
	call char_next
	call draw_blank
	call char_next
	add sp, 2
	push word [cmd_list+si]; draw_string arg1
	call draw_string
	add sp, 2
	add si, 0x0002
	jmp .loop
.end:
	pop word [char_x_start]
	popa
	jmp console_new_cmd


txtcolour:
	pusha
	push word [char_x_start]
	mov word [char_x_start], 0x0000
	push colour_text_desc; draw_string arg1
	call draw_string
	add sp, 2
	call char_next_line
	call colour_choices
	cmp ax, 0xffff
	je .end
	mov cx, 0x0100
	mul cx
	mov word [colour_text_user], ax
	mov word [colour_text], ax
.end:
	pop word [char_x_start]
	popa
	jmp console_new_cmd

bordcolour:
	pusha
	push word [char_x_start]
	mov word [char_x_start], 0x0000
	push colour_border_desc; draw_string arg1
	call draw_string
	add sp, 2
	call char_next_line
	call colour_choices
	cmp ax, 0xffff
	je .end
	mov word [colour_border_user], ax
	mov word [colour_border], ax
.end:
	call border_colour
	pop word [char_x_start]
	popa
	jmp console_new_cmd

about:
	push ax
	push word [char_x_start]
	push word [colour_text]
	mov word [char_x_start], 0x0000
	call char_next_line
	push about1
	call draw_string
	call char_next_line
	push about2
	call draw_string
	call char_next_line
	push about3
	call draw_string
	call char_next_line
	push about4
	call draw_string
	mov ax, [about4_2_colour]
	mov word [colour_text], ax
	push about4_2
	call draw_string
	add sp, 10
	pop word [colour_text]
	pop word [char_x_start]
	pop ax
	jmp console_new_cmd