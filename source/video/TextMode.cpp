#include "TextMode.h"
#include "utils/memory.h"

TextMode::TextMode() : 
	screenLoc(reinterpret_cast<void*>(0xB8000)),
	cols(80),
	rows(25)
{
}

void TextMode::drawChar(int x, int y, DisplayCharacter character) {
	((int16_t*)screenLoc)[(y * cols) + x] = character;
}

void TextMode::drawString(int* xPtr, int* yPtr, const uint8_t * str, DisplayColor color, bool wrap) {
	int x = *xPtr;
	int y = *yPtr;
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
	*xPtr = x;
	*yPtr = y;
}

void TextMode::drawString(int x, int y, const uint8_t * str, DisplayColor color, bool wrap) {
	int xT = x;
	int yT = y;
	drawString(&xT, &yT, str, color, wrap);
}

void TextMode::clearScreen() {
	mem::fill(screenLoc, (cols * rows) * 2, 0);
}

void TextMode::scrollUp() {
	uint16_t* src = (uint16_t*)screenLoc + cols;
	uint16_t* dst = (uint16_t*)screenLoc;
	for (int y = 0; y < rows; y++) {
		for (int x = 0; x < cols; x++) {
			if (y == rows - 1) {
				dst[x + y * cols] = 0x0000;
			}
			else {
				dst[x + y * cols] = src[x + y * cols];
			}
		}
	}
}
