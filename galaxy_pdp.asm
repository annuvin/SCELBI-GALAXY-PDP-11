; Native PDP-11 port of Scelbi's Galaxy Game (Robert Findley, 1976),
; ported from the 6800 listing (galaxy_6800.asm) for full mechanical
; fidelity. See GALAXY_DESIGN.md for the full design rationale.
; Load/entry address: 1000 (octal).

STACKTOP = 1000
CR = 15
LF = 12

        MOV #STACKTOP,SP
        JMP MAIN

; ============================================================
; I/O PRIMITIVES (register-argument convention)
; ============================================================

; PUTCHAR: print char in R0 (preserves R0). Polls DL11 XCSR/XBUF.
PUTCHAR:MOV R1,-(SP)
PC_POLL:MOV XCSR,R1
        MOV (R1),R1
        BIC #177577,R1
        BEQ PC_POLL
        MOV XBUF,R1
        MOVB R0,(R1)
        MOV (SP)+,R1
        RTS PC

; ECHOC: alias for PUTCHAR (kept separate name to match earlier convention).
ECHOC:  JMP PUTCHAR

; GETCHAR: block until a key is available; return it (0-177) in R0.
GETCHAR:MOV RCSR,R0
        MOV (R0),R0
        BIC #177577,R0
        BEQ GETCHAR
        MOV RBUF,R0
        MOV (R0),R0
        BIC #177400,R0
        RTS PC

; GETECHO: GETCHAR + echo it. Char returned in R0.
GETECHO:JSR PC,GETCHAR
        JSR PC,ECHOC
        RTS PC

; CRLF: print carriage-return + line-feed.
CRLF:   MOV R0,-(SP)
        MOV #CR,R0
        JSR PC,ECHOC
        MOV #LF,R0
        JSR PC,ECHOC
        MOV (SP)+,R0
        RTS PC

; PRINTSTR: print zero-terminated string whose address is in R0.
PRINTSTR:
        MOV R3,-(SP)
        MOV R0,R3
PS_LOOP:
        MOVB (R3)+,R0
        BEQ PS_DONE
        JSR PC,ECHOC
        BR PS_LOOP
PS_DONE:
        MOV (SP)+,R3
        RTS PC

; ============================================================
; RN: Scelbi's own random-number algorithm, ported as-is from the 6800
; source (rotate-xor-rotate, mixed with an incrementing counter byte):
;   A = RNM; A = ROL(A) [through carry]; A ^= RNM(original);
;   A = ROR(A) [through carry]; RNM+1++; A += RNM+1; RNM = A.
; Simplification vs. the 6800 source: we drop the BVC/DEC "undo the
; increment on signed overflow" correction on the final ADD -- it's a
; subtle 8-bit-arithmetic side effect of the original CPU's flags that
; has no bearing on the quality of the sequence, only on which exact
; byte comes out; RN's job here is "look random enough, no short low-
; bit cycles", not bit-for-bit reproduction of 1976 register contents.
; Returns a random byte (0-377 octal / 0-255 decimal) in R0.
; ============================================================
RN:     MOV R1,-(SP)
        MOVB SEED,R1
        BIC #177400,R1          ; R1 = RNM (clean byte, original value)
        MOV R1,R0
        ROLB R0                 ; R0 = ROL(RNM) through carry
        BIC #177400,R0
        XOR R1,R0               ; R0 = ROL(RNM) xor RNM
        RORB R0                 ; R0 = ROR(that) through carry
        BIC #177400,R0
        INCB RNCTR
        MOVB RNCTR,R1
        BIC #177400,R1
        ADD R1,R0
        BIC #177400,R0          ; wrap to 8-bit range like the source's ADDA
        MOVB R0,SEED
        MOV (SP)+,R1
        RTS PC

        .EVEN
XCSR:   .WORD 177564
XBUF:   .WORD 177566
RCSR:   .WORD 177560
RBUF:   .WORD 177562
SEED:   .WORD 0
RNCTR:  .WORD 0

; PRINTNUMW: print R0 as an N-digit zero-padded unsigned decimal number,
; matching Scelbi's fixed-width DIGPRT/BINDEC display fields (e.g. a
; 4-digit energy value is always shown as "0425", not "425"). N passed
; in R1 (1-5). Clobbers nothing visible (all working regs saved).
; ============================================================
PRINTNUMW:
        MOV R2,-(SP)
        MOV R3,-(SP)
        MOV R4,-(SP)
        MOV R1,R4                ; R4 = digit count N (from caller's R1)
        MOV R0,R2                ; R2 = value to print (from caller's R0)
        ; --- extract N decimal digits into the stack, LS digit first ---
        MOV R4,R3                ; loop counter
PNW_EXTRACT:
        TST R3
        BEQ PNW_PRINT
        CLR R0
        MOV R2,R1
        MOV #10.,R2
        DIV R2,R0                 ; (R0:R1)/10 -> quotient R0, remainder R1
        ADD #'0,R1
        MOV R1,-(SP)
        MOV R0,R2
        DEC R3
        BR PNW_EXTRACT
PNW_PRINT:
        MOV R4,R3
PNW_PLOOP:
        TST R3
        BEQ PNW_DONE
        MOV (SP)+,R0
        JSR PC,ECHOC
        DEC R3
        BR PNW_PLOOP
PNW_DONE:
        MOV (SP)+,R4
        MOV (SP)+,R3
        MOV (SP)+,R2
        RTS PC

; ============================================================
; MATCH: does location (row<<3|col) in R0 collide with the ship, any
; star, the station, or any alien? Returns R1 = 0 (no) or a code telling
; the caller WHAT was hit: 1=star, 2=station, 3=alien; R2 = index (for
; star/alien tables) when applicable. Does not check the ship itself
; (callers that care about ship-vs-something check separately).
; Clobbers R3,R4.
; ============================================================
MATCH:  MOV R0,-(SP)
        MOV R3,-(SP)
        MOV R4,-(SP)
        MOV #STARLOC,R3
        CLR R4
MA_STAR:CMP R4,#7.
        BGE MA_STATION
        CMP (R3)+,R0
        BEQ MA_HITSTAR
        INC R4
        BR MA_STAR
MA_HITSTAR:
        MOV R4,R2
        MOV #1,R1
        BR MA_DONE
MA_STATION:
        CMP STATIONLOC,R0
        BNE MA_ALIEN
        MOV #2,R1
        BR MA_DONE
MA_ALIEN:
        MOV #ALIENLOC,R3
        CLR R4
MA_ALOOP:
        CMP R4,#3.
        BGE MA_NONE
        CMP (R3)+,R0
        BEQ MA_HITALIEN
        INC R4
        BR MA_ALOOP
MA_HITALIEN:
        MOV R4,R2
        MOV #3,R1
        BR MA_DONE
MA_NONE:
        CLR R1
MA_DONE:
        MOV (SP)+,R4
        MOV (SP)+,R3
        MOV (SP)+,R0
        RTS PC

; ============================================================
; LOCSET: place COUNT (R1) entities into the table at R0 (word array),
; picking random 0-63 locations that don't collide with the ship or any
; already-placed entity (rejection sampling, matching LOCSET/MATCH in
; the source). Table pointer advances by 2 (word) per entry placed.
; Clobbers R0-R4.
; ============================================================
LOCSET: MOV R5,-(SP)
        MOV R1,R5               ; R5 = remaining count
LS_LOOP:
        TST R5
        BEQ LS_DONE
        MOV R0,-(SP)             ; save table pointer across RN/MATCH calls
LS_TRY: JSR PC,RN
        BIC #177700,R0           ; low 6 bits -> 0-63 location
        CMP R0,SHIPLOC
        BEQ LS_TRY
        JSR PC,MATCH
        TST R1
        BNE LS_TRY
        MOV (SP)+,R1             ; R1 = saved table pointer
        MOV R0,(R1)              ; store chosen location
        ADD #2,R1
        MOV R1,R0                ; R0 = advanced pointer for next iteration
        DEC R5
        BR LS_LOOP
LS_DONE:
        MOV (SP)+,R5
        RTS PC

; ============================================================
; LOAD: (re)supply the ship -- full energy, no shields, 10 torpedoes.
; Matches the source's LOAD/docking-reload values exactly.
; ============================================================
LOAD:   MOV #5000.,DVME
        CLR DVSE
        MOV #10.,NTR
        RTS PC

; ============================================================
; Galaxy generation: GLXSET fills all 64 quadrants by indexing the
; precomputed 128-entry content table with RN()&0177 (0-127); GLXCK
; tallies stations/aliens and keeps regenerating single entries until
; both totals land in-band (2-6 stations, 10-31 aliens), matching the
; source's PLS/MNS/SSPLS/SSMNS/ASPLS/ASMNS retry loop exactly, including
; its quirk of using OR (not arithmetic add) to bump the alien count
; when balancing -- which only succeeds when the target quadrant's
; current count is even (0 or 2), same as the original 6800 code.
; ============================================================
GENGALAXY:
        MOV #GALAXY,R1
        CLR R2
GG_FILL:
        CMP R2,#64.
        BGE GG_TALLY
        JSR PC,RN
        BIC #177600,R0           ; 0-127
        MOV #GTABLE,R3
        ADD R0,R3
        MOVB (R3),(R1)
        INC R1
        INC R2
        BR GG_FILL
GG_TALLY:
        CLR NSS
        CLR NAS
        MOV #GALAXY,R3
        CLR R2
GG_TLOOP:
        CMP R2,#64.
        BGE GG_CHECK
        MOVB (R3)+,R0
        BIC #177400,R0
        MOV R0,R4
        BIC #367,R4              ; isolate bit3 (0 or 10 octal) -- station flag
        ADD R4,NSS
        MOV R0,R4
        BIC #317,R4              ; isolate bits5-4 (0,20,40,60 octal)
        ASR R4
        ASR R4                   ; >>2 -> 0,4,10,14 octal = count*4
        ADD R4,NAS
        INC R2
        BR GG_TLOOP
GG_CHECK:
        MOV NSS,R0
        ASR R0
        ASR R0
        ASR R0                   ; >>3 -> actual station count
        MOV R0,NSS
        CMP R0,#7.
        BGE GG_SSPLS
        CMP R0,#2.
        BGE GG_CAS
GG_SSMNS:
        MOV #10,R1               ; bit to OR in (station bit, 010 octal)
        JSR PC,GG_MNS
        BR GG_TALLY
GG_SSPLS:
        MOV #10,R1               ; bit to clear (station bit, 010 octal)
        JSR PC,GG_PLS
        BR GG_TALLY
GG_CAS:
        MOV NAS,R0
        ASR R0
        ASR R0                   ; >>2 -> actual alien total
        MOV R0,NAS
        CMP R0,#32.
        BGE GG_ASPLS
        CMP R0,#10.
        BLT GG_ASMNS
        BR GG_GDONE
GG_ASMNS:
        MOV #20,R1               ; bit4 = 020 octal, OR'd in (even-count-only quirk)
        JSR PC,GG_MNS
        BR GG_TALLY
GG_ASPLS:
        JSR PC,GG_APLS           ; arithmetic -1 alien unit, unconditional
        BR GG_TALLY
GG_GDONE:
        RTS PC

; GG_MNS: OR bit R1 into a random quadrant's byte.
GG_MNS: MOV R0,-(SP)
        JSR PC,RN
        BIC #177700,R0
        MOV #GALAXY,R2
        ADD R0,R2
        MOVB (R2),R0
        BIC #177400,R0
        BIS R1,R0
        MOVB R0,(R2)
        MOV (SP)+,R0
        RTS PC

; GG_PLS: clear bit R1 in a random quadrant's byte (station removal).
GG_PLS: MOV R0,-(SP)
        JSR PC,RN
        BIC #177700,R0
        MOV #GALAXY,R2
        ADD R0,R2
        MOVB (R2),R0
        BIC #177400,R0
        BIC R1,R0
        MOVB R0,(R2)
        MOV (SP)+,R0
        RTS PC

; GG_APLS: subtract one full alien unit (020 octal / 16 decimal) from a
; random quadrant, matching the source's arithmetic SUBA #$10 (proper
; decrement regardless of parity, unlike the OR-based add).
GG_APLS:
        MOV R0,-(SP)
        JSR PC,RN
        BIC #177700,R0
        MOV #GALAXY,R2
        ADD R0,R2
        MOVB (R2),R0
        BIC #177400,R0
        SUB #20,R0
        MOVB R0,(R2)
        MOV (SP)+,R0
        RTS PC

; ============================================================
; QCNT: fetch GALAXY[CQY*8+CQX] into CQC.
; ============================================================
QCNT:   MOV CQY,R0
        ASL R0
        ASL R0
        ASL R0
        ADD CQX,R0
        MOV #GALAXY,R1
        ADD R0,R1
        MOVB (R1),R0
        BIC #177400,R0
        MOV R0,CQC
        RTS PC

; ============================================================
; LOADALIENS: prime all 3 alien-energy slots with fresh random values,
; energy = byte | ((byte&3)<<8), matching the source's LAS/LLAS (each
; slot gets its own independent RN() call here, rather than replicating
; the source's tail-call-chained RN priming -- same distribution, same
; formula, simpler control flow).
; ============================================================
LOADALIENS:
        MOV R2,-(SP)
        MOV R3,-(SP)
        MOV #ALIENNRG,R3
        MOV #3,R2
LA_LOOP:
        TST R2
        BEQ LA_DONE
        JSR PC,RN
        MOV R0,R1
        BIC #177774,R1          ; R1 = byte & 3
        SWAB R1                 ; R1 = (byte&3) << 8
        BIS R0,R1               ; R1 = byte | ((byte&3)<<8)
        MOV R1,(R3)+
        DEC R2
        BR LA_LOOP
LA_DONE:
        MOV (SP)+,R3
        MOV (SP)+,R2
        RTS PC

; ============================================================
; SETQUAD: rebuild the current quadrant (NWQD equivalent) -- clears the
; star/station/alien tables, decodes CQC into counts, places each entity
; type via LOCSET, and primes alien energies. Ship location is NOT
; touched here (matches the source: the ship keeps its sector position
; across a NEW quadrant only at the very start of a game -- LOCSET is
; called separately for the ship once, at OVER/game-start).
; ============================================================
SETQUAD:
        MOV #STARLOC,R1
        MOV #7.,R2
SQ_CLRSTAR:
        TST R2
        BEQ SQ_CLRDONE
        MOV #-1,(R1)+
        DEC R2
        BR SQ_CLRSTAR
SQ_CLRDONE:
        MOV #-1,STATIONLOC
        MOV #-1,ALIENLOC
        MOV #-1,ALIENLOC+2
        MOV #-1,ALIENLOC+4

        MOV CQC,R0
        BIC #370,R0             ; isolate bits2-0 = star count (0-7)
        MOV R0,R1
        BEQ SQ_NOSTARS
        MOV #STARLOC,R0
        JSR PC,LOCSET
SQ_NOSTARS:

        MOV CQC,R0
        BIC #367,R0             ; isolate bit3 = station flag (0 or 10 octal)
        BEQ SQ_NOSTATION
        MOV #STATIONLOC,R0
        MOV #1,R1
        JSR PC,LOCSET
SQ_NOSTATION:

        MOV CQC,R0
        BIC #317,R0             ; isolate bits5-4 = alien count field
        ASR R0
        ASR R0
        ASR R0
        ASR R0                  ; >>4 -> actual count 0-3
        MOV R0,R1
        BEQ SQ_NOALIENS
        MOV #ALIENLOC,R0
        JSR PC,LOCSET
SQ_NOALIENS:

        JSR PC,LOADALIENS
        RTS PC

; ============================================================
; CELLCODE: input R0 = (row<<3|col) location within the current
; quadrant. Output R0 = content code: 0=empty,1=ship,2=star,3=station,
; 4=alien.
; ============================================================
CELLCODE:
        MOV R1,-(SP)
        MOV R2,-(SP)
        CMP R0,SHIPLOC
        BNE CCC_CHECK
        MOV #1,R0
        BR CCC_DONE
CCC_CHECK:
        JSR PC,MATCH
        TST R1
        BEQ CCC_EMPTY
        CMP R1,#1
        BEQ CCC_STAR
        CMP R1,#2
        BEQ CCC_STATION
        MOV #4,R0
        BR CCC_DONE
CCC_STAR:
        MOV #2,R0
        BR CCC_DONE
CCC_STATION:
        MOV #3,R0
        BR CCC_DONE
CCC_EMPTY:
        CLR R0
CCC_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        RTS PC

; ============================================================
; PRINTRC: print the location in R0 (row<<3|col, 0-7 each) as "R,C"
; using 1-based digits (matching the source's TWO routine).
; ============================================================
PRINTRC:
        MOV R1,-(SP)
        MOV R2,-(SP)
        MOV R0,R1
        BIC #177770,R1          ; R1 = col (0-7)
        MOV R0,R2
        ASR R2
        ASR R2
        ASR R2                  ; R2 = row (0-7)
        ADD #'1,R2
        MOV R2,R0
        JSR PC,ECHOC
        MOV #54,R0              ; ','
        JSR PC,ECHOC
        ADD #'1,R1
        MOV R1,R0
        JSR PC,ECHOC
        MOV (SP)+,R2
        MOV (SP)+,R1
        RTS PC

; ============================================================
; PRINTGRIDROW: print the 24-char (8 columns x 3 chars/column) grid
; content for quadrant row R0 (0-7). Cell codes -> 3-char glyphs:
;   empty="   "  ship="<*>"  star=" * "  station=">1<"  alien="+++"
; matching the source's ROWSET/RWPNT/AS/STR printout exactly.
; ============================================================
PRINTGRIDROW:
        MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
        MOV R3,-(SP)
        MOV R0,PGR_ROW
        CLR R3
PGR_LOOP:
        CMP R3,#8.
        BGE PGR_DONE
        MOV PGR_ROW,R0
        ASL R0
        ASL R0
        ASL R0
        ADD R3,R0
        JSR PC,CELLCODE
        MOV R0,R1
        ASL R1
        ADD R0,R1               ; R1 = code*3
        MOV #GRIDCHARS,R2
        ADD R1,R2
        MOVB (R2)+,R0
        JSR PC,ECHOC
        MOVB (R2)+,R0
        JSR PC,ECHOC
        MOVB (R2)+,R0
        JSR PC,ECHOC
        INC R3
        BR PGR_LOOP
PGR_DONE:
        MOV (SP)+,R3
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

        .EVEN
PGR_ROW: .WORD 0
GRIDCHARS:
        .BYTE 40,40,40
        .BYTE '<,'*,'>
        .BYTE 40,'*,40
        .BYTE '>,'1,'<
        .BYTE '+,'+,'+
        .EVEN

; ============================================================
; SRSCN: short-range scan -- 8 rows, each row = row digit + 24-char
; grid + an interleaved status field (matching the source's unusual
; layout: row1 trails STARDATE, row2 CONDITION, row3 QUADRANT, row4
; SECTOR, row5 ENERGY, row6 TORPEDOES, row7 SHIELDS, row8 nothing),
; bracketed top and bottom by a column-number ruler.
; ============================================================
SRSCN:  JSR PC,CRLF
        MOV #MSGRULER,R0
        JSR PC,PRINTSTR
        JSR PC,CRLF

        MOV #1.,R4                ; row number 1-8 (kept across the whole scan)
SRS_ROWLOOP:
        CMP R4,#8.
        BGT SRS_BOTTOM
        MOV R4,R0
        ADD #'0,R0
        JSR PC,ECHOC
        MOV R4,R0
        DEC R0                    ; 0-based row for the grid printer
        JSR PC,PRINTGRIDROW
        CMP R4,#1.
        BNE SRS_R2
        MOV #MSGSTARDATE,R0
        JSR PC,PRINTSTR
        MOV #50.,R0
        SUB NSR,R0
        MOV #2.,R1
        JSR PC,PRINTNUMW
        BR SRS_ROWDONE
SRS_R2: CMP R4,#2.
        BNE SRS_R3
        MOV #MSGCONDITION,R0
        JSR PC,PRINTSTR
        MOV CQC,R0
        BIC #317,R0
        BEQ SRS_GREEN
        MOV #MSGRED,R0
        JSR PC,PRINTSTR
        BR SRS_ROWDONE
SRS_GREEN:
        MOV #MSGGREEN,R0
        JSR PC,PRINTSTR
        BR SRS_ROWDONE
SRS_R3: CMP R4,#3.
        BNE SRS_R4
        MOV #MSGQUADRANT,R0
        JSR PC,PRINTSTR
        MOV CQY,R0
        ASL R0
        ASL R0
        ASL R0
        ADD CQX,R0
        JSR PC,PRINTRC
        BR SRS_ROWDONE
SRS_R4: CMP R4,#4.
        BNE SRS_R5
        MOV #MSGSECTOR,R0
        JSR PC,PRINTSTR
        MOV SHIPLOC,R0
        JSR PC,PRINTRC
        BR SRS_ROWDONE
SRS_R5: CMP R4,#5.
        BNE SRS_R6
        MOV #MSGENERGY,R0
        JSR PC,PRINTSTR
        MOV DVME,R0
        MOV #4.,R1
        JSR PC,PRINTNUMW
        BR SRS_ROWDONE
SRS_R6: CMP R4,#6.
        BNE SRS_R7
        MOV #MSGTORPEDOES,R0
        JSR PC,PRINTSTR
        MOV NTR,R0
        MOV #2.,R1
        JSR PC,PRINTNUMW
        BR SRS_ROWDONE
SRS_R7: CMP R4,#7.
        BNE SRS_ROWDONE
        MOV #MSGSHIELDS,R0
        JSR PC,PRINTSTR
        MOV DVSE,R0
        MOV #4.,R1
        JSR PC,PRINTNUMW
SRS_ROWDONE:
        JSR PC,CRLF
        INC R4
        BR SRS_ROWLOOP
SRS_BOTTOM:
        MOV #MSGRULER,R0
        JSR PC,PRINTSTR
        JSR PC,CRLF
        RTS PC

        .EVEN
MSGRULER:     .ASCIZ " -1--2--3--4--5--6--7--8-"
MSGSTARDATE:  .ASCIZ " STARDATE 300"
MSGCONDITION: .ASCIZ " CONDITION "
MSGGREEN:     .ASCIZ "GREEN"
MSGRED:       .ASCIZ "RED"
MSGQUADRANT:  .ASCIZ " QUADRANT "
MSGSECTOR:    .ASCIZ " SECTOR "
MSGENERGY:    .ASCIZ " ENERGY "
MSGTORPEDOES: .ASCIZ " TORPEDOES "
MSGSHIELDS:   .ASCIZ " SHIELDS "
        .EVEN

; ============================================================
; Energy primitives (CKMN/CKSD/FMMN/FMSD/TOMN/TOSD ported ~1:1; amount
; always in R0). ELOM/ELOS replicate the source's exact "drain shields
; into main, then apply a further quarter-strength danger penalty"
; behavior -- including the quirk that ELOM (a plain energy tax, e.g.
; the 10-unit per-command charge) falls into that SAME penalty
; machinery if main energy alone can't cover it, and that ELOS tries
; shields ALONE first (no main-energy or penalty involvement at all)
; before falling into the same drain-and-penalize path as ELOM.
; ============================================================
CKMN:   MOV R2,-(SP)
        MOV DVME,R2
        CLR R1
        CMP R2,R0
        BGE CKMN_OK
        MOV #1,R1
CKMN_OK:
        MOV (SP)+,R2
        RTS PC

CKSD:   MOV R2,-(SP)
        MOV DVSE,R2
        CLR R1
        CMP R2,R0
        BGE CKSD_OK
        MOV #1,R1
CKSD_OK:
        MOV (SP)+,R2
        RTS PC

FMMN:   MOV R1,-(SP)
        MOV DVME,R1
        SUB R0,R1
        MOV R1,DVME
        MOV (SP)+,R1
        RTS PC

FMSD:   MOV R1,-(SP)
        MOV DVSE,R1
        SUB R0,R1
        MOV R1,DVSE
        MOV (SP)+,R1
        RTS PC

TOMN:   MOV R1,-(SP)
        MOV DVME,R1
        ADD R0,R1
        MOV R1,DVME
        MOV (SP)+,R1
        RTS PC

TOSD:   MOV R1,-(SP)
        MOV DVSE,R1
        ADD R0,R1
        MOV R1,DVSE
        MOV (SP)+,R1
        RTS PC

; DIVPOW2: R0 = R0 >> R1 (R1 = number of halvings, 0-3 in practice).
DIVPOW2:
        MOV R2,-(SP)
        MOV R1,R2
DP2_LOOP:
        TST R2
        BEQ DP2_DONE
        ASR R0
        DEC R2
        BR DP2_LOOP
DP2_DONE:
        MOV (SP)+,R2
        RTS PC

; ELOM: take R0 units from main, drawing on shields first if main alone
; is short, then applying a further quarter-strength penalty if THAT
; draw was itself needed (matches the source exactly -- no message for
; the simple/sufficient case).
ELOM:   MOV R1,-(SP)
        MOV R2,-(SP)
        MOV R0,R2
        JSR PC,CKMN
        TST R1
        BEQ ELOM_OK
        MOV DVSE,R0
        JSR PC,FMSD
        JSR PC,TOMN
        MOV R2,R0
        JSR PC,CKMN
        TST R1
        BNE ELOM_DEAD
        JSR PC,FMMN
        MOV #MSGDANGER,R0
        JSR PC,PRINTSTR
        MOV R2,R0
        MOV #2.,R1
        JSR PC,DIVPOW2
        JSR PC,CKMN
        TST R1
        BNE ELOM_DEAD
        JSR PC,FMMN
        BR ELOM_DONE
ELOM_OK:
        MOV R2,R0
        JSR PC,FMMN
        BR ELOM_DONE
ELOM_DEAD:
        JMP OUTOFENERGY
ELOM_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        RTS PC

; ELOS: apply R0 units of "loss" (combat damage/retaliation) -- prints
; "LOSS OF ENERGY nnnn", tries shields alone first (fully absorbs with
; no message and no main-energy impact if sufficient), else drains
; shields into main and falls into the same danger-penalty path as
; ELOM.
ELOS:   MOV R1,-(SP)
        MOV R2,-(SP)
        MOV R0,R2
        MOV #MSGLOSSENERGY,R0
        JSR PC,PRINTSTR
        MOV R2,R0
        MOV #4.,R1
        JSR PC,PRINTNUMW
        JSR PC,CRLF
        MOV R2,R0
        JSR PC,CKSD
        TST R1
        BNE ELOS_MAINPATH
        MOV R2,R0
        JSR PC,FMSD
        BR ELOS_DONE
ELOS_MAINPATH:
        MOV DVSE,R0
        JSR PC,FMSD
        JSR PC,TOMN
        MOV R2,R0
        JSR PC,CKMN
        TST R1
        BNE ELOS_DEAD
        JSR PC,FMMN
        MOV #MSGDANGER,R0
        JSR PC,PRINTSTR
        MOV R2,R0
        MOV #2.,R1
        JSR PC,DIVPOW2
        JSR PC,CKMN
        TST R1
        BNE ELOS_DEAD
        JSR PC,FMMN
        BR ELOS_DONE
ELOS_DEAD:
        JMP OUTOFENERGY
ELOS_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        RTS PC

        .EVEN
MSGDANGER:     .ASCIZ "DANGER - SHIELD ENERGY 000\r\n"
MSGLOSSENERGY: .ASCIZ "LOSS OF ENERGY "
        .EVEN

; ============================================================
; Course/warp input and navigation.
; ============================================================

; COURSEIN: read a two-character course (digit 1-8, '.', digit 0 or 5)
; matching DRCT. Output R0 = course table index (0-15), R1 = 1 if
; valid, 0 if invalid (caller should re-prompt).
; ============================================================
COURSEIN:
        MOV R2,-(SP)
        JSR PC,GETECHO
        CMP R0,#'1
        BLT CI_BAD
        CMP R0,#'8
        BGT CI_BAD
        SUB #'0,R0
        MOV R0,R2
        ASL R2
        SUB #2.,R2              ; R2 = (digit1-1)*2
        MOV #'.,R0
        JSR PC,ECHOC
        JSR PC,GETECHO
        CMP R0,#'0
        BEQ CI_D0
        CMP R0,#'5
        BEQ CI_D5
        BR CI_BAD
CI_D0:  MOV R2,R0
        MOV #1,R1
        BR CI_DONE
CI_D5:  ADD #1,R2
        MOV R2,R0
        MOV #1,R1
        BR CI_DONE
CI_BAD: CLR R1
CI_DONE:
        MOV (SP)+,R2
        RTS PC

; WARPIN: read a two-digit warp factor (each 0-7), forming CNTR =
; digit1*8+digit2 (1-63; 0 rejected), matching WRP. Output R0=CNTR,
; R1=1 valid / 0 invalid.
; ============================================================
WARPIN: MOV R2,-(SP)
        JSR PC,GETECHO
        CMP R0,#'0
        BLT WI_BAD
        CMP R0,#'7
        BGT WI_BAD
        SUB #'0,R0
        MOV R0,R2
        ASL R2
        ASL R2
        ASL R2                  ; R2 = digit1*8
        MOV #'.,R0
        JSR PC,ECHOC
        JSR PC,GETECHO
        CMP R0,#'0
        BLT WI_BAD
        CMP R0,#'7
        BGT WI_BAD
        SUB #'0,R0
        ADD R2,R0
        BEQ WI_BAD
        MOV #1,R1
        BR WI_DONE
WI_BAD: CLR R1
WI_DONE:
        MOV (SP)+,R2
        RTS PC

; ACTV: input R0 = course table index (0-15). Sets MOVEDX/MOVEDY from
; the course table and ADJCOL/ADJROW (2x-scale sector position) from
; the ship's current SHIPLOC.
; ============================================================
ACTV:   MOV R1,-(SP)
        MOV R2,-(SP)
        MOV #DXTAB,R2
        ADD R0,R2
        MOVB (R2),R1
        MOV R1,MOVEDX
        MOV #DYTAB,R2
        ADD R0,R2
        MOVB (R2),R1
        MOV R1,MOVEDY
        MOV SHIPLOC,R1
        MOV R1,R2
        BIC #177770,R2          ; col 0-7
        ASL R2
        MOV R2,ADJCOL
        MOV R1,R2
        ASR R2
        ASR R2
        ASR R2                  ; row 0-7
        ASL R2
        MOV R2,ADJROW
        MOV (SP)+,R2
        MOV (SP)+,R1
        RTS PC

; TRK: advance one sector-step along (MOVEDX,MOVEDY). Updates
; ADJCOL/ADJROW and, on a quadrant-boundary crossing, CQX/CQY. Sets
; CROSSFLAG=1 if a boundary was crossed this step (else 0), and
; OUTFLAG=1 if the ship has left the galaxy (else 0) -- when OUTFLAG is
; set, the row half of the step is skipped, matching the source.
; ============================================================
TRK:    MOV R0,-(SP)
        CLR CROSSFLAG
        CLR OUTFLAG
        MOV ADJCOL,R0
        ADD MOVEDX,R0
        MOV R0,ADJCOL
        TST R0
        BLT TRK_LEFT
        CMP R0,#16.
        BGE TRK_RIGHT
        BR TRK_ROW
TRK_LEFT:
        BIC #177760,R0
        MOV R0,ADJCOL
        MOV #1,CROSSFLAG
        TST CQX
        BNE TRK_LEFTOK
        MOV #1,OUTFLAG
        BR TRK_RET
TRK_LEFTOK:
        DEC CQX
        BR TRK_ROW
TRK_RIGHT:
        BIC #177760,R0
        MOV R0,ADJCOL
        MOV #1,CROSSFLAG
        CMP CQX,#7.
        BLT TRK_RIGHTOK
        MOV #1,OUTFLAG
        BR TRK_RET
TRK_RIGHTOK:
        INC CQX
TRK_ROW:
        MOV ADJROW,R0
        ADD MOVEDY,R0
        MOV R0,ADJROW
        TST R0
        BLT TRK_UP
        CMP R0,#16.
        BGE TRK_DOWN
        BR TRK_RET
TRK_UP: BIC #177760,R0
        MOV R0,ADJROW
        MOV #1,CROSSFLAG
        TST CQY
        BNE TRK_UPOK
        MOV #1,OUTFLAG
        BR TRK_RET
TRK_UPOK:
        DEC CQY
        BR TRK_RET
TRK_DOWN:
        BIC #177760,R0
        MOV R0,ADJROW
        MOV #1,CROSSFLAG
        CMP CQY,#7.
        BLT TRK_DOWNOK
        MOV #1,OUTFLAG
        BR TRK_RET
TRK_DOWNOK:
        INC CQY
TRK_RET:
        MOV (SP)+,R0
        RTS PC

; RWCM: current (ADJROW,ADJCOL) -> a (row<<3|col) value in R0.
; ============================================================
RWCM:   MOV R1,-(SP)
        MOV ADJROW,R0
        ASR R0
        ASL R0
        ASL R0
        ASL R0
        MOV ADJCOL,R1
        ASR R1
        ADD R1,R0
        MOV (SP)+,R1
        RTS PC

        .EVEN
DXTAB:  .BYTE 2,2,2,1,0,-1,-2,-2,-2,-2,-2,-1,0,1,2,2
DYTAB:  .BYTE 0,-1,-2,-2,-2,-2,-2,-1,0,1,2,2,2,2,2,1
        .EVEN
MOVEDX:     .WORD 0
MOVEDY:     .WORD 0
ADJCOL:     .WORD 0
ADJROW:     .WORD 0
CROSSFLAG:  .WORD 0
OUTFLAG:    .WORD 0
CROSSEDEVER: .WORD 0
CNTR:       .WORD 0

; ============================================================
; CHNG: relocate whatever occupies R0 (a location that just collided
; with the ship's final resting position) to a fresh random location,
; matching the source's CHNG (re-run LOCSET for a single item in
; whichever table it came from). R1 = the MATCH code (1=star,2=station,
; 3=alien) and R2 = index, as returned by the most recent MATCH call.
; ============================================================
CHNG:   MOV R0,-(SP)
        MOV R3,-(SP)
        CMP R1,#1
        BNE CHNG_NOTSTAR
        MOV #STARLOC,R3
        ASL R2
        ADD R2,R3
        BR CHNG_GO
CHNG_NOTSTAR:
        CMP R1,#2
        BNE CHNG_ALIEN
        MOV #STATIONLOC,R3
        BR CHNG_GO
CHNG_ALIEN:
        MOV #ALIENLOC,R3
        ASL R2
        ADD R2,R3
CHNG_GO:
        MOV R3,R0
        MOV #1,R1
        JSR PC,LOCSET
        MOV (SP)+,R3
        MOV (SP)+,R0
        RTS PC

; DKED: docking check -- if a station is present in this quadrant and
; the ship's sector is directly left or right of it IN THE SAME ROW,
; reload the ship (LOAD), matching the source's row+adjacent-column
; rule exactly (no diagonal docking).
; ============================================================
DKED:   MOV R0,-(SP)
        MOV R1,-(SP)
        MOV STATIONLOC,R0
        CMP R0,#-1
        BEQ DKED_NO
        MOV R0,R1
        BIC #7,R1               ; station row*8 (bits5-3, col bits cleared)
        MOV SHIPLOC,R0
        BIC #7,R0               ; ship row*8
        CMP R0,R1
        BNE DKED_NO             ; different row -> no docking
        MOV STATIONLOC,R1
        BIC #177770,R1          ; station col
        MOV SHIPLOC,R0
        BIC #177770,R0          ; ship col
        MOV R1,-(SP)
        ADD #1,R0
        CMP R0,(SP)
        BEQ DKED_YES1
        SUB #2,R0
        CMP R0,(SP)
        BEQ DKED_YES1
        TST (SP)+
        BR DKED_NO
DKED_YES1:
        TST (SP)+
        JSR PC,LOAD
        BR DKED_DONE
DKED_NO:
DKED_DONE:
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

; ============================================================
; GQADDR: R1 = address of GALAXY[CQY*8+CQX] (the current quadrant's raw
; content byte, in the master galaxy array). Preserves R0.
; ============================================================
GQADDR: MOV R0,-(SP)
        MOV CQY,R0
        ASL R0
        ASL R0
        ASL R0
        ADD CQX,R0
        MOV #GALAXY,R1
        ADD R0,R1
        MOV (SP)+,R0
        RTS PC

; ============================================================
; DELSTATION: remove the (sole) space station from the current
; quadrant -- clears STATIONLOC, clears the station bit in both the
; master GALAXY byte and CQC (matching the source's DLET), decrements
; NSS, and prints the "LAST" warning if that was the last station in
; the galaxy (matching the source exactly, short message and all).
; ============================================================
DELSTATION:
        MOV R0,-(SP)
        MOV R1,-(SP)
        MOV #-1,STATIONLOC
        JSR PC,GQADDR
        MOVB (R1),R0
        BIC #177400,R0
        BIC #10,R0
        MOVB R0,(R1)
        BIC #10,CQC
        DEC NSS
        BNE DS_DONE
        MOV #MSGLASTSTN,R0
        JSR PC,PRINTSTR
DS_DONE:
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

; ============================================================
; DELALIEN: remove alien ALIENLOC[R2] from the current quadrant --
; clears that table slot, subtracts one alien unit (020 octal,
; arithmetic SUB matching the source's asymmetric add-by-OR/
; remove-by-SUB quirk) from both the master GALAXY byte and CQC,
; decrements NAS, and JMPs to WINGAME if that was the last alien ship
; in the galaxy (matching the source's DLET/DONE sequence).
; ============================================================
DELALIEN:
        MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
        ASL R2
        MOV #ALIENLOC,R1
        ADD R2,R1
        MOV #-1,(R1)
        JSR PC,GQADDR
        MOVB (R1),R0
        BIC #177400,R0
        SUB #20,R0
        MOVB R0,(R1)
        SUB #20,CQC
        DEC NAS
        BNE DA_DONE
        JMP WINGAME
DA_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

; ============================================================
; MOVECMD: command '0' -- set course & warp, execute the move. Direct
; port of DRCT/WRP/MOV/MVDN/CLSN/NOX from the source: reads a course
; (re-prompting on bad input) and a warp factor (re-prompting on bad
; input, but WITHOUT re-asking the course, matching the source's
; separate CRSE/WRP retry loops), then steps the ship one sector at a
; time via TRK. Each step: leaving the galaxy ends the game (LOST);
; crossing a quadrant boundary costs 25 energy (ELOM) and rebuilds the
; new quadrant (QCNT+SETQUAD) and marks CROSSEDEVER; landing on a star/
; station/alien has consequences ONLY if the ship is still in its
; starting quadrant for this move (CROSSEDEVER still clear) -- a star
; is fatal (WPOUT), a station/alien is destroyed (600/1500 ELOS loss);
; once CROSSEDEVER is set, collisions during the rest of the move are
; ignored in-flight and instead resolved at the end (NOX: whatever the
; ship's final sector lands on gets relocated via CHNG, since two
; things can't occupy one sector). A stardate is spent only if a
; quadrant was crossed during the move (matching MVDN's CI-gated DEC
; NSR); running out of stardates ends the game (TIMEOUT). Finishes by
; checking docking (DKED) and redrawing the short-range scan (SRSCN).
; ============================================================
MOVECMD:
        MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
MC_COURSE:
        MOV #MSGCOURSEQ,R0
        JSR PC,PRINTSTR
        JSR PC,COURSEIN
        TST R1
        BEQ MC_COURSE
        MOV R0,R2               ; R2 = course table index, held across WARPIN
MC_WARP:
        MOV #MSGWARPQ,R0
        JSR PC,PRINTSTR
        JSR PC,WARPIN
        TST R1
        BEQ MC_WARP
        MOV R0,CNTR             ; R0 = warp step count (1-63)
        MOV R2,R0
        JSR PC,ACTV
        CLR CROSSEDEVER
MC_STEP:
        JSR PC,TRK
        TST OUTFLAG
        BNE MC_LOST
        TST CROSSFLAG
        BEQ MC_CLSN
        MOV #1,CROSSEDEVER
        MOV #25.,R0
        JSR PC,ELOM
        JSR PC,QCNT
        JSR PC,SETQUAD
MC_CLSN:
        JSR PC,RWCM
        JSR PC,MATCH
        TST R1
        BEQ MC_MVDN
        CMP R1,#1
        BEQ MC_STARHIT
        CMP R1,#2
        BEQ MC_STNHIT
        BR MC_ALNHIT
MC_STARHIT:
        TST CROSSEDEVER
        BNE MC_MVDN
        JMP WPOUT
MC_STNHIT:
        TST CROSSEDEVER
        BNE MC_MVDN
        JSR PC,DELSTATION
        MOV #MSGSTNKILL,R0
        JSR PC,PRINTSTR
        MOV #600.,R0
        JSR PC,ELOS
        BR MC_MVDN
MC_ALNHIT:
        TST CROSSEDEVER
        BNE MC_MVDN
        JSR PC,DELALIEN
        MOV #MSGALNKILL,R0
        JSR PC,PRINTSTR
        MOV #1500.,R0
        JSR PC,ELOS
MC_MVDN:
        DEC CNTR
        BNE MC_STEP
        TST CROSSEDEVER
        BEQ MC_NOX
        DEC NSR
        BNE MC_NOX
        JMP TIMEOUT
MC_NOX:
        JSR PC,RWCM
        MOV R0,SHIPLOC
        JSR PC,MATCH
        TST R1
        BEQ MC_NOX1
        JSR PC,CHNG
MC_NOX1:
        JSR PC,DKED
        JSR PC,SRSCN
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC
MC_LOST:
        JMP LOST

        .EVEN
MSGCOURSEQ:  .ASCIZ "\r\nCOURSE (1-8.5)? "
MSGWARPQ:    .ASCIZ "\r\nWARP FACTOR (0.1-7.7)? "
MSGSTNKILL:  .ASCIZ "\r\nSPACE STATION DESTROYED\r\n"
MSGALNKILL:  .ASCIZ "\r\nALIEN SHIP DESTROYED\r\n"
MSGLASTSTN:  .ASCIZ "\r\nLAST\r\n"
        .EVEN

; ============================================================
; NUMIN4: read a fixed 4-digit decimal number (matching EIN/DCBN's fixed
; 4-slot digit entry, no Enter key, no variable length -- consistent
; with the source's uniform "fixed keystroke count" input style used
; everywhere else). Each digit is echoed; a non-digit character aborts
; immediately (R1=0), matching EIN's BMI-on-FNUM-failure abort. Builds
; the value via shift/add (R2*10 = (R2<<3)+(R2<<1)) rather than a MUL
; instruction, since neither the assembler nor the emulator implements
; the EIS MUL/DIV opcodes -- an implementation-technique choice, not a
; behavioral difference (full fidelity is to what the game DOES).
; Output: R0 = value (0-9999), R1 = 1 valid / 0 invalid.
; ============================================================
NUMIN4: MOV R2,-(SP)
        MOV R3,-(SP)
        MOV R4,-(SP)
        CLR R2
        MOV #4.,R3
NI4_LOOP:
        JSR PC,GETECHO
        CMP R0,#'0
        BLT NI4_BAD
        CMP R0,#'9
        BGT NI4_BAD
        SUB #'0,R0
        MOV R2,R4
        ASL R2
        ASL R2
        ASL R2                  ; R2 = orig*8
        ASL R4                  ; R4 = orig*2
        ADD R4,R2               ; R2 = orig*10
        ADD R0,R2
        DEC R3
        BNE NI4_LOOP
        MOV R2,R0
        MOV #1,R1
        BR NI4_DONE
NI4_BAD:
        CLR R1
NI4_DONE:
        MOV (SP)+,R4
        MOV (SP)+,R3
        MOV (SP)+,R2
        RTS PC

; ============================================================
; ASPH: fire the already-energy-and-count-adjusted phaser share
; (PHSHARE) at alien R2 (0-2), matching the source's ASPH exactly --
; silently returns if that alien slot is empty; else prints "ALIEN SHIP
; AT SECTOR r,c: ", computes a further distance-based falloff (Manhattan
; distance /4, clamped 0-3, another halving-shift division -- same
; convention as the count-based split in PHASERS), subtracts the result
; from the alien's own energy, and either destroys it (DELALIEN, short
; "DESTROYED" message -- deliberately the SHORT source message here,
; not the longer "ALIEN SHIP DESTROYED" MOVECMD/TRPD use, matching the
; source's own distinct message choice for this exact spot) or prints
; its remaining energy and has it retaliate for 1/4 of THAT remaining
; energy against the ship's shields (ELOS).
; ============================================================
ASPH:   MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R3,-(SP)
        MOV R4,-(SP)
        MOV R5,-(SP)
        MOV #ALIENLOC,R3        ; R3 = &ALIENLOC[R2] (index*2 byte offset)
        ADD R2,R3
        ADD R2,R3
        MOV #ALIENNRG,R5        ; R5 = &ALIENNRG[R2]
        ADD R2,R5
        ADD R2,R5
        MOV (R3),R0
        CMP R0,#-1
        BEQ AS_DONE             ; alien slot empty -- silent return

        MOV #MSGALNSECTOR,R0
        JSR PC,PRINTSTR
        MOV (R3),R0
        ASR R0
        ASR R0
        ASR R0                  ; alien row
        MOV #4.,R1
        JSR PC,PRINTNUMW
        MOV #54,R0              ; ','
        JSR PC,ECHOC
        MOV (R3),R0
        BIC #177770,R0          ; alien col
        MOV #4.,R1
        JSR PC,PRINTNUMW
        MOV #MSGCOLON,R0
        JSR PC,PRINTSTR

        ; distance factor: |ship_row-alien_row| + |ship_col-alien_col|,
        ; >>2, clamped 0-3.
        MOV (R3),R0
        ASR R0
        ASR R0
        ASR R0                  ; R0 = alien row
        MOV SHIPLOC,R1
        ASR R1
        ASR R1
        ASR R1                  ; R1 = ship row
        SUB R1,R0
        BGE AS_RPOS
        NEG R0
AS_RPOS:
        MOV R0,R4               ; R4 = |row diff|
        MOV (R3),R0
        BIC #177770,R0          ; alien col
        MOV SHIPLOC,R1
        BIC #177770,R1          ; ship col
        SUB R1,R0
        BGE AS_CPOS
        NEG R0
AS_CPOS:
        ADD R4,R0               ; R0 = |row diff|+|col diff|
        ASR R0
        ASR R0
        BIC #177774,R0          ; >>2, clamp to 0-3
        MOV R0,R1
        MOV PHSHARE,R0
        JSR PC,DIVPOW2          ; R0 = distance-adjusted damage

        MOV (R5),R1
        SUB R0,R1
        MOV R1,(R5)             ; ALIENNRG[R2] -= damage (may go negative)
        BLE AS_DESTROY          ; <=0 (matches source's BMI-or-exact-zero test)

        ; alien survives: print its remaining energy, then it retaliates
        ; for 1/4 of that remaining energy against the ship's shields.
        MOV #MSGALNENERGY,R0
        JSR PC,PRINTSTR
        MOV R1,R0
        MOV #4.,R1
        JSR PC,PRINTNUMW
        JSR PC,CRLF
        MOV (R5),R0
        MOV #2.,R1
        JSR PC,DIVPOW2
        JSR PC,ELOS
        BR AS_DONE
AS_DESTROY:
        MOV #MSGDESTROYEDSHORT,R0
        JSR PC,PRINTSTR
        JSR PC,DELALIEN
AS_DONE:
        MOV (SP)+,R5
        MOV (SP)+,R4
        MOV (SP)+,R3
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

        .EVEN
MSGALNSECTOR:      .ASCIZ "\r\nALIEN SHIP AT SECTOR "
MSGCOLON:          .ASCIZ ": "
MSGALNENERGY:      .ASCIZ "ENERGY = "
MSGDESTROYEDSHORT: .ASCIZ "\r\nDESTROYED\r\n"
        .EVEN
PHSHARE:           .WORD 0

; ============================================================
; PHASERS: command '5' -- direct port of PHSR. Prompts for a 4-digit
; energy amount (NUMIN4), spends it from main energy via the FULL ELOM
; cascade (matching the source exactly -- a big enough request can, via
; ELOM's own danger-penalty/abandon-ship path, actually cost the ship
; the game; this is intentional risk in the original, not a bug), THEN
; checks whether any aliens are even present (matching WASTE's order --
; energy is spent regardless of whether the shot can hit anything), and
; if so divides the spent energy flatly by count (1/2/4, via the same
; halving-shift convention as DIVPOW2/ELOM's penalty) before firing at
; each of the 3 alien slots via ASPH.
; ============================================================
PHASERS:
        MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
PH_ASK: MOV #MSGPHASERQ,R0
        JSR PC,PRINTSTR
        JSR PC,NUMIN4
        TST R1
        BEQ PH_ASK
        JSR PC,CRLF
        MOV R0,R2               ; R2 = requested amount, held across ELOM
        JSR PC,ELOM

        MOV CQC,R0
        BIC #317,R0             ; isolate bits5-4 = alien count field
        ASR R0
        ASR R0
        ASR R0
        ASR R0                  ; R0 = alien count 0-3
        TST R0
        BEQ PH_WASTED

        MOV R0,R1
        SUB #1,R1               ; R1 = halving count (0/1/2 for count 1/2/3)
        MOV R2,R0
        JSR PC,DIVPOW2          ; R0 = per-alien flat share
        MOV R0,PHSHARE

        CLR R2
        JSR PC,ASPH
        MOV #1,R2
        JSR PC,ASPH
        MOV #2.,R2
        JSR PC,ASPH
        BR PH_DONE
PH_WASTED:
        MOV #MSGWASTED,R0
        JSR PC,PRINTSTR
PH_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

; ============================================================
; TRPD: command '6' -- direct port of TRPD/TR1/TR2/HIT/QOUT. A
; torpedo costs 250 energy from MAIN ONLY (a plain CKMN+FMMN check --
; deliberately NOT the ELOM shield-draining cascade, matching the
; source exactly) and always consumes a torpedo even if that check
; fails (matching the source's DEC NTR happening before the energy
; check). Tracks sector-by-sector along the input course; leaving the
; galaxy OR crossing a quadrant boundary OR hitting a star are all
; treated as an identical miss (matching the source's shared QOUT
; label), restoring the ship's original quadrant position and then
; checking for aliens present (WASTE) before either a wasted-shot
; message or a "MISSED, ALIEN SHIP RETALIATES" 200-unit ELOS penalty.
; A station or alien hit destroys it (DELSTATION/DELALIEN) and returns
; immediately with no retaliation risk, matching the source.
; ============================================================
TRPD:   MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
        TST NTR
        BEQ TR_NONE
        DEC NTR
        MOV #250.,R0
        JSR PC,CKMN
        TST R1
        BNE TR_NOENERGY
        MOV #250.,R0
        JSR PC,FMMN

TR_COURSE:
        MOV #MSGTORPQ,R0
        JSR PC,PRINTSTR
        JSR PC,COURSEIN
        TST R1
        BEQ TR_COURSE
        JSR PC,ACTV
        MOV CQX,-(SP)
        MOV CQY,-(SP)

TR_STEP:
        JSR PC,TRK
        TST OUTFLAG
        BNE TR_MISS
        TST CROSSFLAG
        BNE TR_MISS
        JSR PC,RWCM
        JSR PC,MATCH
        TST R1
        BEQ TR_STEP
        CMP R1,#1
        BEQ TR_MISS             ; star -- absorbed, treated as a miss
        CMP R1,#2
        BEQ TR_STATION
        JSR PC,DELALIEN
        MOV #MSGALNKILL,R0
        JSR PC,PRINTSTR
        BR TR_HITDONE
TR_STATION:
        JSR PC,DELSTATION
        MOV #MSGSTNKILL,R0
        JSR PC,PRINTSTR
TR_HITDONE:
        TST (SP)+
        TST (SP)+
        BR TR_DONE
TR_MISS:
        MOV (SP)+,CQY
        MOV (SP)+,CQX
        MOV CQC,R0
        BIC #317,R0
        BEQ TR_WASTED
        MOV #MSGMISSED,R0
        JSR PC,PRINTSTR
        MOV #200.,R0
        JSR PC,ELOS
        BR TR_DONE
TR_WASTED:
        MOV #MSGWASTED,R0
        JSR PC,PRINTSTR
        BR TR_DONE
TR_NOENERGY:
        MOV #MSGNOTENOUGH,R0
        JSR PC,PRINTSTR
        BR TR_DONE
TR_NONE:
        MOV #MSGNOTORP,R0
        JSR PC,PRINTSTR
TR_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

        .EVEN
MSGPHASERQ:   .ASCIZ "\r\nPHASOR ENERGY TO FIRE = "
MSGWASTED:    .ASCIZ "\r\nNO ALIEN SHIPS! WASTED SHOT\r\n"
MSGTORPQ:     .ASCIZ "\r\nTORPEDO TRAJECTORY(1-8.5) : "
MSGMISSED:    .ASCIZ "\r\nYOU MISSED! ALIEN SHIP RETALIATES\r\n"
MSGNOTENOUGH: .ASCIZ "\r\nNOT ENOUGH ENERGY\r\n"
MSGNOTORP:    .ASCIZ "\r\nNO TORPEDOES\r\n"
        .EVEN

; ============================================================
; LRDASH: print CRLF followed by R0 dash characters (matching NTN,
; used as both the LRSCN 3x3 border -- 19 dashes -- and the GXPRT
; full-galaxy border -- 49 dashes, 8*6+1 matching each cell's 6-char
; width plus one trailing bar).
; ============================================================
LRDASH: MOV R1,-(SP)
        MOV R0,R1
        JSR PC,CRLF
LRD_LOOP:
        TST R1
        BEQ LRD_DONE
        MOV #55,R0              ; '-'
        JSR PC,ECHOC
        DEC R1
        BR LRD_LOOP
LRD_DONE:
        MOV (SP)+,R1
        RTS PC

; ============================================================
; LRCELL: print one long-range-scan cell "1 KSB " for the raw galaxy
; content byte in R0 (0 = blank/out-of-galaxy prints "1 000 ", matching
; the source's CLC1/CLC2/RWC zero-fill), matching QDSET's exact digit
; order (alien count 0-3, station 0/1, star count 0-7).
; ============================================================
LRCELL: MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
        MOV R0,R2
        MOV #'1,R0
        JSR PC,ECHOC
        MOV #40,R0              ; ' '
        JSR PC,ECHOC
        MOV R2,R0
        BIC #317,R0
        ASR R0
        ASR R0
        ASR R0
        ASR R0                  ; alien count 0-3
        ADD #'0,R0
        JSR PC,ECHOC
        MOV R2,R0
        BIC #367,R0
        ASR R0
        ASR R0
        ASR R0                  ; station flag 0/1
        ADD #'0,R0
        JSR PC,ECHOC
        MOV R2,R0
        BIC #370,R0             ; star count 0-7
        ADD #'0,R0
        JSR PC,ECHOC
        MOV #40,R0              ; ' '
        JSR PC,ECHOC
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

; ============================================================
; LRBLANKROW: print an all-blank 3-cell long-range row, matching RWC
; (used when the row above/below the ship's quadrant is off the edge
; of the galaxy).
; ============================================================
LRBLANKROW:
        MOV R0,-(SP)
        JSR PC,CRLF
        CLR R0
        JSR PC,LRCELL
        CLR R0
        JSR PC,LRCELL
        CLR R0
        JSR PC,LRCELL
        MOV #'1,R0
        JSR PC,ECHOC
        MOV (SP)+,R0
        RTS PC

; ============================================================
; LRROW3: print one 3-cell long-range row for galaxy row R0 (0-7),
; centered on the ship's current column (CQX) -- left/right cells
; blank if CQX is at the galaxy edge, matching LRR exactly.
; ============================================================
LRROW3: MOV R1,-(SP)
        MOV R2,-(SP)
        MOV R3,-(SP)
        MOV R4,-(SP)
        MOV R0,R4               ; R4 = row 0-7
        JSR PC,CRLF
        TST CQX
        BEQ LR3_LBLANK
        MOV R4,R0
        ASL R0
        ASL R0
        ASL R0
        MOV CQX,R1
        SUB #1,R1
        ADD R1,R0
        MOV #GALAXY,R2
        ADD R0,R2
        MOVB (R2),R0
        BIC #177400,R0
        BR LR3_LDONE
LR3_LBLANK:
        CLR R0
LR3_LDONE:
        JSR PC,LRCELL
        MOV R4,R0
        ASL R0
        ASL R0
        ASL R0
        ADD CQX,R0
        MOV #GALAXY,R2
        ADD R0,R2
        MOVB (R2),R0
        BIC #177400,R0
        JSR PC,LRCELL
        CMP CQX,#7.
        BEQ LR3_RBLANK
        MOV R4,R0
        ASL R0
        ASL R0
        ASL R0
        MOV CQX,R1
        ADD #1,R1
        ADD R1,R0
        MOV #GALAXY,R2
        ADD R0,R2
        MOVB (R2),R0
        BIC #177400,R0
        BR LR3_RDONE
LR3_RBLANK:
        CLR R0
LR3_RDONE:
        JSR PC,LRCELL
        MOV #'1,R0
        JSR PC,ECHOC
        MOV (SP)+,R4
        MOV (SP)+,R3
        MOV (SP)+,R2
        MOV (SP)+,R1
        RTS PC

; ============================================================
; LRSCN: command '2' -- long range scan. Direct port of LRSCN/LRR:
; prints "L+R. SCAN FOR QUADRANT r,c", a 19-dash border, and the 3x3
; neighborhood of quadrants around the ship (blank rows/cells at the
; galaxy edge), each row followed by another 19-dash border.
; ============================================================
LRSCN:  MOV R0,-(SP)
        MOV #MSGLRSCN,R0
        JSR PC,PRINTSTR
        MOV #MSGQUADRANT,R0
        JSR PC,PRINTSTR
        MOV CQY,R0
        ASL R0
        ASL R0
        ASL R0
        ADD CQX,R0
        JSR PC,PRINTRC
        MOV #19.,R0
        JSR PC,LRDASH

        TST CQY
        BEQ LR_TOPBLANK
        MOV CQY,R0
        SUB #1,R0
        JSR PC,LRROW3
        BR LR_MID
LR_TOPBLANK:
        JSR PC,LRBLANKROW
LR_MID:
        MOV #19.,R0
        JSR PC,LRDASH
        MOV CQY,R0
        JSR PC,LRROW3
        MOV #19.,R0
        JSR PC,LRDASH

        CMP CQY,#7.
        BEQ LR_BOTBLANK
        MOV CQY,R0
        ADD #1,R0
        JSR PC,LRROW3
        BR LR_BOTDONE
LR_BOTBLANK:
        JSR PC,LRBLANKROW
LR_BOTDONE:
        MOV #19.,R0
        JSR PC,LRDASH
        JSR PC,CRLF
        MOV (SP)+,R0
        RTS PC

; ============================================================
; GXPRT: command '3' -- full galaxy printout. Direct port of GXPRT/
; GL1/GL2: prints "GALAXY DISPLAY", a 49-dash border, then all 8 rows
; of 8 quadrants each (LRCELL per quadrant, same K/S/B digit format),
; each row followed by another 49-dash border.
; ============================================================
GXPRT:  MOV R0,-(SP)
        MOV R2,-(SP)
        MOV R3,-(SP)
        MOV R4,-(SP)
        MOV #MSGGALAXYDISPLAY,R0
        JSR PC,PRINTSTR
        MOV #49.,R0
        JSR PC,LRDASH
        CLR R4                  ; row 0-7
GX_ROWLOOP:
        CMP R4,#8.
        BGE GX_DONE
        JSR PC,CRLF
        MOV R4,R3
        ASL R3
        ASL R3
        ASL R3                  ; R3 = row*8
        CLR R2                  ; col 0-7
GX_COLLOOP:
        CMP R2,#8.
        BGE GX_COLDONE
        MOV #GALAXY,R0
        ADD R3,R0
        ADD R2,R0
        MOVB (R0),R0
        BIC #177400,R0
        JSR PC,LRCELL
        INC R2
        BR GX_COLLOOP
GX_COLDONE:
        MOV #'1,R0
        JSR PC,ECHOC
        MOV #49.,R0
        JSR PC,LRDASH
        INC R4
        BR GX_ROWLOOP
GX_DONE:
        MOV (SP)+,R4
        MOV (SP)+,R3
        MOV (SP)+,R2
        MOV (SP)+,R0
        RTS PC

; ============================================================
; NUMIN4S: like NUMIN4 but accepts an optional leading '-' before the
; 4 digits (matching EIN's sign handling), for SHEN's shield-transfer
; direction. Output: R0 = magnitude (0-9999), R1 = 1 valid/0 invalid,
; R2 = 1 if negative / 0 if positive.
; ============================================================
NUMIN4S:
        MOV R3,-(SP)
        MOV R4,-(SP)
        CLR R2                  ; sign flag
        JSR PC,GETECHO
        CMP R0,#'-
        BNE NS_HAVEFIRST
        MOV #1,R2
        JSR PC,GETECHO
NS_HAVEFIRST:
        MOV #0,R4               ; accumulator, held in R4 (R0/R1 are scratch)
        MOV #4.,R3
NS_LOOP:
        CMP R0,#'0
        BLT NS_BAD
        CMP R0,#'9
        BGT NS_BAD
        SUB #'0,R0
        MOV R4,R1
        ASL R4
        ASL R4
        ASL R4                  ; R4 = orig*8
        ASL R1                  ; R1 = orig*2
        ADD R1,R4               ; R4 = orig*10
        ADD R0,R4
        DEC R3
        BEQ NS_GOOD
        JSR PC,GETECHO
        BR NS_LOOP
NS_GOOD:
        MOV R4,R0
        MOV #1,R1
        BR NS_DONE
NS_BAD:
        CLR R1
NS_DONE:
        MOV (SP)+,R4
        MOV (SP)+,R3
        RTS PC

; ============================================================
; SHEN: command '4' -- shield energy transfer. Direct port of SHEN:
; reads a signed 4-digit amount; negative transfers FROM shields TO
; main (CKSD/FMSD/TOMN), positive transfers FROM main TO shields
; (CKMN/FMMN/TOSD); either direction prints "NOT ENOUGH ENERGY" and
; does nothing if the source side can't cover it (a plain check, not
; the ELOM/ELOS danger cascade -- matching the source exactly).
; ============================================================
SHEN:   MOV R0,-(SP)
        MOV R1,-(SP)
        MOV R2,-(SP)
SH_ASK: MOV #MSGSHENQ,R0
        JSR PC,PRINTSTR
        JSR PC,NUMIN4S
        TST R1
        BEQ SH_ASK
        JSR PC,CRLF
        TST R2
        BNE SH_NEG
        JSR PC,CKMN
        TST R1
        BNE SH_NE
        JSR PC,FMMN             ; FMMN preserves R0 (the amount) -- no
        JSR PC,TOSD             ; need to re-save it before TOSD
        BR SH_DONE
SH_NEG: JSR PC,CKSD
        TST R1
        BNE SH_NE
        JSR PC,FMSD             ; likewise FMSD preserves R0 for TOMN
        JSR PC,TOMN
        BR SH_DONE
SH_NE:  MOV #MSGNOTENOUGH,R0
        JSR PC,PRINTSTR
SH_DONE:
        MOV (SP)+,R2
        MOV (SP)+,R1
        MOV (SP)+,R0
        RTS PC

        .EVEN
MSGLRSCN:          .ASCIZ "\r\nL+R. SCAN FOR"
MSGGALAXYDISPLAY:  .ASCIZ "\r\nGALAXY DISPLAY"
MSGSHENQ:          .ASCIZ "\r\nSHIELD ENERGY TRANSFER = "

        .EVEN
; 128-entry precomputed (K,B,S)-packed quadrant-content table, ported
; verbatim (same values in both the 8080 and 6800 source listings).
GTABLE:
        .BYTE 0,1,4,43,12,3,7,0
        .BYTE 0,32,43,5,3,24,26,22
        .BYTE 0,0,0,0,0,5,4,27
        .BYTE 5,1,24,0,0,4,5,0
        .BYTE 7,2,21,11,0,4,0,0
        .BYTE 43,0,2,44,0,0,3,7
        .BYTE 0,25,0,5,16,0,2,6
        .BYTE 25,0,3,2,23,0,64,3
        .BYTE 7,1,0,0,0,3,25,0
        .BYTE 0,4,0,37,4,1,3,2
        .BYTE 3,24,0,0,0,26,15,0
        .BYTE 0,4,23,3,0,0,0,24
        .BYTE 13,1,25,23,0,0,0,3
        .BYTE 7,0,0,0,35,4,0,26
        .BYTE 0,23,25,0,0,4,6,2
        .BYTE 3,25,0,0,26,0,47,0

        .EVEN
GALAXY:      .BLKB 64.
NSS:         .WORD 0          ; number of space stations in the galaxy
NAS:         .WORD 0          ; number of alien ships in the galaxy
NSR:         .WORD 0          ; number of stardates left in the mission

SHIPLOC:     .WORD 0          ; ship's (row<<3|col) in current quadrant
STARLOC:     .WORD -1,-1,-1,-1,-1,-1,-1    ; up to 7 stars
STATIONLOC:  .WORD -1         ; station, or -1 if none this quadrant
ALIENLOC:    .WORD -1,-1,-1   ; up to 3 aliens
ALIENNRG:    .WORD 0,0,0      ; alien energy, parallel to ALIENLOC

CQY:         .WORD 0          ; current quadrant row (0-7)
CQX:         .WORD 0          ; current quadrant col (0-7)
CQC:         .WORD 0          ; current quadrant's raw galaxy content byte

DVME:        .WORD 0          ; main energy
DVSE:        .WORD 0          ; shield energy
NTR:         .WORD 0          ; torpedoes

; ============================================================
; End-of-game handlers (LOST/WPOUT/TIMEOUT/OUTOFENERGY/WINGAME): each
; prints the source's exact message then, matching the source's shared
; DONE routine (every one of these -- LOST/WPOUT/TIME/EOUT/the all-
; aliens-destroyed win -- funnels through DONE, which prints a message
; then JMPs back to START), restarts the whole game via MAIN rather
; than halting.
; ============================================================
LOST:   MOV #MSGLOST,R0
        JSR PC,PRINTSTR
        JMP MAIN

WPOUT:  MOV #MSGWPOUT,R0
        JSR PC,PRINTSTR
        JMP MAIN

TIMEOUT:
        MOV #MSGTIMEOUT,R0
        JSR PC,PRINTSTR
        JMP MAIN

WINGAME:
        MOV #MSGCONGRATS,R0
        JSR PC,PRINTSTR
        JMP MAIN

OUTOFENERGY:
        MOV #MSGABANDON,R0
        JSR PC,PRINTSTR
        JMP MAIN

        .EVEN
MSGLOST:     .ASCIZ "\r\nYOU MOVED OUT OF THE GALAXY, YOUR SHIP IS LOST..LOST\r\n"
MSGWPOUT:    .ASCIZ "\r\nKA-BOOM, YOU CRASHED INTO A STAR. YOUR SHIP IS DESTROYED\r\n"
MSGTIMEOUT:  .ASCIZ "\r\nMISSION FAILED, YOU HAVE RUN OUT OF STARDATES\r\n"
MSGCONGRATS: .ASCIZ "\r\nCONGRATULATIONS, YOU HAVE ELIMINATED ALL OF THE ALIEN SHIPS\r\n"
MSGABANDON:  .ASCIZ "\r\nABANDON SHIP! NO ENERGY LEFT\r\n"
        .EVEN

; ============================================================
; MAIN: direct port of START/OVER/CAS-tail/CMND. Prints the voyage
; prompt and reads one un-echoed keypress (matching source's INPUT-
; without-PRINT here, unlike every other single-key read in the game)
; both to seed RNCTR with player entropy and to check for the 'N'
; ("chicken out") quit condition. Otherwise generates the galaxy,
; computes NSR=NAS+5, prints the mission briefing with live NAS/NSR/
; NSS counts, places the ship in a random starting quadrant/sector,
; shows the initial short-range scan, and enters the command loop:
; a flat 10-energy tax + RNCTR entropy stir per command (matching
; CMND exactly, tax and all -- including the risk of it ending the
; game via ELOM's cascade), then single-keypress dispatch to the
; matching subsystem. An unrecognized command is silently re-prompted
; (matching NPHSR's fallthrough to CMD with no error message).
; ============================================================
MAIN:   MOV #MSGINTRO,R0
        JSR PC,PRINTSTR
        JSR PC,RN
        JSR PC,GETCHAR
        MOVB R0,RNCTR
        CMP R0,#'N
        BNE M_OVER
        MOV #MSGCHICKEN,R0
        JSR PC,PRINTSTR
        HALT

M_OVER: JSR PC,GENGALAXY
        MOV NAS,R0
        ADD #5.,R0
        MOV R0,NSR

        MOV #MSGMISSION1,R0
        JSR PC,PRINTSTR
        MOV NAS,R0
        MOV #2.,R1
        JSR PC,PRINTNUMW
        MOV #MSGMISSION2,R0
        JSR PC,PRINTSTR
        MOV NSR,R0
        MOV #2.,R1
        JSR PC,PRINTNUMW
        MOV #MSGMISSION3,R0
        JSR PC,PRINTSTR
        MOV NSS,R0
        ADD #'0,R0
        JSR PC,ECHOC
        MOV #MSGMISSION4,R0
        JSR PC,PRINTSTR

        JSR PC,RN
        BIC #177700,R0          ; 0-63
        MOV R0,R1
        ASR R1
        ASR R1
        ASR R1
        MOV R1,CQY
        MOV R0,R1
        BIC #177770,R1
        MOV R1,CQX
        JSR PC,QCNT
        JSR PC,LOAD
        JSR PC,SETQUAD
        MOV #SHIPLOC,R0
        MOV #1,R1
        JSR PC,LOCSET

        JSR PC,SRSCN

MAINLOOP:
        MOV #10.,R0
        JSR PC,ELOM
        DEC RNCTR
        MOV #MSGCOMMANDQ,R0
        JSR PC,PRINTSTR
        JSR PC,GETECHO
        CMP R0,#'0
        BEQ M_MOVE
        CMP R0,#'1
        BEQ M_SRSCN
        CMP R0,#'2
        BEQ M_LRSCN
        CMP R0,#'3
        BEQ M_GXPRT
        CMP R0,#'4
        BEQ M_SHEN
        CMP R0,#'5
        BEQ M_PHASERS
        CMP R0,#'6
        BEQ M_TRPD
        BR MAINLOOP
M_MOVE: JSR PC,MOVECMD
        BR MAINLOOP
M_SRSCN:
        JSR PC,SRSCN
        BR MAINLOOP
M_LRSCN:
        JSR PC,LRSCN
        BR MAINLOOP
M_GXPRT:
        JSR PC,GXPRT
        BR MAINLOOP
M_SHEN: JSR PC,SHEN
        BR MAINLOOP
M_PHASERS:
        JSR PC,PHASERS
        BR MAINLOOP
M_TRPD: JSR PC,TRPD
        BR MAINLOOP

        .EVEN
MSGINTRO:     .ASCIZ "\r\nDO YOU WANT TO GO ON A SPACE VOYAGE? "
MSGCHICKEN:   .ASCIZ "\r\nCHICKEN!\r\n"
MSGMISSION1:  .ASCIZ "\r\nYOU MUST DESTROY "
MSGMISSION2:  .ASCIZ " ALIEN SHIPS IN "
MSGMISSION3:  .ASCIZ " STARDATES WITH "
MSGMISSION4:  .ASCIZ " SPACE STATIONS\r\n"
MSGCOMMANDQ:  .ASCIZ "\r\nCOMMAND?"
        .EVEN
