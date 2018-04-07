#include "video/TextMode.h"

TextMode video;

extern "C" int kernel_main() {
	int ret = 8;
	video = TextMode();
	video.clearScreen();
	video.drawString(4, 5, "Yo boi! this is a super duper extra really long string thats getting typed! Also with wrapping!", 0x07);
	video.drawString(0, 10, "Yo boi! this is a super duper extra really long string thats getting typed! Also without wrapping!", 0x07, false);
	return ret;
}