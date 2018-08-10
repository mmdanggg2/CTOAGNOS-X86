#pragma once

class String {
	unsigned char* str;

public:
	String(unsigned char* base);
	int getLength();
	bool operator==(const String& str);
	inline const unsigned char operator[](int i) const { return str[i]; }
	inline unsigned char operator[](int i) { return str[i]; }
};

void toHex(unsigned char* in, unsigned int insz, char* out, unsigned int outsz);
void toHex(int in, char* out, unsigned int outsz);