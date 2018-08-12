#include "interrupts.h"
#include "video/TextMode.h"
#include "utils/string.h"
#include "utils/memory.h"
#include "system/PIC.h"
#include "utils/asmWraps.h"
#include "input/keyboard.h"

struct isframe { //interrupt stack frame
	int errCode;
	int eip;
	int ecs;
	int flags;
};

volatile int line = 0;

void printFrame(isframe* frame) {
	const uint32_t intBufSz = sizeof(int) * 2;
	char errCodeBuf[intBufSz];
	char eipBuf[intBufSz];
	char ecsBuf[intBufSz];
	char flagsBuf[intBufSz];
	toHex(frame->errCode, errCodeBuf, intBufSz);
	toHex(frame->eip, eipBuf, intBufSz);
	toHex(frame->ecs, ecsBuf, intBufSz);
	toHex(frame->flags, flagsBuf, intBufSz);
	char frStr[8 + ((intBufSz + 1) * 4)] = "frame: ";
	char* strpos = frStr + 7;
	mem::copy(strpos, errCodeBuf, intBufSz);
	strpos += intBufSz;
	*strpos++ = ' ';
	mem::copy(strpos, eipBuf, intBufSz);
	strpos += intBufSz;
	*strpos++ = ' ';
	mem::copy(strpos, ecsBuf, intBufSz);
	strpos += intBufSz;
	*strpos++ = ' ';
	mem::copy(strpos, flagsBuf, intBufSz);
	strpos += intBufSz;
	*strpos++ = '\0';

	video.drawString(0, line++, frStr);
}
__attribute__((interrupt))
void iHandlerStub(struct isframe *frame) {
	video.drawString(0, line++, "int 0x??: UNKNOWN INTERRUPT!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerDiv0(struct isframe *frame) {
	video.drawString(0, line++, "int 0x00: Division by 0!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerNMI(struct isframe *frame) {
	video.drawString(0, line++, "int 0x02: Non-Maskable Interrupt!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerBreakpoint(struct isframe *frame) {
	video.drawString(0, line++, "int 0x03: Breakpoint!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerInvalidOpcode(struct isframe *frame) {
	video.drawString(0, line++, "int 0x06: Invalid Opcode!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerDoubleFault(struct isframe *frame) {
	video.drawString(0, line++, "int 0x08: Double Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerStackFault(struct isframe *frame) {
	video.drawString(0, line++, "int 0x0C: Stack Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerGeneralProtection(struct isframe *frame) {
	video.drawString(0, line++, "int 0x0D: General Protection Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerPageFault(struct isframe *frame) {
	video.drawString(0, line++, "int 0x0E: Page Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerPITTimer(struct isframe *frame) {
	video.drawString(0, line++, "int 0x20: PIT Timer interrupt!");
	printFrame(frame);
	PIC::sendEOI(0x0);
}

__attribute__((interrupt))
void iHandlerKeyboard(struct isframe *frame) {
	uint8_t scan_code = inb(0x60);//Read keyboard scan code.
	if (!(scan_code & 0b10000000)) {// Ignore codes with high bit (release)
		char keyMsg[] = "Key: ?";
		keyboard::lastKey = keyboard::translateScanCode(scan_code);
		keyMsg[sizeof(keyMsg) - 2] = keyboard::lastKey;
		video.drawString(0, line, keyMsg);

	}
	PIC::sendEOI(0x1);
}

/*
void iHandler2() {
	__asm__("pushad");
	video.drawString(0, line++, "int 2");
	__asm__("popad; leave; iret"); // BLACK MAGIC!
}
*/