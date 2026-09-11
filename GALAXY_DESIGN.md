# SCELBI Galaxy -> native PDP-11 port -- design notes

Source of truth: `galaxy_6800.asm` (Robert Findley, 1976, Scelbi Computer
Consulting -- the 6800 listing, chosen over the 8080 listing because it
already addresses in full 16-bit terms via the X index register with
`n,X` indexed addressing and `JSR`/`RTS`, which maps directly onto the
PDP-11's `offset(Rn)` addressing mode. The 8080 listing constantly splits
addresses into a fixed page byte (H) + computed offset (L), an idiom with
no PDP-11 equivalent and no reason to reproduce.)

Full-fidelity port: same galaxy size, same energy costs, same fractional
course/warp, same distance-based phaser falloff, same shields-then-main
damage absorption, same docking/resupply rule, same self-balancing galaxy
generator. Implementation technique is native PDP-11 (real MUL/DIV instead
of the 6800's shift-and-subtract BCD loops; a single 16-bit word wherever
the 6800 needed a LS/MS byte pair) since that's what "full fidelity"
should mean for a *port* -- matching what the game DOES, not literally
replicating 8-bit workarounds that only exist because the 6800 has no
divide instruction and 8-bit registers.

Load address: 1000 (octal), same convention as Mandelbrot/Star Trek.

## Internal representation: hybrid of source tables + a dense sector grid
The 6800 source has no persisted 8x8 sector grid -- ROWSET reconstructs
each short-range-scan row on the fly by scanning the ship/star/station/
alien position tables and checking which entries fall in the current row.
That's a fine design for a CPU with no RAM to spare, but it buys nothing
on a PDP-11 with a full 64KB address space, and re-deriving it exactly
would just make collision/lookup code slower and harder to test than it
needs to be for *identical player-visible behavior*. So:
  - Keep per-entity-type position tables (ship, up to 7 stars, 1 station,
    3 aliens), each holding a (row<<3|col) byte, matching the source's
    MATCH/RWPNT logic -- this is what "did I hit something" and "what's
    in this row" logic is built on in the original, and it's what the
    distance calculations (PH2/PH3 in ASPH) index into.
  - ALSO maintain a dense SECTOR[64] content-code grid (0=empty,1=ship,
    2/3/4=alien slot,5=station,6=star) purely as a display/collision
    fast-path, exactly as in the Star Trek build. Every routine that
    mutates a position table also updates SECTOR in lockstep.
This changes no observable behavior; it's an implementation detail like
choosing MOV vs a different register.

## Galaxy encoding (bit-for-bit identical to the source)
One byte per quadrant, GALAXY[64], row-major 8x8:
  bits5-4 = alien ship count (0-3)   [ALNMSK 00110000b, source ASHIFT>>4]
  bit3    = space station present   [STNMSK 00001000b]
  bits2-0 = star count (0-7)        [STRMSK 00000111b]
(Note: this differs from my Star Trek build's packing, which used bits
6-5 for K and bit4 for B -- SCELBI's packing is reproduced exactly here
since we're matching its generator/balancer logic bit-for-bit.)

Sector/location byte (row<<3|col), used in position tables:
  bits5-3 = row (0-7), bits2-0 = col (0-7), matching ROWMSK/COLMSK.
  Sentinel for "absent" = negative byte (high bit set), matching the
  source's BMI/RM checks after CLR-to-0xC0.

## Galaxy generation (GLXSET / GLXCK / PLS / MNS -- ported ~1:1)
1. Fill all 64 quadrant bytes with `RNDINT(128)` (source: ANDA #$7F then
   indirect through a 128-entry precomputed table at $0F00-$0F7F -- this
   table is itself just a curated set of "plausible" (K,B,S) bytes so the
   generator doesn't need per-field random rolls; we reproduce the same
   128-entry table verbatim in a PDP-11 .BYTE block).
2. Tally total stations (sum of bit3 across all 64) and total aliens (sum
   of bits5-4 across all 64, i.e. >>4).
3. If stations > 6: pick a random quadrant, clear its station bit, recheck.
   If stations < 2: pick a random quadrant, set its station bit, recheck.
4. Same band-check for aliens: >31 remove one (random quadrant, SUB 0x10
   if present), <10 add one (random quadrant, ADD 0x10 if room). [Source
   bands: CMPA #$07/#$02 for stations pre-shift (i.e. 2-6 after the >>3
   normalize); CMPA #$20/#$0A for aliens pre-shift (i.e. 10-31 after >>2).]
5. Repeat from step 2 until both bands are satisfied (source: JMP GLXCK
   after every add/remove -- a real retry loop, not a single correction).
6. NSR (stardates) = alien_total + 5. NSS/NAS stored for the intro message
   and the win condition (NAS reaching 0).

## Course table (16 entries, half-integer headings 1.0-8.5)
Direct port of the .BYTE table at ORG 0000 in both source listings: 16
signed (dy,dx) pairs, one per half-step course from 1.0 to 8.5. Course
input is two characters: a digit 1-8, then '.' echoed, then a digit that
must be '0' or '5' -- table index = (digit1-1)*2 + (0 if second digit is
'0' else 1). Ported as a .WORD table of packed (dy<<8|dx) bytes, same
values, indexed the same way (DRCT logic, CR1 label).

## Warp factor / movement distance
Warp input is also two digits: X.Y where X=0-7, Y=0-7 (not just 0/5 -- any
digit), forming a count 0-63 of "warp units", except source treats the
combined value as a literal step counter (WARP = digit1*8 + digit2,
CNTR := that value) and moves the ship that many *sectors* per unit... on
closer read: source's CNTR is used directly as the outer MOV loop counter
(MVDN: DEC CNTR / BNE MOV), i.e. the ship moves CNTR individual sectors
along the course vector, where CNTR = digit1*8+digit2 (0-63). This lets a
single command move up to 63 sectors (i.e. potentially across almost the
whole galaxy in one warp command) at a flat 25-energy-per-quadrant-crossed
cost (not per sector) -- reproduced exactly: same CNTR formation, same
per-quadrant-crossing (not per-sector) 25-unit energy cost.

## Energy / shields (ELOS, CKSD, CKMN, FMSD, FMMN, TOSD, TOMN, ELOM)
Single 16-bit word each for main energy (DVME, init 5000), shield energy
(DVSE, init 0), replacing the source's LS/MS byte pairs -- a 16-bit PDP-11
word already covers the full range these ever use, so no double-precision
tricks are needed; CKMN/CKSD's "compare 16-bit values" collapses to a
plain CMP. ELOM ("energy loss, main"): if main energy is enough, subtract
directly; if not, pull enough from shields into main first (mirrors the
source's SDO1 shield-raid path) then subtract, and if STILL not enough
after draining shields, that's game over (EOUT). ELOS ("energy loss,
possibly retaliation"): prints the loss message, then subtracts from
shields first; whatever the shields can't absorb spills into main energy
at FULL cost, with a "DANGER - SHIELD ENERGY 000" warning, and if THAT
overflows main energy too, an extra 1/4-strength penalty hits main energy
again (source's double-jeopardy SD0 path) before finally checking for
game-over.

## Docking (DKED)
After a completed move, if a space station is present in the current
quadrant and the ship's new sector is directly left or right of the
station's sector *in the same row*, call LOAD (reset energy=5000,
shields=0, torpedoes=10) -- ported exactly, including the "same row,
adjacent column" adjacency rule (no diagonal docking, matches source).

## Phasers (PHSR / ASPH)
Energy input is split evenly... no -- re-read: PH1 divides total energy
by 1 (1 alien), 2 (2 aliens), or 4 (3 aliens) as a FLAT split (not by
count in general, just those three cases, matching ROTR4-1 -> DVD with
B=that count). Then for EACH alien present, ASPH computes the Manhattan-
style distance (|row diff| + |col diff|, /4, clamped 0-3) between ship and
that alien, and further divides that alien's *share* by 2^distance_factor
before applying it as damage. Alien retaliates for 1/4 of its OWN energy
back at the shields (via ELOS) if it survives the hit. All ported exactly:
same 1/2/4 split by alien count, same distance-based falloff, same
retaliation fraction.

## Torpedoes (TRPD)
250-energy flat cost, one torpedo consumed regardless of hit/miss,
sector-by-sector tracking along the (possibly fractional -> but torpedo
course uses the same DRCT/course-table input, i.e. same half-step
resolution as navigation) course vector until it leaves the quadrant
(miss) or hits something (star = miss/absorbed, station or alien =
destroyed). A miss triggers 200-unit alien retaliation via ELOS, same as
source, restoring the ship's quadrant/sector afterward.

## Long-range scan / galaxy printout
Direct ports of LRR/QDS1 (3x3 neighborhood, K/S/B digit codes per
quadrant, blank/zero for out-of-galaxy) and GXPRT (full 8x8 galaxy dump) --
functionally identical to the Star Trek build's LRS, extended to the
3-digit-per-cell K/S/S format SCELBI uses (alien count 0-3, station 0/1,
star count 0-7 -- one digit each, no dashes for out-of-galaxy; source
just prints "000" for cells outside the current 3x3 that fall off the
galaxy edge, so we match that rather than Star Trek's "---").

## Command set (single keypress, no Enter needed -- matches Star Trek build)
  0 = set course & warp, move          (source: '0')
  1 = short range scan                 (source: '1')
  2 = long range scan                  (source: '2')
  3 = galaxy printout                  (source: '3')
  4 = shield energy transfer           (source: '4')
  5 = phasers                          (source: '5')
  6 = photon torpedo                   (source: '6')
Kept the source's digit-command scheme rather than Star Trek's mnemonic
letters, since that's part of this game's actual identity and the port
should feel like SCELBI Galaxy, not a Star Trek reskin.

## RNG
Keypress-entropy seeding exactly as in the Star Trek build (no hardware
timer available); LCG update per RN: seed = (seed ROL1 XOR seed) ROR1,
then seed+1's low byte incremented and added in -- source's RN is a fairly
unusual generator (rotate-xor-rotate plus an incrementing counter folded
in via ADDA), reproduced as-is rather than substituting Star Trek's
seed*25173+13849 LCG, since RN's exact statistical behavviour isn't load-
bearing for anything except "looks random enough", and reproducing the
source's actual algorithm keeps this a faithful port rather than a
different RNG wearing SCELBI's clothes.

## Progress log
Navigation/combat-consequence loop (MOVECMD, command '0') is now written
and fully validated: COURSEIN/WARPIN retry loops, ACTV/TRK/RWCM stepping
with quadrant-crossing (25 energy + rebuild via QCNT/SETQUAD) and galaxy-
edge detection (LOST), the CROSSEDEVER-gated collision consequences (star
crash only in the starting quadrant = WPOUT; station/alien destroyed only
in the starting quadrant, via new DELSTATION/DELALIEN routines mirroring
the source's DLET -- 600/1500-unit ELOS loss, NSS/NAS decrement, "LAST"
warning / CONGRATULATIONS win message), the end-of-move NOX relocation
(CHNG) for anything the ship lands on after crossing without consequence,
the CI-gated stardate cost (TIMEOUT on expiry), and final DKED docking +
SRSCN redraw. All exact prompt/message text (COURSE, WARP FACTOR, LOST,
WPOUT, TIMEOUT, station/alien-destroyed, LAST, CONGRATULATIONS, ABANDON
SHIP) was recovered by decoding the source's HEX-encoded message table
($0100-$04ED) rather than guessed. LOST/WPOUT/TIMEOUT/WINGAME/OUTOFENERGY
are temporary message+HALT stubs until MAIN exists to restart the game.

Combat (task #12) is now written and fully validated: PHASERS (command
'5', fixed 4-digit NUMIN4 energy input, full ELOM cascade on the spent
amount -- including the risk of abandoning ship on an over-large
request, matching the source exactly -- WASTE check for "no aliens
present" *after* energy is already spent, flat 1/2/4 count-based split
via the same halving-shift convention as DIVPOW2, and per-alien ASPH
targeting with Manhattan-distance/4 falloff, remaining-energy display,
and 1/4-energy retaliation) and TRPD (command '6', 250-energy MAIN-ONLY
flat cost via CKMN/FMMN -- deliberately not the ELOM cascade -- that
still consumes a torpedo even on failure, sector-by-sector tracking
that treats leaving the galaxy/crossing a quadrant/hitting a star as an
identical miss with restored quadrant position, WASTE-gated "wasted
shot" vs 200-unit retaliation, and immediate no-retaliation destruction
on a station/alien hit). NUMIN4 (fixed 4-digit decimal input, built via
shift/add since the toolchain has no MUL/DIV opcodes) is new and
reusable for any future fixed-width numeric prompt.

Long-range scan and galaxy display (task #13) are now written and
validated: LRSCN (command '2', "L+R. SCAN FOR QUADRANT r,c" + a 3x3
neighborhood of quadrants with 19-dash borders, blank rows/cells at the
galaxy edge) and GXPRT (command '3', full 8x8 dump with 49-dash
borders), both sharing an LRCELL helper that prints the "1 KSB "
digit-triple format (alien count/station flag/star count) exactly
matching QDSET. Also added SHEN (command '4', shield<->main energy
transfer via a signed 4-digit NUMIN4S input) since it's the same kind
of small energy-command as PHASERS/TRPD and belongs with the rest of
the command set before MAIN wires them together.

MAIN is now written and validated end to end: the intro prompt (with
its deliberately un-echoed keypress, matching source, used both to seed
RNCTR with player entropy and to check the 'N'/"chicken out" quit),
galaxy generation, the live mission briefing (NAS/NSR/NSS pulled from
the just-generated galaxy, NSR=NAS+5 computed exactly as CAS does),
random starting quadrant/sector placement, the first short-range scan,
and the command loop (10-energy CMND tax + RNCTR stir per command,
single-keypress dispatch to MOVECMD/SRSCN/LRSCN/GXPRT/SHEN/PHASERS/
TRPD, silent re-prompt on an unrecognized key). LOST/WPOUT/TIMEOUT/
WINGAME/OUTOFENERGY now all JMP back into MAIN to restart the whole
game after printing their message, matching the source's shared DONE
-> START loop exactly (confirmed via test_elom_elos.py/test_main.py:
an ELOM/ELOS game-over now genuinely restarts and reaches the intro
prompt again). The full port is now playable start-to-finish in the
emulator: every command has been exercised at least once via MAIN's
own dispatch loop, not just as an isolated subroutine call.

Fuzz/playthrough testing (task #16) is done: 40 short randomized trials
(random intro keypress + 300 random keystrokes each, from a keyspace of
digits/'.'/'-'/'N'/invalid letters) plus one long 1500-keystroke
adversarial stream, all run to a multi-million-step budget, confirmed
zero exceptions, zero hangs beyond budget, and no memory-corruption
signs (DVME/DVSE/NAS/NSS/NTR all stay in sane ranges whenever the run
reaches a genuine HALT; mid-GENGALAXY STEP_LIMIT snapshots are exempted
from the NAS/NSS/NTR check since GG_TALLY's raw scaled accumulator is
legitimately >31 before normalization -- a real, previously-understood
property of the algorithm, not a bug). Every subroutine has now been
both unit-tested in isolation and exercised through MAIN's real command
dispatch (task #15's ongoing validation is complete).

Remaining: task #17, generating the ODT-paste deliverable (octal
dump + load/start instructions) and the readable source file, mirroring
the Star Trek build's delivery format.

## Scope / deferred
None planned -- this is the full-fidelity option. If real hardware testing
turns up something that doesn't fit (e.g. a mechanic that depends on 8080/
6800 timing), it'll be flagged explicitly rather than silently dropped.
