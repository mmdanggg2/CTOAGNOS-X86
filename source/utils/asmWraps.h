#pragma once
#include <cinttypes>

static inline void enableInterrupts()
{
	__asm__("sti");
}

static inline void disableInterrupts()
{
	__asm__("cli");
}

static inline void halt() {
	__asm__("hlt");
}


static inline uint8_t inb(uint16_t port)
{
	uint8_t ret;
	__asm__ ("inb %0, %1"
		: "=a"(ret)
		: "Nd"(port));
	return ret;
}

static inline void outb(uint16_t port, uint8_t val)
{
	__asm__ ("out %1, %0" : : "a"(val), "Nd"(port));
	/* There's an outb %al, $imm8  encoding, for compile-time constant port numbers that fit in 8b.  (N constraint).
	* Wider immediate constants would be truncated at assemble-time (e.g. "i" constraint).
	* The  outb  %al, %dx  encoding is the only option for all other cases.
	* %1 expands to %dx because  port  is a uint16_t.  %w1 could be used if we had the port number a wider C type */
}

static inline void io_wait()
{
	/* Port 0x80 is used for 'checkpoints' during POST. */
	/* The Linux kernel seems to think it is free for use :-/ */
	__asm__("out 0x80, al" : : "a"(0));
	/* %%al instead of %0 makes no difference.  TODO: does the register need to be zeroed? */
}