#include "video/TextMode.h"
#include "utils/memory.h"
#include "utils/asmWraps.h"
#include "system/InterruptTable.h"
#include "system/interrupts.h"
#include "system/PIC.h"
#include "system/Console.h"

TextMode video;

extern "C" void kernel_init() {
	video = TextMode();
	video.clearScreen();

	PIC::remap(0x20, 0x28);
	PIC::setMask1(0xFD);

	InterruptTable idt = InterruptTable((void*)0x500);
	for (uint8_t i = 0; i < 0xFF; i++) {
		idt.set(i, IDTDescr(&iHandlerStub));
	}
	idt.set(0x00, IDTDescr(&iHandlerDiv0));
	idt.set(0x02, IDTDescr(&iHandlerNMI));
	idt.set(0x03, IDTDescr(&iHandlerBreakpoint));
	idt.set(0x06, IDTDescr(&iHandlerInvalidOpcode));
	idt.set(0x08, IDTDescr(&iHandlerDoubleFault));
	idt.set(0x0C, IDTDescr(&iHandlerStackFault));
	idt.set(0x0D, IDTDescr(&iHandlerGeneralProtection));
	idt.set(0x0E, IDTDescr(&iHandlerPageFault));
	idt.set(0x20, IDTDescr(&iHandlerPITTimer));
	idt.set(0x21, IDTDescr(&iHandlerKeyboard));
	idt.setIDTReg();

	enableInterrupts();

}

extern "C" int kernel_main() {
	int ret = 8;

	ret = Console().run();

	return ret;
}
