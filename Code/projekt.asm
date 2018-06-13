										;ABLAUFSTEUERUNG
								;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Init:

	;SET STATE=11
	DRAW1 EQU 48
	DRAW2 EQU 50
	State EQU 10
	MOV State, #11B
	left  EQU 60
	MOV left,#0b
	right EQU 68
	MOV right,#0b
	rightr EQU 18
	MOV rightr,#0b
	rightl EQU 20
	MOV rightl,#0b
	timerstelle1 EQU 28
	MOV timerstelle1,#0b
	timerstelle2 EQU 30
	MOV timerstelle2,#0b
	timerstelle3 EQU 38
	MOV timerstelle3,#0b
	timerstelle4 EQU 40
	MOV timerstelle4,#0b
	initialized EQU 70
	MOV initialized,#0b
	zufallsbit EQU 58

	;for timerdisplay
	digit1 EQU timerstelle1
	digit2 EQU timerstelle2
	digit3 EQU timerstelle3
	digit4 EQU timerstelle4
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
;Tick: ausgefÃ¼hrt jede ms.
Wait:
	;warte 1ms
	LJMP Tick
Tick:
	CPL zufallsbit
	;jump depending on state

	MOV A,state
	CJNE A,#00B,N1
		LJMP statevoll
	N1:
	CJNE A,#01B,N2
		LJMP stateaktiv
	N2:
	CJNE A,#10B,N3
		LJMP statereagiert
	N3:
	CJNE A,#11B,N4
		LJMP statefehler
	N4: ;fehler D:
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
MOV A,initialized
CJNE A,#1B,XCOMP1
LJMP JEQ1
XCOMP1:
JC ELE1
LJMP JGT1
;ELEVATOR TO MAKE JUMPS LONGER
LJMP ELEVATORSKIP1
ELE1:
LJMP JLT1
ELEVATORSKIP1:
;ELEVATORSKIP

JEQ1:
	MOV A,left
	XRL A,right ;if either left or right is pressed
	JZ ENDE
		MOV state,#11B;then state=11 (Fehler)
		MOV initialized,#0;initialized=0
	ENDE:
	;timerdecrement
		MOV A,timerstelle4
		SUBB A,#1d
		MOV timerstelle4,A

		;COMPARATOR
		MOV A,timerstelle4
		CJNE A,#0B,XCOMP2
		LJMP JEQ2
		XCOMP2:
		JC JLT2
		LJMP JGT2
		;ENDCOMPARATOR
		JLT2:
		JEQ2:
			MOV timerstelle4,#9H
			MOV A,timerstelle3
			SUBB A,#1H
			MOV timerstelle3,A
			;COMPARATOR
			MOV A,timerstelle3
			CJNE A,#0B,XCOMP3
			LJMP JEQ3
			XCOMP3:
			JC JLT3
			LJMP JGT3
			;ENDCOMPARATOR
			JLT3:
			JEQ3:
			MOV timerstelle3,#9H
			MOV A,timerstelle2
			SUBB A,#1H
			MOV timerstelle2,A
			;COMPARATOR
			MOV A,timerstelle2
			CJNE A,#0B,XCOMP4
			LJMP JEQ4
			XCOMP4:
			JC JLT4
			LJMP JGT4
			;ENDCOMPARATOR
			JLT4:
			JEQ4:
			MOV timerstelle2,#9H
			MOV A,timerstelle1
			SUBB A,#1H
			MOV timerstelle1,A
			;COMPARATOR
			MOV A,timerstelle1
			CJNE A,#0B,XCOMP5
			LJMP JEQ5
			XCOMP5:
			JC JLT5
			LJMP JGT5
			;ENDCOMPARATOR
			JLT5:
			JEQ5:
			MOV timerstelle1,#0H;if we reach this then timer must be 0 already; this should never happen, if it does we do what should have happened
				MOV STATE,#01B
				MOV initialized,#0
				LJMP endtick
	;end timerdecrement
	JGT2:
	JGT3:
	JGT4:
	JGT5:
	ENDDECREMENT:
	;ELEVATOR TO MAKE JUMPS LONGER
	LJMP ELEVATORSKIP2
	ELE2:
	LJMP EndTick
	ELEVATORSKIP2:
	;ELEVATORSKIP
	MOV A,timerstelle1
	JNZ Ele2
	MOV A,timerstelle2
	JNZ Ele2
	MOV A,timerstelle3
	JNZ Ele2
	MOV A,timerstelle4
	JNZ Ele2 ;timer=0?
		;else
		MOV STATE,#01B
		MOV initialized,#0
		LJMP EndTick
JLT1:
JGT1:
	MOV initialized,#1B
	MOV timerstelle1,#0H
	MOV timerstelle2,#5H
	MOV timerstelle3,#0H
	MOV timerstelle4,#0H
	LJMP endtick
StateAktiv:
;zeige halbes leeres display
;warte auf richtige nutzereingabe, zÃ¤hle wÃ¤hrenddessen die Ticks (ms), dann ->StateReagiert
;CODE: 01
;COMPARATOR
			MOV A,initialized
			CJNE A,#0B,XCOMP6
			LJMP JEQ6
			XCOMP6:
			JC ELE3
			;ELEVATOR TO MAKE JUMPS LONGER
	LJMP ELEVATORSKIP3
	ELE3:
	LJMP JLT6
	ELEVATORSKIP3:
	;ELEVATORSKIP
			LJMP JGT6
			;ENDCOMPARATOR
			JGT6:
			JEQ6:
	MOV A,timerstelle4
	ADD A,#1b
	MOV timerstelle4,A
			;COMPARATOR
			MOV A,timerstelle4
			CJNE A,#10d,XCOMP7
			LJMP JEQ7
			XCOMP7:
			JC JLT7
			LJMP JGT7
			;ENDCOMPARATOR
			JGT7:
			JEQ7:
		MOV timerstelle4,#0d
		MOV A,timerstelle3
		ADD A,#1b
		MOV timerstelle3,A
		;COMPARATOR
			MOV A,timerstelle3
			CJNE A,#10d,XCOMP8
			LJMP JEQ8
			XCOMP8:
			JC JLT8
			LJMP JGT8
			;ENDCOMPARATOR
			JGT8:
			JEQ8:
		MOV timerstelle3,#0d
		MOV A,timerstelle2
		ADD A,#1b
		MOV timerstelle2,A
		;COMPARATOR
			MOV A,timerstelle2
			CJNE A,#10d,XCOMP9
			LJMP JEQ9
			XCOMP9:
			JC JLT9
			LJMP JGT9
			;ENDCOMPARATOR
			JGT9:
			JEQ9:
		MOV timerstelle2,#0d
		MOV A,timerstelle1
		ADD A,#1b
		MOV timerstelle1,A
		;COMPARATOR
			MOV A,timerstelle1
			CJNE A,#10d,XCOMP10
			LJMP JEQ10
			XCOMP10:
			JC JLT10
			LJMP JGT10
			;ENDCOMPARATOR
			JGT10:
			JEQ10:
			MOV timerstelle1,#9d;we just reset it to 9 to prevent overflow. Everyone above 9 secs sucks ._.
	;end timerincrement
	JLT7:
	JLT8:
	JLT9:
	JLT10:
	ENDINCREMENT:
		;boolean crap
		MOV A,left
			MOV C,right
			CPL C
		ANL A,R0
		ANL A,rightr
			MOV C,rightl
			CPL C
		ANL A,R0
		;COMPARATOR
			CJNE A,#0H,XCOMP11
			LJMP JEQ11
			XCOMP11:
			JC JLT11
			LJMP JGT11
			;ENDCOMPARATOR
		JLT11:
		JEQ11:
		;if A is 1 do
		MOV A,right
			MOV C,left
			CPL C
		ANL A,R0
		ANL A,rightl
			MOV C,rightr
			CPL C
		ANL A,R0
		;COMPARATOR
			CJNE A,#0H,XCOMP12
			LJMP JEQ12
			XCOMP12:
			JC JLT12
			LJMP JGT12
			;ENDCOMPARATOR
		JLT12:
		JEQ12:
		;if A is 1 do
		LJMP DONOT33
		;else dont
		;end of booleancrap
	JGT12:
	JGT11:
	DO33:
		clr tr0 ; stop timer
		MOV state,#10B
		MOV initialized,#0B
	DONOT33:
		clr tr0 ; stop timer
		MOV state,#11B
		MOV initialized,#0B
	FINALLY33:
JLT6:
	MOV timerstelle1,#0D;timer=0
	MOV timerstelle2,#0D
	MOV timerstelle3,#0D
	MOV timerstelle4,#0D
	MOV A,zufallsbit
	JNZ Else30
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
MOV A,initialized
			CJNE A,#0B,XCOMP13
			LJMP JEQ13
			XCOMP13:
			JC JLT13
			LJMP JGT13
			;ENDCOMPARATOR
			JGT13:
			JEQ13:
	MOV A,left
	XRL A,right ;if either left or right is pressed
	JZ SKIP23
		MOV State,#00b
		MOV initialized,#0b
		LJMP EndTick
JLT13:
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
MOV A,initialized
			CJNE A,#0B,XCOMP14
			LJMP JEQ14
			XCOMP14:
			JC JLT14
			LJMP JGT14
			;ENDCOMPARATOR
			JGT14:
			JEQ14:
	MOV A,left
	XRL A,right ;if either left or right is pressed
	JZ SKIP24
		MOV State,#00b
		MOV initialized,#0b
		LJMP EndTick
JLT14:
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
