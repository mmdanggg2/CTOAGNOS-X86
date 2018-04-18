#include "asmWraps.h"

void enableInterrupts()
{
	__asm__("sti");
}

void disableInterrupts()
{
	__asm__("cli");
}

