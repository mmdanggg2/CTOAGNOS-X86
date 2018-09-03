#pragma once
#include "system/Console.h"
namespace OSCmds {

typedef void (*OSCmdSig)();

void clear();
void test();
void shutdown();
void about();
void textColor();

extern const char* cmdList[];
extern const OSCmdSig cmdAddrList[];

} // namespace OSCmds
