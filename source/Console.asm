;-----	Console -----
console:
	;set sp, 0x0000
	push ax
	push bx

	; mov ax, 0
	; mov bx, [screen_loc]
	; hwi [dev_screen]

	; mov a, 1
	; mov b, sys_font ;Set font
	; hwi [dev_screen]

	; set a, 2
	; set b, sys_colour ;Set colours
	; hwi [dev_screen]

	mov ax, [colour_text_user]	;Change to user settings
	mov [colour_text], ax
	mov ax, [colour_border_user]
	mov [colour_border], ax
	;call border_colour

	mov word [char_x_start], 0x0001
	call console_clear_cmd
	call clear_screen	;Clear screen

	mov word [char_x], 0x0000
	mov word [char_y], 0x0000
	mov ax, intro_text
	call draw_string	;Draw intro text

	mov word [char_x], 0x0000
	mov word [char_y], 0x0001
	call draw_cmd_line	;Draw >
	
	KEYBOARD_INTERRUPT equ 9h
	
	push ds
	push word 0
	pop ds
	cli
	mov [4 * KEYBOARD_INTERRUPT], word console_int_handler
	mov [4 * KEYBOARD_INTERRUPT + 2], cs
	sti
	pop ds

	; mov a, 3
	; mov b, 0xbeef	;interrupt message = 0xbeef
	; hwi [dev_keyboard]	;Make keyboard send interupts

	; ias console_int_handler	;set interrupt handler

	; set a, 0
	; hwi [dev_keyboard]	;clear keyboard buffer

	pop bx
	pop ax
	jmp console_loop_start

console_loop_start:
	mov cx, 0x0000
	mov word [key_char], 0x0000
	; ias console_int_handler
	; iaq 0x0000
	sti
console_loop:
	cmp word [key_char], 0x0000
	jne console_inp
	jmp console_loop

console_int_handler:
	pusha
	call key_inp
	popa
	iret ;return from interrupt

console_new_cmd:
	call char_next_line
	mov word [char_x], 0x0000
	call console_clear_cmd
	call draw_cmd_line
	mov cx, 0
	jmp console_loop_start

;-- Input Handling --

console_inp:
	cli ;start queing interrupts
	mov cx, [key_char]
	cmp cx, 8
	je console_bksp	;Backspace
	cmp cx, 13
	je console_return	;Return
	cmp cx, 10
	je console_insert	;Insert
	cmp cx, 11
	je console_delete	;Delete
	jmp console_char	;Other

console_bksp:
	mov word si, [char_x]
	cmp si, word [char_x_start]	;if nothing to remove
	je console_loop_start	;return
	call draw_blank
	sub word [char_x], 0x0001
	call draw_cur
	push bx
	cmp word [con_cmd_pos], 0x0000
	je .ifjmp1
	sub word [con_cmd_pos], 0x0001
.ifjmp1:
	mov bx, [con_cmd_pos]
	mov word [con_cmd+bx], 0x0000
	pop bx
	jmp console_loop_start

console_return:
	call draw_blank
	call char_next_line
	jmp console_cmd_read

console_insert:
	push ax
	mov ax, con_cmd
	call draw_string
	call draw_cur
	pop ax
	jmp console_loop_start

console_delete:
	push 0x4D; draw_char arg1
	call draw_char
	add sp, 2
	call draw_cur
	jmp console_loop_start

;-- Character Handling --

console_char:
	push word [colour_cur]
	
	push word [key_char]; draw_char arg1
	call draw_char
	add sp, 2
	
	push 0x0000; char_next arg1
	call char_next
	add sp, 2
	
	cmp word [char_x], 0x001F
	jne .ifjmp1
	mov word [colour_cur], 0x8C00; set cursor red
.ifjmp1:
	call console_cmd_inp
	call draw_cur
	pop word [colour_cur]
	jmp console_loop_start

console_cmd_inp:
	push si
	mov si, word [con_cmd_pos]
	cmp si, word [con_cmd_len]
	pop si
	jne .ifjmp1
	ret
.ifjmp1:
	push bx
	push cx
	mov cx, [key_char]
	mov bx, [con_cmd_pos]
	mov word [con_cmd+bx], cx
	add word [con_cmd_pos], 0x0001
	pop cx
	pop bx
	ret

;-- Command Reading --

console_cmd_read:
	cmp word [con_cmd_pos], 0x0000
	je console_new_cmd
	push dx
	mov dx, 0x0000
	mov si, dx
console_cmd_read_loop:
	cmp word [cmd_list+si], 0x0000
	je console_cmd_read_none
	mov ax, [cmd_list+si]
	mov bx, con_cmd
	call cmp_string
	cmp cx, 0x0001 ;CX = ret from cmp_string FIXME function returns
	je console_cmd_read_match
	add si, 0x0001
	jmp console_cmd_read_loop

console_cmd_read_none:
	pop dx
	mov word [char_x], 0x0000
	mov ax, not_cmd
	call draw_string
	jmp console_new_cmd

console_cmd_read_match:
	call console_clear_cmd
	mov cx, 0x0000
	pop cx ;was pop 0
	mov cx, 0x0000
	sti
	; iaq 0 ;enable interupts
	; ias 0 ;resets interrupt addr
	jmp [cmd_list_addr+si]

console_clear_cmd:
	pusha
	mov bx, con_cmd
	mov ax, [con_cmd_len]
	mov cx, 0
	call fill_mem
	mov word [con_cmd_pos], 0
	popa
	ret

;-- End loop --

end_secret:
	mov word [char_x], 0
	mov word [char_y], 0
	mov ax, secret
	mov cx, 0x0000
	mov bx, 0x0000
end_secret_loop:
	add cx, 0x0001
	cmp cx, 0xFFFF
	je .ifjmp1
	add bx, 0x0001
.ifjmp1:
	cmp bx, 0x0004
	je .ifjmp2
	call draw_string
.ifjmp2:
	cmp bx, 0x0004
	je end
	jmp end_secret_loop