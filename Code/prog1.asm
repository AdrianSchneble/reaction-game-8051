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
	hier zufallsbit setzen
	LJMP Tick
	;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
										;SUB ROUTINEN
;Tick: ausgeführt jede ms.
Wait:
	;warte 1ms
	LJMP Tick
Tick:
	randbit=!randbit
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
	
JLT initialized,0,ELSE;if initialized
	MOV 0.0,left
	XOL 0.0,right ;if either left or right is pressed
	
	CJEQ 0.0,#0,END
		MOV state,#11B;then state=11 (Fehler)
		MOV initialize,#0;initialized=0
	END:
	timer--
	CJNE timer,#0,endtick ;if timer==0 info: timer=0 bedeutet alle timer variablen müssen 0 sein. TODO!
		MOV STATE,#01B
		MOV initialized,#0
		LJMP endtick
ELSE:
	MOV initialized,#1B
	timer=zufallszahl
	LJMP endtick
StateAktiv:
;zeige halbes leeres display
;warte auf richtige nutzereingabe, zähle währenddessen die Ticks (ms), dann ->StateReagiert
;CODE: 01
JLT initialized,0,ELSE2;if initialized
	timer++
	if(left&&!right&&sider&&!sidel  || right&&!left&&sidel&&!sider)
		stoptimer
		MOV state,#10B
		MOV initialized,#0B
	else
		MOV state,#11B
		MOV initialized,#0B
ELSE2:
	MOV timer1,0B;timer=0
	MOV timer2,0B
	MOV timer3,0B
	MOV timer4,0B
	if(zufallsbit)
		MOV rightr,#1B
		MOV rightl,#0B
		;Register setzen sodass alle rechten an
		MOV DRAW1, #0CH
		MOV DRAW2, #0H
	else
		MOV rightr,#0B
		MOV rightl,#1B
		;Register setzen sodass alle linken an
		MOV DRAW1, #3H
		MOV DRAW2, #0H
	MOV initialized,#1B
LJMP EndTick
StateReagiert:
;warte auf nutzereingabe, zeige timerausgabe, dann -> StateVoll
;CODE: 10
if(initialized)
	if(left|right)
		State=00
		initialized=0
else
	left=0
	right=0
	initialized=1
	->TimerDisplay
LJMP EndTick
StateFehler:
;warte auf nutzereingabe, zeige fehlerdisplay, dann ->StateVoll
;CODE: 11
if(initialized)
	if(left|right)
		State=00
		initialized=0
else
	left=0
	right=0
	initialized=1
	->FehlerDisplay
LJMP EndTick
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------
										;USER INPUT
;Interrupts
NutzerLinks:
;setztlinksflag
left=1
NutzerRechts:
;setzt rechtsflag
right=1
END