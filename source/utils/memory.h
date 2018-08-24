#pragma once
#include <cinttypes>
#include <cstddef>

namespace mem {
void fill(void* dst, size_t size, char filler = 0x00);
void copy(void* dst, const void* src, size_t size);
void* alloc(size_t bytes);
void free(void* ptr);
}