#pragma once
#include <cinttypes>

namespace mem {
void fill(void* dst, uint32_t size, char filler);
void copy(void* dst, void* src, uint32_t size);
}