#include "Console.h"
#include "input/keyboard.h"
#include "programs/OSCommands.h"
#include "utils/asmWraps.h"
#include "utils/memory.h"
#include "utils/string.h"
#include "video/TextMode.h"

Console::Console() {
	clearCmd();
}

void Console::clearCmd() {
	mem::fill(cmdBuffer, sizeof(cmdBuffer), 0);
	cmdPos = 0;
}

void Console::drawCmdLine() {
	video.drawString(">");
	video.drawCur();
}

void Console::advanceCur(bool toNextLine) {
	if (video.curX >= video.getCols() - 1) {
		if (toNextLine) {
			advanceLine();
		}
		return;
	}
	video.curX++;
}

void Console::advanceLine() {
	video.curX = 0;
	video.curY++;
	if (video.curY >= video.getRows()) {
		video.curY = video.getRows() - 1;
		video.scrollUp();
	}
}

int Console::run() {
	video.drawString("---== Welcome to CTOAGNOS! ==---");
	video.curX = 0;
	video.curY = 1;
	drawCmdLine();
	while (true) {
		keyInp = keyboard::waitForKey();
		disableInterrupts();

		switch (keyInp) {
			case KB_ESCAPE:
				break;
			case KB_BACKSPACE:
				handleBackspace();
				break;
			case KB_RETURN:
				handleReturn();
				break;
			case KB_DELETE:
				break;
			case KB_INSERT:
				break;
			case KB_TAB:
				break;
			default:
				handleChar(keyInp);
				break;
		}
	}
	return 8;
}

void Console::handleChar(uint8_t chr) {
	DisplayColor preCol = video.cursorCol;
	video.drawChar(chr);
	advanceCur();
	if (video.curX >= video.getCols() - 1) {
		video.cursorCol = DisplayColor(0xC).setBlink();
	}
	if (cmdPos < CON_CMD_LEN) {
		cmdBuffer[cmdPos++] = chr;
	}

	video.drawCur();
	video.cursorCol = preCol;
}

void Console::handleBackspace() {
	if (video.curX <= startX) {
		return;
	}
	video.drawChar(0x20); // draw blank space
	video.curX--;
	video.drawCur();
	if (cmdPos > 0) {
		cmdPos--;
	}
	cmdBuffer[cmdPos] = 0; // null the end of the command
}

void Console::handleReturn() {
	video.drawChar(0x20); // draw blank space
	advanceLine();
	execCommand();
	video.curX = 0;
	drawCmdLine();
}

void Console::execCommand() {
	using namespace OSCmds;
	if (cmdPos > 0) {
		for (int i = 0; cmdList[i]; i++) {
			if (String(cmdBuffer) == cmdList[i]) {
				cmdAddrList[i](); // call command
				break;
			}
		}
	}
	clearCmd();
}
