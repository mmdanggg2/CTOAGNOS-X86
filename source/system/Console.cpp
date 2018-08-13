#include "Console.h"
#include "input/keyboard.h"
#include "utils/asmWraps.h"
#include "video/TextMode.h"

Console::Console()
{
}

void Console::drawCmdLine() {
	video.drawString(">"); video.drawCur();
}

void advanceCur() {
	video.curX++;
}

void handleChar(uint8_t chr) {
	video.drawChar(chr);
	advanceCur();
	video.drawCur();
}

int Console::run() {
	video.drawString("---== Welcome to CTOAGNOS! ==---");
	video.curX = 0;
	video.curY = 1;
	drawCmdLine();
	while (true) {
		enableInterrupts();
		while (!keyboard::lastKey) {
			halt();
		}
		disableInterrupts();
		keyInp = keyboard::lastKey;
		keyboard::lastKey = 0;

		switch (keyInp)
		{
		case KB_ESCAPE:
			break;
		case KB_BACKSPACE:
			break;
		case KB_RETURN:
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
