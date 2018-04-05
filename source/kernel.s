.code32
.globl start
start:
	cli #disable interrupts until table is setup...
	call kernel_main
	
end:
	hlt
	jmp end

