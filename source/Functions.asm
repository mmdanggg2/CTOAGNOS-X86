;-----	Keyboard Input	-----
;-	Output on C
:key_inp
ifn a, 0xbeef
	set pc, key_inp_old
set push, c
set push, a
set a, 0x0001
hwi [dev_keyboard]
set a, pop
set [key_char], c
set c, pop
set pc, pop

:key_inp_old
set push, a
set a, 0x0001
hwi [dev_keyboard]
set a, pop
ife c, 0x001B
	set pc, restart
set pc, pop

:key_char dat 0x0000



;-----	Draw Character	-----
;-	char_x and char_y set pos
;-	C is character
:draw_char
set push, c
set push, i
ife [draw_type], 0x0000
	bor c, [colour_text]
and [char_x], 0x00ff	;prevent overflows
and [char_y], 0x000f
jsr get_screen_offset
set i, [char_offset]
set [i], c
set i, pop
set c, pop
set pc, pop



;-----	Get Screen Offset	-----
;-	outputs on char_offset
:get_screen_offset
set push, j
set j, [char_y]
mul j, 0x0020
add j, [char_x]
add j, [screen_loc]
set [char_offset], j
set j, pop
set pc, pop



;-----	Scroll Screen Up	-----
:scroll_up
set push, i
set push, j
set i, 0x0000
set j, [screen_loc]
:scroll_up_loop
sti [j], [j+0x20]
ifn i, 0x0180
	set pc, scroll_up_loop
set j, pop
set i, pop
set pc, pop



;-----	Draw Cursor	-----
:draw_cur
set push, c
set push, [draw_type]
set [draw_type], 0x0001
set c, [style_cur]
bor c, [colour_cur]
jsr draw_char
set [draw_type], pop
set c, pop
set pc, pop



;-----	Draw Blank	-----
:draw_blank
set push, c
set c, 0x0020
jsr draw_char
set c, pop
set pc, pop



;-----	Draw Cmd Line	-----
:draw_cmd_line
set push, a
set a, new_cmd
jsr draw_string
jsr draw_cur
set a, pop
set pc, pop



;-----	Character Movement	-----
;-	Move character to next pos/line
;-	If z=AAAA, moves to nxt line w/ char_next
:char_next
ife [char_x], 0x001F
ife z, 0xAAAA
	set pc, char_next_line
ifn [char_x], 0x001F
	add [char_x], 0x0001
set pc, pop
:char_next_line
set [char_x], [char_x_start]
;ife z, 0xAAAA
;	set [char_x], 0x0000
add [char_y], 0x0001
ife [char_y], 0x000C
	set pc, char_btm_screen
set pc ,pop
:char_btm_screen
set [char_y], 0x000B
jsr scroll_up
set pc, pop



;-----	Clear Screen	-----
:clear_screen
set push, i
set push, z
set push, y
set i, [screen_loc]
set z, 0x180
set y, 0
jsr fill_mem
set y, pop
set z, pop
set i, pop
set pc, pop



;-----	Fill Memory	-----
;i/ax = address to fill
;z/bx = ammount to fill
;y/cx = filler
:fill_mem
set push, i
set push, j
set j, 0
:fill_mem_loop
sti [i], y
ifn j, z
	set pc, fill_mem_loop
set j, pop
set i, pop
set pc, pop



;-----	Copy Memory	-----
;i = copy from
;j = copy to
;z = ammount to copy
:copy_mem
set push, i
set push, j
set push, z
:copy_mem_loop
sti [j], [i]
sub z, 1
ifg z, 0
	set pc, copy_mem_loop
:copy_mem_end
set z, pop
set j, pop
set i, pop
set pc, pop



;-----	Draw String	-----
;-	A points to sring
:draw_string
set push, a
set push, c
set push, z
set z, 0xAAAA
:draw_string_loop
set c, [a]
ife c, 0x0000
	set pc, draw_string_end
jsr draw_char
jsr char_next
add a, 0x0001
set pc, draw_string_loop
:draw_string_end
set z, pop
set c, pop
set a, pop
set pc, pop



;-----	Compare String	-----
;-	A, B = strings to cmp
;-	Z = 1 if equal
:cmp_string
set push, a
set push, b
:cmp_string_loop
ifn [a], [b]
	set pc, cmp_string_no
ife [a], 0x0000
	set pc, cmp_string_yes
add a, 0x0001
add b, 0x0001
set pc, cmp_string_loop
:cmp_string_yes
set b, pop
set a, pop
set z, 0x0001
set pc, pop
:cmp_string_no
set b, pop
set a, pop
set z, 0x0000
set pc, pop



;-----	Draw Logo	-----
;-	[char_x] & [char_y] set pos
:draw_logo
set push, a
set push, b
set push, i
set push, [colour_text]
set [colour_text], [logo_colour]
set b, [char_x]
set a, logo_str1
set i, 0x0000
:draw_logo_loop
set [char_x], b
jsr draw_string
add a, 0x0009
add i, 0x0001
add [char_y], 0x0001
ifn i, 0x0004
	set pc, draw_logo_loop
:draw_logo_end
set [colour_text], pop
set i, pop
set b, pop
set a, pop
set pc, pop



;-----	Set Border Colour	-----
;-	Sets border to colour_border
:border_colour
set push, a
set push, b
set a, 3
set b, [colour_border]
hwi [dev_screen]
set b, pop
set a, pop
set pc, pop



;-----	Colour Choice	------
;-	draws all the colours
;-	returns user choice on C
;-	returns 0xffff if none chosen
:colour_choices
set push, a
set push, i
set i, 0x0000
set [colour_text], 0x0000

:colour_choices_loop1
ife [colour_list+i], 0x0000
	set pc, colour_choices_loop1_end
set a, [colour_list+i]
set [char_x], 0x0000
jsr draw_string
add i, 0x0001
ife [colour_list+i], 0x0000
	set pc, colour_choices_loop1_end
set a, [colour_list+i]
add [colour_text], 0x1000
set [char_x], 0x0012
jsr draw_string
add i, 0x0001
jsr char_next_line
add [colour_text], 0x1000
set pc, colour_choices_loop1

:colour_choices_loop1_end
set [colour_text], [colour_text_user]
jsr char_next_line
set [char_x], 0x0000
set a, colour_input
jsr draw_string
jsr draw_cur

:colour_choices_loop2
jsr key_inp
ifl c, 0x003A
ifg c, 0x002F
	set pc, colour_choices_num_inp
ifl c, 0x0067
ifg c, 0x0060
	set pc, colour_choices_hex_inp
ife c, 0x0011
	set pc, colour_choices_no_inp
set pc, colour_choices_loop2

:colour_choices_hex_inp
jsr draw_char
sub c, 0x0060
add c, 0x0009
set i, pop
set a, pop
set pc, pop

:colour_choices_num_inp
jsr draw_char
sub c, 0x0030
set i, pop
set a, pop
set pc, pop

:colour_choices_no_inp
jsr draw_blank
set c, 0xffff
set i, pop
set a, pop
set pc, pop



;-----	Floppy State	-----
;b = state
;c = error
:fdd_status
set push, a
set a, 0x0000
set b, 0x0000
set c, 0x0000
hwi [dev_fdd]
set a, pop
set pc, pop