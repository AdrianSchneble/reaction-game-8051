										;ABLAUFSTEUERUNG
								;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Init:

	;SET STATE=11
	State EQU 10
	MOV State, #11B
	left  EQU 08.0
	MOV left,#0
	right EQU 08.1
	MOV right,#0
	rightr EQU 18
	MOV rightr,#0
	rightl EQU 20
	MOV righl,#0
	timer1 EQU 28
	MOV timer1,#0
	timer2 EQU 30
	MOV timer2,#0
	timer3 EQU 38
	MOV timer3,#0
	timer4 EQU 40
	MOV timer4,#0
	initialized EQU 48.0
	MOV initialized,#0
	zufallsbit EQU 48.1

	;for timerdisplay
	digit1 EQU timer1
	digit2 EQU timer2
	digit3 EQU timer3
	digit4 EQU timer4
	reg1 EQU R7
	reg2 EQU R6
	reg3 EQU R5
	reg4 EQU R4
	MOV reg1, #9d
	MOV reg2, #1d
	MOV reg3, #6d
	MOV reg4, #4d
;zufallsbit:
	mov tmod, #00000010b ; mode des timers 2 = auto reload
	mov ie, #10010010b ; timer freischalten
	mov tl0, #0c0h ; working #0C0h 
	mov th0, #0c0h ; working #0C0h 
	setb tr0 ; startet timer
	MOV zufallsbit,tl0;SET RANDBIT
	LJMP Tick
	;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
										;SUB ROUTINEN
;Tick: ausgeführt jede ms.
Wait:
	;warte 1ms
	LJMP Tick
Tick:
	CPL zufallsbit
	;jump depending on state
	JCEQ state,#00B,statevoll
	JCEQ state,#01B,stateaktiv
	JCEQ state,#10B,statereagiert
	JCEQ state,#11B,statefehler
EndTick:
	LJMP Draw
Draw:
;zeichne was auch immer grad im register steht
MOV P0, DRAW1
MOV P1, DRAW2
LJMP Wait
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
										;DISPLAYS
DisplayFull:
;Register setzen sodass alle an
MOV DRAW1, #0H
MOV DRAW2, #0H
DisplayRight:
;Register setzen sodass alle rechten an
MOV DRAW1, #0CH
MOV DRAW2, #0H
DisplayLeft:
;Register setzen sodass alle linken an
MOV DRAW1, #3H
MOV DRAW2, #0H
DisplayTime:
;Register setzen sodass timer angezeigt
DisplayError:
;Register setzen sodass Error sichtbar
MOV DRAW1, #0b
MOV DRAW2, #10111111b
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
										;STATES
StateVoll:
;volles display warte bis zufallstimer auslaeuft, dann -> StateAktiv
;wenn nutzereingabe -> StateFehler
;CODE: 00
JLT initialized,ELSE;if initialized
	MOV 0.0,left
	XOL 0.0,right ;if either left or right is pressed
	CJEQ 0.0,#0,END
		MOV state,#11B;then state=11 (Fehler)
		MOV initialize,#0;initialized=0
	END:
	;timerdecrement
		SUB timer4,#1d
		JGT timer4,ENDDECREMENT
			MOV timer4,#9d
			SUB timer3,#1d
			JGT timer3,ENDDECREMENT
			MOV timer3,#9d
			SUB timer2,#1d
			JGT timer2,ENDDECREMENT
			MOV timer2,#9d
			SUB timer1,#1d
			JGT timer1,ENDDECREMENT
			MOV timer1,#0d;if we reach this then timer must be 0 already; this should never happen, if it does we do what should have happened
				MOV STATE,#01B
				MOV initialized,#0
				LJMP endtick
	;end timerdecrement
	ENDDECREMENT:
	JNE timer1,EndTick
	JNE timer2,EndTick
	JNE timer3,EndTick
	JNE timer4,EndTick ;timer=0?
		;else
		MOV STATE,#01B
		MOV initialized,#0
		LJMP EndTick
ELSE:
	MOV initialized,#1B
	MOV timer1,#0d
	MOV timer2,#5d
	MOV timer3,#0d
	MOV timer4,#0d
	LJMP endtick
StateAktiv:
;zeige halbes leeres display
;warte auf richtige nutzereingabe, zähle währenddessen die Ticks (ms), dann ->StateReagiert
;CODE: 01
JLT initialized,ELSE2;if initialized
	;timerincrement
	MOV A,timer4
	ADD A,#1b
	MOV timer4,A
	JLT timer4,#10d,ENDINCREMENT
		MOV timer4,#0d
		MOV A,timer3
		ADD A,#1b
		MOV timer3,A
		JLT timer3,#10d,ENDINCREMENT
		MOV timer3,#0d
		MOV A,timer2
		ADD A,#1b
		MOV timer2,A
		JLT timer2,#10d,ENDINCREMENT
		MOV timer2,#0d
		MOV A,timer1
		ADD A,#1b
		MOV timer1,A
		JLT timer1,#10d,ENDINCREMENT
		MOV timer1,#9d;we just reset it to 9 to prevent overflow. Everyone above 9 secs sucks ._.
	;end timerincrement
	ENDINCREMENT:
		;boolean crap
		MOV A,left
			MOV R0,right
			CMP R0
		ANL A,R0
		ANL A,rightr
			MOV R0,rightl
			CMP R0
		ANL A,R0
		JGT A,DO33
		;if A is 1 do
		MOV A,right
			MOV R0,left
			CMP R0
		ANL A,R0
		ANL A,rightl
			MOV R0,rightr
			CMP R0
		ANL A,R0
		JGT A,DO33
		;if A is 1 do
		LJMP DONOT33
		;else dont
		;end of booleancrap
	DO33:
		clr tr0 ; stop timer
		MOV state,#10B
		MOV initialized,#0B
	DONOT33:
		clr tr0 ; stop timer
		MOV state,#11B
		MOV initialized,#0B
	FINALLY33:
ELSE2:
	MOV timer1,0B;timer=0
	MOV timer2,0B
	MOV timer3,0B
	MOV timer4,0B
	JNE zufallsbit,Else30
		MOV rightr,#1B
		MOV rightl,#0B
		;Register setzen sodass alle rechten an
		MOV DRAW1, #0CH
		MOV DRAW2, #0H
		LJMP END30
	ELSE30:
		MOV rightr,#0B
		MOV rightl,#1B
		;Register setzen sodass alle linken an
		MOV DRAW1, #3H
		MOV DRAW2, #0H
	END30:
	MOV initialized,#1B
LJMP EndTick
StateReagiert:
;warte auf nutzereingabe, zeige timerausgabe, dann -> StateVoll
;CODE: 10
JLT initialized,ELSE25;if initialized
	MOV 0.0,left
	XOL 0.0,right ;if either left or right is pressed
	CJEQ 0.0,#0,SKIP23
		MOV State,#00b
		MOV initialized,#0b
		LJMP EndTick
ELSE25:
MOV left,#0b
MOV right,#0b
MOV initialized,#1b
SKIP23:
	;Ab hier timer anzeige:
	;CONVERT:
	MOV A,reg1
	mov dptr, #table
	movc A,@A+DPTR
	mov digit1,A
	MOV A,reg2
	mov dptr, #table
	movc A,@A+DPTR
	mov digit2,A
	MOV A,reg3
	mov dptr, #table
	movc A,@A+DPTR
	mov digit3,A
	MOV A,reg4
	mov dptr, #table
	movc A,@A+DPTR
	mov digit4,A
	;DRAW
	MOV P0, #11110111b
	MOV P1, R3
	MOV P0, #11111111b
	MOV P1, #11111111b
	MOV P0, #11111011b
	MOV P1, R2
	MOV P0, #11111111b
	MOV P1, #11111111b
	MOV P0, #11111101b
	MOV P1, R1
	MOV P0, #11111111b
	MOV P1, #11111111b
	MOV P0, #11111110b
	MOV P1, R0
	MOV P0, #11111111b
	MOV P1, #11111111b
	LJMP WAIT;we skip the normal draw event
StateFehler:
;warte auf nutzereingabe, zeige fehlerdisplay, dann ->StateVoll
;CODE: 11
JLT initialized,ELSE26;if initialized
	MOV 0.0,left
	XOL 0.0,right ;if either left or right is pressed
	CJEQ 0.0,#0,SKIP24
		MOV State,#00b
		MOV initialized,#0b
		LJMP EndTick
ELSE26:
MOV left,#0b
MOV right,#0b
MOV initialized,#1b
SKIP24:
	;FEHLERDISPLAY
	MOV DRAW1, #0b
	MOV DRAW2, #10111111b
LJMP EndTick
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------
										;USER INPUT
;Interrupts
NutzerLinks:
;setztlinksflag
MOV left,#1b
NutzerRechts:
;setzt rechtsflag
MOV right,#1b
table:
DB 11000000b
DB 11111001b, 10100100b, 10110000b
DB 10011001b, 10010010b, 10000010b
DB 11111000b, 10000000b, 10010000b
END