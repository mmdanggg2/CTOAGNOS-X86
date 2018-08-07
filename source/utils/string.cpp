#include "string.h"

int String::getLength()
{
	int len = 0;
	while (str[len]) {
		len++;
	}
	return len;
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