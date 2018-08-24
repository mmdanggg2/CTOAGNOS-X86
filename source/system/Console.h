#pragma once
#include <cinttypes>
class Console
{
	uint8_t keyInp = 0;
#define CON_CMD_LEN 78
	char cmdBuffer[CON_CMD_LEN];//TODO custom command length?
	uint8_t cmdPos = 0;

	int startX = 1;

	void drawCmdLine();
	void handleChar(uint8_t chr);
	void handleBackspace();
	void handleReturn();
	void execCommand();
	void clearCmd();
public:
	Console();

	static void advanceCur(bool toNextLine = false);
	static void advanceLine();

	int run();
};

