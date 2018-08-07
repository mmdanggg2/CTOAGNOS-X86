#pragma once
#include <cinttypes>

class DisplayColor {
	uint8_t foreCol;
	uint8_t backCol;
public:
	void setValue(uint8_t value) { setFore(value); setBack(value >> 4); };
	//Sets the foreground color, truncates to 4 bits
	void setFore(uint8_t value) { foreCol = value & 0x0F; };
	//Sets the background color, truncates to 4 bits
	void setBack(uint8_t value) { backCol = value & 0x0F; };
	//Sets the blink bit on foreground color
	void setBlink(bool blink) {
		if (blink)
			foreCol |= 0b1000;
		else
			foreCol &= ~0b1000;
	};
	uint8_t getFore() { return foreCol; };
	uint8_t getBack() { return backCol; };
	uint8_t getValue() { return foreCol | (backCol << 4); };

	DisplayColor(uint8_t value) { setValue(value); };
	DisplayColor(uint8_t fore, uint8_t back) { setFore(fore); setBack(back); };

	DisplayColor& operator=(uint8_t value) { setValue(value); return *this; };
	operator uint8_t() { return getValue(); };
};

class DisplayCharacter {
	uint8_t character;
	DisplayColor attrib;
public:
	DisplayCharacter(uint8_t character, DisplayColor attrib = 0x07) : character(character), attrib(attrib) {};
	uint16_t getValue() { return character | attrib << 8; }
	operator uint16_t() { return getValue(); }
};

class TextMode { 
	void* screenLoc;
	int cols;
	int rows;

public:
	TextMode();
	void drawChar(int8_t x, int8_t y, DisplayCharacter character);
	void drawString(int8_t x, int8_t y, const char* str, DisplayColor color = 0x7, bool wrap = true);
	void clearScreen();
};

extern TextMode video;