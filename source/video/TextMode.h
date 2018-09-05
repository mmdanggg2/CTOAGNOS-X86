#pragma once
#include <cinttypes>

class DisplayColor {
	uint8_t foreCol;
	uint8_t backCol;

public:
	void setValue(uint8_t value) {
		setFore(value);
		setBack(value >> 4);
	};
	//Sets the foreground color, truncates to 4 bits
	void setFore(uint8_t value) { foreCol = value & 0x0F; };
	//Sets the background color, truncates to 4 bits
	void setBack(uint8_t value) { backCol = value & 0x0F; };
	//Sets the blink bit on background color
	DisplayColor& setBlink(bool blink = true) {
		if (blink)
			backCol |= 0b1000;
		else
			backCol &= ~0b1000;
		return *this;
	};
	uint8_t getFore() const { return foreCol; };
	uint8_t getBack() const { return backCol; };
	uint8_t getValue() const { return foreCol | (backCol << 4); };

	DisplayColor(uint8_t value) { setValue(value); };
	DisplayColor(uint8_t fore, uint8_t back) {
		setFore(fore);
		setBack(back);
	};

	DisplayColor(const DisplayColor& other) {
		setValue(other);
	}

	DisplayColor& operator=(uint8_t value) {
		setValue(value);
		return *this;
	};
	operator uint8_t() const { return getValue(); };
};

struct DisplayCharacter {
	uint8_t character;
	DisplayColor attrib;

	DisplayCharacter(uint8_t character, DisplayColor attrib)
		: character(character), attrib(attrib){};
	uint16_t getValue() const { return character | attrib << 8; }
	operator uint16_t() const { return getValue(); }
};

class TextMode {
	void* screenLoc;
	int cols;
	int rows;

public:
	int curX = 0;
	int curY = 0;
	DisplayColor defaultCol = DisplayColor(0x7);

	inline int getCols() { return cols; }
	inline int getRows() { return rows; }

	TextMode();

	// Draw a character at the x and y position.
	void drawChar(int x, int y, DisplayCharacter character);
	// Draw a character with default color at the x and y position.
	inline void drawChar(int x, int y, uint8_t character) { drawChar(x, y, DisplayCharacter(character, defaultCol)); }

	// Draw a character at the curX and curY.
	inline void drawChar(DisplayCharacter character) { drawChar(curX, curY, character); };
	// Draw a character with default color at the curX and curY.
	inline void drawChar(uint8_t character) { drawChar(curX, curY, character); };


	// Draw a string at x and y, incrementing the position to the end of the string.
	void drawString(int* x, int* y, const uint8_t* str, DisplayColor color, bool wrap = true);
	// Draw a string at x and y, incrementing the position to the end of the string.
	inline void drawString(int* x, int* y, const char* str, DisplayColor color, bool wrap = true) { drawString(x, y, reinterpret_cast<const uint8_t*>(str), color, wrap); }
	// Draw a string with default color at x and y, incrementing the position to the end of the string.
	inline void drawString(int* x, int* y, const uint8_t* str) { drawString(x, y, str, defaultCol); }
	// Draw a string with default color at x and y, incrementing the position to the end of the string.
	inline void drawString(int* x, int* y, const char* str) { drawString(x, y, reinterpret_cast<const uint8_t*>(str)); }

	// Draw a string at the x and y.
	void drawString(int x, int y, const uint8_t* str, DisplayColor color, bool wrap = true);
	// Draw a string at the x and y.
	inline void drawString(int x, int y, const char* str, DisplayColor color, bool wrap = true) { drawString(x, y, reinterpret_cast<const uint8_t*>(str), color, wrap); }
	// Draw a string at the x and y with default color.
	inline void drawString(int x, int y, const uint8_t* str) { drawString(x, y, str, defaultCol); }
	// Draw a string at the x and y with default color.
	inline void drawString(int x, int y, const char* str) { drawString(x, y, reinterpret_cast<const uint8_t*>(str)); }

	// Draw a string at the curX and curY, incrementing the position to the end of the string.
	inline void drawString(const uint8_t* str, DisplayColor color, bool wrap = true) { drawString(&curX, &curY, str, color, wrap); }
	// Draw a string at the curX and curY, incrementing the position to the end of the string.
	inline void drawString(const char* str, DisplayColor color, bool wrap = true) { drawString(reinterpret_cast<const uint8_t*>(str), color, wrap); }
	// Draw a string with default color at the curX and curY, incrementing the position to the end of the string.
	inline void drawString(const uint8_t* str) { drawString(&curX, &curY, str); }
	// Draw a string with default color at the curX and curY, incrementing the position to the end of the string.
	inline void drawString(const char* str) { drawString(reinterpret_cast<const uint8_t*>(str)); }


	//Draws the cursor with a color
	inline void drawCur(DisplayColor color) { drawChar(DisplayCharacter(0xDB, color)); }
	//Draws the cursor with default color
	inline void drawCur() { drawCur(DisplayColor(defaultCol).setBlink()); }

	// Clears the screen.
	void clearScreen();
	//Scrolls the screen up.
	void scrollUp();
};

extern TextMode video;
