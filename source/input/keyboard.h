#pragma once
#include <cinttypes>

#define KB_RETURN 13
#define KB_ESCAPE 27
#define KB_BACKSPACE 8
#define KB_TAB 9
#define KB_INSERT 10
#define KB_DELETE 11

namespace keyboard {
extern volatile uint8_t lastKey;

uint8_t translateScanCode(uint8_t code);

// Waits until a key is pressed and returns the key.
// This enables interrupts!
uint8_t waitForKey();

inline uint8_t readKey() {
	uint8_t key = lastKey;
	lastKey = 0;
	return key;
}

inline uint8_t peekKey() {
	return lastKey;
}

} // namespace keyboard
