#pragma once
#include <cinttypes>
class Console
{
	uint8_t keyInp = 0;
#define CON_CMD_LEN 78
	uint8_t cmdBuffer[CON_CMD_LEN];//TODO custom command length?
	uint8_t cmdPos = 0;

	int startX = 1;

	void drawCmdLine();
	void handleChar(uint8_t chr);
	void handleBackspace();
public:
	Console();

	void advanceCur(bool toNextLine = false);
	void advanceLine();

	int run();
};

