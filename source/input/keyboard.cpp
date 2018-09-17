#include "keyboard.h"
#include "utils/asmWraps.h"

#define RET KB_RETURN
#define ESC KB_ESCAPE
#define BKS KB_BACKSPACE
#define TAB KB_TAB
#define INS KB_INSERT
#define DEL KB_DELETE

namespace keyboard {

/* clang-format off */

// Quoted characters represent themselves
// values are as follows :
// 0	: No ASCII code assigned
// 13	: Return
// 27	: Escape
// 8	: Backspace
// 9	: Tab
// 10	: Ins
// 11	: Del
uint8_t USKeymap[8 * 16]{
	 0 , ESC, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', BKS, TAB,
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', RET,  0 , 'a', 's',
	'd', 'f', 'g', 'h', 'j', 'k', 'l', ';','\'', '`',  0, '\\', 'z', 'x', 'c', 'v',
	'b', 'n', 'm', ',', '.', '/',  0 , '*',  0 , ' ',  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 , INS, DEL,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0
};

uint8_t UKKeymap[8 * 16]{
	 0 , ESC, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', BKS, TAB,
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', RET,  0 , 'a', 's',
	'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '#','\'',  0, '\\', 'z', 'x', 'c', 'v',
	'b', 'n', 'm', ',', '.', '/',  0 , '*',  0 , ' ',  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 , INS, DEL,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,
	 0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0 ,  0
};

/* clang-format on */

uint8_t* keymap = UKKeymap;

volatile uint8_t lastKey;

uint8_t translateScanCode(uint8_t code) {
	return keymap[code];
}

uint8_t waitForKey() {
	enableInterrupts();
	while (!keyboard::peekKey()) {
		halt();
	}
	return readKey();
}

} // namespace keyboard