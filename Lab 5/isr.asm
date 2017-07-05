;x0100 to x01FF is the interrupt vector table, 
;put the starting address of isr.asm in the interrupt
;vector table.

.ORIG x2000

	ST R1, SAVE_R1
	ST R2, SAVE_R2
	ST R3, SAVE_R3
	ST R4, SAVE_R4
	ST R5, SAVE_R5
	
	LD R2, STADDR		;R2 has x2000
	LD R3, INTRPT		;R3 has x0100
	STR R2, R3, #0		;stores starting address of isr.asm
				;into x0100 (interrupt address)
	

POLL1	LDI R0, KBSR		
	BRzp POLL1		;checks to see if KBSR ready bit [15] is 1
				;if 1, then fall through, if not 1 then keep
				;checking.
	
	LDI R0, KBDR		;retrieve character from KBDR and put it
				;into DDR
	
	LD R5, TEN
POLL2	LDI R1, DSR
	BRzp POLL2

DISPLAY	STI R0, DDR
	ADD R5, R5, #-1
	BRp DISPLAY
	
	
	LD R1, SAVE_R1
	LD R2, SAVE_R2	
	LD R3, SAVE_R3
	LD R4, SAVE_R4
	LD R5, SAVE_R5
RTI

TEN		.FILL #10
KBSR		.FILL xFE00
KBDR		.FILL xFE02
DSR		.FILL xFE04
DDR		.FILL xFE06
STADDR		.FILL x2000
INTRPT		.FILL x0100
SAVE_R1		.blkw 1
SAVE_R2		.blkw 1
SAVE_R3		.blkw 1
SAVE_R4		.blkw 1
SAVE_R5		.blkw 1

.END

