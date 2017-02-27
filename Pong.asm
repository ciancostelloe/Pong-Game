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


; ====== TODO Colin(down) ================================
