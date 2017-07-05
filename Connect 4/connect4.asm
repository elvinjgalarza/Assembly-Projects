;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	description: 	Connect 4 game!				;
;			EE 306 - Spring 2013			;
;			Programming Assignment #4 Solution	;
; 								;
;	file:		connect4.asm				;
;	author:		Birgi Tamersoy				;
;	date:		04/09/2013				;
;		update:	04/10/2013 -> finished & tested.	;
;		update: 04/12/2013 -> re-arranged for students.	;
;				   -> added 2nd dia. check.	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Main Program						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JSR INIT
ROUND
	JSR DISPLAY_BOARD
	JSR GET_MOVE
	JSR UPDATE_BOARD
	JSR UPDATE_STATE

	ADD R6, R6, #0
	BRz ROUND

	JSR DISPLAY_BOARD
	JSR GAME_OVER

	HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Functions & Constants!!!				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_TURN						;
;	description:	Displays the appropriate prompt.	;
;	inputs:		None!					;
;	outputs:	None!					;
;	assumptions:	TURN is set appropriately!		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_TURN
	ST R0, DT_R0
	ST R7, DT_R7

	LD R0, TURN
	ADD R0, R0, #-1
	BRp DT_P2
	LEA R0, DT_P1_PROMPT
	PUTS
	BRnzp DT_DONE
DT_P2
	LEA R0, DT_P2_PROMPT
	PUTS

DT_DONE

	LD R0, DT_R0
	LD R7, DT_R7

	RET
DT_P1_PROMPT	.stringz 	"Player 1, choose a column: "
DT_P2_PROMPT	.stringz	"Player 2, choose a column: "
DT_R0		.blkw	1
DT_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GET_MOVE						;
;	description:	gets a column from the user.		;
;			also checks whether the move is valid,	;
;			or not, by calling the CHECK_VALID 	;
;			subroutine!				;
;	inputs:		None!					;
;	outputs:	R6 has the user entered column number!	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET_MOVE
	ST R0, GM_R0
	ST R7, GM_R7

GM_REPEAT
	JSR DISPLAY_TURN
	GETC
	OUT
	JSR CHECK_VALID
	LD R0, ASCII_NEWLINE
	OUT

	ADD R6, R6, #0
	BRp GM_VALID

	LEA R0, GM_INVALID_PROMPT
	PUTS
	LD R0, ASCII_NEWLINE
	OUT
	BRnzp GM_REPEAT

GM_VALID

	LD R0, GM_R0
	LD R7, GM_R7

	RET
GM_INVALID_PROMPT 	.stringz "Invalid move. Try again."
GM_R0			.blkw	1
GM_R7			.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_BOARD						;
;	description:	updates the game board with the last 	;
;			move!					;
;	inputs:		R6 has the column for last move.	;
;	outputs:	R5 has the row for last move.		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_BOARD
	ST R1, UP_R1
	ST R2, UP_R2
	ST R3, UP_R3
	ST R4, UP_R4
	ST R6, UP_R6
	ST R7, UP_R7

	; clear R5
	AND R5, R5, #0
	ADD R5, R5, #6

	LEA R4, ROW6
	
UB_NEXT_LEVEL
	ADD R3, R4, R6

	LDR R1, R3, #-1
	LD R2, ASCII_NEGHYP

	ADD R1, R1, R2
	BRz UB_LEVEL_FOUND

	ADD R4, R4, #-7
	ADD R5, R5, #-1
	BRnzp UB_NEXT_LEVEL

UB_LEVEL_FOUND
	LD R4, TURN
	ADD R4, R4, #-1
	BRp UB_P2

	LD R4, ASCII_O
	STR R4, R3, #-1

	BRnzp UB_DONE
UB_P2
	LD R4, ASCII_X
	STR R4, R3, #-1

UB_DONE		

	LD R1, UP_R1
	LD R2, UP_R2
	LD R3, UP_R3
	LD R4, UP_R4
	LD R6, UP_R6
	LD R7, UP_R7

	RET
ASCII_X	.fill	x0058
ASCII_O	.fill	x004f
UP_R1	.blkw	1
UP_R2	.blkw	1
UP_R3	.blkw	1
UP_R4	.blkw	1
UP_R5	.blkw	1
UP_R6	.blkw	1
UP_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHANGE_TURN						;
;	description:	changes the turn by updating TURN!	;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHANGE_TURN
	ST R0, CT_R0
	ST R1, CT_R1
	ST R7, CT_R7

	LD R0, TURN
	ADD R1, R0, #-1
	BRz CT_TURN_P2

	ST R1, TURN
	BRnzp CT_DONE

CT_TURN_P2
	ADD R0, R0, #1
	ST R0, TURN

CT_DONE
	LD R0, CT_R0
	LD R1, CT_R1
	LD R7, CT_R7

	RET
CT_R0	.blkw	1
CT_R1	.blkw	1
CT_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_WINNER						;
;	description:	checks if the last move resulted in a	;
;			win or not!				;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNER
	ST R5, CW_R5
	ST R6, CW_R6
	ST R7, CW_R7

	AND R4, R4, #0
	
	JSR CHECK_HORIZONTAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_VERTICAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_DIAGONALS

CW_DONE

	LD R5, CW_R5
	LD R6, CW_R6
	LD R7, CW_R7

	RET
CW_R5	.blkw	1
CW_R6	.blkw	1
CW_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_STATE						;
;	description:	updates the state of the game by 	;
;			checking the board. i.e. tries to figure;
;			out whether the last move ended the game;
; 			or not! if not updates the TURN! also	;
;			updates the WINNER if there is a winner!;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R6 has  1, if the game is over,		;
;				0, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_STATE
	ST R0, US_R0
	ST R1, US_R1
	ST R4, US_R4
	ST R7, US_R7
	
	; checking if the last move resulted in a win or not!
	JSR CHECK_WINNER
	
	ADD R4, R4, #0
	BRp US_OVER
	
	; checking if the board is full or not!
	AND R6, R6, #0
		
	LD R0, NBR_FILLED
	ADD R0, R0, #1
	ST R0, NBR_FILLED

	LD R1, MAX_FILLED
	ADD R1, R0, R1
	BRz US_TIE

US_NOT_OVER
	JSR CHANGE_TURN
	BRnzp US_DONE

US_OVER
	ADD R6, R6, #1
	LD R0, TURN
	ST R0, WINNER
	BRnzp US_DONE

US_TIE
	ADD R6, R6, #1

US_DONE
	LD R0, US_R0
	LD R1, US_R1
	LD R4, US_R4
	LD R7, US_R7

	RET
NBR_FILLED	.fill	#0
MAX_FILLED	.fill	#-36
US_R0		.blkw	1
US_R1		.blkw	1
US_R4		.blkw	1
US_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	INIT							;
;	description:	simply sets the BOARD_PTR appropriately!;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT
	ST R0, I_R0
	ST R7, I_R7

	LEA R0, ROW1
	ST R0, BOARD_PTR

	LD R0, I_R0
	LD R7, I_R7

	RET
I_R0	.blkw	1
I_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Global Constants!!!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_SPACE	.fill		x0020				;
ASCII_NEWLINE	.fill		x000A				;
TURN		.fill		1				;
WINNER		.fill		0				;
								;
ASCII_OFFSET	.fill		x-0030				;
ASCII_NEGONE	.fill		x-0031				;
ASCII_NEGSIX	.fill		x-0036				;
ASCII_NEGHYP	.fill	 	x-002d				;
								;
ROW1		.stringz	"------"			;
ROW2		.stringz	"------"			;
ROW3		.stringz	"------"			;
ROW4		.stringz	"------"			;
ROW5		.stringz	"------"			;
ROW6		.stringz	"------"			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;DO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;CHANGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ANYTHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ABOVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;THIS!!!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_BOARD						;
;	description:	Displays the board.			;
;	inputs:		None!					;
;	outputs:	None!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_BOARD 
	
					;STARTS at x3125
	ST R7, DBR7
	ST R1, DBR1
	ST R2, DBR2
	ST R3, DBR3
	
	LEA R1, ROW1			;R1 is the pointer for Rows
	ADD R3, R3, #6			;R3 is counter for Rows 
L2	ADD R2, R2, #5			;R2 is counter for 5 dashes
L1	LDR R0, R1, #0			
	OUT
	LD R0, ASCII_SPACE
	OUT
	ADD R1, R1, #1			;Increment pointer 5 times
	ADD R2, R2, #-1			;get flag from counter
	BRp L1				;if 5 dashes OUT, fall through
	
	LDR R0, R1, #0			;OUT 6th final dash of Row,
	OUT				;but do not OUT a space after final
	LD R0, ASCII_NEWLINE		;dash. OUT new line, skip null, 
	OUT				;get next Row.
	ADD R1, R1, #2			
	ADD R3, R3, #-1
	BRp L2		
		

	LD R7, DBR7
	LD R1, DBR1
	LD R2, DBR2
	LD R3, DBR3
	
DBR7	.blkw 1
DBR1	.blkw 1
DBR2	.blkw 1
DBR3	.blkw 1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GAME_OVER						;
;	description:	checks WINNER and outputs the proper	;
;			message!				;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GAME_OVER

	ST R0, GO_R0
	ST R7, GO_R7

	LD R1, WINNER		
	BRz TIED		;If R1 is zero, then TIE
	LD R1, TURN		

	ADD R1, R1, #-1		;if R1 is still positive, then Player 2 is winner
	BRp WIN2		;if R1 is negative, then Player 1 is winner	
	LEA R0, P1
	
OUTPUT	PUTS
	BRnzp COMPLT

TIED	LEA R0, TIE
	BRnzp OUTPUT

WIN2	LEA R0, P2
	BRnzp OUTPUT

COMPLT	LD R7, GO_R7
	LD R0, GO_R0
	
	

	RET

TIE	.STRINGZ "Tie Game."
P1	.STRINGZ "Player 1 Wins."
P2	.STRINGZ "Player 2 Wins."

GO_R0	.blkw 1
GO_R7	.blkw 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VALID						;
;	description:	checks whether a move is valid or not!	;
;	inputs:		R0 has the ASCII value of the move!	;
;	outputs:	R6 has:	0, if invalid move,		;
;				decimal col. val., if valid.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VALID

	ST R7, CV_R7			
					; ask about x3088
	ST R1, CV_R1
	ST R2, CV_R2
	ST R3, CV_R3
	ST R4, CV_R4
	ST R5, CV_R5
	
	LEA R1, CVx31			;R1 is pointer to column address
	AND R4, R4, #0
	ADD R4, R4, #6			;R4 is counter for 1-6 valid columns tries 
KEEPLKG	LDR R2, R1, #0			;R2 contains column check
	
	NOT R2, R2			;(-) value of column check
	ADD R2, R2, #1
	ADD R3, R0, R2			;flag for checking if valid
	BRz VALID
	ADD R1, R1, #1			;if not valid column, increment pointer
	ADD R4, R4, #-1			;decrement tries
	BRp KEEPLKG			;keep looking for a valid column
	AND R6, R6, #0			;if run out of tries, fall to invalid
	BRnzp INVALID
	
VALID					;NOW CHECK IF FULL
	LD R1, ASCII_OFFSET
	ADD R0, R1, R0			;R0 now has valid dec. col.
	LEA R1, ASCII_NEGHYP		;R1 has Column 0
	LD R2, ASCII_NEGHYP

	ADD R1, R0, R1			;now has User's col.
	LDR R1, R1, #0			;has move of User's col.
	ADD R3, R1, R2
	BRz NOTFULL
	BRnp INVALID
	


NOTFULL ADD R6, R0, #0	
	BRnzp A
INVALID AND R6, R6, #0	

A	LD R7, CV_R7
	LD R1, CV_R1
	LD R2, CV_R2
	LD R3, CV_R3
	LD R4, CV_R4
	LD R5, CV_R5

	RET
CV_R5	.blkw 1
CV_R7	.blkw 1
CV_R1	.blkw 1
CV_R2	.blkw 1
CV_R3	.blkw 1
CV_R4	.blkw 1
CV_R6	.blkw 1
CVx31	.FILL x0031
CVx32	.FILL x0032
CVx33	.FILL x0033
CVx34	.FILL x0034
CVx35	.FILL x0035
CVx36 	.FILL x0036
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;USE THE FOLLOWING TO ACCESS THE BOARD!!!;;;;;;;;;;;;;;;;;;
;;;;;IT POINTS TO THE FIRST ELEMENT OF ROW1 (TOP-MOST ROW)!!!;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BOARD_PTR	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_HORIZONTAL					;
;	description:	horizontal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_HORIZONTAL		
	
	ST R0, CH_R0
	ST R1, CH_R1
	ST R2, CH_R2
	ST R3, CH_R3
	ST R6, CH_R6
	ST R7, CH_R7
	
	LD R0, BOARD_PTR
	ADD R1, R5, #-1
	LD R2, ROWS
	ADD R3, R1, #0
EQTN	ADD R3, R3, R1
	ADD R2, R2, #-1
	BRz START
	BRnzp EQTN

START	ADD R0, R0, R3
CHL	LD R2, CHECK
CHL1	LDR R1, R0, #0
	ADD R0, R0, #1
	LDR R3, R0, #0

	LD R6, ASCII_NEGHYP
	ADD R6, R3, R6
	BRz HYP
	
	ADD R3, R3, #0
	BRz HYP
	NOT R4, R3
	ADD R4, R4, #1
	ADD R1, R1, R4
	BRz MATCH
	BRnzp CHL

HYP	AND R4, R4, #0
	BRnzp ENDCH

MATCH	ADD R2, R2, #-1
	BRz GOOVER
	BRnzp CHL1

GOOVER  AND R4, R4, #0
	ADD R4, R4, #1
	BRnzp ENDCH

ENDCH	LD R0, CH_R0
	LD R1, CH_R1
	LD R2, CH_R2
	LD R3, CH_R3
	LD R6, CH_R6
	LD R7, CH_R7

	RET

CH_R0	.blkw 1
CH_R1	.blkw 1
CH_R2	.blkw 1
CH_R3	.blkw 1
CH_R6	.blkw 1
CH_R7	.blkw 1
ROWS	.FILL x0006
CHECK	.FILL x0003

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VERTICAL						;
;	description:	vertical check.				;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VERTICAL

	ST R0, VC_R0
	ST R1, VC_R1
	ST R2, VC_R2
	ST R3, VC_R3
	ST R5, VC_R5
	ST R6, VC_R6
	ST R7, VC_R7

	AND R0, R0, #0
	AND R1, R1, #0
	AND R2, R2, #0
	AND R3, R3, #0 

	LD R0, BOARD_PTR
	ADD R1, R5, #-1
	LD R2, ROWS2
	ADD R3, R1, #0
EQTN2	ADD R3, R3, R1
	ADD R2, R2, #-1
	BRz START2
	BRnzp EQTN2	

START2	ADD R0, R0, R3

	ADD R4, R6, #-1
	ADD R0, R0, R4
	AND R4, R4, #0
CVL	LD R2, CHECK2
CVL1	LDR R1, R0, #0
	ADD R0, R0, #7
	LDR R3, R0, #0

	AND R7, R7, #0
	LD R7, MASK
	AND R7, R3, R7
	BRnp HYP2		
	
	NOT R4, R3
	ADD R4, R4, #1
	ADD R1, R1, R4
	
	BRZ MATCH1
	AND R4, R4, #0
	BRnzp CVL

HYP2	AND  R4, R4, #0
	AND R7, R7, #0
	LD R7, VC_R7
	BRnzp ENDCV1

MATCH1	ADD R2, R2, #-1
	BRz GOOVER1
	BRnzp CVL1

GOOVER1	AND R4, R4, #0
	ADD R4, R4, #1
	BRnzp ENDCV1

ENDCV1	LD R0, VC_R0
	LD R1, VC_R1
	LD R2, VC_R2
	LD R3, VC_R3
	LD R5, VC_R5
	LD R6, VC_R6
	LD R7, VC_R7

	
	RET
VC_R0 .blkw 1
VC_R1 .blkw 1
VC_R2 .blkw 1
VC_R3 .blkw 1
VC_R5 .blkw 1
VC_R6 .blkw 1
VC_R7 .blkw 1
ROWS2 .FILL x0006
CHECK2 .FILL x0003
MASK .FILL xFF00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_DIAGONALS						;
;	description:	checks diagonals by calling 		;
;			CHECK_D1 & CHECK_D2.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DIAGONALS
	
	ST R7, CD_R7
	JSR CHECK_D1
	ADD R4, R4, #0
	BRP DONE

	JSR CHECK_D2
DONE 	LD R7, CD_R7

	RET
CD_R7 .blkw 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D1						;
;	description:	1st diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D1	

	ST R0, D1_R0
	ST R1, D1_R1
	ST R2, D1_R2	
	ST R3, D1_R3
	ST R5, D1_R5	
	ST R6, D1_R6
	ST R7, D1_R7	

	LD R0, BOARD_PTR
	ADD R1, R5, #-1
	LD R2, ROWSD
	ADD R3, R1, #0
LOOPD1	ADD R3, R3, R1
	ADD R2, R2, #-1
	BRz STARTD1
	BRnzp LOOPD1

STARTD1	ADD R0, R0, R3
	ADD R4, R6, #-1
	ADD R0, R0, R4

	AND R2, R2, #0
	ADD R2, R2, R0
MOVES	LDR R1, R0, #0
	ADD R2, R2, #-8
	LDR R3, R2, #0
	NOT R5, R3
	ADD R5, R5, #1
	ADD R5, R5, R1
	BRz MOVES

	ADD R2, R2, #8
	AND R0, R0, #0
	ADD R0, R2, R0
	AND R6, R6, #0
	ADD R6, R6, #4
DIAGL	ADD R6, R6, #-1
	BRz WINS
	LDR R1, R0, #0
	ADD R2, R2, #8
	LDR R3, R2, #0
	BRz NOWIN
	NOT R5, R3
	ADD R5, R5, #1
	ADD R5, R5, R1
	BRz DIAGL
	BRnp NOWIN

NOWIN	AND R4, R4, #0
	BRnzp RETURN

WINS 	AND R4, R4, #0
	ADD R4, R4, #1
	BRnzp RETURN

RETURN	LD R0, D1_R0
	LD R1, D1_R1
	LD R2, D1_R2	
	LD R3, D1_R3
	LD R5, D1_R5	
	LD R6, D1_R6
	LD R7, D1_R7

	RET
D1_R0 .blkw 1
D1_R1 .blkw 1
D1_R2 .blkw 1
D1_R3 .blkw 1
D1_R5 .blkw 1
D1_R6 .blkw 1
D1_R7 .blkw 1
ROWSD .FILL x0006
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D2						;
;	description:	2nd diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D2	

	ST R0, D2_R0
	ST R1, D2_R1
	ST R2, D2_R2
	ST R3, D2_R3
	ST R7, D2_R7

	LD R0, BOARD_PTR
	ADD R1, R5, #-1
	LD R2, ROWA
	ADD R3, R1, #0
LOOPD2	ADD R3, R3, R1
	ADD R2, R2, #-1
	BRz STARTD2
	BRnzp LOOPD2


STARTD2	ADD R0, R0, R3
	ADD R4, R6, #-1
	ADD R0, R0, R4
	AND R2, R2, #0
	ADD R2, R2, R0

MOVES1	LDR R1, R0, #0
	ADD R2, R2, #-6
	LDR R3, R2, #0
	NOT R5, R3
	ADD R5, R5, #1
	ADD R5, R5, R1
	BRz MOVES1

	ADD R2, R2, #6
	AND R0, R0, #0
	ADD R0, R2, R0

	AND R6, R6, #0
	ADD R6, R6, #4
CHECKDD	ADD R6, R6, #-1
	BRz YAY

	LDR R1, R0, #0
	ADD R2, R2, #6
	LDR R3, R2, #0
	BRz NAHFAM
	NOT R5, R3
	ADD R5, R5, #1
	ADD R5, R5, R1
	BRz CHECKDD
	BRnzp NAHFAM

NAHFAM	AND R4, R4, #0
	BRnzp DONEZO

YAY	AND R4, R4, #0
	ADD R4, R4, #1
	BRnzp DONEZO

DONEZO	LD R0, D2_R0
	LD R1, D2_R1
	LD R2, D2_R2	
	LD R3, D2_R3
	LD R5, D2_R5	
	LD R6, D2_R6
	LD R7, D2_R7


	RET
	

D2_R0 .blkw 1
D2_R1 .blkw 1
D2_R2 .blkw 1
D2_R3 .blkw 1
D2_R5 .blkw 1
D2_R6 .blkw 1
D2_R7 .blkw 1
ROWA .FILL x0006 

.END