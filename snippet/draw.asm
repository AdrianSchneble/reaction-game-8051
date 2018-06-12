;Code for multiplexed drawing of 4 registers

MAIN:
digit1 EQU R3
digit2 EQU R2
digit3 EQU R1
digit4 EQU R0
reg1 EQU R7
reg2 EQU R6
reg3 EQU R5
reg4 EQU R4

MOV reg1, #9d
MOV reg2, #1d
MOV reg3, #6d
MOV reg4, #4d

JMP CONVERT

DRAW:
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
JMP DRAW

CONVERT:
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
JMP DRAW

table:
DB 11000000b
DB 11111001b, 10100100b, 10110000b
DB 10011001b, 10010010b, 10000010b
DB 11111000b, 10000000b, 10010000b
end
