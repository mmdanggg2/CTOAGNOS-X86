#include "InterruptTable.h"
#include "utils/memory.h"


IDTDescr::IDTDescr(uint32_t offset, uint16_t sel, uint8_t type, uint8_t attr)
{
	offset_1 = offset;
	offset_2 = offset >> 16;
	selector = sel;
	type_attr = (attr << 4) | (type & 0x0F);
}

void InterruptTable::set(uint8_t intNum, IDTDescr descriptor)
{
	tableAddr[intNum] = descriptor;
}

void InterruptTable::setIDTReg()
{
#pragma pack(push)
#pragma pack(1)
	struct IDTInfo{
		uint16_t size = (256 * 8) - 1;
		uint32_t idtStart;
	};
#pragma pack(pop)
	static_assert(sizeof(IDTInfo) == 6, "Bad IDTInfo size!");

	IDTInfo idtInf = IDTInfo();
	idtInf.idtStart = (uint32_t)tableAddr;

	__asm__("lidt [%[info]]"
	: /*no outs*/
	: [info] "r"(&idtInf)
	: /*no clobbered*/);
}

InterruptTable::InterruptTable(void* tableAddr) : tableAddr((IDTDescr*)tableAddr)
{
	mem::fill(tableAddr, 256 * 8, 0x00);
}


InterruptTable::~InterruptTable()
{
}

