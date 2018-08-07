#include "interrupts.h"
#include "video/TextMode.h"
#include "utils/string.h"
#include "utils/memory.h"

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
	video.drawString(0, line++, "int 0x0: Division by 0!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerBreakpoint(struct isframe *frame) {
	video.drawString(0, line++, "int 0x3: Breakpoint!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerInvalidOpcode(struct isframe *frame) {
	video.drawString(0, line++, "int 0x6: Invalid Opcode!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerDoubleFault(struct isframe *frame) {
	video.drawString(0, line++, "int 0x8: Double Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerStackFault(struct isframe *frame) {
	video.drawString(0, line++, "int 0xC: Stack Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerGeneralProtection(struct isframe *frame) {
	video.drawString(0, line++, "int 0xD: General Protection Fault!");
	printFrame(frame);
}

__attribute__((interrupt))
void iHandlerPageFault(struct isframe *frame) {
	video.drawString(0, line++, "int 0xE: Page Fault!");
	printFrame(frame);
}

/*
void iHandler2() {
	__asm__("pushad");
	video.drawString(0, line++, "int 2");
	__asm__("popad; leave; iret"); // BLACK MAGIC!
}
*/