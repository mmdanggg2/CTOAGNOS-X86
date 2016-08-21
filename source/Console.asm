;-----	Console -----
:console
;set sp, 0x0000
push, ax
push, bx

; mov ax, 0
; mov bx, [screen_loc]
; hwi [dev_screen]

; mov a, 1
; mov b, sys_font ;Set font
; hwi [dev_screen]

; set a, 2
; set b, sys_colour ;Set colours
; hwi [dev_screen]

mov [colour_text], [colour_text_user]	;Change to user settings
mov [colour_border], [colour_border_user]
call border_colour

mov [char_x_start], 0x0001
call console_clear_cmd
call clear_screen	;Clear screen

mov [char_x], 0x0000
mov [char_y], 0x0000
mov a, intro_text
call draw_string	;Draw intro text

mov [char_x], 0x0000
mov [char_y], 0x0001
call draw_cmd_line	;Draw >

; mov a, 3
; mov b, 0xbeef	;interrupt message = 0xbeef
; hwi [dev_keyboard]	;Make keyboard send interupts

; ias console_int_handler	;set interrupt handler

; set a, 0
; hwi [dev_keyboard]	;clear keyboard buffer

pop bx
pop ax
jmp console_loop_start

:console_loop_start
mov cx, 0x0000
mov [key_char], 0x0000
; ias console_int_handler
; iaq 0x0000
:console_loop
cmp [key_char], 0x0000
jne console_inp
jmp console_loop

:console_int_handler
call key_inp
mov ax, [key_char]
and ax, 0x0100
cmp ax, 0x0100
jne .ifjmp1
	mov [key_char], 0
.ifjmp1
; rfi 1 ;return from interrupt

:console_new_cmd
call char_next_line
mov [char_x], 0x0000
call console_clear_cmd
call draw_cmd_line
mov cx, 0
jmp console_loop_start

;-- Input Handling --

:console_inp
; iaq 0x0001 ;start queing interrupts
mov cx, [key_char]
cmp cx, 0x0010
je console_bksp	;Backspace
cmp cx, 0x0011
je console_return	;Return
cmp cx, 0x0012
je console_insert	;Insert
cmp cx, 0x0013
je console_delete	;Delete
jmp console_char	;Other

:console_bksp
cmp [char_x], [char_x_start]	;if nothing to remove
je console_loop_start	;return
call draw_blank
sub [char_x], 0x0001
call draw_cur
push dx
cmp [con_cmd_pos], 0x0000
je .ifjmp1
sub [con_cmd_pos], 0x0001
.ifjmp1
mov dx, [con_cmd_pos]
mov [con_cmd+i], 0x0000
pop dx
jmp console_loop_start

:console_return
call draw_blank
call char_next_line
jmp console_cmd_read

:console_insert
push, ax
mov ax, con_cmd
call draw_string
call draw_cur
pop ax
jmp console_loop_start

:console_delete
push cx
mov cx, 0x4D
call draw_char
call draw_cur
pop cx
jmp console_loop_start

;-- Character Handling --

:console_char
push [colour_cur]
call draw_char
call char_next
cmp [char_x], 0x001F
je .ifjmp1
	mov [colour_cur], 0xC000
.ifjmp1
call console_cmd_inp
call draw_cur
pop [colour_cur]
mov cx, 0
jmp console_loop_start

:console_cmd_inp
cmp [con_cmd_pos], [con_cmd_len]
je .ifjmp1
	ret
.ifjmp1
push dx
mov dx, [con_cmd_pos]
mov [con_cmd+i], cx
add [con_cmd_pos], 0x0001
pop dx
ret

;-- Command Reading --

:console_cmd_read
cmp [con_cmd_pos], 0x0000
je console_new_cmd
push dx
mov dx, 0x0000
:console_cmd_read_loop
cmp [cmd_list+dx], 0x0000
je console_cmd_read_none
mov ax, [cmd_list+dx]
mov bx, con_cmd
call cmp_string
cmp cx, 0x0001 ;CX = ret from cmp_string
je console_cmd_read_match
add dx, 0x0001
jmp console_cmd_read_loop

:console_cmd_read_none
pop dx
mov [char_x], 0x0000
mov ax, not_cmd
call draw_string
jmp console_new_cmd

:console_cmd_read_match
call console_clear_cmd
mov cx, 0x0000
pop 0
; iaq 0 ;enable interupts
; ias 0 ;resets interrupt addr
jmp [cmd_list_addr+i]

:console_clear_cmd
pusha
mov i, con_cmd
mov z, [con_cmd_len]
mov y, 0
call fill_mem
mov [con_cmd_pos], 0
popa
ret

;-- End loop --

:end_secret
set [char_x], 0
set [char_y], 0
set a, secret
set i, 0x0000
set j, 0x0000
:end_secret_loop
add i, 0x0001
ife i, 0xFFFF
	add j, 0x0001
ife j, 0x0004
	call draw_string
ife j, 0x0004
	jmp end
jmp end_secret_loop