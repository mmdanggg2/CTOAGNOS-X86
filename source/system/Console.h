#pragma once
#include <cinttypes>
class Console
{
	uint8_t keyInp = 0;

	uint8_t cmdBuffer[78];//TODO custom command length?

	void drawCmdLine();
public:
	Console();

	int run();
};

