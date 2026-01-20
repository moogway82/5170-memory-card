# 5170-memory-card

Alternative CPLD codeto allow Rodney's 286 Memory Card be used as a simple Memory Expansion Card for an IBM 5170.

Mods to the card to make this work:
- REFRESH_N line from ISA bus, pin 19 underside, needs to be wired up to pin 10 on CPLD U36
- Pin 1 of the J5 System Control pins is now the XMS_ONLY_N switch and is either pulled high (off) or GND (on)

Switches:
XMS_ONLY_N - '0' will only decode the Extended Memory, above 1MB. '1' will provide 128kb of conventional RAM above 512kb (0x08000 - 0x09FFF range).
UMBD_N - '0' will provide 64kb UMB block in the "0D": 0x0D000 to 0x0DFFF range
UMBE_N - '0' will provide 64kb UMB block in the "0E": 0x0E000 to 0x0EFFF range

