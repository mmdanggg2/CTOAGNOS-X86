#include "video/TextMode.h"
#include "utils/memory.h"
#include "utils/asmWraps.h"
#include "system/InterruptTable.h"

//InterruptTable idt;
TextMode video;

struct interrupt_frame;

__attribute__((interrupt)) void iHandler0(interrupt_frame *frame) {
	return;
}

extern "C" int kernel_main() {
	int ret = 8;
	InterruptTable idt = InterruptTable((void*)0x500);
	idt.set(0x21, IDTDescr((uint32_t)&iHandler0, 0x8, 0xE, 0x8));
	idt.setIDTReg();

	enableInterrupts();

	video = TextMode();
	video.clearScreen();
	mem::copy((void*)0xB8000, (void*)0x07c00, 80 * 25 * 2);
	video.drawString(4, 5, "Yo boi! this is a super duper extra really long string thats getting typed! Also with wrapping!", 0x07);
	video.drawString(0, 10, "Yo boi! this is a super duper extra really long string thats getting typed! Also without wrapping!", 0x07, false);
	return ret;
}
