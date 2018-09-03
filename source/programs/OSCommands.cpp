#include "OSCommands.h"
#include "video/TextMode.h"

namespace OSCmds {

void clear() {
	video.clearScreen();
	video.curX = 0;
	video.curY = 0;
}

void test() {
	video.drawString("YOU JUST ACTIVATED MY TEST COMMAND!!!");
	Console::advanceLine();
	for (uint16_t i = 0; i <= 0xFF; i++) {
		video.drawString(reinterpret_cast<uint8_t*>(&i));
		if (i % 32 == 0) Console::advanceLine();
	}
	Console::advanceLine();
}

void drawLogo() {
	int startx = video.curX;
	const unsigned char strs[4][11] = {
		{0xC2, 0xC3, 0x20, 0x20, 0x20, 0x20, 0x20, 0xC2, 0xC3, 0x20, 0},
		{0xDB, 0xDB, 0xC4, 0xC5, 0x20, 0xC6, 0xC7, 0xDB, 0xDB, 0xC4, 0},
		{0xDB, 0xDB, 0xC8, 0xC9, 0xCA, 0xCB, 0xDB, 0xDB, 0xDB, 0xC8, 0},
		{0xDB, 0xDB, 0xC8, 0xCC, 0xCD, 0xCE, 0xCF, 0xDB, 0xDB, 0xC8, 0}};
	for (int i = 0; i < 4; i++) {
		video.curX = startx;
		video.drawString(strs[i], 0x09);
		video.curY++;
	}
}

void shutdown() {
	video.clearScreen();
	video.curX = video.getCols() / 2 - 0xB / 2;
	video.curY = video.getRows() / 2 - 0x4 / 2;
	drawLogo();
}

void about() {}

} // namespace OSCmds
