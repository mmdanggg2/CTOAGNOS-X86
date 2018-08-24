#pragma once

class String {
	char* str;

public:
	String(const char* base);
	~String();
	int getLength();
	int getLength(const char* str);
	bool operator==(const String& str);
	inline const char operator[](int i) const { return str[i]; }
	inline char operator[](int i) { return str[i]; }
};

void toHex(unsigned char* in, unsigned int insz, char* out, unsigned int outsz);
void toHex(int in, char* out, unsigned int outsz);