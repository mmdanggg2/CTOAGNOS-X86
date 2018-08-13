#pragma once
#include <cinttypes>

class IDTDescr {
	uint16_t offset_1; // offset bits 0..15
	uint16_t selector; // a code segment selector in GDT or LDT
	uint8_t zero;      // unused, set to 0
	uint8_t type_attr; // type and attributes
	uint16_t offset_2; // offset bits 16..31

public:

	IDTDescr(uint32_t offset, uint16_t selector, uint8_t type, uint8_t attr);

	IDTDescr(void (*offset)(struct isframe*)) : IDTDescr((uint32_t)offset, 0x8, 0xE, 0x8) {};

};

static_assert((sizeof(IDTDescr) == 8), "Bad IDTDescr size!");

class InterruptTable
{
	IDTDescr* tableAddr;
public:
	void set(uint8_t intNum, IDTDescr descriptor);

	// Sets up the IDT register to the constructed table.
	void setIDTReg();

	InterruptTable(void* tableAddr);
};

