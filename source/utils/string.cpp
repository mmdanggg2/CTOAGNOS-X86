#include "string.h"
#include "utils/memory.h"

String::String(const char * base)
{
	int len = getLength(base);
	str = (char*)mem::alloc(len + 1);
	mem::copy(str, base, len);
	str[len] = 0;
}

String::~String() {
	mem::free(str);
}

int String::getLength()
{
	return getLength(str);
}

int String::getLength(const char* string)
{
	int len = 0;
	while (string[len]) {
		len++;
	}
	return len;
}

bool String::operator==(const String & str2)
{
	bool ret = true;
	int i = 0;
	while (str[i] || str2[i]) {
		if (str[i] != str2[i]) {
			ret = false;
			break;
		}
		i++;
	}
	return ret;
}

void toHex(unsigned char* in, unsigned int insz, char* out, unsigned int outsz) {
	unsigned char* pin = in;
	const char* hex = "0123456789ABCDEF";
	char* pout = out;
	for (; pin < in + insz; pout += 2, pin++) {
		pout[0] = hex[(*pin >> 4) & 0xF];
		pout[1] = hex[*pin & 0xF];
		if (pout + 2 - out > outsz) {
			/* Better to truncate output string than overflow buffer */
			/* it would be still better to either return a status */
			/* or ensure the target buffer is large enough and it never happen */
			break;
		}
	}
	//pout[-1] = 0;
}

void toHex(int in, char* out, unsigned int outsz) {
	toHex((unsigned char*)&in, sizeof(int), out, outsz);
}

void toHex(unsigned char in, char* out, unsigned int outsz) {
	toHex((unsigned char*)&in, sizeof(unsigned char), out, outsz);
}