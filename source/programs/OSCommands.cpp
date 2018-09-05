#include "OSCommands.h"
#include "input/keyboard.h"
#include "utils/asmWraps.h"
#include "video/TextMode.h"

namespace OSCmds {

const char* cmdList[] = {"clear", "shutdown", "about", "textcolor", "test", 0};
const OSCmdSig cmdAddrList[] = {clear, shutdown, about, textColor, test};

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
	while (true) {
		halt(); //TODO good enough shutdown for now
	}
}

void about() {
	video.drawString("CTOAGNOS Ver 0.01");
	Console::advanceLine();
	video.drawString("Couldn't Think Of A Good Name OS");
	Console::advanceLine();
	Console::advanceLine();
	video.drawString("Created by ");
	video.drawString("mmdanggg2 \xC0\xC1", 0x9);
	Console::advanceLine();
}

const char* colorList[] = {"0.Black", "1.Dark Blue", "2.Dark Green", "3.Dark Cyan", "4.Dark Red", "5.Dark Purple", "6.Brown", "7.Grey", "8.Dark Grey", "9.Blue", "a.Green", "b.Cyan", "c.Red", "d.Purple", "e.Yellow", "f.White"};

uint8_t chooseColor() {
	video.drawString("Choose the text color: ");
	Console::advanceLine();

	for (int i = 0; i < 0x10; i += 2) {
		video.drawString(colorList[i], i);
		video.curX = 0x12;
		video.drawString(colorList[i + 1], i + 1);
		Console::advanceLine();
	}

	video.drawString("Number or letter> ");
	video.drawCur();
	while (true) {
		uint8_t key = keyboard::waitForKey();
		if (key >= '0' && key <= '9') {
			video.drawChar(key);
			return key - 0x30;
		} else if (key >= 'a' && key <= 'f') {
			video.drawChar(key);
			return key - 0x60 + 0x9;
		} else if (key == KB_RETURN || key == KB_ESCAPE) {
			return -1;
		}
	}
}

void textColor() {
	uint8_t color = chooseColor();
	if (color != -1) {
		video.defaultCol = DisplayColor(color, video.defaultCol.getBack());
	}
	Console::advanceLine();
}

} // namespace OSCmds
