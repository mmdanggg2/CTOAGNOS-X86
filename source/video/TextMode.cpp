#include "TextMode.h"
#include "utils/memory.h"

TextMode::TextMode() : 
	screenLoc(reinterpret_cast<void*>(0xB8000)),
	cols(80),
	rows(25)
{

}

void TextMode::drawChar(int8_t x, int8_t y, DisplayCharacter character) {
	((int16_t*)screenLoc)[(y * cols) + x] = character;
}

void TextMode::drawString(int8_t x, int8_t y, const char * str, DisplayColor color, bool wrap) {
	bool truncated = false;
	int i = 0;
	while (str[i] != 0) {
		drawChar(x, y, DisplayCharacter(str[i], color));
		x++;
		if (x >= cols) {
			if (wrap) {
				x = 0;
				y++;
			}
			else {
				truncated = true;
				break;
			}
		}
		i++;
	}
}

void TextMode::clearScreen() {
	mem::fill(screenLoc, (cols * rows) * 2, 0);
}

void TextMode::scrollUp() {
	uint16_t* src = (uint16_t*)screenLoc + cols;
	uint16_t* dst = (uint16_t*)screenLoc;
	for (int y = 0; y < rows; y++) {
		for (int x = 0; x < cols; x++) {
			if (x == rows - 1) {
				dst[x*y] = 0x0000;
			}
			else {
				dst[x*y] = src[x*y];
			}
		}
	}
}
