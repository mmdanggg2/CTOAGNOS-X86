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
	DisplayColor& setBlink(bool blink) {
		if (blink)
			backCol |= 0b1000;
		else
			backCol &= ~0b1000;
		return *this;
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
	int curX = 0;
	int curY = 0;
	DisplayColor cursorCol = DisplayColor(0x7).setBlink(true);

	TextMode();
	// Draw a character at the x and y position.
	void drawChar(int x, int y, DisplayCharacter character);
	// Draw a character at the curX and curY.
	inline void drawChar(DisplayCharacter character) { drawChar(curX, curY, character); };
	// Draw a string at x and y, incrementing the position to the end of the string.
	void drawString(int* x, int* y, const char* str, DisplayColor color = 0x7, bool wrap = true);
	// Draw a string at the x and y.
	void drawString(int x, int y, const char* str, DisplayColor color = 0x7, bool wrap = true);
	// Draw a string at the curX and curY, incrementing the position to the end of the string.
	inline void drawString(const char* str, DisplayColor color = 0x7, bool wrap = true) { drawString(&curX, &curY, str, color, wrap); }

	inline void drawCur() { drawChar(DisplayCharacter(0xDB, cursorCol)); }


	// Clears the screen.
	void clearScreen();
	//Scrolls the screen up.
	void scrollUp();
};

extern TextMode video;