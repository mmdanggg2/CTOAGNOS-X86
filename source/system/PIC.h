#pragma once
#include <cinttypes>

namespace PIC
{
	/*
	arguments:
	offset1 - vector offset for master PIC
	vectors on the master become offset1..offset1+7
	offset2 - same for slave PIC: offset2..offset2+7
	*/
	void remap(int offset1, int offset2);

	void setMask1(uint8_t mask);
	void setMask2(uint8_t mask);

	void sendEOI(uint8_t irq);

};
