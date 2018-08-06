#include "video/TextMode.h"
#include "utils/memory.h"
#include "utils/asmWraps.h"
#include "system/InterruptTable.h"

//InterruptTable idt;
TextMode video;

struct interrupt_frame;

void iHandler0() {
	__asm__("pushad");
	video.drawString(0, 0, "int 0");
	__asm__("popad; leave; iret"); /* BLACK MAGIC! */
}
void iHandler1() {
	__asm__("pushad");
	video.drawString(0, 1, "int 1");
	__asm__("popad; leave; iret"); /* BLACK MAGIC! */
}
void iHandler2() {
	__asm__("pushad");
	video.drawString(0, 2, "int 2");
	__asm__("popad; leave; iret"); /* BLACK MAGIC! */
}

extern "C" int kernel_main() {
	int ret = 8;
	InterruptTable idt = InterruptTable((void*)0x500);
	idt.set(0x9, IDTDescr((uint32_t)&iHandler0, 0x8, 0xE, 0x8));
	idt.set(0x8, IDTDescr((uint32_t)&iHandler1, 0x8, 0xE, 0x8));
	idt.set(0xD, IDTDescr((uint32_t)&iHandler2, 0x8, 0xE, 0x8));
	idt.setIDTReg();

	enableInterrupts();

	video = TextMode();
	video.clearScreen();
	//mem::copy((void*)0xB8000, (void*)0x07c00, 80 * 25 * 2);
	video.drawString(4, 5, "Yo boi! this is a super duper extra really long string thats getting typed! Also with wrapping!", 0x07);
	video.drawString(0, 10, "Yo boi! this is a super duper extra really long string thats getting typed! Also without wrapping!", 0x07, false);
	
	return ret;
}
