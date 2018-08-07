#pragma once

class String {
	char* str;
public:
	int getLength();
};

void toHex(unsigned char* in, unsigned int insz, char* out, unsigned int outsz);
void toHex(int in, char* out, unsigned int outsz);