#include "InterruptTable.h"


IDTDescr::IDTDescr(uint32_t offset, uint16_t sel, uint8_t type, uint8_t attr)
{
	offset_1 = offset;
	offset_2 = offset >> 16;
	selector = sel;
	type_attr = (attr << 4) | (type & 0x0F);
}

InterruptTable::InterruptTable(void* tableAddr) : tableAddr(tableAddr)
{
}


InterruptTable::~InterruptTable()
{
}

