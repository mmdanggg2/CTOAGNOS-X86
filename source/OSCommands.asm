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
	;mov z, 0xAAAA ;FIXME command arguments
	; mov i, 0x0000
	; mov c, 0x002C
	; cmp word [cmd_list+i], 0x0000
	; je help_end
	; mov a, [cmd_list+i]
	call draw_string
	; add i, 0x0001
help_loop:
	; cmp word [cmd_list+i], 0x0000
	je help_end
	call draw_char
	call char_next
	call draw_blank
	call char_next
	; mov a, [cmd_list+i]
	call draw_string
	; add i, 0x0001
	jmp help_loop
help_end:
	pop word [char_x_start]
	popa
	jmp console_new_cmd


txtcolour:
	pusha
	push word [char_x_start]
	mov word [char_x_start], 0x0000
	mov ax, colour_text_desc ;FIXME arguments
	call draw_string
	call char_next_line
	call colour_choices
	; cmp c, 0xffff
	; je txtcolour_end
	; mul c, 0x1000
	; mov word [colour_text_user], c
	; mov word [colour_text], c
txtcolour_end:
	pop word [char_x_start]
	popa
	jmp console_new_cmd

bordcolour:
	pusha
	push word [char_x_start]
	mov word [char_x_start], 0x0000
	; mov a, colour_border_desc
	call draw_string
	call char_next_line
	call colour_choices
	; cmp c, 0xffff
	je bordcolour_end
	; mov word [colour_border_user], c
	; mov word [colour_border], c
bordcolour_end:
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
	mov ax, about1
	call draw_string
	call char_next_line
	mov ax, about2
	call draw_string
	call char_next_line
	mov ax, about3
	call draw_string
	call char_next_line
	mov ax, about4
	call draw_string
	mov word [colour_text], 0x1000
	mov ax, about4_2
	call draw_string
	pop word [colour_text]
	pop word [char_x_start]
	pop ax
	jmp console_new_cmd