#include "string.h"

int String::getLength()
{
	int len = 0;
	while (str[len]) {
		len++;
	}
	return len;
}
