;-----	Console -----
console:
	push ax
	push bx

	; mov a, 1
	; mov b, sys_font ;Set font
	; hwi [dev_screen]
	call setup_font

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
	push intro_text
	call draw_string	;Draw intro text
	add sp, 2

	mov word [char_x], 0x0000
	mov word [char_y], 0x0001
	call draw_cmd_line	;Draw >
	
	push keyboard_int_handler
	call keyboard_int_setup
	add sp, 2

	pop bx
	pop ax
	jmp console_loop_start

console_loop_start:
	mov cx, 0x0000
	mov word [key_char], 0x0000
	sti
console_loop:
	cmp word [key_char], 0x0000
	jne console_inp
	jmp console_loop

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
	mov byte [con_cmd+bx], 0x00
	pop bx
	jmp console_loop_start

console_return:
	call draw_blank
	call char_next_line
	jmp console_cmd_read

console_insert:
	push con_cmd; draw_string arg1
	call draw_string
	add sp, 2
	call draw_cur
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
	
	cmp word [char_x], SCREEN_WIDTH - 1
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
	mov byte [con_cmd+bx], cl
	add word [con_cmd_pos], 0x0001
	pop cx
	pop bx
	ret

;-- Command Reading --

console_cmd_read:
	cmp word [con_cmd_pos], 0x0000
	je console_new_cmd
	push si
	mov si, 0x0000
console_cmd_read_loop:
	cmp byte [cmd_list+si], 0x00
	je console_cmd_read_none
	push con_cmd
	push word [cmd_list+si]; cmp_string arg1
	call cmp_string
	add sp, 4
	cmp al, 0x01 ;al = ret from cmp_string
	je console_cmd_read_match
	add si, 0x0001
	jmp console_cmd_read_loop

console_cmd_read_none:
	pop si
	mov word [char_x], 0x0000
	push not_cmd
	call draw_string
	add sp, 2
	jmp console_new_cmd

console_cmd_read_match:
	call console_clear_cmd
	add sp, 2
	sti
	jmp [cmd_list_addr+si]

console_clear_cmd:
	push 0x0000
	push word [con_cmd_len]
	push con_cmd; fill_mem arg1
	call fill_mem
	add sp, 6
	mov word [con_cmd_pos], 0
	ret

;-- End loop --

end_secret:
	mov word [char_x], 0
	mov word [char_y], 0
	mov cx, 0x0000
	mov bx, 0x0000
end_secret_loop:
	add cx, 0x0001
	cmp cx, 0xFFFF
	jne .ifjmp1
	add bx, 0x0001
.ifjmp1:
	cmp bx, 0xffff
	jne .ifjmp2
	push secret
	call draw_string
	add sp, 2
.ifjmp2:
	cmp bx, 0xffff
	je end
	jmp end_secret_loop