#include "Console.h"
#include "input/keyboard.h"
#include "utils/asmWraps.h"
#include "video/TextMode.h"

Console::Console()
{
}

int Console::run() {
	while (true) {
		while (!keyboard::lastKey) {
			halt();
		}
		disableInterrupts();
		keyInp = keyboard::lastKey;
		keyboard::lastKey = 0;
		enableInterrupts();

		if (keyInp == 27) {
			video.scrollUp();
		}

	}
	return 8;
}
