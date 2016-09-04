;----- NASM defines -----
SCREEN_WIDTH equ 80
SCREEN_HEIGHT equ 25
SCREEN_TOTAL_BYTES equ 0xFA0

;-----	Variables	-----
;screen_loc: dw 0x8000 now specified by es, segment
colour_text: dw 0x0700
colour_text_user: dw 0x0700
colour_border: dw 0x0000
colour_border_user: dw 0x0000
style_cur: dw 0x00DB
colour_cur: dw 0x8700
draw_type: dw 0x0000
;-	Screen Pos	-
char_x: dw 0x0000
char_y: dw 0x0000
char_offset: dw 0x0000
char_x_start: dw 0x0001
;-	Typed Chars	-
con_cmd:
times SCREEN_WIDTH - 2 db 0x00
dw 0x0000
con_cmd_len: dw SCREEN_WIDTH - 2
con_cmd_pos: dw 0x0000

;-----	Strings	-----
intro_text: db "---== Welcome to CTOAGNOS! ==---", 0x00
new_cmd: db ">", 0x00
not_cmd: db "Unknown Command", 0x00
test_text: db "Watch my vids on YouTube! =)", 0x00
secret: db "What were you expecting, a pie?", 0x00

colour_text_desc: db "Choose the text colour.", 0x00
colour_border_desc: db "Choose the border colour.", 0x00
colour_list: dw colour_0, colour_1, colour_2, colour_3, colour_4, colour_5, colour_6, colour_7, colour_8
dw colour_9, colour_a, colour_b, colour_c, colour_d, colour_e, colour_f, 0x00
colour_0: db "0.Black", 0x00
colour_1: db "1.Dark Blue", 0x00
colour_2: db "2.Dark Green", 0x00
colour_3: db "3.Dark Cyan", 0x00
colour_4: db "4.Dark Red", 0x00
colour_5: db "5.Dark Pruple", 0x00
colour_6: db "6.Brown", 0x00
colour_7: db "7.Grey", 0x00
colour_8: db "8.Dark Grey", 0x00
colour_9: db "9.Blue", 0x00
colour_a: db "a.Green", 0x00
colour_b: db "b.Cyan", 0x00
colour_c: db "c.Red", 0x00
colour_d: db "d.Purple", 0x00
colour_e: db "e.Yellow", 0x00
colour_f: db "f.White", 0x00
colour_input: db "Number or letter>", 0x00

about1: db "CTOAGNOS Ver 3", 0x00
about2: db "Couldn't Think Of A Good Name OS", 0x00
about3: db "", 0x00
about4: db "Created by ", 0x00
about4_2_colour: dw 0x0900
about4_2: db "mmdanggg2", 0x20, 0xC0, 0xC1, 0x00

;-----	Commands	-----
cmd_list: dw cmd_help, cmd_about, cmd_txtcolour, cmd_bordcolour, cmd_clear, cmd_restart, cmd_shutdown, cmd_test, 0x00;prog_painter, prog_calc, prog_logo, 0x00
cmd_help: db "help", 0x00
cmd_about: db "about", 0x00
cmd_txtcolour: db "txtcolour", 0x00
cmd_bordcolour: db "bordercolour", 0x00
cmd_clear: db "clear", 0x00
cmd_restart: db "restart", 0x00
cmd_shutdown: db "shutdown", 0x00
cmd_test: db "test", 0x00
prog_painter: db "painter", 0x00
prog_calc: db "calc", 0x00
prog_logo: db "logo", 0x00

cmd_list_addr: dw help, about, txtcolour, bordcolour, clear, restart, shutdown, test, 0x00;program_painter, program_calculator, program_logo, 0x00

null: dw 0x0000

logo_colour: dw 0x0900
logo_str1 db 0xC2, 0xC3, 0x20, 0x20, 0x20, 0x20, 0x20, 0xC2, 0xC3, 0x20, 0
logo_str2 db 0xDB, 0xDB, 0xC4, 0xC5, 0x20, 0xC6, 0xC7, 0xDB, 0xDB, 0xC4, 0
logo_str3 db 0xDB, 0xDB, 0xC8, 0xC9, 0xCA, 0xCB, 0xDB, 0xDB, 0xDB, 0xC8, 0
logo_str4 db 0xDB, 0xDB, 0xC8, 0xCC, 0xCD, 0xCE, 0xCF, 0xDB, 0xDB, 0xC8, 0

sys_font:
%include "MFont.asm"

keymap:
%include "us_keymap.asm"