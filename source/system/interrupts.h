#pragma once

/* Standard interrupts
0x00	Division by zero
0x01	Single-step interrupt (see trap flag)
0x02	NMI
0x03	Breakpoint (callable by the special 1-byte instruction 0xCC, used by debuggers)
0x04	Overflow
0x05	Bounds
0x06	Invalid Opcode
0x07	Coprocessor not available
0x08	Double fault
0x09	Coprocessor Segment Overrun (386 or earlier only)
0x0A	Invalid Task State Segment
0x0B	Segment not present
0x0C	Stack Fault
0x0D	General protection fault
0x0E	Page fault
0x0F	reserved
0x10	Math Fault
0x11	Alignment Check
0x12	Machine Check
0x13	SIMD Floating-Point Exception
0x14	Virtualization Exception
0x15	Control Protection Exception
*/


void iHandlerStub(struct isframe *frame);

void iHandlerDiv0(struct isframe *frame);
void iHandlerBreakpoint(struct isframe *frame);
void iHandlerInvalidOpcode(struct isframe *frame);
void iHandlerDoubleFault(struct isframe *frame);
void iHandlerStackFault(struct isframe *frame);
void iHandlerGeneralProtection(struct isframe *frame);
void iHandlerPageFault(struct isframe *frame);