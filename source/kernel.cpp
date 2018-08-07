#include "video/TextMode.h"
#include "utils/memory.h"
#include "utils/asmWraps.h"
#include "system/InterruptTable.h"
#include "system/interrupts.h"

//InterruptTable idt((void*)0x500);
TextMode video;

extern "C" void kernel_init() {
	video = TextMode();
	video.clearScreen();

	InterruptTable idt = InterruptTable((void*)0x500);
	for (uint8_t i = 0; i < 0xFF; i++) {
		idt.set(i, IDTDescr((uint32_t)&iHandlerStub, 0x8, 0xE, 0x8));
	}
	idt.set(0x0, IDTDescr((uint32_t)&iHandlerDiv0, 0x8, 0xE, 0x8));
	idt.set(0x3, IDTDescr((uint32_t)&iHandlerBreakpoint, 0x8, 0xE, 0x8));
	idt.set(0x6, IDTDescr((uint32_t)&iHandlerInvalidOpcode, 0x8, 0xE, 0x8));
	idt.set(0x8, IDTDescr((uint32_t)&iHandlerDoubleFault, 0x8, 0xE, 0x8));
	idt.set(0xC, IDTDescr((uint32_t)&iHandlerStackFault, 0x8, 0xE, 0x8));
	idt.set(0xD, IDTDescr((uint32_t)&iHandlerGeneralProtection, 0x8, 0xE, 0x8));
	idt.set(0xE, IDTDescr((uint32_t)&iHandlerPageFault, 0x8, 0xE, 0x8));
	idt.setIDTReg();

	enableInterrupts();

}

extern "C" int kernel_main() {
	int ret = 8;

	//mem::copy((void*)0xB8000, (void*)0x07c00, 80 * 25 * 2);
	//video.drawString(4, 5, "Yo boi! this is a super duper extra really long string thats getting typed! Also with wrapping!", 0x07);
	//video.drawString(0, 10, "Yo boi! this is a super duper extra really long string thats getting typed! Also without wrapping!", 0x07, false);
	bool run = true;

	uint32_t x = 0;
	char out[] = { 'a', 'a', '\0'};
	while (run) {
		if (x++ == 0u) {
			out[0] += 0x1u;
			video.drawString(0, 1, out);
		}
		if (x > 0x2FFFFFFu) {
			x = 0;
		}
		//if (line > 32) {
		//	run = false;
		//}
	}

	return ret;
}
