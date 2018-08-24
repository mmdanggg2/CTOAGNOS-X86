#include "OSCommands.h"
#include "video/TextMode.h"

namespace OSCmds {

void clear()
{
	video.clearScreen();
	video.curX = 0;
	video.curY = 0;
}

void test()
{
	video.drawString("YOU JUST ACTIVATED MY TEST COMMAND!!!");
	Console::advanceLine();
}

void shutdown()
{

}

}
