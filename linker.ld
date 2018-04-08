/*OUTPUT_FORMAT(binary)*/
ENTRY(start)
PHYS_BASE = 0X20000;
SECTIONS
{
	. = PHYS_BASE;
	
	.text :
	{
		*(.text);
	}
	.data :
	{
		*(.data);
		*(.bss);
		*(.rodata);
	}
	_heap = ALIGN(4);

	/DISCARD/ : {
		*(.note.gnu.build-id);
		*(.comment);
	}
}