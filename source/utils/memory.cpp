#include "memory.h"
#include "video/TextMode.h"

namespace mem {

void fill(void* dst, size_t size, char filler)
{
	for (int i = 0; i < size; i++) {
		((char*)dst)[i] = filler;
	}
}

void copy(void* dst, const void* src, size_t size)
{
	for (int i = 0; i < size; i++) {
		((char*)dst)[i] = ((char*)src)[i];
	}
}

char* freeBase = reinterpret_cast<char*>(0x1000);
char* freeTop = reinterpret_cast<char*>(0x20000);

void * alloc(size_t bytes)
{
	void* allocated = freeBase;
	bytes = (bytes + 7) / 8 * 8; // round up to 8 byte boundry
	if (freeBase + bytes > freeTop) {
		const char err[] = "mem::alloc ran out of memory!";
		video.drawString(video.getCols() - sizeof(err), video.getRows()-1, err, 0xC);
		return nullptr;
	}
	else {
		freeBase += bytes;
		return allocated;
	}
}

void free(void* mem) {
	//TODO free stub
}

}

void* operator new(size_t size) {
	return mem::alloc(size);
}

void operator delete(void* ptr, size_t size) {
	mem::free(ptr);
}
