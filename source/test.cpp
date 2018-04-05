//#include "boot.cpp"

int subFunc(int a, int b);

extern "C" int kernel_main() {
	int ret = subFunc(5, 3);
	volatile char* screenPtr = reinterpret_cast<char*>(0xB8010);
	*((int*)screenPtr) = 0x07690748;
	return ret;
}