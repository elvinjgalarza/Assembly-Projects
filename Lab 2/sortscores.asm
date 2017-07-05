		.ORIG x3000

; R7 is our n-counter for n-length of the array
; Student A Address: R1
; Student B Address: R2
; Student A: R3
; Student B: R4
; REGISTERS ARE CLEARED PRIOR TO EXECUTION
		AND R1, R1, #0
		AND R2, R2, #0
		AND R3, R3, #0
		AND R4, R4, #0
		AND R5, R5, #0
		AND R6, R6, #0
		AND R7, R7, #0				

			
		LD R0, MASKID				;The Mask for checking Student ID (xFF00).
		LD R1, LIST				;Gives address x4003, the beginning of our list.
		ADD R2, R1, #1
		LDR R3, R1, #0				;Puts all of Student A criteria [R3].
		AND R3, R0, R3				;Masks Student A for Student ID.
		BRz NOSTUDENT				;If Student A ID is NULL, stop sort, but if valid
		ADD R7, R7, #1				;then fall through to add one to the R7 (counter)
		LDR R3, R1, #0				;and MASK Student A for the Score.
LOOP1		LD R0, MASKSCORE
		AND R3, R0, R3						
	
		LD R0, MASKID
		LDR R4, R2, #0				;Student B stuff....
		AND R4, R0, R4
		BRz STOPSORT
		ADD R7, R7, #1
		LD R0, MASKSCORE
		LDR R4, R2, #0
		AND R4, R0, R4

							;Now it's time to do the comparing process.
		NOT R4, R4				;Gives us the negative value of Student B, 
		ADD R4, R4, #1				;this is then added to Student A to compare
		ADD R5, R3, R4				;and see which is greater. If R5 is (+), then
		BRp SWAP				;Student A > Student B, then we swap. If R5 is (-), 
		BRnz DONTSWAP				;Student A < Student B, then we don't swap. If R5 is (0), 
							;Student A = B, then we don't swap.


SWAP		LDR R3, R1, #0				;Get back the Students' full criteria. Swap the two Students.
		LDR R4, R2, #0				;Then incremement the pointers.
		STR R4, R1, #0
		STR R3, R2, #0
		ADD R1, R1, #1
		ADD R2, R2, #1
		LDR R3, R1, #0
		LDR R4, R2, #0
		BRnzp LOOP1

DONTSWAP	ADD R1, R1, #1				;No need to swap, so we just increment the pointers.
		ADD R2, R2, #1
		LDR R3, R1, #0
		LDR R4, R2, #0
		BRnzp LOOP1

STOPSORT		
		STI R7, NUMST				;Stores the number of students in x4001, so that it doesn't get lost.
		BRnzp PHASE2				;
							;
;///////////////////////////////Sort Phase 2\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;R7 has our final value for number of students in the list. Now we can just do everything again, but this
;time we decrement R7. Note: Branch LABELS are slightly different in order to remain in Phase 2.

PHASE2		LD R0, MASKID				;The Mask for checking Student ID (xFF00).
		LD R1, LIST				;Gives address x4003, the beginning of our list.
		ADD R2, R1, #1
		LDR R3, R1, #0				;Puts all of Student A criteria [R3].
		AND R3, R0, R3				;Masks Student A for Student ID.
							;If Student A ID is NULL, stop sort, but if valid then fall through to add one to the R7 (counter)
		LDR R3, R1, #0				;and MASK Student A for the Score.
LOOP2		LD R0, MASKSCORE
		AND R3, R0, R3						
	
		LD R0, MASKID
		LDR R4, R2, #0				;Student B stuff....
		AND R4, R0, R4
		BRz STOPSORT1
		LD R0, MASKSCORE
		LDR R4, R2, #0
		AND R4, R0, R4

							;Now it's time to do the comparing process.
		NOT R4, R4				;Gives us the negative value of Student B, 
		ADD R4, R4, #1				;this is then added to Student A to compare
		ADD R5, R3, R4				;and see which is greater. If R5 is (+), then
		BRp SWAP1				;Student A > Student B, then we swap. If R5 is (-), 
		BRnz DONTSWAP1				;Student A < Student B, then we don't swap. If R5 is (0), 
							;Student A = B, then we don't swap.


SWAP1		LDR R3, R1, #0				;Get back the Students' full criteria. Swap the two Students.
		LDR R4, R2, #0				;Then incremement the pointers.
		STR R4, R1, #0
		STR R3, R2, #0
		ADD R1, R1, #1
		ADD R2, R2, #1
		LDR R3, R1, #0
		LDR R4, R2, #0
		BRnzp LOOP2

DONTSWAP1	ADD R1, R1, #1				;No need to swap, so we just increment the pointers.
		ADD R2, R2, #1
		LDR R3, R1, #0
		LDR R4, R2, #0
		BRnzp LOOP2 
		
STOPSORT1		
		ADD R7, R7, #-1				;Decrements R7
		BRz STOP				;
		BRnp PHASE2				;
;Finding Max and Min process now begins.
	
STOP		LDI R6, NUMST				;R6 has the number of students
		LD R7, MEDST				;R7 has x4002 (or you could decrement counter by 1 to get same effect)
		ADD R6, R6, R7				;We add the (number of students-1) to x4003 to get the location of max
		
		LDR R6, R6, #0				;R6 now has max
		LD R0, MASKSCORE
		AND R6, R6, R0
		
		LD R7, LIST
		LDR R7, R7, #0				;R7 now has min
		AND R7, R7, R0

		STI R6, RANGEST				;Max in [7:0], but we need it in [15:8]
		LDI R6, RANGEST				;Add it to itself 8 times, to get it to [15:8]
		ADD R6, R6, R6
		ADD R6, R6, R6
		ADD R6, R6, R6
		ADD R6, R6, R6
		ADD R6, R6, R6
		ADD R6, R6, R6
		ADD R6, R6, R6
		ADD R6, R6, R6
		STI R6, RANGEST
		ADD R6, R7, R6				;Min should not be present, along with max.
		STI R6, RANGEST
		BRnzp MEDIAN
; Finding Median process begins (care there are odd and even lists, work accordingly)

MEDIAN 		LD R7, LIST				;Gives us x4003
		LDI R6, NUMST				;Gives us number of students
		AND R6, R6, #1				;Masks bits of number of students in order to see if even or odd
		BRp ODD					;If 1, then ODD
		BRz EVEN				;If 0, then EVEN


ODD		LDI R6, NUMST				;Calls back number of students
		AND R1, R1, #0				;divide number of students by 2,
		ADD R1, R1, #15				;then add that to x4003... this gives us the address for the median
							;R1 = 15 is our counter
							
		ADD R6, R6, #0	
		BRp ODDPOS
		BRn ODDNEG
ODDPOS		
		ADD R6, R6, R6	
		ADD R1, R1, #-1
		BRz STOREODD
		ADD R6, R6, #0
		BRp ODDPOS
		BRn ODDNEG
ODDNEG		
		ADD R6, R6, R6
		ADD R6, R6, #1
		ADD R1, R1, #-1
		BRz STOREODD
		ADD R6, R6, #0
		BRp ODDPOS
		BRn ODDNEG
				

STOREODD	LD R0, ODDMASK
		AND R6, R6, R0
		ADD R6, R7, R6				;add (#students/2) to x4003
		LDR R7, R6, #0
		LD R0, MASKSCORE
		AND R7, R7, R0
		STI R7, MEDST				
		BRnzp END
;---------------------------
EVEN		LDI R6, NUMST				;Calls back number of students
		AND R1, R1, #0				;divide number of students by 2,
		ADD R1, R1, #15				;then add that to x4003... this gives us the address for the median
							;R1 = 15 is our counter
							
		ADD R6, R6, #0	
		BRp EVENPOS
		BRn EVENNEG
EVENPOS		
		ADD R6, R6, R6	
		ADD R1, R1, #-1
		BRz CALCEVEN
		ADD R6, R6, #0
		BRp EVENPOS
		BRn EVENNEG
EVENNEG		
		ADD R6, R6, R6
		ADD R6, R6, #1
		ADD R1, R1, #-1
		BRz CALCEVEN
		ADD R6, R6, #0
		BRp EVENPOS
		BRn EVENNEG
				
CALCEVEN	
		LD R0, ODDMASK
		AND R6, R6, R0
		ADD R6, R7, R6				;add (#students/2) to x4003
							; R6 has the address of median
		ADD R5, R6, #-1				; R5 has the address -1 of median
		LDR R7, R6, #0				; R7 has data of Student A
		LDR R4, R5, #0				; R4 has data of Student B
		LD R0, MASKSCORE			; Mask both to get score
		AND R7, R0, R7
		AND R4, R0, R4
		ADD R6, R4, R7				; R6 has medians
		BRnzp EVENMED
;----------------------
EVENMED
		AND R1, R1, #0				
		ADD R1, R1, #15				
							
		ADD R6, R6, #0	
		BRp EVENPOS1
		BRn EVENNEG1
EVENPOS1	
		ADD R6, R6, R6	
		ADD R1, R1, #-1
		BRz STOREEVEN
		ADD R6, R6, #0
		BRp EVENPOS1
		BRn EVENNEG1
EVENNEG1		
		ADD R6, R6, R6
		ADD R6, R6, #1
		ADD R1, R1, #-1
		BRz STOREEVEN
		ADD R6, R6, #0
		BRp EVENPOS1
		BRn EVENNEG1
				

STOREEVEN	LD R0, ODDMASK
		AND R6, R6, R0
		STI R6, MEDST				
		BRnzp END	
		
NOSTUDENT	LD R0, NONE
		STI R0, RANGEST
		STI R0, MEDST
		AND R0, R0, #0
		STI R0, NUMST
		BRnzp END

END		HALT		


MASKID 		.FILL xFF00
MASKSCORE	.FILL x00FF
RANGEST		.FILL x4000
NUMST 		.FILL x4001
MEDST 		.FILL x4002
LIST 		.FILL x4003
ODDMASK		.FILL x7FFF
NONE		.FILL xFFFF
     		.END 