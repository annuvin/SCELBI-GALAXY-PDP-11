	ORG	$0000

	FCB	$02		; Course 1.0
	FCB	$00
	FCB	$02		; Course 1.5
	FCB	$FF
	FCB	$02		; Course 2.0
	FCB	$FE
	FCB	$01		; Course 2.5
	FCB	$FE
	FCB	$00		; Course 3.0
	FCB	$FE
	FCB	$FF		; Course 3.5
	FCB	$FE
	FCB	$FE		; Course 4.0
	FCB	$FE
	FCB	$FE		; Course 4.5
	FCB	$FF
	FCB	$FE		; Course 5.0
	FCB	$00
	FCB	$FE		; Course 5.5
	FCB	$01
	FCB	$FE		; Course 6.0
	FCB	$02
	FCB	$FF		; Course 6.5
	FCB	$02
	FCB	$00		; Course 7.0
	FCB	$02
	FCB	$01		; Course 7.5
	FCB	$02
	FCB	$02		; Course 8.0
	FCB	$02
	FCB	$02		; Course 8.5
	FCB	$01

;0020

PNTR1	RMB	$2		; Temp pointer storage area
PNTR2	RMB	$2
PNTR3	RMB	$2
STORE1	RMB	$2		; Temp data storage area
STORE2	RMB	$2
STORE3	RMB	$2
STORE4	RMB	$2
STORE5	RMB	$2
CNTR	RMB	$1		; Temporary counter storage
CI	RMB	$1		; Crossing indicator
CF	RMB	$1		; Crossing flag
RNM	RMB	$2		; Random number storage
CQC	RMB	$1		; Current quadrant's contents
SLOSS	RMB	$1		; Sector location of space ship
SOLSS	RMB	$7		; Sector location of stars
SLSS	RMB	$1		; Sector location of space station
SLAS1	RMB	$1		; Sect. loc. of alien ship no. 1
SLAS2	RMB	$1		; Sect. loc. of alien ship no. 2
SLAS3	RMB	$1		; Sect. loc. of alien ship no. 3
DVME	RMB	$2		; Energy in main supply
DVSE	RMB	$2		; Energy in shields
VASE1	RMB	$2		; Alien ship no. 1 energy
VASE2	RMB	$2		; Alien ship no. 2 energy
VASE3	RMB	$2		; Alien ship no. 3 energy
CQLSS	RMB	$1		; Quadrant loc. of space ship
NTR	RMB	$1		; Number of torpedoes
NSS	RMB	$1		; Number of space stations
NAS	RMB	$1		; Number of alien ships
NSR	RMB	$1		; Number of star dates left
DGT1ST	RMB	$1		; Digit storage for
DGT2ND	RMB	$1		; Binary to decimal and
DGT3RD	RMB	$1		; Decimal to binary
DGT4TH	RMB	$1		; Conversion
DGT5TH	RMB	$1
;0056
PSTR1	FCB	$00		; Table of pointers
	FCB	$26		; Used for loading
PSTR51	FCB	$00		; The index register
	FCB	$2F
PSLOSS	FCB	$00
	FCB	$36
PSOLSS	FCB	$00
	FCB	$37
PSLSS	FCB	$00
	FCB	$3E
PSLAS1	FCB	$00
	FCB	$3F
PSLAS2	FCB	$00
	FCB	$40
PSLAS3	FCB	$00
	FCB	$41
PDVME	FCB	$00
	FCB	$42
PDVSE	FCB	$00
	FCB	$44
PVASE1	FCB	$00
	FCB	$46
PVASE2	FCB	$00
	FCB	$48
PVASE3	FCB	$00
	FCB	$4A
PCQLSS	FCB	$00
	FCB	$4C
PDG1ST	FCB	$00
	FCB	$51
PDG5TH	FCB	$00
	FCB	$55


	ORG	$0080

;0080
	HEX	8D 8A B1 A0 B0 B0 B0 A0
	HEX	B1 A0 B0 B0 B0 A0 B1 A0
	HEX	B0 B0 B0 A0 B1 A0 B0 B0
	HEX	B0 A0 B1 A0 B0 B0 B0 A0
	HEX	B1 A0 B0 B0 B0 A0 B1 A0
	HEX	B0 B0 B0 A0 B1 A0 B0 B0
	HEX	B0 A0 B1 00

; 00C0 through 00FF reserved for Galaxy Content Table

	ORG	$0100

;0100
	HEX	8D 8A C4 CF A0 D9 CF D5
	HEX	A0 D7 C1 CE D4 A0 D4 CF
	HEX	A0 C7 CF A0 CF CE A0 C1
	HEX	A0 D3 D0 C1 C3 C5 A0 D6
	HEX	CF D9 C1 C7 C5 BF A0 00
	HEX	8D 8A D9 CF D5 A0 CD D5
	HEX	D3 D4 A0 C4 C5 D3 D4 D2
	HEX	CF D9 A0 B2 B4 A0 C1 CC
	HEX	C9 C5 CE A0 D3 C8 C9 D0
	HEX	D3 A0 C9 CE A0 B2 B9 A0
	HEX	D3 D4 C1 D2 C4 C1 D4 C5
	HEX	D3 A0 D7 C9 D4 C8 A0 B5
	HEX	A0 D3 D0 C1 C3 C5 A0 D3
	HEX	D4 C1 D4 C9 CF CE D3 00
	HEX	8D 8A A0 AD B1 AD AD B2
	HEX	AD AD B3 AD AD B4 AD AD
;0180
	HEX	B5 AD AD B6 AD AD B7 AD
	HEX	AD B8 AD 00 8D 8A B8 A0
	HEX	A0 A0 A0 A0 A0 A0 A0 A0
	HEX	A0 A0 A0 A0 A0 A0 A0 A0
	HEX	A0 A0 A0 A0 A0 A0 A0 00
	HEX	A0 D3 D4 C1 D2 C4 C1 D4
	HEX	C5 A0 A0 B3 B0 B2 B1 00
	HEX	A0 C3 CF CE C4 C9 D4 C9
	HEX	CF CE A0 C7 D2 C5 C5 CE
	HEX	00 A0 D1 D5 C1 C4 D2 C1
	HEX	CE D4 A0 A0 B5 AC B8 00
	HEX	A0 D3 C5 C3 D4 CF D2 A0
	HEX	A0 A0 A0 B6 AC B1 00 A0
	HEX	C5 CE C5 D2 C7 D9 A0 A0
	HEX	A0 A0 B5 B0 B0 B0 00 A0
	HEX	D4 CF D2 D0 C5 C4 CF C5
;0200
	HEX	D3 A0 B1 B0 00 A0 D3 C8
	HEX	C9 C5 CC C4 D3 A0 A0 A0
	HEX	B0 B0 B0 B0 00 8D 8A C3
	HEX	CF CD CD C1 CE C4 BF 00
	HEX	8D 8A C3 CF D5 D2 D3 C5
	HEX	A0 A8 B1 AD B8 AE B5 A9
	HEX	BF A0 00 8D 8A D7 C1 D2
	HEX	D0 A0 C6 C1 C3 D4 CF D2
	HEX	A0 A8 B0 AE B1 AD B7 AE
	HEX	B7 A9 BF A0 00 8D 8A CC
	HEX	AB D2 AE A0 D3 C3 C1 CE
	HEX	A0 C6 CF D2 00 8D 8A CD
	HEX	C9 D3 D3 C9 CF CE A0 C6
	HEX	C1 C9 CC C5 C4 AC A0 D9
	HEX	CF D5 A0 C8 C1 D6 C5 A0
	HEX	D2 D5 CE A0 CF D5 D4 A0
;0280
	HEX	CF C6 A0 D3 D4 C1 D2 C4
	HEX	C1 D4 C5 D3 00 8D 8A CB
	HEX	C1 AD C2 CF CF CD AC A0
	HEX	D9 CF D5 A0 C3 D2 C1 D3
	HEX	C8 C5 C4 A0 C9 CE D4 CF
	HEX	A0 C1 A0 D3 D4 C1 D2 AE
	HEX	A0 D9 CF D5 D2 A0 D3 C8
	HEX	C9 D0 A0 C9 D3 A0 C4 C5
	HEX	D3 D4 D2 CF D9 C5 C4 00
	HEX	8D 8A D9 CF D5 A0 CD CF
	HEX	D6 C5 C4 A0 CF D5 D4 A0
	HEX	CF C6 A0 D4 C8 C5 A0 C7
	HEX	C1 CC C1 D8 D9 AC A0 D9
	HEX	CF D5 D2 A0 D3 C8 C9 D0
	HEX	A0 C9 D3 A0 CC CF D3 D4
	HEX	AE AE CC CF D3 D4 00 8D
;0300
	HEX	8A CC CF D3 D3 A0 CF C6
	HEX	A0 C5 CE C5 D2 C7 D9 A0
	HEX	B0 B1 B2 B9 00 8D 8A C4
	HEX	C1 CE C7 C5 D2 AD D3 C8
	HEX	C9 C5 CC C4 A0 C5 CE C5
	HEX	D2 C7 D9 A0 B0 B0 B0 00
	HEX	8D 8A D3 C8 C9 C5 CC C4
	HEX	A0 C5 CE C5 D2 C7 D9 A0
	HEX	D4 D2 C1 CE D3 C6 C5 D2
	HEX	A0 BD A0 00 8D 8A CE CF
	HEX	D4 A0 C5 CE CF D5 C7 C8
	HEX	A0 C5 CE C5 D2 C7 D9 00
	HEX	8D 8A D4 CF D2 D0 C5 C4
	HEX	CF A0 D4 D2 C1 CA C5 C3
	HEX	D4 CF D2 D9 A8 B1 AD B8
	HEX	AE B5 A9 A0 BA A0 00 8D
;0380
	HEX	8A C1 CC C9 C5 CE A0 D3
	HEX	C8 C9 D0 A0 C4 C5 D3 D4
	HEX	D2 CF D9 C5 C4 00 8D 8A
	HEX	D9 CF D5 A0 CD C9 D3 D3
	HEX	C5 C4 A1 A0 C1 CC C9 C5
	HEX	CE A0 D3 C8 C9 D0 A0 D2
	HEX	C5 D4 C1 CC C9 C1 D4 C5
	HEX	D3 00 8D 8A D3 D0 C1 C3
	HEX	C5 A0 D3 D4 C1 D4 C9 CF
	HEX	CE A0 C4 C5 D3 D4 D2 CF
	HEX	D9 C5 C4 00 8D 8A C3 CF
	HEX	CE C7 D2 C1 D4 D5 CC C1
	HEX	D4 C9 CF CE D3 AC A0 D9
	HEX	CF D5 A0 C8 C1 D6 C5 A0
	HEX	C5 CC C9 CD C9 CE C1 D4
	HEX	C5 C4 A0 C1 CC CC A0 CF
;0400
	HEX	C6 A0 D4 C8 C5 A0 C1 CC
	HEX	C9 C5 CE A0 D3 C8 C9 D0
	HEX	D3 00 8D 8A D4 D2 C1 C3
	HEX	CB C9 CE C7 BA A0 B3 AC
	HEX	B3 00 8D 8A C7 C1 CC C1
	HEX	D8 D9 A0 C4 C9 D3 D0 CC
	HEX	C1 D9 00 8D 8A D0 C8 C1
	HEX	D3 CF D2 A0 C5 CE C5 D2
	HEX	C7 D9 A0 D4 CF A0 C6 C9
	HEX	D2 C5 A0 BD A0 00 8D 8A
	HEX	C1 CC C9 C5 CE A0 D3 C8
	HEX	C9 D0 A0 C1 D4 A0 D3 C5
	HEX	C3 D4 CF D2 A0 B7 AC B8
	HEX	BA A0 00 C5 CE C5 D2 C7
	HEX	D9 A0 BD A0 B0 B5 B1 B8
	HEX	00 8D 8A CE CF A0 C1 CC
;0480
	HEX	C9 C5 CE A0 D3 C8 C9 D0
	HEX	D3 A1 A0 D7 C1 D3 D4 C5
	HEX	C4 A0 D3 C8 CF D4 00 8D
	HEX	8A C1 C2 C1 CE C4 CF CE
	HEX	A0 D3 C8 C9 D0 A1 A0 CE
	HEX	CF A0 C5 CE C5 D2 C7 D9
	HEX	A0 CC C5 C6 D4 00 8D 8A
	HEX	CE CF A0 D4 CF D2 D0 C5
	HEX	C4 CF C5 D3 00 8D 8A B1
	HEX	A0 B0 B0 B0 A0 B1 A0 B0
	HEX	B0 B4 A0 B1 A0 B0 B0 B0
	HEX	A0 B1 00 8D 8A CC C1 D3
	HEX	D4 00 8D 8A C3 C8 C9 C3
	HEX	CB C5 CE A1 00


	ORG	$0500

GALAXY	LDS	#$0EFF		; Set stack pointer to stack area
	JMP	START		; Jump to start of Galaxy program

MSG	LDAA	0,X		; Fetch indexed character
	BEQ	MSG1		; Character zero byte? Return
	JSR	PRINT		; No, output character
	INX			; Advance to next character
	BRA	MSG		; Continue printout
MSG1	RTS			; Output complete, return

ROTR4	ASRA			; Shift accumulator A right
ROTR3	ASRA
	ASRA
	ASRA
	RTS			; Return

RN	LDAA	RNM		; Random number subroutine
	ROLA			; Fetch random number and
	EORA	RNM		; Perform a series of
	RORA			; Operations to generate
	INC	RNM+$1		; A random value
	ADDA	RNM+$1
	BVC	SKIP
	DEC	RNM+$1
SKIP	STAA	RNM		; Store new random number
	RTS			; Return with random number in A

BINDEC	STX	PNTR1		; Save pointer temporarily
	LDX	PDG1ST		; Set pointer to start of decimal table
	CLR	0,X		; Clear digit table
	CLR	$01,X
	CLR	$02,X
	CLR	$03,X
	CLR	$04,X
	LDX	PNTR1		; Set pointer to binary value
	LDAA	0,X		; Get least significant half
	DECB			; Single precision?
	BEQ	BNDC		; Yes, most significant half = 0
	LDAB	$01,X		; No, get most significant half
BNDC	STAA	STORE1		; Store LS half in temporary storage
	STAB	STORE1+$1	; Store MS half in temporary storage+1
	LDX	#$1027		; Set up value for 10K
	STX	STORE2		; Store for subtract routine
	BSR	BD		; Calculate 5th digit
	STAB	DGT5TH		; Store value of 5th digit
	LDX	#$E803		; Binary value for 1K
	STX	STORE2		; Store for subtract routine
	BSR	BD		; Calculate 4th digit
	STAB	DGT4TH		; Store value of 4th digit
	LDX	#$6400		; Binary value for 100
	STX	STORE2		; Store for subtract routine
	BSR	BD		; Calculate 3rd digit
	STAB	DGT3RD		; Store value of 3rd digit
	LDAA	#$0A		; LS half value of 10 decimal
	STAA	STORE2		; Store for subtract routine
	BSR	BD		; Calculate 2nd digit
	STAB	DGT2ND		; Store value of 2nd digit
	LDAA	STORE1		; Get unit value
	STAA	DGT1ST		; Store value of 1st digit
	RTS			; Return to calling program

BD	CLRB			; Clear decimal digit counter
BD1	INCB			; Increment decimal digit
	LDAA	STORE1		; Fetch the least significant half
	SUBA	STORE2		; Subtract LS half of constant
	STAA	STORE1		; Save LS half of result
	LDAA	STORE1+$1	; Fetch most significant half
	SBCA	STORE2+$1	; Subtract MS half of constant
	STAA	STORE1+$1	; Save MS half of result
	BCC	BD1		; If greater than 0, continue subtraction
	LDAA	STORE1		; Else, restore binary value
	ADDA	STORE2		; Add LS half back to result
	STAA	STORE1		; Restore result in memory
	LDAA	STORE1+$1	; Fetch MS half of result
	ADCA	STORE2+$1	; Add MS half back to result
	STAA	STORE1+$1	; Restore result in memory
	DECB			; Decrement decimal digit to correct
	RTS			; Return

DCBN	CLR	STORE2+$1	; Clear MS half of result
	LDAA	DGT1ST		; Fetch units digit
	STAA	STORE2		; Store in work area
	LDAB	DGT2ND		; Fetch ten's digit
	BEQ	DC1		; Digit = 0? Yes, do 100's digit
	LDX	#$0A00		; Binary value of 10
	STX	STORE1		; To be added B times
	BSR	TOBN		; Add 10's digit
DC1	LDAB	DGT3RD		; Get 3rd digit
	BEQ	DC2		; Digit = 0? Yes, do 1000's digit
	LDX	#$6400		; Binary value of 100
	STX	STORE1		; To be added B times
	BSR	TOBN		; Add 100's digit
DC2	LDAB	DGT4TH		; Get 4th digit
	BEQ	DC3		; Digit = 0? Yes, finished
	LDX	#$E803		; Binary value of 1000
	STX	STORE1		; To be added B times
	BSR	TOBN		; Add 1000's digit
DC3	RTS			; Return, binary value in STORE1

TOBN	LDX	#STORE2		; Set pointer to binary value
	JSR	TO1		; Add value to STORE 1
	DECB			; Multiplier 0?
	BNE	TOBN		; No, continue
	RTS			; Yes, return

FNUM	LDAA	0,X		; Fetch ASCII character
	CMPA	#$B0		; Is character a number?
	BMI	FNUM1		; No, return with N flag set
	SUBA	#$BA		; Valid number, return with
	ADDA	#$80		; N flag reset
FNUM1	RTS

NWQD	LDX	PSOLSS		; Set pointer to star table
	LDAA	#$C0		; Clear code in A
	LDAB	#$0B		; Counter in B
CLR1	STAA	0,X		; Clear object location table
	INX			; Increment table pointer
	DECB			; Decrement counter
	BNE	CLR1		; Not done? Clear more

	LDAB	CQC		; Else get quadrant contents
	ANDB	#$07		; Get number of stars
	BEQ	NWQD1		; If none, check space station
	LDX	PSOLSS		; Set pointer to star table
	BSR	LOCSET		; Set up star locations

NWQD1	LDAA	CQC		; Get quadrant contents
	JSR	ROTR3		; Move to space station position
	TAB			; Set up for LOCSET
	ANDB	#$01		; Any space stations?
	BEQ	NWQD2		; No, check alien ships
	LDX	PSLSS		; Fetch space station table location
	BSR	LOCSET		; Set position if present

NWQD2	LDAA	CQC		; Get quadrant contents
	JSR	ROTR4		; Position alien count
	TAB			; Put count in B
	ANDB	#$03		; Mask for count
	BEQ	LLAS		; No aliens, skip positioning
	LDX	PSLAS1		; Set pointer to alien ship location
	BSR	LOCSET		; Assign alien ship locations

LDAS	BSR	LLAS		; Get random numbers
	LDX	PVASE1		; Pointer to alien ship no. 1 shields
	BSR	LAS		; Store alien ship no. 1 energy
	LDX	PVASE2		; Pointer to alien ship no. 2 shields
	BSR	LAS		; Store alien ship no. 2 energy
	LDX	PVASE3		; Pointer to alien ship no. 3 shields

LAS	STAA	0,X		; Store least significant half value
	ANDA	#$03		; Mask for most significant half
	STAA	$01,X		; Store most significant half
LLAS	JMP	RN		; Get random and return

LOCSET	STX	PNTR1		; Store table pointer
	BSR	LLAS		; Fetch random location
	ANDA	#$3F		; Mask off most significant bits
	BSR	MATCH		; New location match others?
	BEQ	LOCSET+$2	; Yes, find new location
	LDX	PNTR1		; Fetch table pointer
	STAA	0,X		; Store random location
	INX			; Table pointer to next object
	DECB			; Decrement object counter
	BNE	LOCSET		; Counter not =0, do next
	RTS			; Table complete, return

MATCH	LDX	PSOLSS		; Set pointer to star table
MATCH2	CMPA	0,X		; Same sector location?
	BEQ	MATCH1		; Yes, match, return
	INX			; Advance table pointer
	CPX	PDVME		; End of table?
	JMP	PATCH

MATCH1	RTS			; Return

QCNT	LDAA	CQLSS		; Fetch current quadrant
	ORAA	#$C0		; Form pointer to galaxy
	JSR	ATINX1		; Set pointer to quadrant
	LDAA	0,X		; Fetch quadrant contents
	STAA	CQC		; Store new quadrant contents
	RTS			; Return

LOAD	LDX	#$8813		; Store double precision value 5000
	STX	DVME		; In main energy store
	LDX	#$0000		; Set shields to zero
	STX	DVSE
	LDAA	#$0A		; Load ten torpedoes on board
	STAA	NTR
	RTS			; Return to main program

TIME	LDX	#$025D		; Stardates time run out - player loses

DONE	JSR	MSG		; Print message and start
	JMP	START ; GALAXY	; A new game

LOST	LDX	#$02C8		; Out of known galaxy
	BRA	DONE		; Player loses

WPOUT	LDX	#$028D		; Smashed into star
	BRA	DONE		; Player loses

EOUT	LDX	#$0497		; Out of energy
	BRA	DONE		; Abandon ship

DIGPRT	STX	PNTR1		; Save message digit location pointer
	STS	PNTR2		; Save stack pointer temporarily
	LDS	PNTR1		; Set stack pointer to 1st digit location
	LDX	PDG1ST		; Set index to 1st digit
DGPRT1	LDAA	0,X		; Get digit from storage
	INX			; Advance index to next digit
	ORAA	#$B0		; Form ASCII code
	PSHA			; Store in message
	DECB			; Decrement digit counter
	BNE	DGPRT1		; Not =0? Continue
	LDS	PNTR2		; Equals 0, restore stack pointer
	RTS			; And return

ROWSET	LDX	#$018F		; Set pointer to row message
	LDAA	#$A0		; Clear with ASCII space
RCLR	STAA	0,X		; Store space character
	INX			; Advance pointer
	CPX	#$01A7		; Message cleared?
	BNE	RCLR		; No, clear next

	TBA
	ORAA	#$B0		; Form ASCII code for row
	STAA	$018E		; Store in message
	DECB			; Set up row number for checkout
	LDX	PSLOSS		; Set pointer to object location table
	BSR	RWPNT		; Fetch space ship location
	BNE	STR		; In this row?
	LDAA	#$BC		; Yes, store space ship
	STAA	0,X		; Code for printout
	LDAA	#$AA
	STAA	$01,X
	LDAA	#$BE
	STAA	$02,X
STR	LDX	PSOLSS		; Set a star table pointer
	STX	PNTR2

STR1	BSR	RWPNT		; Is star in this row?
	BNE	NXSTR		; No, pointer to next star
	LDAA	#$AA		; Yes, store star code
	STAA	$01,X		; In proper location
NXSTR	INC	PNTR2+$1	; Increment star table pointer
	LDX	PNTR2		; Put new pointer in index
	CPX	PSLSS		; End of star table?
	BNE	STR1		; No, check next star
	BSR	RWPNT		; Space station in this row?
	BNE	AS		; No, look for alien ships
	LDAA	#$BE		; Yes, store space station
	STAA	0,X		; Code for printout
	LDAA	#$B1
	STAA	$01,X
	LDAA	#$BC
	STAA	$02,X
AS	LDX	PSLAS1		; Set alien ship table pointer
	STX	PNTR2
AS1	BSR	RWPNT		; Alien ship in this row?
	BNE	NXAS		; No, look for next ship
	LDAA	#$AB		; Yes, store code for alien
	STAA	0,X		; Ship printout
	STAA	$01,X
	STAA	$02,X
NXAS	INC	PNTR2+$1	; Advance alien ship table pointer
	LDX	PNTR2		; Get new pointer
	CPX	PDVME		; End of table?
	BNE	AS1		; No, try next alien
	LDX	#$018C		; Set pointer to print short range scan &
	JMP	MSG		; Return

RWPNT	LDAA	0,X		; Fetch entry location
	BMI	RWPNT1		; No, return
	JSR	ROTR3		; Position row entry
	ANDA	#$07		; Separate row entry
	CBA			; Is row current row?
	BNE	RWPNT1		; No, return
	LDAA	0,X		; Yes, fetch column location
	ANDA	#$07		; Separate column location
	STAA	STORE1		; Save column
	ASLA			; Multiply by two
	ADDA	STORE1		; Form pointer to row message
	ADDA	#$8F
	CLR	PNTR1		; Set up pointer storage to page 01
	INC	PNTR1
	JSR	ATINX		; Set index pointer from A
	CLRA			; Set zero flag
RWPNT1	RTS			; Return

QUAD	LDX	#$01D4		; Store temp, quadrant
	STX	PNTR1		; Message pointer
	LDX	#CQLSS		; Index to quadrant location storage
	BSR	TWO		; Put digits in message
	LDX	#$01C9		; Index to quadrant message
	JMP	MSG		; Print quadrant message and return

TWO	LDAA	0,X		; Fetch row and column
	TAB			; Save row and column
	LDX	PNTR1		; Get message pointer
T1	JSR	ROTR3		; Position row number
	ANDA	#$07		; Mask off other bits
	ADDA	#$B1		; Form ASCII code
	STAA	0,X		; Store in message
	ANDB	#$07		; Separate column number
	ADDB	#$B1		; Form ASCII code
	STAB	$02,X		; Store column in message
	RTS

NTN	LDAB	#$13		; Set counter 19 dashes
NT1	LDAA	#$8D		; Print carriage return
	BSR	NT3
	LDAA	#$8A		; Print line feed
	BSR	NT3
NT2	LDAA	#$AD		; ASCII code for dash
	BSR	NT3		; Print '-'
	DECB			; Decrement counter. =0?
	BNE	NT2		; No, print more dashes
	RTS			; Yes, return

NT3	JMP	PRINT

QDSET	TAB			; Fetch quadrant contents
	JSR	ROTR4		; Position alien ship number
	ANDA	#$03		; Mask alien ship number
	ORAA	#$B0		; Form ASCII digit
	STAA	0,X		; Store in message
	TBA			; Fetch quadrant contents
	JSR	ROTR3		; Position space ship number
	ANDA	#$01		; Mask space ship number
	ORAA	#$B0		; Form ASCII digit
	STAA	$01,X		; Store space ship in message
	ANDB	#$07		; Mask star number
	ORAB	#$B0		; Form ASCII digit
	STAB	$02,X		; Store in message
	RTS			; Return

CLC1	CLRA			; Clear column contents
	BRA	LR3		; Print 000 quadrant

CLC2	CLRA			; Clear column contents
	BRA	LR4		; Print 000 quadrant

LR5	JMP	ATINX1
LRR	ORAA	#$C0		; Set pointer to galaxy
	TAB
	STAA	STORE1		; Save pointer
	ANDB	#$07		; First column?
	BEQ	CLC1		; Yes, first column zero
	DECA			; No, back one column
	BSR	LR5		; Set quadrant pointer
	LDAA	0,X		; Fetch quadrant contents
LR3	LDX	#$04C9		; Set pointer to left quadrant
	BSR	QDSET		; Set quadrant contents
	LDAA	STORE1		; Get pointer
	BSR	LR5		; Set quadrant pointer
	LDAA	0,X		; Fetch quadrant contents
	LDX	#$04CF		; Set pointer to middle quadrant
	BSR	QDSET		; Set quadrant contents
	LDAA	STORE1		; Fetch quadrant location
	TAB
	ANDB	#$07		; Is quadrant in last column?
	CMPB	#$07
	BEQ	CLC2		; Yes, right column =0
	INCA			; Set to right quadrant
	BSR	LR5		; Set quadrant pointer
	LDAA	0,X		; Fetch quadrant contents
LR4	LDX	#$04D5		; Index to right quadrant
	JSR	QDSET		; Set quadrant contents
LRP	LDX	#$04C5		; Set pointer to long range row message
LR6	JMP	MSG		; Print and return

ELOS	STX	STORE3		; Save energy value
	LDX	#STORE3		; Set pointer to value to be converted
	LDAB	#$02		; Double precision conversion
	JSR	BINDEC		; Convert to BCD for message
	LDX	#$0313		; Set pntr to least signif digit of energy
	LDAB	#$04		; Set digit counter
	JSR	DIGPRT		; Put digit in message
	LDX	#$02FF		; Set pointer to energy loss message
	BSR	LR6		; Print energy toss message
	LDX	STORE3		; Restore value for routines
	STX	STORE1		; To follow

ELS1	BSR	CKSD		; Is shield energy sufficient?
	BCC	FMSD		; Yes, delete from shields and return
SDO1	LDX	DVSE		; Move shield energy to main storage
	STX	STORE1
	BSR	FMSD		; Remove energy from shields
	BSR	TOMN		; Move shield energy to main storage
	LDX	STORE3		; Fetch energy to be deleted
	STX	STORE1		; Store for routines

SDO	BSR	CKMN		; Energy enough?
	BCS	EOUT1		; No, ship out of energy
	BSR	FMMN		; Yes, take from main
	LDX	#$0315		; Print WARNING!
	BSR	LR6		; DANGER - SHIELD ENERGY 000
	LDAB	#$02		; Divide energy loss by 2 twice
	BSR	DVD		; To divide by 4
	BSR	CKMN		; Enough main energy for penalty?
	BCS	EOUT1		; No, out of energy message
	BRA	FMMN		; Yes, take penalty and return

CKSD	LDX	PDVSE		; Check shield energy level
	BRA	CK1		; Against requested level

CKMN	LDX	PDVME		; Check main energy level

CK1	LDAA	$01,X		; Fetch most significant half
	CMPA	STORE1+$1	; Is most significant half =0?
	BNE	ELOS1		; No, return with flags set up
CK2	LDAA	0,X		; If > , return with C flag set
	CMPA	STORE1		; If less than, C flag reset
	RTS			; Return

FMSD	LDX	PDVSE		; Set pointer to shield energy
	BRA	FM1		; Subtract energy from shields

FMMN	LDX	PDVME		; Set pointer to main storage

FM1	LDAA	0,X		; Fetch least significant half of energy
	SUBA	STORE1		; Subtract least significant half of loss
	STAA	0,X		; Return to storage
	LDAA	$01,X		; Fetch most significant half of energy
	SBCA	STORE1+$1	; Subtract most significant half of loss
	STAA	$01,X		; Return to storage
	RTS

TOSD	LDX	PDVSE		; Set pointer to shield energy
	BRA	TO1		; Add energy to shields

TOMN	LDX	PDVME		; Set pointer to main energy
TO1	LDAA	0,X		; Fetch least significant half of energy
	ADDA	STORE1		; Add least significant half of loss
	STAA	0,X		; Return to storage
	LDAA	$01,X		; Fetch most significant half of energy
	ADCA	STORE1+$1	; Add most significant half of loss
	STAA	$01,X		; Return to storage
	RTS

DVD	TSTB			; Divide the double
	ROR	STORE1+$1	; Precision value
	ROR	STORE1		; By two the number
	DECB			; Of times indicated in B
	BNE	DVD
ELOS1	RTS			; Return

EOUT1	JMP	EOUT

ELOM	BSR	CKMN		; Enough energy in main?
	BCC	FMMN		; Yes, take from main and return
	LDX	STORE1		; No, save value of energy loss
	STX	STORE3
	JMP	SDO1		; Transfer shield energy and try again

EIN	LDX	PDG5TH		; Set pointer to start of digit store
	CLR	0,X		; Clear sign indicator
	JSR	INPUT		; Get first character
	CMPA	#$AD		; Negative sign?
	BNE	EN2		; No, check digit
	STAA	0,X		; Make negative indicator not =0
EN1	JSR	INPUT		; Get next character
EN2	DEX			; Advance storage pointer
	STAA	0,X		; Store digit
	JSR	FNUM		; Valid digit?
	BMI	EIN1		; No, return with N flag set
	LDAA	0,X		; Yes, fetch digit
	ANDA	#$0F		; Mask off ASCII bits
	STAA	0,X		; Save BCD value
	CPX	PDG1ST		; End of input?
	BNE	EN1		; No, fetch next digit
EIN1	RTS			; Yes, return

DLET	LDAA	#$C0		; Load with clear character
	STAA	0,X		; Clear object from table
	STX	PNTR2		; Save table location
	LDAA	CQLSS		; Get quadrant location
	ADDA	#$C0		; Form galaxy table pointer
	JSR	ATINX1		; Place pointer in index
	STX	PNTR3		; Set table pointer
	LDX	PNTR2		; Fetch table location
	JSR	COMPAR		; Space station hit?
	BNE	DLAS		; No, delete alien ship
	LDX	PNTR3		; Fetch galaxy pointer
	LDAA	0,X		; Get quadrant contents
	ANDA	#$37		; Delete space station
	STAA	0,X		; Restore quadrant in galaxy
	STAA	CQC		; Place new contents
	DEC	NSS		; Decrement number of space stations
	BNE	DLET1		; If more left, return
	LDX	#$04DB		; If number of space stations =0,
	JMP	MSG		; Print warning message & return

DLAS	LDX	PNTR3		; Fetch galaxy pointer
	LDAA	0,X		; Get quadrant contents
	SUBA	#$10		; Delete 1 alien ship from quadrant
	STAA	0,X		; Restore to galaxy
	STAA	CQC		; Save new contents
	DEC	NAS		; Decrement number of alien ships
	BNE	DLET1		; More aliens, return
	LDX	#$03D4		; All aliens destroyed!
	JMP	DONE		; Print CONGRATULATIONS,

DLET1	RTS			; Start new game

DRCT	JSR	INPUT		; Input first course number
	CMPA	#$B1		; Is input less than 1?
	BCS	ZRET		; Yes, illegal input
	CMPA	#$B9		; Is input greater than 8?
	BCC	ZRET		; Yes, illegal input
	ANDA	#$0F		; No, mask off ASCII bits
	ASLA			; If good times 2
	TAB			; And save in temporary storage
	LDAA	#$AE		; Print decimal point
	JSR	PRINT
	JSR	INPUT		; Input second course number
	CMPA	#$B0		; Is digit zero?
	BEQ	CR1		; Yes, continue process
	CMPA	#$B5		; No, is digit 5?
	BNE	ZRET		; No, return with Z flag set

CR1	ANDA	#$01		; Mask off all but first bit
	ABA			; Add first number input
	ASLA			; And form pointer to course table
	SUBA	#$04
	STAA	PNTR1+$1	; Save pointer in temporary storage
	CLRA
	STAA	PNTR1		; Clear least significant byte of pointer
	INCA			; Reset Z Rag
	RTS			; Before returning

ZRET	CLRA			; Set Z flag
	RTS			; And return

ACTV	STS	PNTR2		; Save stack pointer temporarily
	LDS	PSTR51		; Set stack to storage area
	LDAA	SLOSS		; Get present location
	TAB			; Save temporarily
	ANDB	#$07		; Mask out column
	ASLB			; Multiply by 2
	PSHB			; Store adjusted column
	ANDA	#$38		; Mask out row
	LSRA			; Set up times 2 value
	LSRA
	PSHA			; Save adjusted row

	LDX	PNTR1		; Get displacement table pointer
	LDAA	0,X		; Get column movement
	PSHA			; Store column displacement
	LDAA	$01,X		; Get row movement
	PSHA			; Store row displacement
	LDS	PNTR2		; Restore stack pointer
	RTS

TRK	CLR	CF		; Clear quadrant crossing flag
	LDAA	STORE5+$1	; Get adjusted column
	ADDA	STORE4+$1	; Add column move
	STAA	STORE5+$1	; Save temporarily current column
	BPL	NOBK		; If no left crossing, branch
	ANDA	#$0F		; Left crossing correction
	STAA	STORE5+$1	; And save new adjusted column
	INC	CF		; Indicate left crossing
	LDAA	CQLSS		; And decrement current column
	ANDA	#$07		; is CQC=O?
	BEQ	TRK1		; Yes, return with Z set
	DEC	CQLSS		; No, decrement CQC
	BRA	RMV		; Do row move

NOBK	CMPA	#$10		; Quadrant crossing right
	BCS	RMV		; No, do row move
	ANDA	#$0F		; Yes, correct and
	STAA	STORE5+$1	; Save new adjusted column
	INC	CF		; Indicate crossing by making
				; Crossing flag non-zero
	LDAA	CQLSS		; Fetch current quadrant location
	ANDA	#$07		; Separate column entry
	INCA			; Increment column entry
	CMPA	#$08		; Move out of galaxy
	BEQ	TRK1		; Yes, return with flags set
	INC	CQLSS		; No, increment quadrant column

RMV	LDAA	STORE5		; Get adjusted row value
	ADDA	STORE4		; Add movement
	STAA	STORE5		; Save new adjusted row
	BPL	NOUP		; If not up, jump
	ANDA	#$0F		; Move up one quadrant, correct
	STAA	STORE5		; And save new adjusted value
	INC	CF		; Make crossing flag non-zero
	LDAA	CQLSS		; Decrement quadrant row
	TAB			; Save temporarily
	ANDA	#$38		; Is quadrant row =0?
	BEQ	TRK1		; Yes, return with Z flag set
	SUBB	#$08		; No, decrement current quadrant row
	STAB	CQLSS		; Save new current quadrant
	BRA	CKX		; Then perform crossing logic

NOUP	CMPA	#$10		; Quadrant crossing down?
	BCS	CKX		; No, check for crossing flag
	ANDA	#$0F		; Yes, correct and
	STAA	STORE5		; Save new adjusted row
	INC	CF		; Indicate crossing
	LDAA	CQLSS		; Then increment quadrant row
	TAB			; Save temporarily
	ANDA	#$38		; Separate row entry
	ADDA	#$08		; Increment row value
	CMPA	#$40		; Out of galaxy?
	BEQ	TRK1		; Yes, return with Z flag set
	ADDB	#$08		; No, increment row
	STAB	CQLSS		; Save new current quadrant

CKX	BNE	TRK1		; Return with Z flag reset
	LDAA	#$01		; If not, reset it
TRK1	RTS

RWCM	LDAA	STORE5+$1	; Fetch adjusted column
	LSRA			; Adjust position
	ANDA	#$07		; Form column value
	LDAB	STORE5		; Fetch row
	ASLB			; Position row value
	ASLB
	ANDB	#$38		; Form row value
	ABA			; Form row and column byte
	RTS			; Return

ATINX1	CLR	PNTR1		; Clear MS. half of pointer for page 00
ATINX	STAA	PNTR1+$1	; Store A in least significant half of pntr
	LDX	PNTR1		; Load pointer into index register
	RTS

COMPAR	STX	PNTR1		; Store index value
	LDAA	PNTR1+$1	; Fetch low portion of the address
	CMPA	#$3E		; Set flags for address relative to SLSS
	RTS			; Return with results

WASTE	LDAA	CQC		; Fetch quadrant contents
	ANDA	#$30		; Mask out alien ship count
	BEQ	WASTE1		; If none, wasted shot
	RTS			; Otherwise, return

WASTE1	PULB			; Remove unwanted address
	PULB			; From stack
	LDX	#$0479		; Set pointer to wasted shot message
	JSR	MSG		; Print message
	JMP	CMND		; Input new command

START	LDX	#$0100		; Set pointer to initial message
	JSR	MSG		; Print introduction

	JSR	RN		; Increment random number
	JSR	INPUT		; Input character
	STAA	RNM+$1		; Store input to randomize
	CMPA	#$CE		; Character N? Yes, stop game
	BNE	OVER		; No, set up galaxy

	LDX	#$04E2		; Print "CHICKEN"
	JSR	MSG		
	NOP			; User defined
	NOP			; End of program
	NOP
OVER	LDAB	#$C0		; Set pointer to galaxy storage
	STAB	STORE1		; Save in temporary storage

GLXSET	JSR	RN		; Fetch random number
	ANDA	#$7F		; Form pointer to
	LDAB	#$0F		; Galaxy table from
	STAB	PNTR1		; Random number
	JSR	ATINX		; Set index to galaxy table
	LDAB	0,X		; Get galaxy entry
	LDAA	STORE1
	JSR	ATINX1		; Set index to galaxy content table
	STAB	0,X		; Store quadrant contents
	INC	STORE1		; Galaxy contents complete?
	BNE	GLXSET		; No, fetch more sectors

GLXCK	CLR	NSS		; Clear space station count
	CLR	NAS		; Clear alien ship count
	LDX	#$00C0		; Pointer to galaxy content table

GLXCK1	LDAA	0,X		; Fetch quadrant contents
	TAB			; Save in 'B' accumulator
	ANDA	#$08		; Mask space station
	ADDA	NSS		; Add to space station total
	STAA	NSS		; Save space station total
	ANDB	#$30		; Mask alien ship
	LSRB			; Position
	LSRB
	ADDB	NAS		; Add to alien ship total
	STAB	NAS		; Save alien ship total
	INX			; Increment galaxy content pointer
	CPX	#$0100		; End of table?
	BNE	GLXCK1		; No, continue adding
	LDAA	NSS		; Fetch space station total
	LSRA			; Position total to right
	LSRA
	LSRA
	STAA	NSS		; Store total
	CMPA	#$07		; Too many space stations?
	BPL	SSPLS		; Yes, delete 1
	CMPA	#$02		; Too few?
	BPL	CAS		; No, O.K., check alien ships

SSMNS	LDAB 	#$08		; Yes, form mask to
	STAB	STORE1		; Add one space station
	BRA	MNS

SSPLS	LDAB	#$F7		; Form and store mask to
	STAB	STORE1		; Delete one space station
	BRA	PLS

ASPLS	LDAB	#$CF		; Form mask to delete
	STAB	STORE1		; One alien ship
PLS	JSR	RN		; Fetch random number
	ORAA	#$C0		; Form galaxy table pointer
	JSR	ATINX1		; Place pointer in index
	LDAA	STORE1		; Fetch mask
	ANDA	0,X		; Delete from galaxy
PLS1	STAA	0,X		; Store new quadrant contents
	JMP	GLXCK		; Check galaxy again

ASMNS	LDAB	#$10		; Form mask to add
	STAB	STORE1		; One alien ship

MNS	JSR	RN		; Fetch random number
	ORAA	#$C0		; Form galaxy table pointer
	JSR	ATINX1		; Place pointer in index
	LDAA	STORE1		; Fetch mask
	ORAA	0,X		; Add one alien ship to quadrant
	BRA	PLS1		; Check galaxy again

CAS	LDAA	NAS		; Fetch alien ship total
	LSRA			; Position
	LSRA
	STAA	NAS		; Save total
	CMPA	#$20		; Too many alien ships?
	BPL	ASPLS		; Yes, delete one alien ship
	CMPA	#$0A		; Too few?
	BMI	ASMNS		; Yes, add one alien ship
	LDAA	#$05		; Set up five more stardates
	ADDA	NAS		; Than alien ships
	STAA	NSR		; Save number of stardates
	LDX	#NSR		; Convert binary value
	LDAB	#$01		; Set precision counter
	JSR	BINDEC		; Convert stardate value
	LDX	#$014E		; Pointer to stardate count
	LDAB	#$02		; Set precision counter
	JSR	DIGPRT		; Put digits in starting message
	LDX	#NAS		; Pointer to alien ship value
	LDAB	#$01		; Set precision counter
	JSR	BINDEC		; Convert alien ship value
	LDX	#$013C		; Pointer to alien ship count
	LDAB	#$02		; Set precision counter
	JSR	DIGPRT		; Put digits in starting message
	LDAA	NSS		; Get number of space stations
	ORAA	#$B0		; Form ASCII digit
	STAA	$015F		; Store in starting message
	LDX	#$0128		; Pointer to start of message
	JSR	MSG		; Print starting message
	JSR	RN		; Fetch starting quadrant
	ANDA	#$3F		; Mask off MSB's
	STAA	CQLSS		; Save current quadrant location
	JSR	QCNT		; Fetch current quadrant contents
	JSR	LOAD		; Set initial conditions
	JSR	NWQD		; Set quadrant contents location
	LDX	PSLOSS		; Pointer to sector location storage
	LDAB	#$01		; Set precision counter
	JSR	LOCSET		; Set initial space ship location

SRSCN	LDX	#$0170		; Set pointer for short range scan
	JSR	MSG		; Print initial row
	LDAB	#$01		; Set row number one
	JSR	ROWSET		; Set up row for printout
	LDAA	#$32
	SUBA	NSR		; Calculate stardate number
	STAA	STORE1		; Save temporarily
	LDX	PSTR1		; Set pointer to binary value
	LDAB	#$01		; Set precision counter
	JSR	BINDEC		; Convert to current stardate
	LDX	#$01B6		; Set pointer to stardate message
	LDAB	#$02		; Set counter to number of digits
	JSR	DIGPRT		; Put digits in stardate message
	LDX	#$01A8		; Set pointer to message
	BSR	SRSCN1		; Print stardate message

	LDAB	#$02		; Set row number two
	JSR	ROWSET		; Set up row for printout
	LDAA	CQC		; Fetch current quadrant contents
	LDX	#$01C3		; Set pointer to condition message
	ANDA	#$30		; Alien ship in quadrant?
	BNE	RED		; Yes, condition red

	LDAA	#$C7		; No, condition green
	STAA	0,X		; Fill in 'GREEN' in
	LDAA	#$D2		; Condition message
	STAA	$01,X
	LDAA	#$C5
	STAA	$02,X
	LDAA	#$C5
	STAA	$03,X
	LDAA	#$CE
	STAA	$04,X
	BRA	CND		; Output condition message

SRSCN1	JMP	MSG

RED	LDAA	#$D2		; Condition red
	STAA	0,X		; Fill in 'RED' in
	LDAA	#$C5		; Condition message
	STAA	$01,X
	LDAA	#$C4
	STAA	$02,X
	CLR	$03,X

CND	LDX	#$01B8		; Set pointer to condition message
	BSR	SRSCN1		; Print condition message

	LDAB	#$03		; Set row number three
	JSR	ROWSET		; Set up for printout
	JSR	QUAD		; Print current quadrant

	LDAB	#$04		; Set row number four
	JSR	ROWSET		; Set up for printout
	LDX	#$01E3		; Set up sector message
	STX	PNTR1		; Pointer in storage
	LDX	PSLOSS		; Pointer to current sector
	JSR	TWO		; Put two digits in message
	LDX	#$01D8		; Set pointer to sector message
	BSR	SRSCN1		; Print sector message

	LDAB	#$05		; Set row number 5
	JSR	ROWSET		; Set up row for printout
	LDX	PDVME		; Set pointer to main energy

	LDAB	#$02		; Set precision counter
	JSR	BINDEC		; Convert to decimal
	LDX	#$01F5		; Message pointer
	LDAB	#$04		; Counter for four digits
	JSR	DIGPRT		; Put digits in message
	LDX	#$01E7		; Set pointer to energy message
	BSR	SRSCN1		; Print energy message
	LDAB	#$06		; Set row number six
	JSR	ROWSET		; Set up for printout

	LDX	#NTR		; Pointer to torpedo count
	LDAB	#$01		; Precision =1
	JSR	BINDEC		; Convert to decimal

	LDX	#$0203		; Set pointer to torpedo message
	LDAB	#$02		; Counter to number of digits
	JSR	DIGPRT		; Put number of torpedoes in message
	LDX	#$01F7		; Print torpedo message
	JSR	SRSCN1

	LDAB	#$07		; Set row number seven
	JSR	ROWSET		; Set up row for printout
	LDX	PDVSE		; Set pointer to shield energy
	LDAB	#$02		; And set precision for
	JSR	BINDEC		; Binary to decimal conversion
	LDX	#$0213		; Set pointer to shield energy message
	LDAB	#$04		; Set digit count
	JSR	DIGPRT		; Put digits in memory
	LDX	#$0205		; Set pointer to shield message
	JSR	MSG		; Print shield message
	LDAB	#$08		; Set row number eight
	JSR	ROWSET		; Set up row for printout
	LDX	#$0170		; Set pointer to final row
	JSR	MSG		; Print final row

CMND	LDX	#$0A00		; Delete ten units of energy
	STX	STORE1		; For each command
	JSR	ELOM
	DEC	RNM+$1		; Randomize random number

CMD	LDX	#$0215		; Set pointer to command message
	JSR	MSG		; Request command input
	JSR	INPUT		; Input command
	CMPA	#$B0		; Ship movement?
	BNE	NCRSE		; No, try next
	JMP	CRSE		; Yes, input course

NCRSE	CMPA	#$B1		; Short range scan?
	BNE	NSRSCN		; No, try next
	JMP	SRSCN		; Yes, display quadrant

NSRSCN	CMPA	#$B2		; Long range scan?
	BNE	NLRSCN		; No, try next
	JMP	LRSCN		; Yes, print long range scan

NLRSCN	CMPA	#$B3		; Galaxy printout?
	BNE	NGXPRT		; No, try next
	JMP	GXPRT		; Yes, print galaxy

NGXPRT	CMPA	#$B4		; Shield energy?
	BNE	NSHEN		; No, try next
	JMP	SHEN		; Yes, adjust shields

NSHEN	CMPA	#$B5		; Phasor control?
	BNE	NPHSR		; No, try next
	JMP	PHSR		; Yes, fire phasors

NPHSR	CMPA	#$B6		; Torpedo shot?
	BNE	CMD		; No, illegal command, try again
	JMP	TRPD		; Yes, shoot torpedo

LRSCN	LDX	#$024D		; Set pointer to long range message
	JSR	MSG		; Print long range scan
	JSR	QUAD		; Print quadrant location
	BSR	LRSCN1		; Print row of dashes
	LDAA	CQLSS		; Fetch current quadrant
	TAB			; Save temporarily
	ANDB	#$38		; Current quadrant in row no. 1?
	BEQ	RWC1		; Yes, top row clear
	SUBA	#$08		; Indicate row -1
	JSR	LRR		; Set up and print top row
LR1	BSR	LRSCN1		; Print separating row
	LDAA	CQLSS		; Fetch current quadrant
	JSR	LRR		; Set up and print middle row
	BSR	LRSCN1		; Print separating row
	LDAA	CQLSS		; Fetch current quadrant
	CMPA	#$38		; Current quadrant in row no. 8?
	BCC	RWC2		; Yes, bottom row clear
	ADDA	#$08		; No, set quadrant row +1
	JSR	LRR		; Set and print bottom row
LR2	BSR	LRSCN1		; Print bottom border
	JMP	CMND		; Input next command
LRSCN1	JMP	NTN

RWC1	BSR	RWC		; Print clear row
	JMP	LR1		; Continue long range scan

RWC2	BSR	RWC		; Print clear row
	JMP	LR2		; Finish long range scan

RWC	LDX	#$04C9		; Set pointer to left quadrant
	CLRA			; Set zero entry
	JSR	QDSET		; Set quadrant contents
	LDX	#$04CF		; Set pointer to middle quadrant
	CLRA			; Set zero entry
	JSR	QDSET		; Set quadrant contents
	LDX	#$04D5		; Set pointer to right quadrant
	CLRA			; Set zero entry
	JSR	QDSET		; Set quadrant contents
	JMP	LRP		; Print long range row

GXPRT	LDX	#$0422		; Print GALAXY DISPLAY
	JSR	MSG
	LDAB	#$31
	JSR	NT1		; Print border

	LDX	#$00C0		; Set pointer to galaxy
	STX	PNTR1		; Store temporarily
GL1	LDX	#$0084		; Set up message pointer
	STX	PNTR2		; Store temporarily
GL2	LDX	PNTR1		; Fetch galaxy pointer
	CPX	#$0100		; End of printout?
	BEQ	GL3		; Yes, input next command
	LDAA	0,X		; Get quadrant contents
	INX			; Advance pointer
	STX	PNTR1		; Restore to memory
	LDX	PNTR2		; Set up message pointer
	JSR	QDSET		; Set quadrant contents in MSG
	LDAA	#$06
	ADDA	PNTR2+$1	; Advance message pointer
	STAA	PNTR2+$1	; Restore to memory
	CMPA	#$B4		; This end of line?
	BNE	GL2		; No, set next quadrant

	LDX	#$0080		; Print current line of galaxy
	JSR	MSG
	LDAB	#$31
	JSR	NT1		; Print border
	BRA	GL1		; Set up next line

GL3	JMP	CMND		; End, return to command input

SHEN	LDX	#$0330		; Print SHIELD ENERGY
	JSR	MSG		; TRANSFER=
	JSR	EIN		; Input energy amount
	BMI	SHEN		; Invalid input, try again

	JSR	DCBN		; Convert to binary
	LDX	STORE2		; Transfer binary amount for
	STX	STORE1		; Routines to follow
	LDAA	DGT5TH		; Test if have '-' sign
	BEQ	POS		; No, transfer main to shields
	JSR	CKSD		; Check shield energy
	BCS	NE		; Not enough, print message
	JSR	FMSD		; Subtract from shields
	JSR	TOMN		; Add to main
	BRA	SHEN1		; Input new command

POS	JSR	CKMN		; Check main energy
	BCS	NE		; Not enough, display message
	JSR	FMMN		; Subtract from main
	JSR	TOSD		; Add to shields
	BRA	SHEN1		; Input new command


NE	LDX	#$034C		; Print NOT ENOUGH
	JSR	MSG		; ENERGY
SHEN1	JMP	CMND	 	; Input new command

CRSE	LDX	#$0220		; Set pointer to course message
	JSR	MSG		; Request course input
	JSR	DRCT		; Input course direction
	BEQ	CRSE		; Input error, try again

WRP	LDX	#$0233		; Index to WARP message
	JSR	MSG		; Request warp input
	JSR	INPUT		; Input warp factor digit 1
	CMPA	#$B0		; Is digit less than 0?
	BCS	WRP		; Yes, request input again
	CMPA	#$B8		; Is digit greater than 7?
	BCC	WRP		; Yes, try again
	ANDA	#$07		; Mask off ASCII code
	ASLA			; Position to 3rd bit
	ASLA
	ASLA
	TAB			; Store temporarily in B
	LDAA	#$AE		; Print decimal point
	JSR	PRINT
	JSR	INPUT		; Input 2nd warp factor digit
	CMPA	#$B0		; Is digit less than 0?
	BCS	WRP		; Yes, request input again
	CMPA	#$B8		; Is input greater than 7?
	BCC	WRP		; Yes, no good, try again
	ANDA	#$07		; Mask off ASCII code
	ABA			; Add warp digit 1
	BEQ	WRP		; If 0, no good, try again
	STAA	CNTR		; Store warp factor as counter
	JSR	ACTV		; Fetch adjusted row and column
	CLR	CI		; Clear crossing indicator

MOV	JSR	TRK		; Track one sector
	BNE	MOV1		; Out of galaxy? No
	JMP	LOST		; Yes, lost in space

MOV1	LDAA	CF		; No, quadrant crossed?
	BEQ	CLSN		; No, check for collision
	STAA	CI		; Make crossing indicator non-zero
	LDX	#$1900		; Delete 25 units of energy
	STX	STORE1		; From main supply
	JSR	ELOM
	JSR	QCNT		; Fetch new quadrant contents
	JSR	NWQD		; Set up new quadrant

CLSN	JSR	RWCM		; Form row and column byte
	JSR	MATCH		; Collision?
	BNE	MVDN		; No, complete move
	JSR	COMPAR		; What was hit?
	BEQ	SSOUT		; Space ship collision!
	BCC	ASOUT		; Alien ship collision!
	LDAA	CI		; Star, initial quadrant?
	BNE	MVDN		; No, ignore collision
	JMP	WPOUT		; Yes, ship wiped out!

MVDN	DEC	CNTR		; Decrement warp factor
	BNE	MOV		; Not zero, continue move
	LDAA	CI		; Fetch crossing indicator
	BEQ	NOX		; Quadrant not crossed, continue move
	DEC	NSR		; Decrement stardate counter
	BNE	NOX		; Not zero, continue
	JMP	TIME		; Ran out of time, start new game

NOX	JSR	RWCM		; Form row and column byte
	STAA	SLOSS		; Save new sector
	JSR	MATCH		; Was last move a collision?
	BNE	NOX1		; No, check for docking
	JSR	CHNG		; Yes, change object location

NOX1	JSR	DKED		; Check for docking
	JMP	SRSCN		; Do short range scan

SSOUT	LDAA	CI		; Test if initial quadrant
	BNE	MVDN		; No, no loss
	JSR	DLET		; Remove space station from galaxy
	LDX	#$03BA		; Indicate loss of space station
	JSR	MSG
	LDX	#$5802		; Then delete 600 units
	STX	STORE1		; Of energy from sheilds
SSO1	JSR	ELOS		; Delete energy
	JMP	MVDN		; Finish move

ASOUT	LDAA	CI		; Test if initial quadrant
	BNE	MVDN		; No, no loss
	JSR	DLET		; Yes, delete alien ship
	LDX	#$037F		; Print alien ship destroyed message
	JSR	MSG
	LDX	#$DC05		; Delete 1500 units of
	STX	STORE1		; Energy from space ship
	BRA	SSO1

CHNG	LDAB	#$01		; Set number of objects counter
	JMP	LOCSET		; Move object and return

DKED	LDAA	SLSS		; Is space station in quadrant?
	BPL	DKED1		; Yes, continue
	RTS			; No, complete move

DKED1	ANDA	#$38		; Mask out row
	LDAB	SLOSS		; Fetch space ship location
	ANDB	#$38		; Mask out row
	CBA			; Same row?
	BNE	DKED2		; No, return
	LDAA	SLSS		; Fetch space station location
	LDAB	SLOSS		; Fetch space ship location
	ADDB	#$01		; Docked on right?
	CBA
	BEQ	DKED3		; Yes, reload
	SUBB	#$02		; No, check left docking
	CBA			; Docked on left?
	BEQ	DKED3		; Yes, reload
DKED2	RTS			; No, return

DKED3	JMP	LOAD		; Reload space ship and return

TRPD	LDAA	NTR		; Any torpedoes left?
	BEQ	NTPD		; No, print no torpedo message
	DEC	NTR		; Yes, delete one
	LDX	#$FA00		; Setup 250 units
	STX	STORE1		; Of energy to delete
	JSR	CKMN		; Enough in main supply?
	BCC	TRPD1		; Yes, continue
	JMP	NE		; No, report not enough energy

TRPD1	JSR	FMMN		; Delete from main
TR1	LDX	#$0360		; Print 'TORPEDO TRAJECTORY ='
	BSR	TR3
	JSR	DRCT		; Input direction
	BEQ	TR1		; Input invalid, try again
	JSR	ACTV		; Form adjusted row and column
	LDAA	CQLSS		; Save current quadrant
	STAA	CNTR		; Location in temporary storage

TR2	JSR	TRK		; Move torpedo one sector
	BEQ	QOUT		; Out of galaxy? Yes, missed
	LDAA	CF		; Quadrant crossed?
	BNE	QOUT		; Yes, missed
	JSR	RWCM		; No, form row and column byte
	TAB
	STAA	STORE1		; Move to temporary storage
	LDX	#$041E		; Set up tracking message
	JSR	T1		; Print TRACKING: R,C
	LDX	#$0412		; Form message pointer
	BSR	TR3		; Print message

	LDAA	STORE1		; Fetch row and column byte
	JSR	MATCH		; Torpedo hit anything?
	BEQ	HIT		; Yes, analyze
	JMP	TR2		; No, continue tracking

HIT	JSR	COMPAR		; What was hit? A star?
	BCS	QOUT		; Yes, missed alien ship
	BEQ	SSTA		; Space station? Yes, delete space station
	JSR	DLET		; No, delete alien ship
	LDX	#$037F		; Print alien ship hit message
	BSR	TR3
	BRA	CMND1		; Input new command
TR3	JMP	MSG		; Print message and return

SSTA	JSR	DLET		; Delete space station from galaxy
	LDX	#$03BA		; Print message of loss of
	BSR	TR3		; Space station
QOUT	LDAA	CNTR		; Restore current quadrant location
	STAA	CQLSS		; of the space ship
	JSR	WASTE		; See if any alien ships in quadrant
	LDX	#$0396
	JSR	MSG		; No, print missed message
	LDX	#$C800		; Set up loss of 200 units of energy
	JSR	ELOS		; Due to alien ship retaliating
	BRA	CMND1		; Input new command
NTPD	LDX	#$04B6		; Print no torpedo message
	JSR	MSG
CMND1	JMP	CMND		; Input new command

PHSR	LDX	#$0433		; Print 'PHASOR ENERGY TO FIRE='
	BSR	TR3
	JSR	EIN		; Input energy amount
	BMI	PHSR		; Input error? Try again
	JSR	DCBN		; Convert decimal to binary
	LDX	STORE2		; Move binary energy value to proper
	STX	STORE1		; Storage for ELOM routine
	JSR	ELOM		; Delete energy from main supply
	JSR	WASTE		; Check for presence of alien ships
PHS1	JSR	ROTR4		; Position alien ship number
	SUBA	#$01		; 1 alien ship, full energy
	BEQ	PH1		; 2 alien ships, half energy
	TAB			; 3 alien ships, 1/4 energy
	JSR	DVD		; Divide energy accordingly

PH1	LDX	STORE1		; Fetch energy amount
	STX	STORE4		; Save energy amount
	LDX	PVASE1		; Fetch pointer to alien ship no. 1 energy
	STX	PNTR3		; Save pointer for ASPH routine
	LDX	PSLAS1		; Pointer to alien ship no. 1 position
	JSR	ASPH		; Fire phasor at alien ship no. 1
	LDX	PVASE2		; Fetch pointer to alien ship no. 2 energy
	STX	PNTR3		; Save pointer for ASPH routine
	LDX	PSLAS2		; Pointer to alien ship no. 2 position
	JSR	ASPH		; Fire phasor at alien ship no. 2
	LDX	PVASE3		; Fetch pointer to alien ship no. 3 energy
	STX	PNTR3		; Save pointer for ASPH routine
	LDX	PSLAS3		; Pointer to alien ship no. 3 position
	JSR	ASPH		; Fire phasor at alien ship no. 3
	BRA	CMND1		; Input new command

ASPH	STX	PNTR2		; Save position pointer
	LDAA	0,X		; Fetch alien ship location
	BPL	ASPH1		; Any alien ship in location?
	RTS			; No, return

ASPH1	LDX	STORE4		; Restore energy value
	STX	STORE1		; Move to temporary storage
	LDX	#$0465		; Set up pointers
	STX	PNTR1		; To fill in alien ship location
	LDX	PNTR2		; In message
	JSR	TWO		; Set sector coordinates
	LDX	#$044E		; Print 'ALIEN SHIP AT SECTOR X,Y:'
	JSR	MSG
	LDX	#SLOSS		; Fetch sector location of the space ship
	BSR	SPRC		; Separate row and column values
	STAA	STORE2		; Save row of space ship
	STAB	STORE2+$1	; Save column of space ship
	LDX	PNTR2		; Fetch pointer to alien ship location
	BSR	SPRC		; Separate row and column values
	SUBA	STORE2		; Create row difference
	BPL	PH2		; Make absolute difference
	NEGA			; By negating a negative value
PH2	SUBB	STORE2+$1	; Create column difference
	BPL	PH3		; Make absolute difference
	NEGB			; By negating a negative value
PH3	ABA			; Add absolute differences
	LSRA			; Divide by 4 to
	LSRA			; Form the distance factor
	ANDA	#$03		; Of energy to reach alien ship
	TAB			; Store in B
	BEQ	PH4		; Make sure not zero
	JSR	DVD		; Calculate energy that reached alien ship
PH4	LDX	PNTR3		; Subtract from shield energy
	JSR	FM1		; Of alien ship
	BMI	DSTR		; If negative, alien ship is destroyed
	BNE	ALOS		; If non-zero, print alien ship energy
	TST	0,X		; Alien ship energy = 0?
	BEQ	DSTR		; Yes, remove from galaxy

ALOS	LDAB	#$02		; Set precision counter
	JSR	BINDEC		; Convert alien ship energy to decimal
	LDX	#$0477		; Set digits in message
	LDAB	#$04		; Set number of digits counter
	JSR	DIGPRT		; Put digits in message
	LDX	#$046B		; Print energy of alien ship
	JSR	MSG
	LDX	PNTR3		; Set pointer to alien ship energy
	LDAA	0,X		; Transfer alien ship energy
	STAA	STORE1		; To STORE1 for calculating
	LDAA	$01,X		; Retaliation amount
	STAA	STORE1+$01
	LDAB	#$02		; Divide energy by 4 as
	JSR	DVD		; Retaliation by alien ship
	LDX	STORE1		; Place energy into index register
	JMP	ELOS		; Remove from shield energy, return

DSTR	LDX	#$03CA		; Print 'DESTROYED'
	JSR	MSG
	LDX	PNTR2		; Fetch alien ship location
	JMP	DLET		; Remove alien ship from galaxy, return

SPRC	LDAA	0,X		; Fetch row and column byte
	TAB			; Save for column value
	JSR	ROTR3		; Position row to right
	ANDA	#$07		; Mask out row value
	ANDB	#$07		; Mask out column value
	RTS			; Return

PATCH	BNE	PATCH1		; No, check next
	INX			; Yes, reset Z flag
	DEX
	RTS

PATCH1	JMP	MATCH2


	ORG	$0F00

	HEX	00 01 04 23 0A 03 07 00
	HEX	00 1A 23 05 03 14 16 12
	HEX	00 00 00 00 00 05 04 17
	HEX	05 01 14 00 00 04 05 00
	HEX	07 02 11 09 00 04 00 00
	HEX	23 00 02 24 00 00 03 07
	HEX	00 15 00 05 0E 00 02 06
	HEX	15 00 03 02 13 00 34 03
	HEX	07 01 00 00 00 03 15 00
	HEX	00 04 00 1F 04 01 03 02
	HEX	03 14 00 00 00 16 0D 00
	HEX	00 04 13 03 00 00 00 14
	HEX	0B 01 15 13 00 00 00 03
	HEX	07 00 00 00 1D 04 00 16
	HEX	00 13 15 00 00 04 06 02
	HEX	03 15 00 00 16 00 27 00


	ORG	$0F80

INPUT	JSR	$E1AC		; Call MIKBUG** input routine
	ORAA	#$80		; Set the parity bit
	RTS			; Return to the calling program


	ORG	$0FC0

PRINT	PSHA			; Save character to be output
	JSR	$E1D1		; Call MIKBUG** output routine
	PULA			; Restore character in A
	RTS			; Return to calling program

	END	GALAXY
