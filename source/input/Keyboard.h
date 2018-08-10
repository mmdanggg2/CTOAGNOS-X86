#pragma once
#include <cinttypes>

class Keyboard
{
	uint8_t lastKey;

public:

	static uint8_t translateScanCode(uint8_t code);

	Keyboard();
};

