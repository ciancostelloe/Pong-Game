; Assign4
; Pong game
; Cian Colin Sean

;Main
SETBR R2, 10	; Paddle
SETBR R2, 9		; Paddle
SETBR R2, 8		; Paddle
SETBR R2, 7		; Paddle
SETBR R2, 6		; Paddle
INV R7, R7		;FFFF Wall
CALL setUpTimer
END

;Setup 32-bit timer with auto-reload, for a repeating 1 sec interrupt =====================================
setUpTimer: INV R0, R0		;FFFFh
MOVRR R1,R0		;FFFFh
SHLA R1, 9		;FE00h
SETBR R1, 1		;FE02h
INVBR R1, 7		;FE82h
SHRL R0, 5		;FFB0h
SETBR R0, 15	;07FFh
INVBR R0, 6		;87FFh
CLRBR R0, 11	;87BFh
MOVRSFR SFR2, R1	; Move FE82h to higher tmr
MOVRSFR SFR7, R1	; Move FE82h to higher load val of timer
MOVRSFR SFR1, R0	; Move 87BFh to lower tmr
MOVRSFR SFR6, R0	; Move 87BFh to lower load val timer
SETBSFR SFR0, 5	; 32 1111001 000 000 101,  32  => X"F205h", SFR0(5) = 1, set timer auto reload
SETBSFR SFR0, 3	; 33 1111001 000 000 011,  33  => X"F203h", SFR0(3) = 1, set timer interrupt enable
SETBSFR SFR0, 0	; 34 1111001 000 000 000,  34  => X"F200h", SFR0(0) = 1, set global interrupt
SETBSFR SFR0, 4	; 35 1111001 000 000 100,  35  => X"F204h", SFR0(4) = 1, set enable timer
XOR R0, R0, R0	; Clears R0
XOR R1, R1, R1	; Clears R1
RET

; ====== Interrupt Service Routine 2 (32-bit timer interrupt) start label ================================
ISR2: ORG 116	; On interrupt, update time and update 7-segment display
CALL setWall		; call function updateTime. Illustrates the use of the CALL (for updateTime subroutine execution)
RETI        ; return from interrupt

; Update Paddle moves left and right =============================================================
setWall: SETBR R4, 2		;
SETBR R4, 3		;
SETBR R4, 4		;		
MOVBAMEM @R4, R7	;
CALL ball		;
CALL switchDir	;
RET

ball: SETBR R0, 8		;
SETBR R5, 0		;
SETBR R5, 4		;
MOVBAMEM @R5, R0	;
RET

switchDir: XOR R4, R4, R4
MOVINL R4				;
SUB R3, R4, R3			;
JZ R3, setPaddle		;
SETBR R3, 0				;
SUB R3, R4, R3			;
JZ R3, goRight		;
SETBR R3, 1				;
SUB R3, R4, R3			;
JZ R3, goRight		;
CLRBR R3, 0			;
SUB R3, R4, R3			;
JZ R3, goLeft		;
RET

setPaddle: SETBR R5, 4
MOVBAMEM @R5, R2
RET

goRight: INV R0, R0
SHRA R2, 1
MOVBAMEM @R5, R2
RET

goLeft: XOR R0, R0, R0
SHLA R2, 1
MOVBAMEM @R5, R2
RET

; ====== TODO Sean(up) ================================
goUp: CALL rightWallIndexSet	;R4 = 0001h
SUB R4, R5, R4			;CHECK IF BALL IS BESIDE RIGHT WALL
JZ R4, 	goUpLeft
CALL leftWallIndexSet	;R4 = 8000h
SUB R4, R5, R3			;CHECK IF BALL IS BESIDE LEFT WALL
JZ R4, goUpRight
CALL upperWallIndexSet	;R4 = 29d
SUB R4, R6, R4			;CHECK IF BALL IS BESIDE UPPER WALL
JZ R4, clearWallBit		;IF YES CLEAR UPPER WALL BIT AND 
JNZ R4, goUpStraight
		
goUpStraight:
	XOR R0, R0, R0		;CLEAR CURRENT MEMORY ROW
	MOVBAMEM @R6, R0
	INC R6, R6			;INCR ROW INDEX
	MOVBAMEM @R6, R5	;SET MEMORY
	CALL goUp
RET

goUpRight:
	XOR R0, R0, R0		;CLEAR CURRENT MEMORY ROW
	MOVBAMEM @R6, R0
	INC R6, R6			;INCR ROW INDEX
	SHRL R5, R5			;SHIFT COL INDEX RIGHT
	MOVBAMEM @R6, R5	;SET MEMORY
	CALL goUp
RET

goUpLeft:
	XOR R0, R0, R0		;CLEAR CURRENT MEMORY ROW
	MOVBAMEM @R6, R0
	INC R6, R6			;INCR ROW INDEX
	SHLL R5, R5			;SHIFT COL INDEX LEFT
	MOVBAMEM @R6, R5	;SET MEMORY
	CALL goUp
RET

clearWallBit:
	XOR R4, R4, R4		;CLEAR R4
	INV R4, R5			;SET R4 TO THE INV OF R5
	AND R7, R5, R7		;CLEAR WALL BIT
	CALL DOWN			;HANDOVER TO DOWN 
RET

; ====== TODO Colin(down) ================================
