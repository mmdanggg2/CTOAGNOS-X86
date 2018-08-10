#include "memory.h"

namespace mem {

void fill(void * dst, uint32_t size, char filler)
{
	for (int i = 0; i < size; i++) {
		((char*)dst)[i] = filler;
	}
}

void copy(void * dst, void * src, uint32_t size)
{
	for (int i = 0; i < size; i++) {
		((char*)dst)[i] = ((char*)src)[i];
	}
}

}
