; Source code created by SMS Examine V1.2a
; Size: 524288 bytes

.MEMORYMAP
SLOTSIZE $4000
SLOT 0 $0000
SLOT 1 $4000
SLOT 2 $8000
DEFAULTSLOT 2
.ENDME

.ROMBANKMAP
BANKSTOTAL 32
BANKSIZE $4000
BANKS 32
.ENDRO

.EMPTYFILL $FF

.include "ps1.constants.asm"

.BANK 0 SLOT 0
.ORG $0000
Bank00:

_START:
	di
	im   1
	ld   sp, System_stack
	jr   MainSetup

_RST_08H:
	ld   a, e
	out  (Port_VDPAddress), a
	ld   a, d
	out  (Port_VDPAddress), a
	ret

.db $FF

_RST_10H:
.db	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

_RST_18H:
.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

_RST_20H:
.db	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

_RST_28H:
.db	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

_RST_30H:
.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; Vertical Interrupt
_RST_38H:
_IRQ_HANDLER:
	push	af
	in   a, (Port_VDPStatus)
	jp   VInt


LABEL_3E:
	ld	a, ($C201)
	and	$BF
	jr	+

LABEL_45:
	ld	a, ($C201)
	or	$40
+
	ld	($C201), a
	ld	e, a
	ld	d, $81
	rst	$08
	ret

WaitForVInt:
	ld   ($C208), a
-
	ld   a, ($C208)
	or   a
	jr   nz, -
	ret


; Data from 5C to 65 (10 bytes)
.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; We get here after the pause button is pressed
_NMI_HANDLER:
	push	af
	ld   a, (Game_mode)
	cp   $05 ; GameMode_Ship
	jr   z, LABEL_7A
	cp   $09 ; GameMode_Map
	jr   z, LABEL_7A
	cp   $0B ; GameMode_Dungeon
	jr   z, LABEL_7A
	cp   $0D ; GameMode_Interaction
	jr   nz, LABEL_81
LABEL_7A:
	ld   a, (Game_is_paused)
	cpl
	ld   (Game_is_paused), a
LABEL_81:
	pop  af
	retn

MainSetup:
	di
	ld   sp, System_stack
	ld   hl, $FFFC
	ld   (hl), $80	; Enable ROM write
	inc  hl
	ld   (hl), $00	; Page 0 - ROM bank 0
	inc  hl
	ld   (hl), $01	; Page 1 - ROM bank 1
	inc  hl
	ld   (hl), $02	; Page 2 - ROM bank 2

; Clear work RAM
	ld   hl, $C000
	ld   de, $C001
	ld   bc, $1FFF
	ld   (hl), l	; clear byte in $C000
	ldir			; then do the rest (until bc = 0)

	call	CallSndInit
	call	LABEL_3A4
	call	LABEL_318
	call	LABEL_7DA
	ei

MainGameLoop:
	ld   hl, Game_mode
	ld   a, (hl)
	and  $1F
	ld   hl, GameModeTbl
	call	GetPtrAndJump
	jp   MainGameLoop


GameModeTbl:
.dw	GameMode_InitIntro	; 0
.dw	GameMode_InitIntro	; 1
.dw	GameMode_LoadIntro	; 2
.dw	GameMode_Intro	; 3
.dw	GameMode_LoadShip	; 4
.dw	GameMode_Ship	; 5
.dw	LABEL_B07	; 6
.dw	LABEL_B07	; 7
.dw	GameMode_LoadMap	; 8
.dw	GameMode_Map	; 9
.dw	GameMode_LoadDungeon	; $A
.dw	GameMode_Dungeon	; $B
.dw	GameMode_LoadInteraction	; $C
.dw	GameMode_Interaction	; $D
.dw	GameMode_LoadRoad	; $E
.dw	GameMode_Road	; $F
.dw	GameMode_LoadNameInput	; $10
.dw	GameMode_NameInput	; $11
.dw	LABEL_467C	; $12
.dw	LABEL_467C	; $13


GetPtrAndJump:
	add  a, a
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	jp   (hl)


PauseLoop:
	call	CallSndMute
-
	ld	a, (Game_is_paused)
	or	a
	ret	z
	jr	-

VInt:
	push	bc
	push	de
	push	hl
	push	ix
	push	iy
	ld   a, ($FFFC)
	push	af
	ld   a, ($FFFF)
	push	af
	ld   a, $80
	ld   ($FFFC), a
	in   a, (Port_IOPort2)
	and  $10
	ld   hl, $C20B
	ld   c, (hl)
	ld   (hl), a
	xor  c
	and  c
	jp   nz, MainSetup
	ld   a, ($C20A)
	or   a
	jp   nz, LABEL_12A
	ld   b, $00
LABEL_126:
	djnz	LABEL_126
LABEL_128:
	djnz	LABEL_128
LABEL_12A:
	ld   a, (Game_is_paused)
	or   a
	jp   nz, LABEL_2DF
	ld   a, ($C208)
	and  $1F
	ld   hl, LABEL_18F
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	jp   (hl)


LABEL_143:
	xor	a
	ld	($C208), a
LABEL_147:
	pop  af
	ld   ($FFFF), a
	pop  af
	ld   ($FFFC), a
	pop  iy
	pop  ix
	pop  hl
	pop  de
	pop  bc
	pop  af
	ei
	ret


LABEL_159:
	call	LABEL_45
	jp	LABEL_143

LABEL_15F:
	ld	a, ($C300)
	out (Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	LABEL_588B
	call	LABEL_7B40
	call	LABEL_7BEE
	ld	hl, $C220
	ld	de, $C000
	rst	$08
	ld	c, Port_VDPData
	call	LABEL_595E
	call	LABEL_63A5
	call	CallSndUpdate
	jp	LABEL_143

LABEL_18F:
.dw	LABEL_1A7
.dw	LABEL_1A7
.dw	LABEL_1A7
.dw	LABEL_1A7
.dw	LABEL_1AD
.dw LABEL_1D1
.dw LABEL_1EF
.dw LABEL_235
.dw LABEL_25F
.dw LABEL_29F
.dw LABEL_159
.dw LABEL_15F

LABEL_1A7:
	call	CallSndUpdate
	jp	LABEL_143

LABEL_1AD:
	ld	a, ($C300)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	LABEL_588B
	call	LABEL_63A5
	call	ReadJoypad
	call	LABEL_2E62
	call	CallSndUpdate
	jp	LABEL_143

LABEL_1D1:
	ld	a, ($C300)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	LABEL_588B
	call	LABEL_63A5
	call	CallSndUpdate
	jp	LABEL_143

LABEL_1EF:
	ld	a, ($C300)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	ld	hl, $D000
	xor a
	out	(Port_VDPAddress), a
	ld	a, $78
	out	(Port_VDPAddress), a
	ld	c, Port_VDPData
	call	LABEL_589E
	call	LABEL_589E
	call	LABEL_589E
	call	LABEL_589E
	call	LABEL_589E
	call	LABEL_589E
	call	LABEL_589E
	ld	a, $03
	ld	b, $80
LABEL_226:
	outi
	jp	nz, LABEL_226
	dec	a
	jp	nz, LABEL_226
	call	CallSndUpdate
	jp	LABEL_143

LABEL_235:
	ld	a, ($C300)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	LABEL_588B
	call	LABEL_7C18
	call	LABEL_61F5
	call	LABEL_73D0
	call	LABEL_62BC
	call	ReadJoypad
	call	CallSndUpdate
	jp	LABEL_143

LABEL_25F:
	ld	a, ($C300)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	LABEL_588B
	ld	hl, $C220
	ld	de, $C000
	rst	$08
	ld	c, Port_VDPData
	call	LABEL_595E
	ld	hl, $D000
	xor	a
	out	(Port_VDPAddress), a
	ld	a, $78
	out	(Port_VDPAddress), a
	ld	c, Port_VDPData
	ld	a, $06
	ld	b, 0
LABEL_290:
	outi
	jp	nz, LABEL_290
	dec	a
	jp	nz, LABEL_290
	call	CallSndUpdate
	jp	LABEL_143

LABEL_29F:
	ld	a, ($C300)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, ($C304)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	LABEL_588B
	ld	hl, $C220
	ld	de, $C000
	rst	$08
	ld	c, Port_VDPData
	call	LABEL_595E
	ld	hl, $D000
	xor	a
	out	(Port_VDPAddress), a
	ld	a, $78
	out	(Port_VDPAddress), a
	ld	c, Port_VDPData
	ld	a, $07
	ld	b, 0
LABEL_2D0:
	outi
	jp	nz, LABEL_2D0
	dec	a
	jp	nz, LABEL_2D0
	call	CallSndUpdate
	jp	LABEL_143

LABEL_2DF:
	call	CallSndMute
	jp   LABEL_147


CallSndUpdate:
	ld	hl, $FFFF
	ld	(hl), :Bank12
	jp	Snd_UpdateAll

CallSndInit:
	ld   hl, $FFFF
	ld   (hl), :Bank12
	jp   Snd_InitDriver

CallSndMute:
	ld   hl, $FFFF
	ld   (hl), :Bank12
	jp   Snd_SilencePSG


LABEL_2FD:
	ld	hl, $C900
	ld	de, $C901
	ld	bc, $40
	ld	(hl), $E0
	ldir
	ld	c, $BF
	ld	(hl), 0
	ldir
	ld	a, $14
	call	WaitForVInt
	jp	FadeIn2

LABEL_318:
	ld   hl, $0000
LABEL_31B:
	in   a, (Port_VDPStatus)
	or   a
	jp   p, LABEL_31B
LABEL_321:
	in   a, (Port_VDPStatus)
	or   a
	jp   p, LABEL_321
LABEL_327:
	inc  hl
	in   a, (Port_VDPStatus)
	or   a
	jp   p, LABEL_327
	xor  a
	ld   de, $0800
	sbc  hl, de
	sbc  a, a
	ld   ($C20A), a
	ret


ReadJoypad:
	in	a, (Port_IOPort1)
	ld	hl, Ctrl_1
	cpl
	ld	b, a
	xor	(hl)
	ld	(hl), b
	inc	hl
	and	b
	ld	(hl), a
	ret

LABEL_346:
	rst  $08
	ld   a, c
	or   a
	jr   z, LABEL_34C
	inc  b
LABEL_34C:
	ld   a, b
	ld   b, c
	ld   c, Port_VDPData
LABEL_350:
	outi
	jp   nz, LABEL_350
	dec  a
	jp   nz, LABEL_350
	ret


LABEL_35A:
	ld	de, $7800
	ld	bc, $380
	ld	hl, 0

LABEL_363:
	rst  $08
	ld   a, c
	or   a
	jr   z, LABEL_369
	inc  b
LABEL_369:
	ld   a, l
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, h
	out  (Port_VDPData), a
	dec  c
	jr   nz, LABEL_369
	djnz	LABEL_369
	ret


; -----------------------------------------------------------------
LABEL_377:
	push	bc
	rst	$08
	ld	b, c
	ld	c, $BE
-
	outi
	ld	a, ($C210)
	nop
	out	(c), a
	jr	nz, -
	ex	de, hl
	ld	bc, $40
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	LABEL_377
	ret
; -----------------------------------------------------------------


LABEL_390:
	push	bc
	rst  $08
	ld   b, c
	ld   c, $BE
LABEL_395:
	outi
	jp   nz, LABEL_395
	ex   de, hl
	ld   bc, $40
	add  hl, bc
	ex   de, hl
	pop  bc
	djnz	LABEL_390
	ret

LABEL_3A4:
	ld   hl, LABEL_3B9
	ld   bc, $14BF
	otir
	ld   a, (LABEL_3B9)
	ld   ($C200), a
	ld   a, (LABEL_3B9+2)
	ld   ($C201), a
	ret


LABEL_3B9:
.db $06, $80, $A0, $81, $FF, $82, $FF, $83, $FF, $84, $FF, $85, $FF, $86, $00, $87
.db $00, $88, $00, $89

LABEL_3CD:
	ld	b, $04
-
	push	bc
	push	de
	call	LABEL_3DA
	pop	de
	inc	de
	pop	bc
	djnz	-
	ret

LABEL_3DA:
	ld	a, (hl)
	inc	hl
	or	a
	ret	z
	ld	c, a
	and	$7F
	ld	b, a
	ld	a, c
	and	$80
-
	rst	$08
	ld	a, (hl)
	out	(Port_VDPData), a
	jp	z, +
	inc	hl
+
	inc	de
	inc	de
	inc	de
	inc	de
	djnz	-
	jp	nz, LABEL_3DA
	inc	hl
	jp	LABEL_3DA


LABEL_3FA:
	ld   b, $04
LABEL_3FC:
	push	bc
	push	de
	call	LABEL_407
	pop  de
	inc  de
	pop  bc
	djnz	LABEL_3FC
	ret

LABEL_407:
	ld   a, (hl)
	inc  hl
	or   a
	ret  z

	ld   c, a
	and  $7F
	ld   b, a
	ld   a, c
	and  $80
LABEL_412:
	di
	rst  $08
	ld   a, (hl)
	out  (Port_VDPData), a
	ei
	jp   z, LABEL_41C
	inc  hl
LABEL_41C:
	inc  de
	inc  de
	inc  de
	inc  de
	djnz	LABEL_412
	jp   nz, LABEL_407
	inc  hl
	jp   LABEL_407



LABEL_429:
	ld	d, $00
	ld	l, d
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	jr	nc, +
	add	hl, de
+
	add	hl, hl
	ret	nc
	add	hl, de
	ret


LABEL_44C:
	or   a
	ld   hl, $0000
	rl   e
	rl   d
	jr   nc, LABEL_45A
	add  hl, bc
	jr   nc, LABEL_45A
	inc  de
LABEL_45A:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_465
	add  hl, bc
	jr   nc, LABEL_465
	inc  de
LABEL_465:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_470
	add  hl, bc
	jr   nc, LABEL_470
	inc  de
LABEL_470:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_47B
	add  hl, bc
	jr   nc, LABEL_47B
	inc  de
LABEL_47B:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_486
	add  hl, bc
	jr   nc, LABEL_486
	inc  de
LABEL_486:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_491
	add  hl, bc
	jr   nc, LABEL_491
	inc  de
LABEL_491:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_49C
	add  hl, bc
	jr   nc, LABEL_49C
	inc  de
LABEL_49C:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4A7
	add  hl, bc
	jr   nc, LABEL_4A7
	inc  de
LABEL_4A7:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4B2
	add  hl, bc
	jr   nc, LABEL_4B2
	inc  de
LABEL_4B2:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4BD
	add  hl, bc
	jr   nc, LABEL_4BD
	inc  de
LABEL_4BD:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4C8
	add  hl, bc
	jr   nc, LABEL_4C8
	inc  de
LABEL_4C8:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4D3
	add  hl, bc
	jr   nc, LABEL_4D3
	inc  de
LABEL_4D3:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4DE
	add  hl, bc
	jr   nc, LABEL_4DE
	inc  de
LABEL_4DE:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4E9
	add  hl, bc
	jr   nc, LABEL_4E9
	inc  de
LABEL_4E9:
	add  hl, hl
	rl   e
	rl   d
	jr   nc, LABEL_4F4
	add  hl, bc
	jr   nc, LABEL_4F4
	inc  de
LABEL_4F4:
	add  hl, hl
	rl   e
	rl   d
	ret  nc

	add  hl, bc
	ret  nc

	inc  de
	ret


; -----------------------------------------------------------------
LABEL_4FE:
	xor	a
	add	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	adc	a, a
	jr	c, +
	cp	e
	jr	c, ++
+
	sub	e
	or	a
++
	ccf
	adc	hl, hl
	ret
; -----------------------------------------------------------------


LABEL_5B1:
	push	hl
	ld   hl, ($C20C)
	ld   a, h
	rrca
	rrca
	xor  h
	rrca
	xor  l
	rrca
	rrca
	rrca
	rrca
	xor  l
	rra
	adc  hl, hl
	jr   nz, LABEL_5C8
	ld   hl, $733C
LABEL_5C8:
	ld   a, r
	xor  l
	ld   ($C20C), hl
	pop  hl
	ret


GameMode_InitIntro:
	ld	hl, Game_mode
	ld	(hl), $02 ; GameMode_LoadIntro
	ret

GameMode_Intro:
	ld	hl, $7C12
	ld	(Cursor_pos), hl
	ld	a, $01
	ld	(Option_total_num), a
	call	CheckOptionSelect
	or	a
	jp	nz, LABEL_634
	
LABEL_5E8:
	ld	hl, $C300
	ld	de, $C301
	ld	bc, $3FF
	ld	(hl), l
	ldir
	ld	iy, Alis_stats
	ld	(iy+weapon), ItemID_ShortSword
	ld	(iy+armor), ItemID_LeatherArmor
	call	UnlockCharacter
	ld	hl, $C600
	ld	(hl), $FF
	ld	hl, $C604
	ld	(hl), $FF
	ld	hl, $404
	ld	($C308), hl
	ld	hl, $610
	ld	($C301), hl
	ld	($C313), hl
	ld	hl, $100
	ld	($C305), hl
	ld	($C311), hl
	ld	hl, 0
	ld	(Current_money), hl
	call	LABEL_42AC
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

LABEL_634:
	ld	a, $08
	ld	($FFFC), a
	ld	hl, $8201
	ld	b, $05
LABEL_63E:
	ld	a, (hl)
	or	a
	jr	nz, LABEL_64D
	inc	hl
	djnz	LABEL_63E
	ld	a, $80
	ld	($FFFC), a
	jp	LABEL_5E8

LABEL_64D:
	ld	a, $80
	ld	($FFFC), a
	call	FadeOut2
	di
	call	LABEL_35A
	ei
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ld	hl, $FFFF
	ld	(hl), :Bank16
	ld	hl, LABEL_B16_BAD8
	ld	de, $5800
	call	LABEL_3FA
	ld	hl, LABEL_B16_BD58
	ld	de, $7E00
	call	LABEL_3FA
	call	LABEL_2FD
LABEL_678:
	ld	hl, LABEL_B12_BE45
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, LABEL_6C5
	ld	hl, LABEL_B12_BE1B
	call	ShowDialogue_B12
-
	push	bc
	call	LABEL_39B1
	pop	bc
	call	LABEL_73A
	jr	z, -
	ld	hl, LABEL_B12_BE35
	call	ShowDialogue_B12
	call	LABEL_3464
	ld	a, $08
	ld	($FFFC), a
	ld	a, ($C2C5)
	ld	h, a
	ld	l, 0
	add	hl, hl
	add	hl, hl
	set	7, h
	ld	de, $C300
	ld	bc, $400
	ldir
	ld	a, $80
	ld	($FFFC), a
	ld	a, ($C316)
	cp	$0B ; GameMode_Dungeon
	ret	nz
	ld	hl, Game_mode
	ld	(hl), $0A ; GameMode_LoadDungeon
	ret

LABEL_6C5:
	ld	hl, LABEL_B12_BE5E
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, LABEL_678
--
	ld	hl, LABEL_B12_BE6F
	call	ShowDialogue_B12
-
	push	bc
	call	LABEL_39B1
	bit	4, c
	pop	bc
	jr	nz, LABEL_6C5
	call	LABEL_73A
	jr	z, -
	ld	hl, LABEL_B12_BA82
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, --
	ld	hl, LABEL_B12_BE82
	call	ShowDialogue_B12
	ld	a, $08
	ld	($FFFC), a
	ld	a, ($C2C5)
	ld	h, $82
	ld	l, a
	ld	(hl), 0
	dec	a
	add	a, a
	ld	e, a
	add	a, a
	add	a, a
	add	a, a
	add	a, e
	add	a, a
	add	a, $18
	ld	e, a
	ld	d, $81
	ld	hl, LABEL_730
	ld	bc, $0A
	ldir
	ex	de, hl
	ld	bc, $08
	add	hl, bc
	ex	de, hl
	ld	hl, LABEL_730
	ld	bc, $0A
	ldir
	ld	a, $80
	ld	($FFFC), a
	ld	hl, Game_mode
	ld	(hl), $02 ; GameMode_LoadIntro
	ret

LABEL_730:
.db $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10

LABEL_73A:
	ld	a, $08
	ld	($FFFC), a
	ld	a, ($C2C5)
	ld	l, a
	ld	h, $82
	ld	a, (hl)
	or	a
	ld	a, $80
	ld	($FFFC), a
	ret

GameMode_LoadIntro:
	call	FadeOut2
	di
	call	LABEL_3E
	call	CallSndInit
	call	LABEL_35A
	ld	hl, Game_mode
	inc	(hl) ; GameMode_Intro
	ld	hl, $258
	ld	($C20E), hl
	ld	hl, LABEL_7BA
	ld	de, $C240
	ld	bc, $20
	ldir
	ld	hl, $C260
	ld	de, $C261
	ld	bc, $9F
	ld	(hl), 0
	ldir
	ld	hl, $C800
	ld	de, $C801
	ld	bc, $FF
	ld	(hl), l
	ldir
	ld	hl, $FFFF
	ld	(hl), :Bank31
	ld	hl, LABEL_B31_A8BD
	ld	de, $4000
	call	LABEL_3CD
	ld	hl, $FFFF
	ld	(hl), :Bank14
	ld	hl, LABEL_B14_BC68
	call	LABEL_6B62
	xor	a
	ld	($C304), a
	ld	($C300), a
	ld	a, $81
	ld	($C004), a
	ld	de, $8006
	rst	$08
	ei
	ld	a, $0C
	call	WaitForVInt
	jp	LABEL_2FD

LABEL_7BA:
.db	$00, $00, $3F, $0F, $0B, $06
.db $2B, $2A, $25, $27, $3B, $01, $3C, $34, $2F, $3C, $00, $00, $3C, $0F, $0B, $06
.db $2B, $2A, $25, $27, $3B, $01, $3C, $34, $2F, $3C

LABEL_7DA:
	ld   a, $08
	ld   ($FFFC), a
	ld   bc, $1000
LABEL_7E2:
	push	bc
	ld   hl, $8001
	ld   de, LABEL_807+1
	ld   bc, $20
LABEL_7EC:
	ld   a, (de)
	inc  de
	cpi
	jr   nz, LABEL_803
	jp   pe, LABEL_7EC
	pop  bc
LABEL_7F6:
	djnz	LABEL_7E2
	ld   a, c
	cp   $08
	jr   nc, LABEL_847
	ld   a, $80
	ld   ($FFFC), a
	ret

LABEL_803:
	pop  bc
	inc  c
	jr   LABEL_7F6


LABEL_807:
.db "PHANTASY STAR         "
.db	"BACKUP RAM"
.db	"PROGRAMMED BY          "
.db	"NAKA YUJI"

LABEL_847:
	ld   hl, $8000
	ld   de, $8001
	ld   bc, $1FFB
	ld   (hl), l
	ldir
	ld   hl, LABEL_3AC4
	ld   de, $8100
	ld   bc, $D8
	ldir
	ld   hl, LABEL_807
	ld   de, $8000
	ld   bc, $40
	ldir
	ld   a, $80
	ld   ($FFFC), a
	ret


GameMode_Ship:
	ld	hl, $2009
	ld	(Fade_timer), hl
-
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jr	nz, _f
	call	LABEL_998
	ld	hl, ($C2F2)
	ld	de, $08
	add	hl, de
	ld	($C2F2), hl
	ld	a, h
	cp	$08
	jr	c, -
__
	ld	a, $16
	call	WaitForVInt
	ld	a, (Fade_timer)
	or	a
	jr	nz, _b
	jr	+
+
	ld	hl, $FFFF
	ld	(hl), :Bank23
	ld	hl, LABEL_B23_B767
	ld	de, $C240
	ld	bc, $11
	ldir
	call	LABEL_A31
	ld	hl, LABEL_B23_B778
	ld	de, $4000
	call	LABEL_3FA
	ld	hl, $FFFF
	ld	(hl), :Bank28
	ld	hl, LABEL_B28_BE88
	call	LABEL_6B62
	ld	hl, $D000
	ld	de, $D300
	ld	bc, $300
	ldir
	ld	hl, $D000
	ld	bc, $100
	ldir
	ld	hl, LABEL_B28_BE00
	call	LABEL_6B62
	xor	a
	ld	($C300), a
	ld	($C304), a
	ld	hl, $D000
	ld	de, $7800
	ld	bc, $700
	di
	call	LABEL_346
	ei
	ld	hl, $D000
	ld	de, $D300
	ld	bc, $300
	ldir
	ld	a, $8F
	ld	($C004), a
	call	FadeIn2
	ld	hl, 0
	ld	($C2F2), hl
	ld	a, $08
	ld	($C307), a
-
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jr	nz, +
	call	LABEL_9E9
	ld	a, ($C307)
	or	a
	jr	nz, -
+
	ld	hl, Game_mode
	ld	(hl), $04 ; GameMode_LoadShip
	call	LABEL_A74
	ld	hl, $800
	ld	($C2F2), hl
-
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jr	nz, +
	call	LABEL_998
	ld	hl, ($C2F2)
	ld	de, $08
	or	a
	sbc	hl, de
	ld	($C2F2), hl
	jr	nc, -
+
	ld	hl, 0
	ld	($C2F2), hl
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ld	a, ($C2E9)
	and	$7F
	ld	l, a
	add	a, a
	add	a, a
	add	a, a
	add	a, l
	ld	l, a
	ld	h, 0
	ld	de, $ABC
	add	hl, de
	xor	a
	ld	($C265), a
	ld	($C264), a
	ld	($C2E9), a
	ld	($C30E), a
	ld	($C307), a
	call	LABEL_787B
	ret

LABEL_998:
	ld	de, ($C2F2)
	ld	a, ($C304)
	ld	h, a
	ld	b, a
	ld	a, ($C307)
	ld	l, a
	or	a
	sbc	hl, de
	ld	a, h
	cp	$E0
	jr	c, +
	sub	$20
+
	ld	h, a
	ld	($C304), a
	ld	a, l
	ld	($C307), a
	ld	a, b
	sub	h
	and $0F
	ret	z
	ld	e, a
	ld	d, 0
	ld	hl, ($C305)
	ld	b, h
	ld	a, l
	sub	e
	cp	$C0
	jr	c, +
	sub	$40
	dec	h
+
	ld	l, a
	ld	a, h
	and	$07
	ld	h, a
	ld	($C305), hl
	cp	b
	call	nz, LABEL_723D
	call	LABEL_733A
	ld	a, ($C2F3)
	cp	$07
	ret	nz
	ld	a, (Fade_timer)
	or	a
	call	nz, LABEL_7B40
	ret

LABEL_9E9:
	ld	de, $02
	ld	a, ($C304)
	sub	e
	cp	$E0
	jr	c, +
	ld	d, $01
	sub	$20
+
	ld	($C304), a
	ld	a, ($C307)
	sub	d
	ld	($C307), a
	cp	$01
	ret	nz
	ld	a, d
	or a
	ret	z
	ld	a, ($C2E9)
	and	$7F
	ld	l, a
	add	a, a
	add	a, a
	add	a, a
	add	a, l
	ld	l, a
	ld	h, 0
	ld	de, LABEL_ABF-6
	add	hl, de
	ld	a, (hl)
	ld	($C308), a
	call	LABEL_A31
	ld	hl, $C240
	ld	de, $C220
	ld	bc, $20
	ldir
	ld	hl, LABEL_B28_BD00
	jp	LABEL_6B62

LABEL_A31:
	ld	a, ($C308)
	and	$03
	add	a, a
	ld	l, a
	add	a, a
	add	a, l
	ld	d, 0
	ld	e, a
	ld	hl, LABEL_A4A
	add	hl, de
	ld	de, $C242
	ld	bc, $06
	ldir
	ret

LABEL_A4A:
.db	$3E, $38, $34, $30, $20
.db $04, $2F, $1F, $0B, $06, $01, $06, $3F
.db $3F, $3E, $3C, $39, $38


GameMode_LoadShip:
	ld	a, ($C2E9)
	and	$7F
	ld	l, a
	add	a, a
	add	a, a
	add	a, a
	add	a, l
	ld	l, a
	ld	h, 0
	ld	de, LABEL_ABF-9
	add	hl, de
	ld	de, LABEL_A8C
	push	de
	call	LABEL_787B

LABEL_A74:
	ld	a, ($C2E9)
	and	$7F
	ld	l, a
	add	a, a
	add	a, a
	add	a, a
	add	a, l
	ld	l, a
	ld	h, 0
	ld	de, LABEL_ABF-6
	add	hl, de
	ld	de, LABEL_A8C
	push	de
	call	LABEL_787B
	
LABEL_A8C:
	xor	a
	ld	(Ctrl_1_held), a
	ld	($C264), a
	ld	a, ($C2E9)
	cp	$83
	ld	a, $10
	jr	c, +
	inc a
+
	ld	($C30E), a
	ld	hl, 0
	ld	($C2F2), hl
	call	GameMode_LoadMap
	ld	hl, $C26F
	ld	de, $C270
	ld	bc, $17
	ld	(hl), 0
	ldir
	call	LABEL_576A
	ld	a, $01
	ld	($C264), a
	ret

LABEL_ABF:
.db $00, $39, $43, $01, $8B, $69, $10, $53
.db $17, $01, $37, $69, $00, $91, $43, $05
.db $17, $17, $00, $47, $35, $01, $27, $74
.db $0F, $20, $58, $00, $47, $35, $02, $33
.db $2D, $13, $18, $1B, $01, $53, $74, $00
.db $1B, $35, $07, $25, $13, $01, $53, $74
.db $02, $33, $2D, $13, $18, $1B, $02, $5B
.db $2D, $00, $1B, $35, $07, $25, $13, $02
.db $5B, $2D, $01, $27, $74, $0F, $20, $58

LABEL_B07:
	ret

GameMode_Map:
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	call	LABEL_576A
	call	LABEL_77AC
	ld	a, ($C265)
	or	a
	jr	nz, +
	ld	a, ($C2D2)
	or	a
	jr	z, +
	xor	a
	ld	($C2D2), a
	call	LABEL_5F63
	or	a
	jr	z, +
	ld	a, $FF
	jp	LABEL_B41
+
	ld	a, (Ctrl_1_held)
	and	Button_1_Mask|Button_2_Mask
	ret	z
	ld	a, ($C265)
	or	a
	ret	nz
	xor	a

LABEL_B41:
	ld	($C29D), a
	ld	hl, Game_mode
	ld	(hl), $0C ; GameMode_LoadInteraction
	ld	a, ($C810)
	ld	($C2D7), a
	ld	hl, $C26F
	ld	de, $C270
	ld	bc, $17
	ld	(hl), 0
	ldir
	ld	hl, $C800
	ld	de, $C801
	ld	bc, $FF
	ld	(hl), 0
	ldir
	ret

GameMode_LoadMap:
	call	FadeOut2
	di
	call	LABEL_3E
	ei
	ld	hl, Game_mode
	inc	(hl) ; GameMode_Map
	xor	a
	ld	($C2D6), a
	ld	($C315), a
	inc	a
	ld	($C2D5), a
	ld	a, ($C308)
	cp	$04
	jr	nc, +
	ld	hl, $FFFF
	ld	(hl), :Bank29
	ld	hl, LABEL_B29_87B8
	ld	de, $4000
	call	LABEL_3FA
	jr	++
+
	ld	hl, $FFFF
	ld	(hl), :Bank22
	ld	hl, LABEL_B22_8570
	ld	de, $4000
	call	LABEL_3FA
++
	call	LABEL_CA6
	call	LABEL_576A
	ld	b, $04
-
	push	bc
	ld	a, $0A
	call	WaitForVInt
	di
	call	LABEL_61F5
	ei
	pop	bc
	djnz	-
	ld	a, ($C301)
	neg
	ld	($C300), a
	ld	a, ($C305)
	ld	($C304), a
	ld	a, ($C309)
	ld	e, a
	ld	d, 0
	ld	hl, LABEL_DC1
	add	hl, de
	ld	a, (hl)
	ld	($C308), a
	add	a, a
	ld	h, a
	add	a, a
	ld	l, a
	add	a, a
	add	a, l
	add	a, h
	ld	l, a
	ld	h, 0
	ld	de, $DF1
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	($C260), de
	ld	a, (hl)
	ld	($C262), a
	inc	hl
	ld	e, (hl)
	ld	d, $1F
	ld	($C26F), de
	inc	hl
	ld	e, (hl)
	ld	d, $0F
	ld	($C273), de
	inc	hl
	ld	e, (hl)
	ld	d, $0F
	ld	($C277), de
	inc	hl
	ld	e, (hl)
	ld	d, $03
	ld	($C27B), de
	inc	hl
	ld	e, (hl)
	ld	d, $0F
	ld	($C27F), de
	inc	hl
	ld	e, (hl)
	ld	d, $07
	ld	($C283), de
	inc	hl
	ld	a, (hl)
	ld	($C263), a
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	ld	de, $C240
	ld	bc, $11
	ldir
	ld	a, ($C30E)
	or	a
	jr	nz, +
	push	hl
	ld	hl, LABEL_DA3
	ld	bc, $0D
	ldir
	pop	hl
	ldi
	ldi
	jp	LABEL_C54
+
	ld	hl, LABEL_DB2
	ld	bc, $0F
	ldir

LABEL_C54:
	pop	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	($C2D9), hl
	call	LABEL_723D
	call	LABEL_744B
	ld	a, $14
	call	LABEL_7764
	rrca
	rrca
	rrca
	rrca
	and	$0F
	ld	($C29E), a
	ld	a, ($C30E)
	cp	$10
	ld	c, $B8
	jr	nc, +
	or	a
	ld	c, $8F
	jr	nz, +
	ld	a, ($C309)
	ld	e, a
	ld	d, 0
	ld	hl, LABEL_DD9
	add	hl, de
	ld	c, (hl)
+
	ld	a, c
	call	LABEL_C97
	ld	de, $8026
	di
	rst	$08
	ei
	jp	LABEL_2FD

LABEL_C97:
	push	hl
	ld	hl, $C2F4
	cp	(hl)
	jr	nz, +
	pop	hl
	ret
+
	ld	($C004), a
	ld	(hl), a
	pop	hl
	ret

LABEL_CA6:
	ld	hl, $C800
	ld	de, $C801
	ld	bc, $FF
	ld	(hl), 0
	ldir
	ld	a, ($C30E)
	or	a
	jp	z, LABEL_CC0
	ld	hl, $C800
	ld	(hl), $09
	ret

LABEL_CC0:
	ld	de, $C800
	ld	bc, $20
	ld	hl, Alis_stats
	ld	a, $01
	call	LABEL_CE3
	ld	hl, Noah_stats
	ld	a, $03
	call	LABEL_CE3
	ld	hl, Odin_stats
	ld	a, $05
	call	LABEL_CE3
	ld	hl, Myau_stats
	ld	a, $07

LABEL_CE3:
	bit 0, (hl)
	ret	z
	ld	(de), a
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ret


.db	$08, $00, $3F, $01
.db $03, $0B, $0F, $2F, $06, $38, $3C, $25
.db $2A, $04, $30, $0C, $08, $08, $00, $3F
.db $01, $03, $0B, $0F, $2F, $06, $38, $3C
.db $25, $2A, $04, $30, $0C, $2F, $3F, $00
.db $3F, $24, $03, $3C, $0F, $3F, $28, $38
.db $3C, $25, $2A, $04, $30, $0C, $3F, $09
.db $00, $3F, $06, $2F, $0B, $0C, $04, $2A
.db $25, $3C, $38, $30, $03, $02, $08, $09
.db $08, $0C, $08, $00, $3F, $06, $2F, $0B
.db $0C, $04, $2A, $25, $3C, $38, $30, $03
.db $02, $08, $08, $0C, $04, $2A, $00, $3F
.db $06, $2F, $0B, $0C, $04, $2A, $25, $3C
.db $38, $30, $03, $02, $08, $2A, $2A, $2A
.db $2F, $00, $3F, $06, $2F, $0B, $0C, $04
.db $2A, $25, $3C, $38, $30, $03, $02, $08
.db $2F, $0B, $06, $3F, $00, $3F, $06, $2F
.db $0B, $0C, $04, $2A, $25, $3C, $38, $30
.db $03, $02, $3F, $3F, $3C, $38, $00, $00
.db $3F, $06, $2F, $0B, $0C, $04, $2A, $25
.db $3C, $38, $30, $03, $02, $08, $00, $00
.db $00, $3C, $00, $3F, $06, $2F, $0B, $0C
.db $04, $2A, $25, $3C, $38, $30, $03, $02
.db $08, $3C, $3C, $3C

LABEL_DA3:
.db	$00, $3F, $2B, $0B
.db $2F, $37, $0F, $38, $34, $06, $01, $2A
.db $25, $00, $00

LABEL_DB2:
.db	$00, $3F, $02, $03, $0B
.db $0F, $20, $38, $34, $2F, $2A, $25, $2F
.db $2A, $25

LABEL_DC1:
.db	$00, $01, $02, $03, $04, $04
.db $04, $05, $05, $05, $05, $05, $06, $06
.db $07, $07, $07, $07, $07, $08, $08, $09
.db $09, $0A

LABEL_DD9:
.db	$82, $83, $84, $84, $87, $87
.db $87, $88, $88, $88, $88, $88, $87, $87
.db $87, $88, $87, $88, $88, $84, $84, $88
.db $88, $85, $00, $80, $0D, $01, $01, $00
.db $01, $01, $00, $1D, $EB, $0C, $35, $A9
.db $76, $A2, $0D, $00, $00, $01, $01, $00
.db $01, $1D, $FC, $0C, $B9, $A9, $00, $80
.db $0E, $00, $00, $00, $00, $00, $00, $1D
.db $0D, $0D, $E3, $A9, $00, $80, $0E, $00
.db $00, $00, $00, $00, $00, $1D, $0D, $0D
.db $49, $AA, $00, $80, $18, $00, $00, $00
.db $00, $00, $00, $16, $1E, $0D, $4A, $AA
.db $62, $87, $18, $00, $00, $00, $00, $00
.db $00, $16, $31, $0D, $70, $AB, $42, $8F
.db $18, $00, $00, $00, $00, $00, $00, $16
.db $44, $0D, $8B, $AC, $D9, $93, $18, $00
.db $00, $00, $00, $00, $00, $16, $57, $0D
.db $F7, $AC, $07, $9C, $18, $00, $00, $00
.db $00, $00, $00, $16, $6A, $0D, $5F, $AE
.db $8B, $9D, $18, $00, $00, $00, $00, $00
.db $00, $16, $7D, $0D, $71, $AE, $50, $A2
.db $18, $00, $00, $00, $00, $00, $00, $16
.db $90, $0D, $37, $AF

GameMode_Road:
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jr	nz, +
	ld	a, ($C2EA)
	ld	(Ctrl_1_held), a
	call	LABEL_576A
	ld	a, ($C265)
	or	a
	ret	nz
	ld	a, ($C2EB)
	dec	a
	ld	($C2EB), a
	ret	nz
+
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ld	a, ($C2E9)
	add	a, a
	add	a, a
	add	a, a
	ld	l, a
	ld	h, $00
	ld	de, LABEL_F0C-3
	add	hl, de
	xor	a
	ld	($C265), a
	ld	($C2E9), a
	ld	($C2EA), a
	ld	($C2EB), a
	call	LABEL_787B
	ret

GameMode_LoadRoad:
	ld	a, ($C2E9)
	add	a, a
	add	a, a
	add	a, a
	ld	l, a
	ld	h, $00
	ld	de, LABEL_F0C-8
	add	hl, de
	ld	a, (hl)
	ld	($C2EA), a
	inc	hl
	ld	a, (hl)
	ld	($C2EB), a
	inc	hl
	ld	de, $EF5
	push	de
	call	LABEL_787B
	call	GameMode_LoadMap
	ld	hl, $C26F
	ld	de, $C270
	ld	bc, $17
	ld	(hl), $00
	ldir
	ld	hl, $01
	ld	($C27B), hl
	ret

LABEL_F0C:
.db $04, $0C, $00
.db $38, $51, $05, $21, $2C, $01, $0B, $00
.db $46, $46, $05, $27, $21, $01, $04, $01
.db $33, $64, $0E, $2A, $20, $08, $0C, $00
.db $38, $48, $04, $21, $53, $02, $0B, $00
.db $3A, $46, $06, $54, $20, $02, $04, $01
.db $2B, $64, $10, $43, $1E


GameMode_Dungeon:
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $08
	call	WaitForVInt
	call	LABEL_65EE
	ld	a, ($C2D2)
	or	a
	ret	z
	xor	a
	ld	($C2D2), a
	ld	a, ($C2E3)
	ld	b, a
	call	LABEL_5B1
	cp	b
	ret	nc
	ld	b, $01
	call	LABEL_6BCA
	ret	nz
	xor	a
	ld	($C2D2), a
	ld	a, ($C2E4)
	call	LABEL_5FD8
	or	a
	ret	z
	call	LABEL_5FFE
	call	LABEL_100F
	ld	a, ($C800)
	or	a
	call	nz, LABEL_1BE1
	ret


GameMode_LoadDungeon:
	call	FadeOut2
	call	LABEL_6DE2
	ld	hl, Game_mode
	inc	(hl) ; GameMode_Dungeon
	ld	hl, $FFFF
	ld	(hl), :Bank16
	ld	hl, LABEL_B16_BAD8
	ld	de, $5800
	call	LABEL_3FA
	ld	hl, LABEL_B16_BD58
	ld	de, $7E00
	call	LABEL_3FA
	ld	a, $39
	call	Inventory_FindFreeSlot
	jr	nz, +
	ld	a, $FF
	ld	($C315), a
+
	call	LABEL_FF3
	xor	a
	ld	($C304), a
	ld	($C300), a
	ld	($C2D5), a
	ld	($C2D6), a
	ld	($C2D3), a
	ld	de, $8006
	di
	rst	$08
	ei
	call	LABEL_2FD
	ld	b, $01
	call	LABEL_6963
	ld	a, ($C315)
	or	a
	ret	nz
	ld	hl, LABEL_B12_B392
	call	ShowDialogue_B12
	call	LABEL_3464
	call	LABEL_1BE1
	ld	a, ($C315)
	or	a
	jr	z, +
	ld	a, $FF
	ld	($C315), a
	call	LABEL_6D7F
	jp	FadeIn2

+
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

LABEL_FF3:
	ld	hl, $C800
	ld	de, $C801
	ld	bc, $FF
	ld	(hl), $00
	ldir
	ld	a, $D0
	ld	($C900), a
	call	LABEL_6D56
	xor	a
	ld	($C29E), a
	jp	LABEL_6AE5

LABEL_100F:
	ld   a, ($C2E6)
	cp   $48
	ld   c, $92
	jr   z, LABEL_101E
	cp   $49
	jr   z, LABEL_1022
	ld   c, $89
LABEL_101E:
	ld   a, c
	ld   ($C004), a
LABEL_1022:
	ld   hl, $C2AB
	ld   b, $0C
LABEL_1027:
	ld   a, b
	dec  a
	ld   (hl), a
	dec  hl
	djnz	LABEL_1027
	xor  a
	ld   ($C2EF), a
	call	LABEL_30ED
	ld   b, $04
LABEL_1036:
	ld   a, b
	dec  a
	call	LABEL_187D
	jp   nz, LABEL_1043
	djnz	LABEL_1036
	jp   LABEL_1656

LABEL_1043:
	ld   b, $04
LABEL_1045:
	ld   a, b
	dec  a
	call	LABEL_187D
	inc  hl
	ld   a, (hl)
	or   a
	jp   nz, LABEL_1055
	djnz	LABEL_1045
	jp   LABEL_1656

LABEL_1055:
	ld   hl, $C2AC
	ld   de, $C2AD
	ld   bc, $000F
	ld   (hl), $00
	ldir
	ld   a, $FF
	ld   ($C29D), a
	xor  a
	ld   ($C267), a
	ld   ($C2D4), a
	call	LABEL_30C3
	call	LABEL_2ED9
	
LABEL_1074:
	call	LABEL_187A
	jp	z, LABEL_1080
	inc	hl
	ld	a, (hl)
	or	a
	jp	nz, LABEL_108A

LABEL_1080:
	ld	a, ($C267)
	inc	a
	ld	($C267), a
	jp	LABEL_10B7

LABEL_108A:
	ld	de, $0C
	add	hl, de
	ld	a, (hl)
	or	a
	jr	nz, LABEL_1080
	call	LABEL_3105
	call	LABEL_30D5
	call	LABEL_2EAC
	ld	hl, $7882
	ld	(Cursor_pos), hl
	ld	a, $04
	ld	(Option_total_num), a
	call	CheckOptionSelect
	bit	Button_1, c
	jp	nz, LABEL_1121	; jump if we pressed the 1 button (cancel)
	ld	hl, BattleMenu_OptionTbl
	call	GetPtrAndJump
	call	LABEL_2ECD

LABEL_10B7:
	ld	a, ($C267)
	cp	$04
	jp	c, LABEL_1074
	cp	$05
	jp	nc, LABEL_163E
	xor	a
	ld	($C267), a
	call	LABEL_30B7
	call	LABEL_30E1
	call	LABEL_18F2
	ld	hl, $C2A0
	ld	b, $0C
	
LABEL_10D6:
	push	bc
	push	hl
	ld	a, (hl)
	cp	$04
	jp	nc, LABEL_10E4
	call	LABEL_1148
	jp	LABEL_10E7


LABEL_10E4:
	call	LABEL_128C

LABEL_10E7:
	ld	hl, $C441
	ld	de, $10
	ld	b, $08
	
-
	ld	a, (hl)
	or	a
	jp	nz, LABEL_10FC
	add	hl, de
	djnz	-
	pop	hl
	pop	bc
	jp	LABEL_1656

LABEL_10FC:
	ld	hl, Char_stats
	ld	de, $10
	ld	b, $04
	
-
	ld	a, (hl)
	or	a
	jp	nz, LABEL_1111
	add	hl, de
	djnz	-
	pop	hl
	pop	bc
	jp	LABEL_1602

LABEL_1111:
	pop	hl
	pop	bc
	inc	hl
	ld	a, ($C267)
	cp	$05
	jp	z, LABEL_163E
	djnz	LABEL_10D6
	jp	LABEL_1043

LABEL_1121:
	call	LABEL_2ECD
	
LABEL_1124:
	ld	a, ($C267)
	or	a
	jr	z, +
	dec	a
+
	ld	($C267), a
	jp	z, LABEL_1074
	call	LABEL_187A
	jp	z, LABEL_1124
	inc	hl
	ld	a, (hl)
	or	a
	jp	z, LABEL_1124
	ld	de, $0C
	add	hl, de
	ld	a, (hl)
	or	a
	jr	nz, LABEL_1124
	jp	LABEL_1074

LABEL_1148:
	ld	($C267), a
	call	LABEL_187A
	ret	z
	ld	a, ($C2D4)
	or	a
	ret	nz
	push	hl
	pop	iy
	ld	a, (iy+1)
	or	a
	ret	z
	ld	a, (iy+$D)
	or	a
	jr	z, LABEL_1188
	ld	a, ($C267)
	ld	($C2C2), a
	call	LABEL_5B1
	and	$01
	inc	a
	ld	b, a
	ld	a, (iy+$D)
	sub	b
	jr	nc, +
	xor	a
+
	ld	(iy+$D), a
	or	a
	ld	hl, LABEL_B12_B20A
	jr	z, +
	ld	hl, LABEL_B12_B1FC
+
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1188:
	call	LABEL_2EAC
	call	LABEL_1BCE
	cp	$01
	jp	nz, LABEL_11DC
	ld	a, ($C267)
	ld	($C2C2), a
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, Char_stats+weapon
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (hl)
	cp	$09
	jr	z, LABEL_11CB
	cp	$0B
	jr	z, LABEL_11CF
	cp	$0D
	jr	z, LABEL_11D3
	call	LABEL_18A9
	
LABEL_11B5:
	call	LABEL_5B1
	and	$07
	add	a, $04
	call	LABEL_187D
	jp	z, LABEL_11B5
	push	hl
	pop	ix
	call	LABEL_121D
	jp	LABEL_120B

LABEL_11CB:
	ld	d, $FB
	jr	LABEL_11D5

LABEL_11CF:
	ld	d, $F6
	jr	LABEL_11D5

LABEL_11D3:
	ld	d, $EC

LABEL_11D5:
	ld	e, a
	call	LABEL_1EEE
	jp	LABEL_120B

LABEL_11DC:
	cp	$03
	jp	nz, LABEL_11F1
	ld	a, c
	ld	($C2C2), a
	ld	a, b
	and	$1F
	ld	hl, LABEL_1A8A
	call	GetPtrAndJump
	jp	LABEL_120B

LABEL_11F1:
	cp	$04
	jp	nz, LABEL_120B
	ld	a, ($C267)
	ld	($C2C2), a
	ld	a, b
	ld	($C2C4), a
	call	Inventory_FindFreeSlot
	jr nz, LABEL_1212
	ld	($C29B), hl
	call	LABEL_2201

LABEL_120B:
	call	LABEL_3105
	call	LABEL_2ECD
	ret

LABEL_1212:
	ld	hl, LABEL_B12_BEA1
	call	ShowDialogue_B12
	call	LABEL_3464
	jr	LABEL_120B

LABEL_121D:
	ld	a, (iy+8)
	bit 7, (iy+0)
	jr	z, +
	ld	c, a
	rrca
	and	$7F
	add	a, c
	jr	nc, +
	ld	a, $FF
+
	call	LABEL_1279
	ld	c, a
	ld	a, (ix+9)
	call	LABEL_1279
	sub	c
	jr	c, LABEL_125E
	cp	$10
	jr	c, LABEL_1251
	rrca
	jr	c, LABEL_1251
	ld	a, $BB
	ld	($C004), a
	ld	hl, LABEL_B12_B108
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1251:
	call	LABEL_5B1
	and	$1F
	cp	(iy+5)
	jr	z, +
	jr	nc, LABEL_1251

+
	cpl

LABEL_125E:
	push	af
	ld	a, $AD
	ld	($C004), a
	call	LABEL_7BAC
	pop	af
	add	a, (ix+1)
	jr	c, + 
	xor	a
+
	ld	(ix+1), a
	ret	nz
	ld	(ix+0), a
	ld	(ix+$D), a
	ret

LABEL_1279:
	rrca
	and	$7F
	ld	b, a
	rrca
	and	$3F
	ld	e, a
	call	LABEL_5B1
	ld	h, a
	call	LABEL_429
	ld	a, e
	add	a, b
	add	a, h
	ret

LABEL_128C:
	call	LABEL_187D
	ret	z
	push	hl
	pop	iy
	ld	a, (iy+$D)
	or	a
	jr	z, LABEL_12B9
	call	LABEL_5B1
	and	$01
	inc	a
	ld	b, a
	ld	a, (iy+$D)
	sub	b
	jr	nc, +
	xor	a
+
	ld	(iy+$D), a
	or	a
	ld	hl, LABEL_B12_B21D
	jr	z, +
	ld	hl, LABEL_B12_B203
+
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_12B9:
	ld	a, ($C2E8)
	and	$07
	ld	hl, LABEL_12C4
	jp	GetPtrAndJump


LABEL_12C4:
.dw LABEL_1305
.dw LABEL_1386
.dw LABEL_13CC
.dw LABEL_13FF
.dw LABEL_1421
.dw LABEL_149D
.dw LABEL_151A
.dw LABEL_1561

LABEL_12D4:
	ld	a, ($C2E8)
	and	$10
	jr	z, LABEL_12FA
	call	LABEL_5B1
	and	$03
	ld	c, a
	ld	a, ($C2EF)
	ld	b, a
	and	$7F
	sub	c
	jr	nc, +
	xor	a
+
	or	a
	jr	z, LABEL_12FA
	bit	7, b
	jr	z, +
	or	$80
+
	ld	($C2EF), a
	ret

LABEL_12FA:
	xor	a
	ld	($C2EF), a
	ld	hl, LABEL_B12_B1C1
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1305:
	ld	a, ($C2EF)
	or	a
	call	nz, LABEL_12D4
	
LABEL_130C:
	call	LABEL_5B1
	and	$03
	call	LABEL_187D
	jp	z, LABEL_130C
	ld	($C2C2), a
	push	hl
	pop	ix
	push	af
	ld	($C2EE), a
	call	LABEL_2F93
	call	LABEL_1573
	ld	a, ($C2ED)
	or	a
	push	af
	call	LABEL_18CE
	pop	af
	jr	nz, LABEL_1344
	ld	a, ($C2EF)
	or	a
	ld	hl, LABEL_B12_B1A3
	jr	nz, +
	ld	hl, LABEL_B12_B118
+
	call	ShowDialogue_B12
	call	LABEL_3464

LABEL_1344:
	pop	af
	call	LABEL_187D
	jr	nz, LABEL_1379
	ld	hl, LABEL_B12_B728
	call	ShowDialogue_B12
	ld	a, ($C2E6)
	cp	$46
	jr	nz, LABEL_1376
	ld	a, ($C2C2)
	cp	$01
	jr	nz, LABEL_1376
	ld	hl, Char_stats
	ld	de, $10
	xor	a
	ld	b, $04
	
-
	or	(hl)
	ld	(hl), $00
	add	hl, de
	djnz	-
	or	a
	jr	z, LABEL_1376
	ld	hl, LABEL_B12_BF3B
	call	ShowDialogue_B12

LABEL_1376:
	call	LABEL_3464

LABEL_1379:
	ld	b, $04
	
-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	call	LABEL_30B7
	ret

LABEL_1386:
	call	LABEL_5B1
	and	$03
	jp	nz, LABEL_1305
	ld	a, ($C2EF)
	and	$80
	call	nz, LABEL_12D4
	ld	a, ($C2EF)
	and	$80
	jr	z, _f
	ld	hl, LABEL_B12_B1B2
	call	ShowDialogue_B12
	jp	LABEL_3464
__
	call	LABEL_5B1
	and $03
	call	LABEL_187D
	jr	z, _b
	ld	($C2C2), a
	ld	a, $0D
	add	a, l
	ld	l, a
	ld	a, (hl)
	or	a
	jp	nz, LABEL_1305
	ld	(hl), $03
	ld	a, $A1
	ld	($C004), a
	ld	hl, LABEL_B12_B1EE
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_13CC:
	ld	a, (iy+1)
	cp	$1E
	jr	c, +
	call	LABEL_5B1
	and	$07
	jp	nz, LABEL_1305
+
	ld	b, (iy+6)
	ld	a, (iy+1)
	add	a, $50
	jr	nc, +
	ld	a, $FF
+
	cp	b
	jr	c, +
	ld	a, b
+
	ld	(iy+1), a
	ld	a, $A1
	ld	($C004), a
	call	LABEL_3105
	ld	hl, LABEL_B12_B1D8
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_13FF:
	call	LABEL_5B1
	and	$0F
	jp	nz, LABEL_1305
	ld	a, (iy+0)
	and	$80
	jp	nz, LABEL_1305
	set	7, (iy+0)
	ld	a, $A1
	ld	($C004), a
	ld	hl, LABEL_B12_BCC2
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1421:
	call	LABEL_5B1
	and	$03
	jp	nz, LABEL_1305
	call	LABEL_142C
	
LABEL_142C:
	ld	a, ($C2EF)
	and	$80
	call	nz, LABEL_12D4
	ld	b, $04
	
-
	ld	a, b
	sub	$04
	neg
	call	LABEL_187D
	jr	nz, LABEL_1443
	djnz	-
	ret
LABEL_1443
	call	LABEL_5B1
	and	$03
	call	LABEL_187D
	jp	z, LABEL_1443
	ld	($C2C2), a
	ld	($C2EE), a
	call	LABEL_2F93
	call	LABEL_5B1
	and	$03
	add	a, $F6
	ld	b, a
	ld	a, ($C2EF)
	and	$80
	ld	a, b
	call	z, LABEL_15C2
	ld	a, $80
	ld	($C88A), a
	call	LABEL_18CE
	ld	a, ($C2EF)
	and	$80
	jr	z, +
	ld	hl, LABEL_B12_B1B2
	call	ShowDialogue_B12
	call	LABEL_3464
+
	ld	a, ($C2C2)
	call	LABEL_187D
	jr	nz, +
	ld	hl, LABEL_B12_B728
	call	ShowDialogue_B12
	call	LABEL_3464
+
	ld	b, $04
	
-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	jp	LABEL_30B7

LABEL_149D:
	call	LABEL_5B1
	and	$03
	jp	nz, LABEL_1305
	ld	c, $D8
	
LABEL_14A7:
	ld	b, $04
	
LABEL_14A9:
	push	bc
	ld	a, ($C2EF)
	and	$80
	call	nz, LABEL_12D4
	pop	bc
	push	bc
	ld	a, b
	sub	$04
	neg
	call	LABEL_187D
	jr	z, LABEL_1501
	ld	($C2C2), a
	ld	($C2EE), a
	push	bc
	call	LABEL_2F93
	pop	bc
	call	LABEL_1505
	ld	a, $C0
	ld	($C88A), a
	call	LABEL_18CE
	ld	a, ($C2EF)
	and	$80
	jr	z, +
	ld	hl, LABEL_B12_B1B2
	call	ShowDialogue_B12
	call	LABEL_3464
+
	ld	a, ($C2C2)
	call	LABEL_187D
	jr	nz, +
	ld	hl, LABEL_B12_B728
	call	ShowDialogue_B12
	call	LABEL_3464
+
	ld	b, $04
	
-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	call	LABEL_30B7

LABEL_1501:
	pop	bc
	djnz	LABEL_14A9
	ret

LABEL_1505:
	ld	a, c
	cp	$FF
	jp	z, LABEL_1579
	ld	a, ($C2EF)
	and	$80
	ret	nz
	call	LABEL_5B1
	and	$0F
	add	a, c
	jp	LABEL_15C2

LABEL_151A:
	ld	a, (Odin_stats)
	or	a
	jr	z, +
	ld	a, (Odin_stats+shield)
	cp	$1F
	jp	z, LABEL_1305
+
	ld	a, ($C2EF)
	or	a
	call	nz, LABEL_12D4
	
LABEL_152F:
	call	LABEL_5B1
	and	$03
	call	LABEL_187D
	jp	z, LABEL_152F
	ld	($C2C2), a
	ld	($C2EE), a
	push	hl
	call	LABEL_2F93
	pop	hl
	xor	a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	call	LABEL_18CE
	ld	hl, LABEL_B12_BE93
	call	ShowDialogue_B12
	call	LABEL_3464
	ld	b, $04
	
-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	jp	LABEL_30B7

LABEL_1561:
	ld	a, ItemID_Crystal
	ld	($C2C4), a
	call	Inventory_FindFreeSlot
	ld	c, $01
	jp	nz, LABEL_14A7
	ld	c, $FF
	jp	LABEL_14A7

LABEL_1573:
	ld	a, ($C2EF)
	or	a
	jr	nz, LABEL_15AD

LABEL_1579:
	ld	a, (iy+8)
	bit	7, (iy+0)
	jr	z, +
	ld	c, a
	rrca
	and	$7F
	add	a, c
	jr	nc, +
	ld	a, $FF
+
	bit	6, (iy+0)
	jr	z, +
	ld	c, a
	rrca
	rrca
	and	$3F
	ld	b, a
	ld	a, c
	sub	b
+
	call	LABEL_1279
	ld	c, a
	ld	a, (ix+9)
	call	LABEL_1279
	sub	c
	jr	c, LABEL_15C2
	cp	$10
	jr	c, LABEL_15B2
	rrca
	jr	c, LABEL_15B2

LABEL_15AD:
	xor	a
	ld	($C2ED), a
	ret

LABEL_15B2:
	call	LABEL_5B1
	and	$1F
	cp	(ix+5)
	jr	z, +
	jr	nc, LABEL_15B2
+
	rrca
	and	$7F
	cpl

LABEL_15C2:
	add	a, (ix+1)
	jr	c, +
	xor	a
+
	ld	(ix+1), a
	jr	nz, +
	ld	(ix+0), a
	ld	(ix+$D), a
+
	ld	a, $FF
	ld	($C2ED), a
	ret

LABEL_15D9:
	call	LABEL_319E
LABEL_15DC:
	ld   hl, $C800
	ld   de, $C801
	ld   bc, $00FF
	ld   (hl), $00
	ldir
	call	LABEL_576A
	ld   a, ($C29E)
	or   a
	jp   nz, LABEL_15F9
	call	LABEL_6B3A
	jp   LABEL_15FC

LABEL_15F9:
	call	LABEL_3D36
LABEL_15FC:
	ld   a, $10
	call	WaitForVInt
	ret


LABEL_1602:
	ld	a, ($C2E6)
	cp	$31
	jr	z, LABEL_160D
	cp	$4A
	jr	nz, LABEL_1613

LABEL_160D:
	ld	a, $D8
	ld	($C004), a
	ret

LABEL_1613:
	cp	$46
	jr	nz, +
	ld	hl, $C230
	ld	b, $10
	
-
	ld	(hl), $30
	inc	hl
	djnz	-

+
	ld	a, $94
	ld	($C004), a
	ld	a, (Party_curr_num)
	or	a
	ld	hl, LABEL_B12_BD17
	call	nz, ShowDialogue_B12
	ld	hl, LABEL_B12_BD23
	call	ShowDialogue_B12
	ld	hl, Game_mode
	ld	(hl), $02 ; GameMode_LoadIntro
	jp	LABEL_3464

LABEL_163E:
	push	af
	call	LABEL_15D9
	call	UpdateCharStats
	ld	a, $D8
	ld	($C004), a
	pop	af
	cp	$05
	ret	nz
	ld	a, ($C29E)
	or	a
	ret	nz
	jp	LABEL_688C

LABEL_1656:
	ld   a, ($C2E6)
	cp   $31
	jr   nz, LABEL_1663
	ld   a, $D8
	ld   ($C004), a
	ret

LABEL_1663:
	cp   $46
	jr   nz, LABEL_1671
	ld   hl, $C230
	ld   b, $10
LABEL_166C:
	ld   (hl), $30
	inc  hl
	djnz	LABEL_166C
LABEL_1671:
	ld   a, $AF
	ld   ($C004), a
	call	LABEL_15D9

LABEL_1679:
	ld	a, ($C2E6)
	cp	$48
	jr	z, LABEL_1683
	cp	$49
	jr	nz,LABEL_1688
	
LABEL_1683:
	ld	b, $B4
	call	LABEL_2D49
	
LABEL_1688:
	ld	a, $D8
	ld	($C004), a
	ld	hl, LABEL_B12_B71B
	call	ShowDialogue_B12
	call	LABEL_170D
	call	UpdateCharStats
	ld	hl, ($C2DD)
	ld	a, ($C2DF)
	or	l
	or	h
	ret	z
	ld	hl, LABEL_B12_BCE1
	call	ShowDialogue_B12
	call	LABEL_16B2
	call	LABEL_2D25
	jp	LABEL_28DB

LABEL_16B2:
	ld   hl, $FFFF
	ld   (hl), :Bank20
	ld   hl, LABEL_B20_8000
	ld   de, $C258
	ld   bc, $0008
	ldir
	ld   hl, $C240
	ld   de, $C220
	ld   bc, $0020
	ldir
	ld   hl, LABEL_B20_8008
	ld   de, $6000
	call	LABEL_3FA
	ld   hl, $C800
	ld   de, $C801
	ld   bc, $00FF
	ld   (hl), $00
	ldir
	ld   a, $0D
	ld   ($C800), a
	call	LABEL_576A
	ld   a, $16
	call	WaitForVInt
	ret


; Data from 16F1 to 187C (396 bytes)
UnlockCharacter:
	ld	(iy+status), 1
	ld	(iy+level), 1
	push	iy
	call	UpdateCharStats
	pop	iy
	ld	a, (iy+max_hp)
	ld	(iy+curr_hp), a
	ld	a, (iy+max_mp)
	ld	(iy+curr_mp), a
	ret

LABEL_170D:
	ld	hl, (CurrentBattle_EXPReward)
	ld	($C2C5), hl
	ld	a, l
	or	h
	ret	z
	ld	hl, LABEL_B12_B604
	call	ShowDialogue_B12
	ld	iy, Alis_stats
	ld	de, B03_AlisLevelTable
	xor	a
	ld	($C2C2), a
	call	CalculateExp
	ld	iy, Myau_stats
	ld	de, B03_MyauLevelTable
	ld	a, $01
	ld	($C2C2), a
	call	CalculateExp
	ld	iy, Odin_stats
	ld	de, B03_OdinLevelTable
	ld	a, $02
	ld	($C2C2), a
	call	CalculateExp
	ld	iy, Noah_stats
	ld	de, B03_NoahLevelTable
	ld	a, $03
	ld	($C2C2), a 

CalculateExp:
	bit	0, (iy+status)
	ret	z
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	l, (iy+level)
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	push	hl
	pop	ix		; ix = level table
	ld	e, (iy+exp)
	ld	d, (iy+exp+1)	; de = char's exp
	ld	hl, (CurrentBattle_EXPReward)
	add	hl, de
	jr	nc, +
	ld	hl, $FFFF ; Set exp to 65535 if overflow is detected
+
	ld	(iy+exp), l
	ld	(iy+exp+1), h
	ret	c
	ld	a, (iy+level)
	cp	30
	ret	z
	ld	a, h
	sub	(ix+5)
	ret	c
	jr	nz, +
	ld	a, l
	sub	(ix+4)
	ret	c
+
	ld	a, $BA
	ld	($C004), a
	ld	hl, LABEL_B12_B621
	call	ShowDialogue_B12
	ld	hl, $FFFF
	ld	(hl), :Bank03
	inc	(iy+level)
	ld	a, (ix+6)
	cp	(iy+battle_magic_num)
	jr	nz, +
	ld	a, (ix+7)
	cp	(iy+map_magic_num)
	ret	z
+
	ld	hl, LABEL_B12_B635
	jp	ShowDialogue_B12


UpdateCharStats:
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	iy, Alis_stats
	ld	de, B03_AlisLevelTable-8
	call	+
	ld	iy, Myau_stats
	ld	de, B03_MyauLevelTable-8
	call	+
	ld	iy, Odin_stats
	ld	de, B03_OdinLevelTable-8
	call	+
	ld	iy, Noah_stats
	ld	de, B03_NoahLevelTable-8


; iy = char stats
+:
	bit	0, (iy+status)
	ret	z
	ld	(iy+status), $01
	ld	(iy+$D), $00
	ld	l, (iy+level)
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	push	hl
	pop	ix	; ix = level table
	ld	a, (ix+0)
	ld	(iy+max_hp), a
	ld	l, (iy+weapon)
	ld	h, $00
	ld	de, LABEL_183A
	add	hl, de
	ld	a, (hl)
	add	a, (ix+1)
	ld	(iy+attack), a
	ld	l, (iy+armor)
	ld	h, $00
	add	hl, de
	ld	a, (hl)
	ld	l, (iy+shield)
	ld	h, $00
	add	hl, de
	add	a, (hl)
	add	a, (ix+2)
	ld	(iy+defense), a
	ld	a, (ix+3)
	ld	(iy+max_mp), a
	ld	a, (ix+6)
	ld	(iy+battle_magic_num), a
	ld	a, (ix+7)
	ld	(iy+map_magic_num), a
	ret


LABEL_183A:
.db	$00, $03, $04, $0C, $0A, $0A, $0A
.db $15, $1F, $12, $1E, $1E, $2E, $32, $3C, $50, $05, $05, $0F, $14, $1E, $1E, $3C
.db $50, $28, $03, $08, $0F, $17, $28, $1E, $28, $32, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00


LABEL_187A:
	ld	a, ($C267)

LABEL_187D:
	push	af
	add  a, a
	add  a, a
	add  a, a
	add  a, a
	ld   hl, Char_stats
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	pop  af
	bit  0, (hl)
	ret

LABEL_188E:
	push	hl
	call	LABEL_187D
	pop  hl
	ret  nz

	push	af
	push	bc
	push	de
	push	hl
	ld   ($C2C2), a
	ld   hl, LABEL_B12_B730
	call	ShowDialogue_B12
	call	LABEL_3464
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret


LABEL_18A9:
	push	iy
	ld	($C80A), a
	ld	a, $0B
	ld	($C800), a
	call	LABEL_18B9
	pop	iy
	ret

LABEL_18B9:
	ld	a, $08
	call	WaitForVInt
	call	LABEL_576A
	ld	a, ($C800)
	or	a
	jp	nz, LABEL_18B9
	ld	a, $08
	call	WaitForVInt
	ret

LABEL_18CE:
	push	iy
	ld	a, $FF
	ld	($C29F), a
	ld	a, ($C2F1)
	ld	($C004), a
	
LABEL_18DB:
	ld	a, $08
	call	WaitForVInt
	call	LABEL_576A
	ld	a, ($C29F)
	or	a
	jp	nz, LABEL_18DB
	ld	a, $08
	call	WaitForVInt
	pop	iy
	ret

LABEL_18F2:
	ld	hl, $C2A0
	ld	b, $0C
	
-
	call	LABEL_5B1
	and	$0F
	cp	$0C
	jr	nc, -
	add	a, $A0
	ld	e, a
	ld	a, $C2
	adc	a, $00
	ld	d, a
	ld	c, (hl)
	ld	a, (de)
	ex	de, hl
	ld	(hl), c
	ld	(de), a
	ex	de, hl
	inc	hl
	djnz	-
	ret


; ========================================
BattleMenu_OptionTbl:
.dw	BattleMenu_Attack
.dw	BattleMenu_Magic
.dw	BattleMenu_Item
.dw	BattleMenu_Talk
.dw BattleMenu_Run
; ========================================

BattleMenu_Attack:
	ld	bc, $01
	xor	a
	call	LABEL_1BB9
	ld	a, ($C267)
	inc	a
	ld	($C267), a
	ret

BattleMenu_Talk:
	call	LABEL_2ECD
	call	LABEL_30B7
	call	LABEL_30E1
	ld	a, ($C267)
	ld	($C2C2), a
	ld	hl, LABEL_B12_B128
	call	ShowDialogue_B12
	ld	a, ($C2E8)
	and	$80
	jr	z, LABEL_1951
	ld	a, ($C448)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	jr	nc, LABEL_1964
LABEL_1951
	ld	a, $04
	ld	($C267), a
	ld	a, $FF
	ld	($C2D4), a
	ld	hl, LABEL_B12_B13D
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1964:
	ld	hl, LABEL_B12_B132
	call	ShowDialogue_B12
	
-
	call	LABEL_5B1
	and	$0F
	cp	$09
	jr	nc, -
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld	de, LABEL_198A
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	call	ShowDialogue_B12
	ld	a, $06
	ld	($C267), a
	jp	LABEL_3464


LABEL_198A:
.dw	LABEL_B12_BAAE
.dw	LABEL_B12_BAD0
.dw	LABEL_B12_BAE6
.dw	LABEL_B12_BAF4
.dw	LABEL_B12_BB06
.dw	LABEL_B12_BB0D
.dw	LABEL_B12_BB20
.dw	LABEL_B12_BB3D
.dw	LABEL_B12_BB45


BattleMenu_Run:
	call	LABEL_2ECD
	call	LABEL_30B7
	call	LABEL_30E1
	ld	a, ($C2E7)
	ld	b, a
	call	LABEL_5B1
	cp	b
	jr	nc, LABEL_19C5
	ld	a, ($C29E)
	or	a
	jr	nz, +
	call	LABEL_687A
	jr	nz, LABEL_19C5
+
	ld	a, $BC
	ld	($C004), a
	ld	a, $05
	ld	($C267), a
	ret

LABEL_19C5:
	ld	a, ($C267)
	ld	($C2C2), a
	ld	hl, LABEL_B12_B15E
	call	ShowDialogue_B12
	ld	a, $04
	ld	($C267), a
	ld	a, $FF
	ld	($C2D4), a
	jp	LABEL_3464

BattleMenu_Magic:
	ld	a, ($C267)
	ld	($C2C2), a
	cp	$02
	jp	nz, LABEL_19F2
	ld	hl, LABEL_B12_B5BA
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_19F2:
	ld	c, a
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, Char_stats+battle_magic_num
	add	a, l
	ld	l, a
	ld	a, (hl)
	or	a
	jp	z, LABEL_1A42
	ld	b, a
	ld	a, c
	cp	$03
	jr	nz, +
	dec	a
+
	push	af
	push	hl
	call	LABEL_3478
	ld	hl, $7A8C
	ld	(Cursor_pos), hl
	pop	hl
	ld	a, (hl)
	dec	a
	ld	(Option_total_num), a
	call	CheckOptionSelect
	pop	hl
	bit	Button_1, c
	jp	nz, LABEL_1A3F
	ld	l, a
	ld	a, h
	add	a, a
	add	a, a
	add	a, h
	add	a, l
	ld	l, a
	ld	h, $00
	ld	de, LABEL_1A57
	add	hl, de
	ld	a, (hl)
	and	$1F
	ld	b, a
	call	LABEL_1B87
	jr	c, LABEL_1A4B
	ld	a, b
	ld	hl, LABEL_1A66
	call	GetPtrAndJump

LABEL_1A3F:
	jp	LABEL_34C9

LABEL_1A42:
	ld	hl, LABEL_B12_B5C8
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1A4B:
	ld	hl, LABEL_B12_B6F7
	call	ShowDialogue_B12
	call	LABEL_3464
	jp	LABEL_34C9


LABEL_1A57:
.db	$01, $09
.db $10, $05, $08, $02, $0B, $03, $0A, $00, $05, $11, $07, $04, $06


LABEL_1A66:
.dw	LABEL_1AAE
.dw	LABEL_1AB1
.dw	LABEL_1AB1
.dw	LABEL_1AFD
.dw	LABEL_1AFD
.dw	LABEL_1AD0
.dw	LABEL_1AD0
.dw	LABEL_1AD0
.dw	LABEL_1AD0
.dw	LABEL_1AFD
.dw	LABEL_1ADE
.dw	LABEL_1AFD
.dw	LABEL_1AFD
.dw	LABEL_1AFD
.dw	LABEL_1AFD
.dw	LABEL_1AFD
.dw	LABEL_1B0D
.dw	LABEL_1B31


LABEL_1A8A:
.dw	LABEL_1E24
.dw	LABEL_1E46
.dw	LABEL_1E4A
.dw	LABEL_1E8A
.dw	LABEL_1E8E
.dw	LABEL_1EA7
.dw	LABEL_1EE6
.dw	LABEL_1F25
.dw	LABEL_1F36
.dw	LABEL_1F80
.dw	LABEL_1FC0
.dw	LABEL_1FDF
.dw	LABEL_201C
.dw	LABEL_2064
.dw	LABEL_2091
.dw	LABEL_20BF
.dw	LABEL_1B0D
.dw	LABEL_1B31


LABEL_1AAE:
	jp	LABEL_1AAE

LABEL_1AB1:
	push	bc
	call	LABEL_3682
	pop	de
	bit	4, c
	jr	nz, LABEL_1ACC
	call	LABEL_188E
	jr	z, LABEL_1ACC
	ld	c, $03
	ld	b, d
	call	LABEL_1BB9
	ld	a, ($C267)
	inc	a
	ld	($C267), a

LABEL_1ACC:
	call	LABEL_36CC
	ret

LABEL_1AD0:
	ld	c, $03
	xor	a
	call	LABEL_1BB9
	ld	a, ($C267)
	inc	a
	ld	($C267), a
	ret

LABEL_1ADE:
	push	bc
	call	LABEL_3682
	pop	de
	bit	4, c
	jr	nz, LABEL_1AF9
	call	LABEL_188E
	jr	z, LABEL_1AF9
	ld	c, $03
	ld	b, d
	call	LABEL_1BB9
	ld	a, ($C267)
	inc	a
	ld	($C267), a

LABEL_1AF9:
	call	LABEL_36CC
	ret

LABEL_1AFD:
	ld	c, $03
	ld	a, ($C2C2)
	call	LABEL_1BB9
	ld	a, ($C267)
	inc	a
	ld	($C267), a
	ret

LABEL_1B0D:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	
LABEL_1B17:
	ld	a, ($C2E8)
	and	$C0
	jp	z, LABEL_1951
	and	$40
	jp	z, LABEL_1964
	ld	a, ($C448)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	jr	nc, LABEL_1B42
	jp	LABEL_1951

LABEL_1B31:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	
LABEL_1B36:
	ld	a, ($C2E8)
	and	$C0
	jp	z, LABEL_1951
	and	$40
	jp	z, LABEL_1964

LABEL_1B42:
	ld	a, $AC
	ld	($C004), a
	ld	hl, LABEL_B12_B132
	call	ShowDialogue_B12
	
-
	call	LABEL_5B1
	and	$0F
	cp	$0A
	jr	nc, -
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld	de, LABEL_1B73
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	call	ShowDialogue_B12
	ld	a, $06
	ld	($C267), a
	ld	a, $D5
	ld	($C004), a
	jp	LABEL_3464

	
LABEL_1B73:
.dw	LABEL_B12_BB5C
.dw	LABEL_B12_BB8D
.dw	LABEL_B12_BBBF
.dw	LABEL_B12_BBD2
.dw	LABEL_B12_BBF0
.dw	LABEL_B12_BC1A
.dw	LABEL_B12_BC42
.dw	LABEL_B12_BC5B
.dw	LABEL_B12_BC89
.dw	LABEL_B12_BCAA


LABEL_1B87:
	ld	hl, LABEL_1DDC
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, ($C267)
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	de, Char_stats+curr_mp
	add	a, e
	ld	e, a
	ld	a, (de)
	sub	(hl)
	ret

BattleMenu_Item:
	call	LABEL_34D5
	call	LABEL_3656
	bit	4, c
	ret	nz
	ld	a, ($C2C4)
	ld	b, a
	ld	c, $04
	xor	a
	call	LABEL_1BB9
	ld	a, ($C267)
	inc	a
	ld	($C267), a
	ret

LABEL_1BB9:
	push	af
	ld	a, ($C267)
	add	a, a
	add	a, a
	ld	hl, $C2AC
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	pop	af
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), a
	ret

LABEL_1BCE:
	ld	a, ($C267)
	add	a, a
	add	a, a
	ld	hl, $C2AC
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	ret

LABEL_1BE1:
	xor  a
	ld   ($C29D), a
	ld   ($C2D8), a
	call	LABEL_36DD
	call	LABEL_2ED9
	
LABEL_1BEE:
	ld	a, ($C2D8)
	or	a
	jr	nz, LABEL_1C15
	ld	hl, $7882
	ld	(Cursor_pos), hl
	ld	a, $04
	ld	(Option_total_num), a
	call	CheckOptionSelect
	bit	Button_1, c
	jp	nz, LABEL_1C13	; jump if we pressed the 1 button (cancel)
	ld	hl, PlayerMenu_OptionTbl
	call	GetPtrAndJump
	call	LABEL_36EF
	jp	LABEL_1BEE

LABEL_1C13:
	ld	a, $FF

LABEL_1C15:
	push	af
	cp	$05
	jr	z, +
	xor	a
	ld	($C800), a
	ld	a, $D0
	ld	($C900), a
+
	call	LABEL_30B7
	call	LABEL_36FB
	pop	af
	cp	$FF
	ret	z
	cp	$03
	ret	c
	cp	$05
	jr	nc, +
	ld	c, a
	jp	LABEL_681B
+
	cp	$06
	jr	nc, +
	call	LABEL_7C85
	call	LABEL_2D25
	jp	LABEL_4414
+
	cp	$07
	jr	nc, +
	ld	a, $85
	call	LABEL_C97
	call	LABEL_7CBB
	ld	a, $FF
	ld	($C2DC), a
	jp	LABEL_1BE1
+
	cp	$08
	jp	c, LABEL_4497
	ld	a, $BF
	ld	($C004), a
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	xor	a
	ld	($C30E), a
	ld	a, ($C317)
	ld	l, a
	add	a, a
	add	a, l
	ld	h, $00
	ld	l, a
	ld	de, LABEL_1C7C
	add	hl, de
	jp	LABEL_787B
	
LABEL_1C7C:
.db $04, $16, $69, $04, $27, $6B, $07
.db	$29, $2A, $09, $19, $66, $0E, $29, $19, $0F, $15, $43, $11, $53, $52, $16, $15
.db	$2C, $15, $28, $61


; ===========================================
PlayerMenu_OptionTbl:
.dw	PlayerMenu_Stats
.dw	PlayerMenu_Magic
.dw	PlayerMenu_Item
.dw	PlayerMenu_Search
.dw	PlayerMenu_Save
; ===========================================

	
PlayerMenu_Stats:
	call	LABEL_3665
	bit  Button_1, c
	jr   nz, LABEL_1CDC
	call	LABEL_188E
	jr   z, LABEL_1CDC
	push	af
	call	LABEL_3707
	call	LABEL_37CF
	call	LABEL_2D25
	pop	af
	ld	c, a
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, Char_stats+battle_magic_num
	add	a, l
	ld	l, a
	ld	a, (hl)
	or	a
	jr	z, LABEL_1CD6
	ld	b, a
	ld	a, c
	cp	$03
	jr	nz, +
	dec	a
+
	call	LABEL_3478
	call	LABEL_2D25
	call	LABEL_34C9
	
LABEL_1CD6:
	call	LABEL_38C1
	call	LABEL_374D

LABEL_1CDC:
	jp   LABEL_36BB


PlayerMenu_Save:
	ld	hl, LABEL_B12_BA62
	call	ShowDialogue_B12
	call	LABEL_39A5
	ld	hl, LABEL_B12_BA82
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, LABEL_1D3B
	ld	a, (Game_mode)
	ld	($C316), a
	ld	hl, LABEL_B12_BA93
	call	ShowDialogue_B12
	push	bc
	ld	a, ($C2C5)
	ld	h, a
	ld	l, $00
	add	hl, hl
	add	hl, hl
	set	7, h
	ex	de, hl
	call	LABEL_73A
	push	af
	push	hl
	ld	a, $08
	ld	($FFFC), a
	ld	(hl), $00
	ld	hl, $C300
	ld	bc, $400
	ldir
	ld	a, $80
	ld	($FFFC), a
	pop	hl
	pop	af
	ld	a, $08
	ld	($FFFC), a
	ld	(hl), $01
	ld	a, $80
	ld	($FFFC), a
	pop	bc
	jr	z, LABEL_1D41
	ld	hl, LABEL_B12_BAA3
	call	ShowDialogue_B12

LABEL_1D3B:
	call	LABEL_39DD
	jp	LABEL_3464

LABEL_1D41:
	xor	a
	ld	($C780), a
	ld	hl, Game_mode
	ld	(hl), $10 ; GameMode_LoadNameInput
	pop	hl
	pop	hl
	ret

PlayerMenu_Magic:
	call	LABEL_3665
	bit	Button_1, c
	jp	nz, LABEL_1DBA
	call	LABEL_188E
	jp	z, LABEL_1DBA
	cp	$02	; is it Odin?
	jp	z, LABEL_1DC5	; jump and display different message for Odin
	ld	c, a
	ld	($C2C2), a
	ld	($C267), a
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, Char_stats+map_magic_num
	add	a, l
	ld	l, a
	ld	a, (hl)	; get spell number
	or	a
	jp	z, LABEL_1DC0 ; jump if character has no spells
	ld	b, a
	ld	a, c
	cp	$03
	jr	nz, +
	dec	a
+
	ld	c, a
	add	a, $03
	push	bc
	push	hl
	call	LABEL_3478
	ld	hl, $7A8C
	ld	(Cursor_pos), hl
	pop	hl
	ld	a, (hl)
	dec	a
	ld	(Option_total_num), a
	call	CheckOptionSelect
	pop	hl
	bit	Button_1, c
	jp	nz, LABEL_1DB7
	ld	h, a
	ld	a, l
	add	a, a
	add	a, a
	add	a, l
	add	a, h
	ld	l, a
	ld	h, $00
	ld	de, LABEL_1DEF
	add	hl, de
	ld	a, (hl)
	and	$1F
	ld	b, a
	call	LABEL_1B87
	jp	c, LABEL_1DD1
	ld	a, b
	ld	hl, LABEL_1DFE
	call	GetPtrAndJump

LABEL_1DB7:
	call	LABEL_34C9

LABEL_1DBA:
	call	LABEL_36BB
	jp	LABEL_2F3C

LABEL_1DC0:
	ld	hl, LABEL_B12_B5C8
	jr	LABEL_1DC8

LABEL_1DC5:
	ld	hl, LABEL_B12_B5BA

LABEL_1DC8:
	call	ShowDialogue_B12
	call	LABEL_3464
	jp	LABEL_36BB

LABEL_1DD1:
	ld	hl, LABEL_B12_B6F7
	call	ShowDialogue_B12
	call	LABEL_3464
	jr	LABEL_1DB7
	

LABEL_1DDC:
.db	$00, $02, $06, $06, $0A, $04, $10, $0C, $04, $02, $0A, $02, $02, $04, $04
.db $0C, $02, $04, $08

LABEL_1DEF:
.db	$01, $12, $00, $00, $00, $02, $0C, $0D, $00, $00, $02, $0D
.db $11, $0E, $0F



LABEL_1DFE:
.dw	LABEL_1E24
.dw	LABEL_1E27
.dw	LABEL_1E2B
.dw	LABEL_1E8A
.dw	LABEL_1E8E
.dw	LABEL_1EA7
.dw	LABEL_1EE6
.dw	LABEL_1F25
.dw	LABEL_1F36
.dw	LABEL_1F80
.dw	LABEL_1FC0
.dw	LABEL_1FDF
.dw	LABEL_201C
.dw	LABEL_2064
.dw	LABEL_2091
.dw	LABEL_20BF
.dw	LABEL_20F8
.dw	LABEL_20F8
.dw	LABEL_2140

LABEL_1E24:
	jp	LABEL_1E24

LABEL_1E27:
	ld	d, $14
	jr	LABEL_1E2D

LABEL_1E2B:
	ld	d, $50

LABEL_1E2D:
	push	bc
	push	de
	call	LABEL_3682
	pop	de
	bit	4, c
	pop	bc
	jr	nz, +
	ld	($C2C2), a
	call	LABEL_188E
	jr	z, +
	call	LABEL_1E53
+
	jp	LABEL_36CC

LABEL_1E46:
	ld	d, $14
	jr	LABEL_1E4C

LABEL_1E4A:
	ld	d, $50

LABEL_1E4C:
	ld	a, ($C2C2)
	call	LABEL_188E
	ret	z
	
LABEL_1E53:
	push	de
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB	
	ld	($C004), a
	pop	de
	
LABEL_1E5F:
	push	de
	ld	hl, LABEL_B12_B1D0
	call	ShowDialogue_B12
	pop	de
	ld	a, $C1
	ld	($C004), a
	ld	a, ($C2C2)
	call	LABEL_187D
	push	hl
	pop	ix
	ld	b, (ix+6)
	ld	a, (ix+1)
	add	a, d
	jr	nc, +
	ld	a, $FF
+
	cp	b
	jr	c, +
	ld	a, b
+
	ld	(ix+1), a
	jp	LABEL_3464

LABEL_1E8A:
	ld	c, $06
	jr	LABEL_1E90

LABEL_1E8E:
	ld	c, $86

LABEL_1E90:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, c
	ld	($C2EF), a
	ld	hl, LABEL_B12_B18B
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1EA7:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	de, $F610
	call	LABEL_1EB2

LABEL_1EB2:
	ld	b, $08
	
-
	ld	a, b
	sub	$0C
	neg
	call	LABEL_187D
	jr	nz, +
	djnz	-
	ret
+
	push	de
	ld	a, e
	call	LABEL_18A9
	
LABEL_1EC6:
	call	LABEL_5B1
	and	$07
	add	a, $04
	call	LABEL_187D
	jp	z, LABEL_1EC6
	push	hl
	pop	ix
	pop	de
	push	de
	call	LABEL_5B1
	and	$03
	add	a, d
	call	LABEL_125E
	call	LABEL_3105
	pop	de
	ret

LABEL_1EE6:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	de, $D811

LABEL_1EEE:
	ld	b, $08
	
LABEL_1EF0:
	push	bc
	ld	a, b
	sub	$0C
	neg
	call	LABEL_187D
	jp	z, LABEL_1F1F
	push	hl
	pop	ix
	push	de
	ld	a, e
	call	LABEL_18A9
	pop	de
	push	de
	ld	a, d
	cp	$D8
	jr	nz, +
	call	LABEL_5B1
	and	$0F
	add	a, d
+
	call	LABEL_125E
	call	LABEL_3105
	pop	de
	ld	a, ($C2E6)
	cp	$49
	jr	z, LABEL_1F23

LABEL_1F1F:
	pop	bc
	djnz	LABEL_1EF0
	ret

LABEL_1F23:
	pop	bc
	ret

LABEL_1F25:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	de, $F412
	call	LABEL_1EB2
	call	LABEL_1EB2
	jp	LABEL_1EB2

LABEL_1F36:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, ($C2E8)
	and	$20
	jr	z, LABEL_1F71
	ld	a, ($C448)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	ld	c, $03
	jr	nc, +
	call	LABEL_5B1
	and	$03
	jr	z, LABEL_1F71
	ld	c, a
+
	ld	de, $0D
	ld	b, 	$08
	
-
	ld	a, b
	sub	$0C
	neg
	call	LABEL_187D
	jr	z, +
	add	hl, de
	ld	a, (hl)
	or	a
	jr	z, LABEL_1F76
+
	djnz	-

LABEL_1F71:
	ld	hl, LABEL_B12_B172
	jr	LABEL_1F7A

LABEL_1F76:
	ld	(hl), c
	ld	hl, LABEL_B12_B1E0

LABEL_1F7A:
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1F80:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	xor	a
	ld	($C2C4), a
	
LABEL_1F89:
	ld	a, ($C2E7)
	or	a
	jr	z, +
	ld	a, ($C29E)
	or	a
	jr	nz, LABEL_1FAC
	call	LABEL_687A
	jr	z, LABEL_1FAC
+
	ld	a, ($C2C4)
	or	a
	ld	hl, LABEL_B12_B172
	jr	z, +
	ld	hl, LABEL_B12_B2CD
+
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1FAC:
	ld	a, $BC
	ld	($C004), a
	ld	hl, LABEL_B12_B25F
	call	ShowDialogue_B12
	call	LABEL_3464
	ld	a, $05
	ld	($C267), a
	ret

LABEL_1FC0:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, ($C2C2)
	call	LABEL_188E
	ret	z
	call	LABEL_187D
	set	7, (hl)
	ld	hl, LABEL_B12_B22F
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_1FDF:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, ($C448)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	jr	c, LABEL_200C
	call	LABEL_5B1
	cp	$B2
	jr	nc, LABEL_200C
	ld	b, $08
	
-
	ld	a, b
	sub	$0C
	neg
	call	LABEL_187D
	jr	z, +
	bit	6, (hl)
	jr	z, LABEL_2011
+
	djnz	-

LABEL_200C:
	ld	hl, LABEL_B12_B172
	jr	LABEL_2016

LABEL_2011:
	set	6, (hl)
	ld	hl, LABEL_B12_B24C

LABEL_2016:
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_201C:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, ($C800)
	cp	$0E
	jr	z, ++
	ld	a, ($C29E)
	or	a
	ld	hl, LABEL_B12_B569
	jr	nz, +
	call	LABEL_684A
	ld	hl, LABEL_B12_B569
	jr	z, +
	ld	l, c
	ld	h, $CB
	ld	(hl), $00
	ld	hl, LABEL_B12_B28E
+:	
	call	ShowDialogue_B12
	jp	LABEL_3464

++:	
	ld	a, ($C80F)
	cp	$3D
	ld	hl, LABEL_B12_B27F
	jr	z, +
	ld	hl, LABEL_B12_B28E
+:	
	call	ShowDialogue_B12
	ld	a, $3D
	ld	($C80F), a
	jp	LABEL_28EE

LABEL_2064:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, ($C29E)
	or	a
	jr	z, LABEL_2078
	ld	hl, LABEL_B12_B172
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_2078:
	ld	a, $BF
	ld	($C004), a
	ld	hl, LABEL_B12_B59C
	call	ShowDialogue_B12
	call	LABEL_3464
	ld	a, $FF
	ld	($C2D8), a
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

LABEL_2091:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, ($C29E)
	or	a
	jr	z, +
-:	
	ld	hl, LABEL_B12_B172
	call	ShowDialogue_B12
	jp	LABEL_3464

+:	
	ld	b, $01
	call	LABEL_6BE9
	and	$07
	cp	$06
	jr	nz, -
	bit	7, (hl)
	jr	nz, -
	ld	a, $04
	ld	($C2D8), a
	ret
	


LABEL_20BF:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	call	LABEL_3682
	bit	4, c
	jr	nz, +++
	push	af
	ld	a, $AB
	ld	($C004), a
	pop	af
	ld	($C2C2), a
	call	LABEL_187D
	jr	z, +
	ld	hl, LABEL_B12_B709
	jr	++

+:	
	ld	(hl), $01
	ld	a, $06
	add	a, l
	ld	e, a
	ld	d, h
	ex	de, hl
	inc	de
	ldi
	ldi
	ld	hl, LABEL_B12_B5B0
++:	
	call	ShowDialogue_B12
	call	LABEL_3464
+++:	
	jp	LABEL_36CC

LABEL_20F8:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AC
	ld	($C004), a
LABEL_2102:	
	ld	a, ($C800)
	cp	$0E
	jr	z, ++
	ld	a, ($C29E)
	or	a
	ld	hl, LABEL_B12_B424
	jr	nz, +
	call	LABEL_684A
	ld	hl, LABEL_B12_B424
	jr	z, +
	ld	hl, LABEL_B12_B404
+:	
	call	ShowDialogue_B12
	ld	a, $D5
	ld	($C004), a
	jp	LABEL_3464

++:	
	ld	a, ($C80F)
	cp	$3D
	ld	hl, LABEL_B12_B424
	jr	z, +
	ld	hl, LABEL_B12_B404
+:	
	call	ShowDialogue_B12
	ld	a, $D5
	ld	($C004), a
	jp	LABEL_28DB

LABEL_2140:
	ld	a, b
	call	LABEL_1B87
	ld	(de), a
	ld	a, $AB
	ld	($C004), a
	ld	a, ($C29E)
	or	a
	jr	nz, LABEL_2159
	ld	hl, LABEL_B12_B172
	call	ShowDialogue_B12
	jp	LABEL_3464

LABEL_2159:	
	ld	hl, LABEL_B12_B59C
	call	ShowDialogue_B12
	call	LABEL_3464
	ld	a, $08
	ld	($C2D8), a
	ret

PlayerMenu_Item:
	ld a, (Inventory_curr_num)
	or a
	jp nz, +
	call LABEL_34D5
	jp LABEL_3656

+:	
	call LABEL_34D5
	bit 4, c
	jp nz, LABEL_21F5
	ld a, ($C2C4)
	cp $21
	jr c, +++
	cp $24
	jr nc, +++
	sub $21
	add a, a
	add a, a
	add a, $04
	ld b, a
	ld a, ($C30E)
	or a
	jr z, +++
	cp b
	jr nz, +++
	cp $08
	jr z, +
	push bc
	call LABEL_7656
	pop bc
	jr ++

+:	
	push bc
	call LABEL_7732
	pop bc
++:	
	ld hl, LABEL_B12_B2FB
	jr nz, +
	xor a
	ld ($C30E), a
	dec a
	ld ($C2D8), a
	ld hl, LABEL_B12_B30A
+:	
	call ShowDialogue_B12
	call LABEL_3464
	jp LABEL_21F5

+++:	
	ld b, $04
-:	
	ld a, b
	sub $04
	neg
	call LABEL_187D
	jp nz, +
	djnz -
	jp LABEL_21F5

+:	
	ld ($C2C2), a
	call LABEL_3759
	ld hl, $7A72
	ld (Cursor_pos), hl
	ld a, $02
	ld (Option_total_num), a
	call CheckOptionSelect
	bit Button_1, c
	jp nz, +
	ld hl, LABEL_21FB
	call GetPtrAndJump
+:	
	call LABEL_376B
LABEL_21F5:	
	call LABEL_3656
	jp LABEL_2F3C
	

LABEL_21FB:	
.dw	LABEL_2201
.dw	LABEL_26C8
.dw	LABEL_2752
	

LABEL_2201:
	ld a, ($C2C4)
	ld hl, LABEL_220A
	jp GetPtrAndJump


LABEL_220A:
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_2299
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_228A
.dw	LABEL_22AF
.dw	LABEL_22E5
.dw	LABEL_231A
.dw	LABEL_2333
.dw	LABEL_2337
.dw	LABEL_2369
.dw	LABEL_239D
.dw	LABEL_23E2
.dw	LABEL_23EC
.dw	LABEL_2416
.dw	LABEL_242F
.dw	LABEL_2491
.dw	LABEL_24E9
.dw	LABEL_2524
.dw	LABEL_2537
.dw	LABEL_2589
.dw	LABEL_25C3
.dw	LABEL_2613
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_2631
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_26B0
.dw	LABEL_267C
.dw	LABEL_26B0

LABEL_228A:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld hl, LABEL_B12_B2CD
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_2299:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jp nz, LABEL_1F89
	ld hl, LABEL_B12_B312
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_22AF:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld e, $04

LABEL_22B7:	
	ld a, ($C308)
	cp $04
	ld hl, LABEL_B12_B2E3
	jr nc, +
	ld a, ($C29E)
	or a
	jr z, +
	push bc
	push de
	call LABEL_7656
	pop de
	pop bc
	ld hl, LABEL_B12_B2E3
	jr nz, +
	ld a, e
	ld ($C30E), a
	ld a, $FF
	ld ($C2D8), a
	ld hl, LABEL_B12_B305
+:	
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_22E5:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C308)
	cp $04
	ld hl, LABEL_B12_B2E3
	jr nc, +
	ld a, ($C29E)
	or a
	jr z, +
	push bc
	push de
	call LABEL_76C1
	pop de
	pop bc
	ld hl, LABEL_B12_B2E3
	jr nz, +
	ld a, $08
	ld ($C30E), a
	ld a, $FF
	ld ($C2D8), a
	ld hl, LABEL_B12_B305
+:	
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_231A:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C308)
	cp $02
	ld e, $0C
	jp z, LABEL_22B7
	ld hl, LABEL_B12_B2E3
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_2333:
	ld d, ItemID_SilverFang
	jr +

LABEL_2337:
	ld d, ItemID_Escaper
+:	
	ld a, ($C29D)
	or a
	ld a, ($C267)
	jr nz, +
	push de
	call LABEL_3665
	pop de
	bit Button_1, c
	jr nz, ++
+:	
	ld ($C2C2), a
	call LABEL_188E
	jr z, ++
	push de
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	pop de
	call LABEL_1E5F
	call Inventory_RemoveItem
++:	
	ld a, ($C29D)
	or a
	ret nz
	jp LABEL_36BB

LABEL_2369:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, $C2
	ld ($C004), a
	ld a, ($C29D)
	or a
	jr nz, +
	ld hl, LABEL_B12_BFC4
	call ShowDialogue_B12
	ld a, $D5
	ld ($C004), a
	ld a, ($C29E)
	or a
	jp z, LABEL_2078
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B322
	call ShowDialogue_B12
	ld a, $D5
	ld ($C004), a
	jp LABEL_3464


LABEL_239D:
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld hl, LABEL_B12_B35C
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C29E)
	or a
	jr z, +
-:	
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld hl, LABEL_B12_B375
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C315)
	or a
	jr nz, -
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	call LABEL_3464
	call Inventory_RemoveItem
	ld a, $FF
	ld ($C315), a
	ld ($C2D8), a
	ret

LABEL_23E2:
	ld a, ($C29D)
	or a
	call nz, Inventory_RemoveItem
	jp LABEL_2299

LABEL_23EC:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B2CD
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C29E)
	or a
	push af
	call nz, Inventory_RemoveItem
	pop af
	jp nz, LABEL_2159
	ld hl, LABEL_B12_B312
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_2416:
	call Inventory_RemoveItem
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jp nz, LABEL_1B17
	ld hl, LABEL_B12_B2CD
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_242F:
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B35C
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C2DB)
	cp $A3
	jr z, ++
	call LABEL_24BE
	ld hl, LABEL_B12_B569
	jr nz, +
-:	
	ld hl, LABEL_B12_B3E3
+:	
	call ShowDialogue_B12
	jp LABEL_3464

++:	
	call LABEL_24BE
	jr z, -
	ld hl, LABEL_B12_B3B1
	call ShowDialogue_B12
	call LABEL_3464
	call Inventory_RemoveItem
	ld iy, Odin_stats
	ld (iy+weapon), ItemID_IronAxe
	ld (iy+armor), ItemID_IronArmor
	call UnlockCharacter
	ld a, $02
	ld (Party_curr_num), a
	ld hl, $C600
	ld (hl), $00
	ld hl, $C50A
	ld (hl), $FF
	ld a, $05
	ld ($C2D8), a
	ret

LABEL_2491:
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B35C
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C2DB)
	cp $A1
	jr z, ++
	call LABEL_24BE
	ld hl, LABEL_B12_B3E3
	jr z, +
	ld hl, LABEL_B12_B3F9
+:	
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_24BE:
	ld a, (Alis_stats)	; get status
	ld d, a
	ld a, (Odin_stats)	; get status
	ld e, a
	ld a, (Noah_stats)	; get status
	or d
	or e
	ret

++:	
	call LABEL_24BE
	jr nz, +
	ld hl, LABEL_B12_B3E3
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B3B1
	call ShowDialogue_B12
	call Inventory_RemoveItem
	call LABEL_5546
	jp LABEL_3464

LABEL_24E9:
	ld a, ($C29E)
	or a
	jr z, +
	
LABEL_24EF:	
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld hl, LABEL_B12_B569
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld b, $01
	call LABEL_6BE9
	and $07
	cp $05
	jr nz, +
	bit 7, (hl)
	jr nz, +
	ld a, $03
	ld ($C2D8), a
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B2CD
	call ShowDialogue_B12
	jp LABEL_3464


LABEL_2524:
	call Inventory_RemoveItem
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jp nz, LABEL_1B36
	jp LABEL_2102

LABEL_2537:
	ld hl, LABEL_B12_B458
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B431
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C2DB)
	cp $AF
	jr z, +
	ld hl, LABEL_B12_B312
	call ShowDialogue_B12
	jp	LABEL_3464

+:	
	push bc
	call LABEL_7CA6
	pop bc
	ld a, $38
	call Inventory_FindFreeSlot
	jr z, +
	ld hl, LABEL_B12_B49A
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	call Inventory_RemoveItem
	ld hl, LABEL_B12_B471
	call ShowDialogue_B12
	call LABEL_3464
	ld a, ItemID_Nuts
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	ret z
	jp Inventory_AddItem

LABEL_2589:
	ld hl, LABEL_B12_B458
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B35C
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C2DB)
	cp $B0
	jr z, +
-:	
	ld hl, LABEL_B12_B312
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, ($C2DC)
	cp $FF
	jr z, -
	ld hl, LABEL_B12_B4D5
	call ShowDialogue_B12
	ld a, $06
	ld ($C2D8), a
	jp LABEL_3464

LABEL_25C3:
	ld a, (Myau_stats)
	or a
	jr z, LABEL_25D7
	ld a, ($C309)
	cp $17
	jr z, +++
	ld a, ($C2DB)
	cp $B0
	jr z, ++

LABEL_25D7:	
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	ld hl, LABEL_B12_B500
	jr z, +
	ld hl, LABEL_B12_B35C
+:	
	call ShowDialogue_B12
	jp LABEL_3464

++:	
	ld a, ($C2DC)
	cp $FF
	jr nz, LABEL_25D7
-:	
	ld hl, LABEL_B12_B743
	call ShowDialogue_B12
	call LABEL_3464
	ld a, $07
	ld ($C2D8), a
	ret

+++:	
	ld a, ($C29E)
	or a
	jr z, LABEL_25D7
	ld a, ($C29D)
	or a
	jr nz, LABEL_25D7
	jr -

LABEL_2613:
	ld a, ($C29D)
	or a
	jr z, +
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld hl, LABEL_B12_B52C
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B544
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_2631:
	ld a, ($C29E)
	or a
	jr z, ++
-:	
	ld hl, LABEL_B12_B366
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	ld hl, LABEL_B12_B375
	jr z, +
	ld hl, LABEL_B12_B35C
+:	
	call ShowDialogue_B12
	jp LABEL_3464

++:	
	ld a, ($C29D)
	or a
	jr nz, -
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, (Dungeon_direction)
	and $03
	ld hl, LABEL_B12_BD01
	jr z, +
	cp $01
	ld hl, LABEL_B12_BCED
	jr z, +
	cp $02
	ld hl, LABEL_B12_BD0C
	jr z, +
	ld hl, LABEL_B12_BCF7
+:	
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_267C:
	ld a, ($C29E)
	or a
	jp nz, LABEL_24EF
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld b, $01
	call LABEL_6BE9
	bit 7, (hl)
	jr nz, ++
	and $07
	cp $05
	ld b, $03
	jr z, +
	cp $06
	jr nz, ++
	ld b, $04
+:	
	ld a, b
	ld ($C2D8), a
	jp LABEL_3464

++:	
	ld hl, LABEL_B12_B2CD
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_26B0:
	ld hl, LABEL_B12_B2AC
	call ShowDialogue_B12
	ld a, ($C29D)
	or a
	ld hl, LABEL_B12_B312
	jr nz, +
	ld hl, LABEL_B12_B555
+:	
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_26C8:
	ld hl, $FFFF
	ld (hl), $02
	ld a, ($C2C4)
	ld hl, LABEL_7FAB
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	rrca
	rrca
	rrca
	rrca
	and $0F
	jp nz, +
	ld hl, LABEL_B12_B5F0
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld d, a
	push de
	push hl
	call LABEL_3665
	pop hl
	pop de
	bit Button_1, c
	jp nz, LABEL_2741
	call LABEL_188E
	jp z, LABEL_2741
	ld ($C2C2), a
	ld c, a
	inc a
	ld b, a
	ld a, d
-:	
	rrca
	djnz -
	jp nc, +
	ld a, c
	add a, a
	add a, a
	add a, a
	add a, a
	ld de, Char_stats+weapon
	add a, e
	ld e, a
	adc a, d
	sub e
	ld d, a
	ld a, (hl)
	and $03
	add a, e
	ld e, a
	ld a, (de)
	ld hl, ($C29B)
	ld (hl), a
	push af
	ld a, ($C2C4)
	ld (de), a
	ld hl, LABEL_B12_B2B6
	call ShowDialogue_B12
	ld a, ($C2C2)
	call LABEL_3707
	call LABEL_2D25
	call LABEL_374D
	call LABEL_3464
	pop af
	or a
	call z, Inventory_RemoveItem

LABEL_2741:	
	call UpdateCharStats
	jp LABEL_36BB

+:	
	ld hl, LABEL_B12_B5DE
	call ShowDialogue_B12
	call LABEL_3464
	jr LABEL_2741

LABEL_2752:
	ld hl, $FFFF
	ld (hl), $02
	ld a, ($C2C4)
	ld hl, LABEL_7FAB
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	and $04
	jr z, +
	ld hl, LABEL_B12_B6DE
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B2C2
	call ShowDialogue_B12
	call Inventory_RemoveItem
	jp LABEL_3464

Inventory_RemoveItem:
	ld hl, ($C29B)

Inventory_RemoveItem2:	
	push bc
	ld e, l
	ld d, h
	inc hl
	ld a, $D7
	sub e
	and $1F
	jr z, +
	ld c, a
	ld b, $00
	ldir
+:	
	ld hl, Inventory
	ld a, (Inventory_curr_num)
	dec a
	ld (Inventory_curr_num), a
	add a, l
	ld l, a
	ld (hl), $00
	pop bc
	ret

Inventory_AddItem:
	ld a, (Inventory_curr_num)
	cp $18
	jr nc, LABEL_27BC
	ld hl, Inventory
	add a, l
	ld l, a
	ld a, ($C2C4)
	ld (hl), a
	ld a, (Inventory_curr_num)
	inc a
	ld (Inventory_curr_num), a
	ld a, $B3
	ld ($C004), a
	ret

LABEL_27BC:	
	ld hl, LABEL_B12_B671
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr z, LABEL_27D8
	ld hl, LABEL_B12_B6C1
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr nz, LABEL_27D8
	ld hl, LABEL_B12_B6D0
	jp ShowDialogue_B12
	
LABEL_27D8:	
	ld a, ($C2C4)
	push af
	ld hl, LABEL_B12_B68C
	call ShowDialogue_B12
	call LABEL_34D5
	call LABEL_3656
	bit 4, c
	jr nz, ++
	ld hl, $FFFF
	ld (hl), $02
	ld a, ($C2C4)
	ld hl, LABEL_7FAB
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	and $04
	jr z, +
	ld hl, LABEL_B12_B6DE
	call ShowDialogue_B12
	pop af
	ld ($C2C4), a
	jp LABEL_27D8

+:	
	ld hl, LABEL_B12_B69E
	call ShowDialogue_B12
	pop af
	ld ($C2C4), a
	ld hl, ($C29B)
	ld (hl), a
	ld a, $B3
	ld ($C004), a
	ld hl, LABEL_B12_B6AD
	jp ShowDialogue_B12

++:	
	pop af
	ld ($C2C4), a
	jp LABEL_27BC

Inventory_FindFreeSlot:
	ld hl, Inventory
	ld b, $18
-:	
	cp (hl)
	ret z
	inc hl
	djnz -
	ret

PlayerMenu_Search:
	ld a, ($C800)
	cp $0E
	jr nz, +
	call LABEL_30B7
	ld hl, LABEL_B12_B569
	call ShowDialogue_B12
	call LABEL_28DB
	jp LABEL_2ED9

+:	
	ld hl, ($C305)
	ld a, l
	add a, $60
	jr c, +
	cp $C0
	jr c, ++
+:	
	add a, $40
	inc h
++:	
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	ld hl, ($C301)
	ld bc, $0080
	add hl, bc
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld l, a
	ld a, ($C309)
	cp $07
	jr nz, +
	ld a, l
	cp $28
	jr nz, LABEL_28C5
	ld a, h
	cp $1E
	jr nz, LABEL_28C5
	ld a, ($C507)
	or a
	jr z, LABEL_28C5
	cp $FF
	jr z, LABEL_28C5
	ld a, $FF
	ld ($C507), a
	ld a, $26
	jr ++

+:	
	cp $01
	jr nz, LABEL_28C5
	ld a, l
	cp $30
	jr nz, LABEL_28C5
	ld a, h
	cp $48
	jr nz, LABEL_28C5
	ld a, ($C509)
	or a
	jr z, LABEL_28C5
	ld a, (Odin_stats+shield)
	ld b, a
	ld a, $1F
	cp b
	jr z, LABEL_28C5
++:	
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	jr z, LABEL_28C5
	ld hl, LABEL_B12_B592
	call ShowDialogue_B12
	call Inventory_AddItem
	jp LABEL_3464

LABEL_28C5:	
	ld a, ($C2DB)
	cp $A2
	jp z, LABEL_5566
	cp $A3
	jp z, LABEL_558C
	ld hl, LABEL_B12_B569
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_28DB:
	ld   hl, LABEL_B12_B656
	call	ShowDialogue_B12
	call	LABEL_37A3
	push	af
	call	LABEL_37C3
	call	LABEL_3464
	pop	af
	or 	a
	ret	nz

LABEL_28EE:
	ld a, $B0
	ld ($C004), a
	ld hl, ($C2E1)
	ld (hl), $FF
	ld a, $01
	ld ($C80A), a
	push bc
	call LABEL_18B9
	pop bc
	ld a, ($C80F)
	cp $3D
	call nz, LABEL_2950
	ld hl, ($C2DD)
	ld a, h
	or l
	jr nz, +
	ld a, ($C2DF)
	or a
	jr nz, +
	ld hl, LABEL_B12_B665
	call ShowDialogue_B12
	ld a, $D0
	ld ($C900), a
	jp LABEL_3464

+:	
	ld hl, ($C2DD)
	ld ($C2C5), hl
	call LABEL_297A
	ld a, h
	or l
	ld hl, LABEL_B12_B648
	call nz, ShowDialogue_B12
	ld a, ($C2DF)
	ld ($C2C4), a
	or a
	jr z, +
	ld hl, LABEL_B12_B592
	call ShowDialogue_B12
	call Inventory_AddItem
+:	
	ld a, $D0
	ld ($C900), a
	jp LABEL_3464

LABEL_2950:	
	ld a, ($C80F)
	cp $3E
	jr nz, +
	ld b, $04
-:	
	ld a, b
	dec a
	call ++
	djnz -
	ret

+:	
	call LABEL_5B1
	and $03
++:	
	call LABEL_187D
	ret z
	inc hl
	push hl
	ld h, (hl)
	ld l, $00
	ld e, $03
	call LABEL_4FE
	pop de
	ex de, hl
	ld a, (hl)
	sub d
	ld (hl), a
	ret

LABEL_297A:
	ex de, hl
	ld hl, (Current_money)
	add hl, de
	jr nc, +
	ld hl, $FFFF
+:	
	ld (Current_money), hl
	ex de, hl
	ret

LABEL_2989:
	call	LABEL_2D25
	ret

	
LABEL_298D:	
	ld hl, LABEL_B12_B8C8
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jp nz, LABEL_2A55
LABEL_2999:	
	ld a, (Party_curr_num)
	or a
	ld hl, LABEL_B12_B925
	call nz, ShowDialogue_B12
	call LABEL_3665
	bit Button_1, c
	jp nz, LABEL_2A52
	ld ($C2C2), a
	call LABEL_187D
	jr nz, +
	ld hl, LABEL_B12_B730
	call ShowDialogue_B12
	jp LABEL_2A48

+:	
	push hl
	pop iy
	ld a, (iy+1)
	cp (iy+6)
	jr nz, +
	ld a, (iy+2)
	cp (iy+7)
	jr nz, +
	ld hl, LABEL_B12_B96B
	call ShowDialogue_B12
	ld a, (Party_curr_num)
	or a
	jr nz, LABEL_2A48
	ld hl, LABEL_B12_B964
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld a, (iy+6)
	sub (iy+1)
	ld b, a
	ld a, (iy+7)
	sub (iy+2)
	add a, b
	ld l, a
	ld h, $00
	ld ($C2C5), hl
	ld hl, LABEL_B12_B8E0
	call ShowDialogue_B12
	call LABEL_39E9
	call ShowYesNoPrompt
	push af
	call nz, LABEL_3A12
	pop af
	jr nz, LABEL_2A48
	ld de, ($C2C5)
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr c, LABEL_2A5E
	ld (Current_money), hl
	call LABEL_39F7
	ld a, $C1
	ld ($C004), a
	ld a, (iy+6)
	ld (iy+1), a
	ld a, (iy+7)
	ld (iy+2), a
	ld hl, LABEL_B12_B938
	call ShowDialogue_B12
	call LABEL_3A12
	ld a, (Party_curr_num)
	or a
	jr z, +
	ld hl, LABEL_B12_B90A
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr nz, LABEL_2A52

LABEL_2A48:	
	call LABEL_36BB
	ld a, (Party_curr_num)
	or a
	jp nz, LABEL_2999
LABEL_2A52:	
	call LABEL_36BB
LABEL_2A55:	
	ld hl, LABEL_B12_B951
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_2A5E:	
	call LABEL_3A12
	call LABEL_36BB
	ld hl, LABEL_B12_BD57
	call ShowDialogue_B12
+:	
	jp LABEL_3464

LABEL_2A6D:	
	ld bc, $04FF
-:	
	ld a, b
	dec a
	call LABEL_187D
	jr z, +
	ld a, $06
	add a, l
	ld e, a
	ld d, h
	ex de, hl
	inc de
	ldi
	ldi
+:	
	djnz -
	ret


LABEL_2A85:	
	ld a, ($C2DB)
	ld ($C317), a
	ld hl, LABEL_B12_B97F
	call ShowDialogue_B12
	call ShowYesNoPrompt
	or a
	jp nz, LABEL_2B46
LABEL_2A98:	
	ld a, (Party_curr_num)
	or a
	jp z, LABEL_2B31
	ld hl, LABEL_B12_B9D3
	call ShowDialogue_B12
	call LABEL_3665
	bit Button_1, c
	jp nz, LABEL_2B43
	call LABEL_187D
	jr nz, LABEL_2B31
	ld ($C2C2), a
	push hl
	pop iy
	ld a, (iy+5)
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld e, l
	ld d, h
	add hl, hl
	add hl, hl
	add hl, de
	ld ($C2C5), hl
	ld hl, LABEL_B12_B9EE
	call ShowDialogue_B12
	call LABEL_39E9
	call ShowYesNoPrompt
	push af
	call nz, LABEL_3A12
	pop af
	jr nz, LABEL_2B15
	ld hl, LABEL_B12_B9B0
	call ShowDialogue_B12
	ld de, ($C2C5)
	ld hl, (Current_money)
	or a
	sbc hl, de
	jp c, +
	ld (Current_money), hl
	call LABEL_39F7
	ld (iy+0), $01
	ld a, (iy+6)
	ld (iy+1), a
	ld a, (iy+7)
	ld (iy+2), a
	ld hl, LABEL_B12_B9C4
	call ShowDialogue_B12
	ld a, $C5
	ld ($C004), a
	call LABEL_2D33
	call LABEL_3A12
LABEL_2B15:	
	ld hl, LABEL_B12_B9E5
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr nz, LABEL_2B43
	call LABEL_36BB
	jp LABEL_2A98

+:	
	ld hl, LABEL_B12_BD9F
	call ShowDialogue_B12
	call LABEL_3A12
	jr LABEL_2B15

LABEL_2B31:	
	ld ($C2C2), a
	ld hl, LABEL_B12_BA56
	call ShowDialogue_B12
	ld a, (Party_curr_num)
	or a
	jr nz, LABEL_2B15
	call LABEL_2D25
LABEL_2B43:	
	call LABEL_36BB
LABEL_2B46:	
	ld hl, LABEL_B12_BA3C
	call ShowDialogue_B12
	ld hl, LABEL_B12_BA04
	call ShowDialogue_B12
	call +
	jp LABEL_3464

+:	
	ld iy, Alis_stats
	ld de, B03_AlisLevelTable
	xor a
	call +
	ld iy, Myau_stats
	ld de, B03_MyauLevelTable
	ld a, $01
	call +
	ld iy, Odin_stats
	ld de, B03_OdinLevelTable
	ld a, $02
	call +
	ld iy, Noah_stats
	ld de, B03_NoahLevelTable
	ld a, $03
+:	
	ld ($C2C2), a
	bit 0, (iy+status)
	ret z
	ld a, (iy+level)
	cp $1E
	jr c, +
	ld hl, LABEL_B12_BDFF
	jp ShowDialogue_B12

+:	
	ld hl, $FFFF
	ld (hl), $03
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	push hl
	pop ix
	ld e, (iy+3)
	ld d, (iy+4)
	ld l, (ix+4)
	ld h, (ix+5)
	or a
	sbc hl, de
	ld ($C2C5), hl
	ld hl, LABEL_B12_BA1F
	jp ShowDialogue_B12

	
LABEL_2BC0:	
	ld hl, LABEL_B12_B7C7
	call ShowDialogue_B12
LABEL_2BC6:	
	call ShowYesNoPrompt
	jr z, LABEL_2BD4
	ld hl, LABEL_B12_B7E3
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_2BD4:	
	push bc
	call LABEL_38CD
	call LABEL_39E9
	pop bc
LABEL_2BDC:	
	ld hl, LABEL_B12_B7F5
	call ShowDialogue_B12
	push bc
	call LABEL_38D9
	bit 4, c
	pop bc
	jr nz, LABEL_2C2D
	ld a, (Inventory_curr_num)
	cp $18
	jr nc, LABEL_2C3C
	ld a, (hl)
	ld ($C2C4), a
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr c, LABEL_2C41
	ld a, ($C2C4)
	cp $40
	jr nc, LABEL_2C46
	ld (Current_money), hl
	call LABEL_39F7
	ld a, ($C2C4)
	cp $21
	jr c, +
	cp $24
	jr nc, +
	call Inventory_FindFreeSlot
	jr z, ++
+:	
	call Inventory_AddItem
++:	
	ld hl, LABEL_B12_B807
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr z, LABEL_2BDC

LABEL_2C2D:	
	ld hl, LABEL_B12_B7E3
-:	
	call ShowDialogue_B12
	call LABEL_3A12
	call LABEL_3999
	jp LABEL_3464

LABEL_2C3C:	
	ld hl, LABEL_B12_B813
	jr -

LABEL_2C41:	
	ld hl, LABEL_B12_BD57
	jr -

LABEL_2C46:	
	ld a, ($C2EC)
	cp $02
	jr nc, ++
	cp $01
	ld hl, $0142
	jr c, +
	ld hl, $0144
+:	
	inc a
	ld ($C2EC), a
	call ShowDialogue_B2
	call LABEL_3A12
	call LABEL_3999
	jp LABEL_3464

++:	
	xor a
	ld ($C2EC), a
	push hl
	ld a, ItemID_RoadPass
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	pop hl
	jr z, LABEL_2C46
	ld (Current_money), hl
	call LABEL_39F7
	call Inventory_AddItem
	ld hl, $0146
	call ShowDialogue_B2
	call LABEL_3A12
	call LABEL_3999
	jp LABEL_3464

LABEL_2C8F:	
	ld hl, LABEL_B12_B832
	call ShowDialogue_B12
	jp LABEL_2BC6

LABEL_2C98:	
	ld hl, LABEL_B12_B85D
	call ShowDialogue_B12
	call LABEL_3777
	push af
	push bc
	call LABEL_3797
	pop bc
	pop af
	bit 4, c
	jp nz, LABEL_2CEA
	or a
	jp z, LABEL_2BD4
LABEL_2CB1:	
	ld hl, LABEL_B12_B882
	call ShowDialogue_B12
	call LABEL_34D5
	bit 4, c
	push af
	call LABEL_3656
	pop af
	jp nz, LABEL_2CEA
	ld hl, $FFFF
	ld (hl), $03
	ld a, ($C2C4)
	and $3F
	add a, a
	ld hl, LABEL_B03_B82F
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld ($C2C5), hl
	or h
	jr nz, +
	ld hl, LABEL_B12_BD7E
	call ShowDialogue_B12
	jp LABEL_2CB1

LABEL_2CEA:	
	ld hl, LABEL_B12_B7E3
	call ShowDialogue_B12
	jp LABEL_3464

+:	
	ld hl, LABEL_B12_B89A
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr z, +
	jp LABEL_2CB1

+:	
	call Inventory_RemoveItem
	ld hl, ($C2C5)
	call LABEL_297A
	ld hl, LABEL_B12_B8BC
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jp z, LABEL_2CB1
	jp LABEL_2CEA

ShowYesNoPrompt:
	push	bc
	call	LABEL_37A3
	push	af
	call	LABEL_37C3
	pop	af
	pop	bc
	or	a
	ret

LABEL_2D25:
	ld   a, $08
	call	WaitForVInt
	ld   a, (Ctrl_1_pressed)
	and  Button_1_Mask|Button_2_Mask
	jp   z, LABEL_2D25
	ret

LABEL_2D33:
	ld   b, $1E
	jr   LABEL_2D39

LABEL_2D37:
	ld	b, $B4

LABEL_2D39:
	ld   a, $08
	call	WaitForVInt
	ld   a, (Ctrl_1_pressed)
	and  Button_1_Mask|Button_2_Mask
	ret  nz

	djnz	LABEL_2D39
	ret

LABEL_2D47:
	ld   b, $D0
LABEL_2D49:
	ld   a, $08
	call	WaitForVInt
	djnz	LABEL_2D49
	ret

CheckOptionSelect:
	ld   a, $FF
	ld   ($C268), a
	ld   hl, $0000
	ld   ($C26B), hl
	xor  a
	ld   ($C26D), a
OptionSelect_Loop:
	ld   a, $08
	call	WaitForVInt
	ld   a, (Ctrl_1_pressed)
	and  ButtonUp_Mask|ButtonDown_Mask
	jp   z, LABEL_2D8B
	ld   c, a
	ld   hl, Option_total_num
	ld   a, ($C26B)
	bit  ButtonUp, c
	jr   z, LABEL_2D7D
	sub  $01
	jr   nc, LABEL_2D7D
	ld   a, (hl)
LABEL_2D7D:
	bit  ButtonDown, c
	jr   z, LABEL_2D88
	inc  a
	cp   (hl)
	jr   c, LABEL_2D88
	jr   z, LABEL_2D88
	xor  a
LABEL_2D88:
	ld   ($C26B), a
LABEL_2D8B:
	ld   a, (Ctrl_1_pressed)
	and  Button_1_Mask|Button_2_Mask
	jp   z, OptionSelect_Loop
	ld   c, a
	xor  a
	ld   ($C26D), a
	ld   a, $08
	call	WaitForVInt
	xor  a
	ld   ($C268), a
	ld   a, ($C26B)
	ret


LABEL_2DA5:
	ld a, $FF
	ld ($C268), a

LABEL_2DAA:	
	ld a, $08
	call WaitForVInt
	ld a, (Ctrl_1_pressed)
	ld c, a
	and ButtonUp_Mask|ButtonDown_Mask
	jp z, ++
	ld c, a
	ld hl, Option_total_num
	ld a, ($C26B)
	bit 0, c
	jr z, +
	sub $01
	jr nc, +
	ld a, (hl)
+:	
	bit 1, c
	jr z, +
	inc a
	cp (hl)
	jr c, +
	jr z, +
	xor a
+:	
	ld ($C26B), a
	jp +++

++:	
	ld hl, ($C299)
	ld a, h
	or a
	jr z, +++
	bit 2, c
	jr z, +
	ld a, l
	sub $08
	jr nc, ++
	ld a, h
	jr ++

+:	
	bit 3, c
	jr z, +++
	ld a, l
	add a, $08
	cp h
	jr c, ++
	jr z, ++
	xor a
++:	
	ld ($C299), a
	jr ++++

+++:	
	ld a, c
	and $30
	jr z, LABEL_2DAA
	xor a
	ld ($C26D), a
	ld a, $08
	call WaitForVInt
	xor a
	ld ($C268), a
	bit 4, c
	ret nz
	ld a, (Inventory_curr_num)
	cp $09
	ld a, ($C26B)
	ret c
	or a
	jr z, +
	dec a
	ret

+:	
	ld hl, ($C299)
	ld a, l
	add a, $08
	cp h
	jr c, +
	jr z, +
	xor a
+:	
	ld ($C299), a
++++:	
	xor a
	ld ($C268), a
	call LABEL_352D
	ld a, ($C299)
	ld l, a
	ld a, (Inventory_curr_num)
	dec a
	cp $08
	ld h, $00
	jr c, +
	ld h, $01
+:	
	sub l
	cp $08
	jr c, +
	ld a, $07
+:	
	and $07
	add a, h
	ld (Option_total_num), a
	ld hl, ($C26B)
	cp l
	jr nc, +
	ld l, a
+:	
	ld h, l
	ld ($C26B), hl
	jp LABEL_2DA5

LABEL_2E62:
	ld a, ($C268)
	or a
	ret z
	ld a, (Game_mode)
	cp $03 ; GameMode_Intro
	ld bc, $F0F3
	jr nz, +
	ld bc, $FF00
+:	
	ld hl, (Cursor_pos)
	ld a, ($C26C)
	srl a
	ld e, $00
	rr e
	ld d, a
	add hl, de
	ex de, hl
	rst $08
	ld a, c
	out (Port_VDPData), a
	ld hl, (Cursor_pos)
	ld a, ($C26B)
	ld ($C26C), a
	srl a
	ld e, $00
	rr e
	ld d, a
	add hl, de
	ex de, hl
	rst $08
	ld a, ($C26D)
	dec a
	and $0F
	ld ($C26D), a
	bit 3, a
	ld a, b
	jr nz, +
	ld a, c
+:	
	out (Port_VDPData), a
	ret

LABEL_2EAC:
	ld hl, $D700
	ld de, $7B02
	ld bc, $030C
	call LABEL_3AA6
	ld a, ($C267)
	add a, a
	add a, a
	ld l, a
	add a, a
	add a, a
	add a, a
	add a, l
	ld hl, LABEL_B27_B40B
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	jp LABEL_3A57

LABEL_2ECD:
	ld hl, $D700
	ld de, $7B02
	ld bc, $030C
	jp LABEL_3A57

LABEL_2ED9:
	ld hl, $D724
	ld de, $7C80
	ld bc, $0640
	call LABEL_3AA6
	ld hl, LABEL_B27_B4AB
	ld de, $7C80
	ld ix, Alis_stats
	call +
	ld hl, LABEL_B27_B4DB
	ld de, $7C90
	ld ix, Myau_stats
	call +
	ld hl, LABEL_B27_B50B
	ld de, $7CA0
	ld ix, Odin_stats
	call +
	ld hl, LABEL_B27_B53B
	ld de, $7CB0
	ld ix, Noah_stats
+:	
	bit 0, (ix+status)
	ret z
LABEL_2F1B:	
	ld bc, $0310
	call LABEL_3A57
	ld hl, LABEL_30A7
	ld a, (ix+curr_hp)
	call LABEL_2FE1
	ld hl, LABEL_30AF
	ld a, (ix+curr_mp)
	call LABEL_2FE1
	ld hl, LABEL_B27_B49B
	ld bc, $0110
	jp LABEL_3A57

LABEL_2F3C:
	ld hl, LABEL_B27_B4AB
	ld de, $7C80
	ld ix, Alis_stats
	call +
	ld hl, LABEL_B27_B4DB
	ld de, $7C90
	ld ix, Myau_stats
	call +
	ld hl, LABEL_B27_B50B
	ld de, $7CA0
	ld ix, Odin_stats
	call +
	ld hl, LABEL_B27_B53B
	ld de, $7CB0
	ld ix, Noah_stats
+:	
	bit 0, (ix+status)
	ret z
	ld bc, $0310
	call LABEL_3A83
	ld hl, LABEL_30A7
	ld a, (ix+curr_hp)
	call LABEL_2FE1
	ld hl, LABEL_30AF
	ld a, (ix+curr_mp)
	call LABEL_2FE1
	ld hl, LABEL_B27_B49B
	ld bc, $0110
	jp LABEL_3A83

LABEL_2F93:
	push af
	ld hl, $D724
	ld de, $7C80
	ld bc, $0640
	call LABEL_3AA6
	pop af
LABEL_2FA1:	
	ld hl, LABEL_B27_B4AB
	ld de, $7C80
	ld ix, Char_stats
	or a
	jp z, LABEL_2F1B
	ld hl, LABEL_B27_B4DB
	ld de, $7C90
	ld ix, Myau_stats
	dec a
	jp z, LABEL_2F1B
	ld hl, LABEL_B27_B50B
	ld de, $7CA0
	ld ix, Odin_stats
	dec a
	jp z, LABEL_2F1B
	ld hl, LABEL_B27_B53B
	ld de, $7CB0
	ld ix, Noah_stats
	jp LABEL_2F1B

LABEL_2FD8:
	di
	push	de
	push	af
	rst  $08
	ld   b, $10
	jp   LABEL_2FE7

LABEL_2FE1:
	di
	push	de
	push	af
	rst  $08
	ld   b, $08
LABEL_2FE7:
	ld   a, (hl)
	out  (Port_VDPData), a
	inc  hl
	djnz	LABEL_2FE7
	pop  af
	ld   bc, $C010
	ld   d, $FF
LABEL_2FF3:
	sub  $64
	inc  d
	jr   nc, LABEL_2FF3
	add  a, $64
	ld   l, a
	ld   a, d
	call	LABEL_3645
	ld   d, $FF
	ld   a, l
LABEL_3002:
	sub  $0A
	inc  d
	jr   nc, LABEL_3002
	add  a, $0A
	ld   l, a
	ld   a, d
	call	LABEL_3645
	ld   d, $FF
	ld   a, l
LABEL_3011:
	sub  $01
	inc  d
	jr   nc, LABEL_3011
	ld   a, d
	ld   bc, $C110
	call	LABEL_3645
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $13
	out  (Port_VDPData), a
	pop  de
	ld   hl, $0040
	add  hl, de
	ex   de, hl
	ei
	ld   a, $0A
	call	WaitForVInt
	ret

LABEL_3036:
	di
	push	de
	push	bc
	rst  $08
	ld   b, $0C
LABEL_303C:
	ld   a, (hl)
	out  (Port_VDPData), a
	inc  hl
	djnz	LABEL_303C
	pop  hl
	ld   bc, $C010
	ld   de, $2710
	xor  a
	dec  a
LABEL_304B:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_304B
	add  hl, de
	call	LABEL_3645
	ld   de, $03E8
	ld   a, $FF
LABEL_3059:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_3059
	add  hl, de
	call	LABEL_3645
	ld   de, $0064
	ld   a, $FF
LABEL_3067:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_3067
	add  hl, de
	call	LABEL_3645
	ld   d, $FF
	ld   a, l
LABEL_3073:
	sub  $0A
	inc  d
	jr   nc, LABEL_3073
	add  a, $0A
	ld   l, a
	ld   a, d
	call	LABEL_3645
	ld   d, $FF
	ld   a, l
LABEL_3082:
	sub  $01
	inc  d
	jr   nc, LABEL_3082
	ld   a, d
	ld   bc, $C110
	call	LABEL_3645
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $13
	out  (Port_VDPData), a
	pop  de
	ld   hl, $0040
	add  hl, de
	ex   de, hl
	ei
	ld   a, $0A
	call	WaitForVInt
	ret


LABEL_30A7:
.db $F3, $11, $F4, $11, $F5, $11, $C0, $10

LABEL_30AF:
.db	$F3, $11, $F6, $11, $F5, $11, $C0, $10

LABEL_30B7:
	ld hl, $D724
	ld de, $7C80
	ld bc, $0640
	jp LABEL_3A57

LABEL_30C3:
	ld   hl, $D8A4
	ld   de, $7842
	ld   bc, $0B0C
	call	LABEL_3AA6
	ld   hl, LABEL_B27_B56B
	jp   LABEL_3A57


LABEL_30D5:
	ld hl, LABEL_B27_B56B
	ld de, $7842
	ld bc, $0B0C
	jp LABEL_3A83

LABEL_30E1:
	ld hl, $D8A4
	ld de, $7842
	ld bc, $0B0C
	jp LABEL_3A57

LABEL_30ED:
	ld   hl, $D928
	ld   de, $781C
	ld   bc, $0414
	call	LABEL_3AA6
	ld   hl, $D978
	ld   de, $7830
	ld   bc, $0A10
	call	LABEL_3AA6
	
LABEL_3105:
	ld   hl, LABEL_B27_BACF
	ld   de, $781C
	ld   bc, $0114
	call	LABEL_3A83
	ld   hl, CurrentBattle_EnemyName
	ld   c, $00
	call	LABEL_315C
	ld   c, $01
	call	LABEL_315C
	ld   hl, LABEL_B27_BAE3
	ld   bc, $0114
	call	LABEL_3A83
	ld   a, ($C2E6)
	cp   $49
	ret  z

	ld   hl, LABEL_B27_B4AB
	ld   de, $7830
	ld   bc, $0110
	call	LABEL_3A57
	ld   ix, $C440
	ld   a, ($C2C7)
	ld   b, a
LABEL_3141:
	push	bc
	ld   hl, LABEL_30A7
	ld   a, (ix+1)
	call	LABEL_2FE1
	ld   bc, $0010
	add  ix, bc
	pop  bc
	djnz	LABEL_3141
	ld   hl, LABEL_B27_B49B
	ld   bc, $0110
	jp   LABEL_3A57

LABEL_315C:
	di
	push	bc
	push	hl
	push	de
	rst  $08
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $11
	out  (Port_VDPData), a
	ld   b, $08
LABEL_316F:
	ld   a, (hl)
	sub  $20
	add  a, a
	add  a, c
	ld   de, LABEL_7D17
	add  a, e
	ld   e, a
	adc  a, d
	sub  e
	ld   d, a
	ld   a, (de)
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $10
	out  (Port_VDPData), a
	inc  hl
	djnz	LABEL_316F
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $13
	out  (Port_VDPData), a
	pop  de
	ld   hl, $0040
	add  hl, de
	ex   de, hl
	pop  hl
	pop  bc
	ei
	ret

LABEL_319E:
	ld   hl, $D978
	ld   de, $7830
	ld   bc, $0A10
	ld   a, ($C2E6)
	cp   $49
	call	nz, LABEL_3A57
	ld   hl, $D928
	ld   de, $781C
	ld   bc, $0414
	jp   LABEL_3A57


LABEL_31BB:
.db "ALIS"
.db	"MYAU"
.db	"ODIN"
.db	"NOAH"

LABEL_31CB:
	dec  hl
	jp   LABEL_3235

ShowDialogue_B12:
	ld   a, :Bank12
	ld   ($FFFF), a
	
LABEL_31D4:
	ld   a, ($C2D3)
	or   a
	jp   nz, LABEL_31CB
	ld   a, $FF
	ld   ($C2D3), a
	push	hl
	ld   hl, $DA18
	ld   de, $7C8C
	ld   bc, $0628
	call	LABEL_3AA6
	ld   hl, LABEL_B27_B5EF
	call	LABEL_3A57
	pop  hl
LABEL_31F4:
	ld   de, $7CCE
	ld   bc, $1200
LABEL_31FA:
	ld   a, (hl)
	or   a
	jp   m, LABEL_3332
	cp   $65
	jp   nc, LABEL_2D25
	cp   $62
	ret  z

	cp   $63
	jp   z, LABEL_2D33
	cp   $64
	jp   z, LABEL_2D47
	cp   $61
	jr   nz, LABEL_321B
	call	LABEL_2D25
	jp   LABEL_3235

LABEL_321B:
	cp   $5F
	jr   nz, LABEL_3231
	push	hl
	ld   hl, LABEL_B27_B5EF
	ld   de, $7C8C
	ld   bc, $0628
	call	LABEL_3A83
	pop  hl
	inc  hl
	jp   LABEL_31F4

LABEL_3231:
	cp   $60
	jr   nz, LABEL_3244
LABEL_3235:
	ld   a, c
	or   a
	call	nz, LABEL_342C
	ld   de, $7D4E
	ld   bc, $1201
	inc  hl
	jp   LABEL_31FA

LABEL_3244:
	cp   $5B
	jr   nz, LABEL_3262
	push	hl
	ld   a, ($C2C2)
	and  $03
	add  a, a
	add  a, a
	ld   hl, LABEL_31BB
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, $04
	call	LABEL_336C
	pop  hl
	inc  hl
	jp   LABEL_31FA

LABEL_3262:
	cp   $5C
	jr   nz, LABEL_3274
	push	hl
	ld   hl, CurrentBattle_EnemyName
	ld   a, $08
	call	LABEL_336C
	pop  hl
	inc  hl
	jp   LABEL_31FA

LABEL_3274:
	cp   $5D
	jr   nz, LABEL_3292
	push	hl
	ld   a, ($C2C4)
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	push	bc
	ld   bc, LABEL_7DA3
	add  hl, bc
	pop  bc
	ld   a, $08
	call	LABEL_336C
	pop  hl
	inc  hl
	jp   LABEL_31FA

LABEL_3292:
	cp   $5E
	jr   nz, LABEL_32F5
	push	hl
	push	bc
	push	de
	ld   hl, ($C2C5)
	ld   de, $2710
	xor  a
	ld   c, a
	dec  a
LABEL_32A2:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_32A2
	add  hl, de
	pop  de
	call	LABEL_32FB
	push	de
	ld   de, $03E8
	ld   a, $FF
LABEL_32B2:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_32B2
	add  hl, de
	pop  de
	call	LABEL_32FB
	push	de
	ld   de, $0064
	ld   a, $FF
LABEL_32C2:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_32C2
	add  hl, de
	pop  de
	call	LABEL_32FB
	push	de
	ld   d, $FF
	ld   a, l
LABEL_32D0:
	sub  $0A
	inc  d
	jr   nc, LABEL_32D0
	add  a, $0A
	ld   l, a
	ld   a, d
	pop  de
	call	LABEL_32FB
	push	de
	ld   d, $FF
	ld   a, l
LABEL_32E1:
	sub  $01
	inc  d
	jr   nc, LABEL_32E1
	ld   a, d
	ld   c, $01
	pop  de
	call	LABEL_32FB
	ld   a, b
	pop  bc
	ld   b, a
	pop  hl
	inc  hl
	jp   LABEL_31FA

LABEL_32F5:
	call	LABEL_33D6
	jp   LABEL_31FA

LABEL_32FB:
	or   a
	jp   nz, LABEL_3302
	bit  0, c
	ret  z

LABEL_3302:
	ld   c, $01
	di
	push	de
	push	af
	rst  $08
	push	af
	pop  af
	ld   a, $C0
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $10
	out  (Port_VDPData), a
	ld   a, $40
	add  a, e
	ld   e, a
	adc  a, d
	sub  e
	ld   d, a
	rst  $08
	pop  af
	add  a, $C1
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $10
	out  (Port_VDPData), a
	pop  de
	inc  de
	inc  de
	ei
	ld   a, $0A
	call	WaitForVInt
	dec  b
	ret

LABEL_3332:
	call	LABEL_333E
	jp   LABEL_31FA

LABEL_3338:
	call LABEL_333E
	jp LABEL_3389

LABEL_333E:
	push	hl
	and  $7F
	add  a, a
	ld   hl, $BA81
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, ($FFFF)
	push	af
	ld   a, :Bank02
	ld   ($FFFF), a
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
LABEL_3357:
	call	LABEL_33D6
	ld   a, (hl)
	cp   $65
	jr   nz, LABEL_3357
	pop  af
	ld   ($FFFF), a
	pop  hl
	inc  hl
	ld   a, b
	or   a
	ret  nz

	ld   a, (hl)
	jp   LABEL_3419

LABEL_336C:
	push	af
	call	LABEL_33D6
	ld   a, (hl)
	cp   $65
	jr   z, LABEL_337B
	pop  af
	dec  a
	jp   nz, LABEL_336C
	ret

LABEL_337B:
	pop  af
	ret


LABEL_337D:
	ld a, $02
	ld ($FFFF), a
	ld de, $7C0C
	ld bc, $0000
-:	
	push de
LABEL_3389:	
	ld a, (hl)
	or a
	jp m, LABEL_3338
	cp $63
	jr z, LABEL_33D1
	cp $65
	jr z, +++
	cp $61
	jr z, ++
	cp $5F
	jr z, ++
	cp $60
	jr nz, +
	inc hl
	ex de, hl
	pop hl
	ld bc, $0080
	add hl, bc
	ex de, hl
	jp -

+:	
	call LABEL_33D6
	jr LABEL_3389

++:	
	pop de
	push hl
	cp $5F
	call nz, LABEL_2D25
	ld de, $7C00
	ld bc, $0100
	ld hl, $0800
	di
	call LABEL_363
	ei
	pop hl
	inc hl
	jp LABEL_337D

+++:	
	call LABEL_2D25
	pop de
	ret

LABEL_33D1:	
	call LABEL_2D47
	pop de
	ret

LABEL_33D6:
	di
	push	bc
	push	de
	rst  $08
	ld   a, (hl)
	sub  $20
	add  a, a
	ld   bc, LABEL_7D17
	add  a, c
	ld   c, a
	adc  a, b
	sub  c
	ld   b, a
	ld   a, (bc)
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $10
	out  (Port_VDPData), a
	ex   de, hl
	ld   bc, $0040
	add  hl, bc
	ex   de, hl
	rst  $08
	ld   a, (hl)
	sub  $20
	add  a, a
	ld   bc, LABEL_7D18
	add  a, c
	ld   c, a
	adc  a, b
	sub  c
	ld   b, a
	ld   a, (bc)
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $10
	out  (Port_VDPData), a
	inc  hl
	pop  de
	inc  de
	inc  de
	pop  bc
	ei
	ld   a, $0A
	call	WaitForVInt
	dec  b
	ret  nz

	ld   a, (hl)
LABEL_3419:
	or   a
	jp   m, LABEL_3420
	cp   $5F
	ret  nc

LABEL_3420:
	ld   a, c
	or   a
	call	nz, LABEL_342C
	ld   de, $7D4E
	ld   bc, $1201
	ret

LABEL_342C:
	push	bc
	push	de
	push	hl
	call	LABEL_3439
	call	LABEL_3439
	pop  hl
	pop  de
	pop  bc
	ret

LABEL_3439:
	ld   hl, $DB08
	ld   de, $7D0E
	ld   bc, $0324
	call	LABEL_3AA6
	ld   hl, $DB08
	ld   de, $7CCE
	ld   bc, $0324
	call	LABEL_3A83
	ld   hl, LABEL_B27_B619
	ld   bc, $0124
	call	LABEL_3A83
	ld   b, $04
LABEL_345C:
	ld   a, $0A
	call	WaitForVInt
	djnz	LABEL_345C
	ret

LABEL_3464:
	ld   hl, $C2D3
	ld   a, (hl)
	or   a
	ret  z

	ld   (hl), $00
	ld   hl, $DA18
	ld   de, $7C8C
	ld   bc, $0628
	jp   LABEL_3A57


LABEL_3478:
	push af
	push bc
	ld hl, $DB74
	ld de, $7A0C
	ld bc, $0C0C
	call LABEL_3AA6
	pop bc
	pop af
	add a, a
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld e, l
	ld d, h
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	add hl, hl
	ld de, LABEL_B27_B6DF
	add hl, de
	ld de, $7A0C
	ld a, b
	or a
	jp z, +
	add a, a
	inc a
	ld b, a
	ld c, $0C
	push bc
	call LABEL_3A57
	pop bc
	ld a, b
	add a, a
	ld l, a
	add a, a
	add a, l
	add a, a
	ld hl, LABEL_B27_BA3F
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, $0C
	sub b
	ld b, a
	jp LABEL_3A57

+:	
	ld hl, LABEL_B27_BA3F
	ld bc, $0C0C
	jp LABEL_3A57

LABEL_34C9:
	ld hl, $DB74
	ld de, $7A0C
	ld bc, $0C0C
	jp LABEL_3A57

LABEL_34D5:
	ld a, (Inventory_curr_num)
	dec a
	and $18
	ld h, a
	ld l, $00
	ld ($C299), hl
	call LABEL_3521
	ld a, (Inventory_curr_num)
	or a
	jp z, LABEL_2D25
	dec a
	cp $08
	ld l, $00
	jr c, +
	ld l, $01
	ld a, $07
+:	
	and $07
	add a, l
	ld (Option_total_num), a
	ld hl, $796C
	ld (Cursor_pos), hl
	ld hl, $0000
	ld ($C26B), hl
	xor a
	ld ($C26D), a
	call LABEL_2DA5
	ld l, a
	ld a, ($C299)
	add a, l
	ld hl, Inventory
	add a, l
	ld l, a
	ld ($C29B), hl
	ld a, (hl)
	ld ($C2C4), a
	ret

LABEL_3521:	
	ld hl, $DC04
	ld de, $78AC
	ld bc, $1514
	call LABEL_3AA6

LABEL_352D:
	ld hl, LABEL_B27_BACF
	ld de, $78AC
	ld bc, $0114
	call LABEL_3A57
	call LABEL_35C4
	ld a, (Inventory_curr_num)
	cp $09
	ld hl, LABEL_B27_BAF7
	ld bc, $0214
	call nc, LABEL_3A57
	ld a, ($C299)
	ld hl, Inventory
	add a, l
	ld l, a
	ld b, $08
-:	
	ld c, $00
	call LABEL_356B
	ld c, $01
	call LABEL_356B
	inc hl
	djnz -
	ld hl, LABEL_B27_BAE3
	ld bc, $0114
	call LABEL_3A57
	ret

LABEL_356B:
	di
	push	bc
	push	hl
	push	de
	rst  $08
	ld   l, (hl)
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, LABEL_7DA3
	add  hl, de
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $11
	out  (Port_VDPData), a
	ld   b, $08
LABEL_3588:
	ld   a, (hl)
	sub  $20
	add  a, a
	add  a, c
	ld   de, LABEL_7D17
	add  a, e
	ld   e, a
	adc  a, d
	sub  e
	ld   d, a
	ld   a, (de)
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $10
	out  (Port_VDPData), a
	inc  hl
	djnz	LABEL_3588
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $13
	out  (Port_VDPData), a
	pop  de
	ld   hl, $0040
	add  hl, de
	ex   de, hl
	pop  hl
	pop  bc
	ei
	ld   a, $0A
	call	WaitForVInt
	ret

LABEL_35BC:
	di
	push	de
	rst  $08
	ld   b, $0C
	jp   LABEL_35C9


LABEL_35C4:
	di
	push de
	rst $08
	ld b, $08

LABEL_35C9:
	ld   hl, LABEL_3639
LABEL_35CC:
	ld   a, (hl)
	out  (Port_VDPData), a
	inc  hl
	djnz	LABEL_35CC
	ld   hl, (Current_money)
	
LABEL_35D5:
	ld   bc, $C010
	ld   de, $2710
	xor  a
	cpl
LABEL_35DD:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_35DD
	add  hl, de
	call	LABEL_3645
	ld   de, $03E8
	xor  a
	cpl
LABEL_35EB:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_35EB
	add  hl, de
	call	LABEL_3645
	ld   de, $0064
	xor  a
	cpl
LABEL_35F9:
	sbc  hl, de
	inc  a
	jr   nc, LABEL_35F9
	add  hl, de
	call	LABEL_3645
	ld   d, $FF
	ld   a, l
LABEL_3605:
	sub  $0A
	inc  d
	jr   nc, LABEL_3605
	add  a, $0A
	ld   l, a
	ld   a, d
	call	LABEL_3645
	ld   d, $FF
	ld   a, l
LABEL_3614:
	sub  $01
	inc  d
	jr   nc, LABEL_3614
	ld   a, d
	ld   bc, $C110
	call	LABEL_3645
	
LABEL_3620:
	push	af
	pop  af
	ld   a, $F3
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, $13
	out  (Port_VDPData), a
	pop  de
	ld   hl, $0040
	add  hl, de
	ex   de, hl
	ei
	ld   a, $0A
	call	WaitForVInt
	ret


LABEL_3639:
.db $F3, $11, $D7, $10, $DD, $10, $DE, $10, $C0, $10, $C0, $10

LABEL_3645:
	and  $0F
	jp   z, LABEL_364D
	ld   bc, $C110
LABEL_364D:
	add  a, b
	out  (Port_VDPData), a
	push	af
	pop  af
	ld   a, c
	out  (Port_VDPData), a
	ret


LABEL_3656:
	push bc
	ld hl, $DC04
	ld de, $78AC
	ld bc, $1514
	call LABEL_3A57
	pop bc
	ret


LABEL_3665:
	ld   a, (Party_curr_num)
	or   a
	ret  z	; return if there's only 1 party member

	ld   hl, $DDA8
	ld   de, $7A44
	ld   bc, $090C
	call	LABEL_3AA6
	call	LABEL_369F
	ld   hl, $7A84
	ld   (Cursor_pos), hl
	jp   CheckOptionSelect


LABEL_3682:
	ld a, (Party_curr_num)
	or a
	ret z
	ld hl, $DE14
	ld de, $7A54
	ld bc, $090C
	call LABEL_3AA6
	call LABEL_369F
	ld hl, $7A94
	ld (Cursor_pos), hl
	jp CheckOptionSelect

LABEL_369F:
	ld   a, (Party_curr_num)
	or   a
	ret  z

	ld   (Option_total_num), a
	inc  a
	add  a, a
	ld   b, a
	ld   c, $0C
	ld   hl, LABEL_B27_BB1F
	call	LABEL_3A57
	ld   hl, LABEL_B27_BB7F
	ld   bc, $010C
	jp   LABEL_3A57

LABEL_36BB:
	ld   a, (Party_curr_num)
	or   a
	ret  z

	ld   hl, $DDA8
	ld   de, $7A44
	ld   bc, $090C
	jp   LABEL_3A57


LABEL_36CC:
	ld a, (Party_curr_num)
	or a
	ret z
	ld hl, $DE14
	ld de, $7A54
	ld bc, $090C
	jp LABEL_3A57

LABEL_36DD:
	ld   hl, $D8A4
	ld   de, $7842
	ld   bc, $0B0C
	call	LABEL_3AA6
	ld   hl, LABEL_B27_BB8B
	jp   LABEL_3A57


LABEL_36EF:
	ld hl, LABEL_B27_BB8B
	ld de, $7842
	ld bc, $0B0C
	jp LABEL_3A83

LABEL_36FB:
	ld hl, $D8A4
	ld de, $7842
	ld bc, $0B0C
	jp LABEL_3A57

LABEL_3707:
	push	af
	ld   hl, $D928
	ld   de, $7A8C
	ld   bc, $0814
	call	LABEL_3AA6
	ld   hl, LABEL_B27_BACF
	ld   de, $7A8C
	ld   bc, $0114
	call	LABEL_3A57
	pop  af
	push	af
	add  a, a
	add  a, a
	add  a, a
	add  a, a
	ld   hl, $FFFF
	ld   (hl), :Bank02
	ld   hl, Char_stats+weapon
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   b, $03
LABEL_3735:
	ld   c, $00
	call	LABEL_356B
	ld   c, $01
	call	LABEL_356B
	inc  hl
	djnz	LABEL_3735
	ld   hl, LABEL_B27_BAE3
	ld   bc, $0114
	call	LABEL_3A57
	pop  af
	ret


LABEL_374D:
	ld hl, $D928
	ld de, $7A8C
	ld bc, $0814
	jp LABEL_3A57

LABEL_3759:
	ld hl, $DE14
	ld de, $7A32
	ld bc, $070A
	call LABEL_3AA6
	ld hl, LABEL_B27_BC0F
	jp LABEL_3A57

LABEL_376B:
	ld hl, $DE14
	ld de, $7A32
	ld bc, $070A
	jp LABEL_3A57

LABEL_3777:
	ld hl, $DE14
	ld de, $7B48
	ld bc, $050C
	call LABEL_3AA6
	ld hl, LABEL_B27_BC55
	call LABEL_3A57
	ld hl, $7B88
	ld (Cursor_pos), hl
	ld a, $01
	ld (Option_total_num), a
	jp CheckOptionSelect

LABEL_3797:
	ld hl, $DE14
	ld de, $7B48
	ld bc, $050C
	jp LABEL_3A57

LABEL_37A3:
	ld   hl, $DE64
	ld   de, $7B6A
	ld   bc, $050A
	call	LABEL_3AA6
	ld   hl, LABEL_B27_BC91
	call	LABEL_3A57
	ld   hl, $7BAA
	ld   (Cursor_pos), hl
	ld   a, $01
	ld   (Option_total_num), a
	jp   CheckOptionSelect

LABEL_37C3:
	ld   hl, $DE64
	ld   de, $7B6A
	ld   bc, $050A
	jp   LABEL_3A57

LABEL_37CF:
	add  a, a
	add  a, a
	add  a, a
	add  a, a
	ld   hl, Char_stats
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	push	hl
	pop  ix
	ld   hl, $DC04
	ld   de, $7920
	ld   bc, $0E18
	call	LABEL_3AA6
	ld   hl, LABEL_B27_BCC3
	ld   bc, $0118
	call	LABEL_3A57
	ld   hl, LABEL_3865
	ld   a, (ix+5)
	call	LABEL_2FD8
	ld   hl, LABEL_3875
	ld   c, (ix+3)
	ld   b, (ix+4)
	call	LABEL_3036
	ld   hl, LABEL_B27_BCDB
	ld   bc, $0118
	call	LABEL_3A57
	ld   hl, LABEL_3881
	ld   a, (ix+8)
	call	LABEL_2FD8
	ld   hl, LABEL_B27_BCDB
	ld   bc, $0118
	call	LABEL_3A57
	ld   hl, LABEL_3891
	ld   a, (ix+9)
	call	LABEL_2FD8
	ld   hl, LABEL_B27_BCDB
	ld   bc, $0118
	call	LABEL_3A57
	ld   hl, LABEL_38A1
	ld   a, (ix+6)
	call	LABEL_2FD8
	ld   hl, LABEL_B27_BCDB
	ld   bc, $0118
	call	LABEL_3A57
	ld   hl, LABEL_38B1
	ld   a, (ix+7)
	call	LABEL_2FD8
	ld   hl, LABEL_B27_BCF3
	ld   bc, $0118
	call	LABEL_3A57
	call	LABEL_35BC
	ld   hl, LABEL_B27_BD0B
	ld   bc, $0118
	jp   LABEL_3A57


LABEL_3865:
.db $F3, $11, $FA, $11, $FB, $11, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10

LABEL_3875:
.db $F3, $11, $F7, $11, $F5, $11, $C0, $10, $C0, $10, $C0, $10

LABEL_3881:
.db	$F3, $11, $CB, $10
.db $DE, $10, $DE, $10, $CB, $10, $CD, $10, $D5, $10, $C0, $10

LABEL_3891:
.db	$F3, $11, $CE, $10
.db $CF, $10, $D0, $10, $CF, $10, $D8, $10, $DD, $10, $CF, $10

LABEL_38A1:
.db	$F3, $11, $D7, $10
.db $CB, $10, $E2, $10, $C0, $10, $D2, $10, $DA, $10, $C0, $10

LABEL_38B1:
.db	$F3, $11, $D7, $10
.db $CB, $10, $E2, $10, $C0, $10, $D7, $10, $DA, $10, $C0, $10

LABEL_38C1:
	ld hl, $DC04
	ld de, $7920
	ld bc, $0E18
	jp LABEL_3A57

LABEL_38CD:
	ld hl, $D8A4
	ld de, $780C
	ld bc, $0820
	jp LABEL_3AA6

LABEL_38D9:
	ld hl, LABEL_B27_BD23
	ld de, $780C
	ld bc, $0120
	call LABEL_3A57
	ld hl, $FFFF
	ld (hl), $03
	ld a, ($C2DB)
	and $1F
	ld l, a
	ld h, $00
	add hl, hl
	ld c, l
	ld b, h
	add hl, hl
	add hl, hl
	add hl, bc
	ld bc, $B70D
	add hl, bc
	ld a, (hl)
	ld (Option_total_num), a
	inc hl
	push hl
	ld b, $03
-:	
	push bc
	ld c, $00
	push hl
	call +
	pop hl
	ld c, $01
	push hl
	call +
	pop hl
	inc hl
	inc hl
	inc hl
	pop bc
	djnz -
	ld hl, LABEL_B27_BD43
	ld bc, $0120
	call LABEL_3A57
	ld hl, $788C
	ld (Cursor_pos), hl
	call CheckOptionSelect
	ld hl, $FFFF
	ld (hl), $03
	pop hl
	ld b, a
	add a, a
	add a, b
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ret

+:	
	di
	push de
	push hl
	rst $08
	ld a, (hl)
	or a
	jr nz, +
	ld c, $00
+:	
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, LABEL_7DA3
	add hl, de
	push af
	pop af
	ld a, $F3
	out (Port_VDPData), a
	push af
	pop af
	ld a, $11
	out (Port_VDPData), a
	ld b, $08
-:	
	ld a, (hl)
	sub $20
	add a, a
	add a, c
	ld de, LABEL_7D17
	add a, e
	ld e, a
	adc a, d
	sub e
	ld d, a
	ld a, (de)
	out (Port_VDPData), a
	push af
	pop af
	ld a, $10
	out (Port_VDPData), a
	inc hl
	djnz -
	ld a, c
	or a
	ld b, $01
	jr nz, LABEL_397D
	ld b, $06
LABEL_397D:	
	push af
	pop af
	ld a, $C0
	out (Port_VDPData), a
	push af
	pop af
	ld a, $10
	out (Port_VDPData), a
	djnz LABEL_397D
	pop hl
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld a, c
	or a
	jp nz, LABEL_35D5
	jp LABEL_3620

LABEL_3999:
	ld hl, $D8A4
	ld de, $780C
	ld bc, $0820
	jp LABEL_3A57

LABEL_39A5:
	ld hl, $D928
	ld de, $786E
	ld bc, $0C12
	call LABEL_3AA6

LABEL_39B1:
	ld a, $08
	ld ($FFFC), a
	ld hl, $8100
	ld de, $786E
	ld bc, $0C12
	call LABEL_3A68
	ld a, $80
	ld ($FFFC), a
	ld hl, $78EE
	ld (Cursor_pos), hl
	ld a, $04
	ld (Option_total_num), a
	call CheckOptionSelect
	ld l, a
	inc l
	ld h, $00
	ld ($C2C5), hl
	ret

LABEL_39DD:
	ld hl, $D928
	ld de, $786E
	ld bc, $0C12
	jp LABEL_3A57

LABEL_39E9:
	push bc
	ld hl, $D700
	ld de, $782C
	ld bc, $0314
	call LABEL_3AA6
	pop bc

LABEL_39F7:
	push bc
	ld hl, LABEL_B27_BACF
	ld de, $782C
	ld bc, $0114
	call LABEL_3A57
	call LABEL_35C4
	ld hl, LABEL_B27_BAE3
	ld bc, $0114
	call LABEL_3A57
	pop bc
	ret

LABEL_3A12:
	push bc
	ld hl, $D700
	ld de, $782C
	ld bc, $0314
	call LABEL_3A57
	pop bc
	ret

LABEL_3A21:	
	ld hl, $DE14
	ld de, $7AE4
	ld bc, $0710
	call LABEL_3AA6
	ld a, :Bank18
	ld ($FFFF), a
	ld hl, LABEL_B18_BE84
	call LABEL_3A68
	ld hl, $7B24
	ld (Cursor_pos), hl
	ld a, $02
	ld (Option_total_num), a
	call CheckOptionSelect
	push af
	push bc
	ld hl, $DE14
	ld de, $7AE4
	ld bc, $0710
	call LABEL_3A57
	pop bc
	pop af
	ret

LABEL_3A57:
	ld   a, ($FFFF)
	push	af
	ld   a, :Bank27
	ld   ($FFFF), a
	call	LABEL_3A68
	pop  af
	ld   ($FFFF), a
	ret

LABEL_3A68:
	push	bc
	di
	rst  $08
	ld   b, c
	ld   c, $BE
LABEL_3A6E:
	outi
	jp   nz, LABEL_3A6E
	ex   de, hl
	ld   bc, $0040
	add  hl, bc
	ex   de, hl
	ei
	ld   a, $0A
	call	WaitForVInt
	pop  bc
	djnz	LABEL_3A68
	ret

LABEL_3A83:
	ld   a, ($FFFF)
	push	af
	ld   a, :Bank27
	ld   ($FFFF), a
	di
LABEL_3A8D:
	push	bc
	rst  $08
	ld   b, c
	ld   c, $BE
LABEL_3A92:
	outi
	jp   nz, LABEL_3A92
	ex   de, hl
	ld   bc, $0040
	add  hl, bc
	ex   de, hl
	pop  bc
	djnz	LABEL_3A8D
	ei
	pop  af
	ld   ($FFFF), a
	ret

LABEL_3AA6:
	di
	push	bc
	push	de
	res  6, d
LABEL_3AAB:
	push	bc
	rst  $08
	ld   b, c
	ld   c, $BE
LABEL_3AB0:
	ini
	push	af
	pop  af
	jp   nz, LABEL_3AB0
	ex   de, hl
	ld   bc, $0040
	add  hl, bc
	ex   de, hl
	pop  bc
	djnz	LABEL_3AAB
	pop  de
	pop  bc
	ei
	ret


LABEL_3AC4:
.db $F1, $11, $F2, $11, $F2, $11, $F2, $11, $F2, $11, $F2, $11, $F2, $11, $F2, $11
.db $F1, $13, $F3, $11, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10
.db $C0, $10, $F3, $13, $F3, $11, $C2, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10
.db $C0, $10, $C0, $10, $F3, $13, $F3, $11, $C0, $10, $C0, $10, $C0, $10, $C0, $10
.db $C0, $10, $C0, $10, $C0, $10, $F3, $13, $F3, $11, $C3, $10, $C0, $10, $C0, $10
.db $C0, $10, $C0, $10, $C0, $10, $C0, $10, $F3, $13, $F3, $11, $C0, $10, $C0, $10
.db $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $F3, $13, $F3, $11, $C4, $10
.db $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $F3, $13, $F3, $11
.db $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $F3, $13
.db $F3, $11, $C5, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10
.db $F3, $13, $F3, $11, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10
.db $C0, $10, $F3, $13, $F3, $11, $C6, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10
.db $C0, $10, $C0, $10, $F3, $13, $F1, $15, $F2, $15, $F2, $15, $F2, $15, $F2, $15
.db $F2, $15, $F2, $15, $F2, $15, $F1, $17


GameMode_Interaction:
	ld a, (Game_is_paused)
	or a
	call nz, PauseLoop
	ld a, $08
	call WaitForVInt
	ld a, ($C29D)
	or a
	jp nz, LABEL_3C1A
	ld a, ($C2DC)
	call LABEL_617D
	ld a, ($C29E)
	sub $10
	jr nc, +
	xor a
+:	
	and $0F
	ld hl, LABEL_3C2A
	call GetPtrAndJump
LABEL_3BC5:	
	ld a, ($C29E)
	sub $0F
	jr nc, +
	xor a
+:	
	and $0F
	ld l, a
	ld h, $00
	ld de, LABEL_3D25
	add hl, de
	ld a, (hl)
	or a
	jr z, +
	ld a, $D8
	ld ($C004), a
+:	
	xor a
	ld ($C29D), a
	ld ($C29E), a
	ld ($C2D5), a
	ld hl, $0000
	ld ($C2DB), hl
	ld hl, $C800
	ld de, $C801
	ld bc, $00FF
	ld (hl), $00
	ldir
	ld a, (Game_mode)
	cp $0D ; GameMode_Interaction
	ret nz
	ld a, ($C2E9)
	bit 7, a
	jr z, +
	ld a, $04 ; GameMode_LoadShip
	ld (Game_mode), a
	ret

+:	
	or a
	ld a, $08 ; GameMode_LoadMap
	jr z, +
	ld a, $0E ; GameMode_LoadRoad
+:	
	ld (Game_mode), a
	ret

LABEL_3C1A:	
	call LABEL_5FFE
	call LABEL_100F
	ld a, ($C800)
	or a
	call nz, LABEL_1BE1
	jp LABEL_3BC5


LABEL_3C2A:
.dw	LABEL_474B
.dw	LABEL_474B
.dw	LABEL_298D
.dw	LABEL_298D
.dw	LABEL_2A85
.dw	LABEL_2A85
.dw	LABEL_2BC0
.dw	LABEL_2BC0
.dw LABEL_2C8F
.dw	LABEL_2C8F
.dw	LABEL_2C98
.dw	LABEL_2C98
.dw	LABEL_474B
.dw	LABEL_474B
.dw	LABEL_474B
.dw	LABEL_474B
.dw LABEL_474B
.dw	LABEL_474B
.dw	LABEL_474B
.dw	LABEL_474B


GameMode_LoadInteraction:
	ld a, $D6
	ld ($C004), a
	call FadeOut2
	ld a, ($C308)
	or a
	jr nz, +
	ld a, ($C29E)
	cp $05
	jr nz, LABEL_3CAD
	ld a, $04
	ld ($C29E), a
	jr LABEL_3CAD

+:	
	cp $01
	jr nz, +
	ld a, ($C29E)
	cp $01
	jr nz, LABEL_3CAD
	ld a, $05
	ld ($C29E), a
	jr LABEL_3CAD

+:	
	cp $07
	jr nz, +
	ld a, ($C29E)
	cp $01
	jr nz, LABEL_3CAD
	ld a, $05
	ld ($C29E), a
	jr LABEL_3CAD

+:	
	cp $08
	jr nz, +
	ld a, $06
	ld ($C29E), a
	jr LABEL_3CAD

+:	
	cp $0A
	jr nz, LABEL_3CAD
	ld a, ($C29E)
	cp $09
	jr nz, LABEL_3CAD
	ld a, $08
	ld ($C29E), a
LABEL_3CAD:	
	ld a, ($C29E)
	or a
	jr nz, +
	inc a
	ld ($C29E), a
+:	
	call LABEL_3D47
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, LABEL_B16_BAD8
	ld de, $5800
	call LABEL_3FA
	ld hl, LABEL_B16_BD58
	ld de, $7E00
	call LABEL_3FA
	xor a
	ld ($C304), a
	ld ($C300), a
	ld ($C800), a
	ld ($C2E9), a
	dec a
	ld ($C2D6), a
	ld hl, $0000
	ld ($C213), hl
	ld hl, $FF00
	ld ($C2BC), hl
	di
	call LABEL_63A5
	ei
	ld a, ($C29E)
	sub $0F
	jr nc, +
	xor a
+:	
	and $0F
	ld l, a
	ld h, $00
	ld de, LABEL_3D25
	add hl, de
	ld a, (hl)
	or a
	jr z, +
	ld ($C004), a
+:	
	ld hl, Game_mode
	inc (hl) ; GameMode_Interaction
	di
	ld de, $8006
	rst $08
	ei
	ld a, $0C
	call WaitForVInt
	jp LABEL_2FD


LABEL_3D1D:
.db	$00, $00, $3F, $30, $38, $03, $0B
.db $0F

LABEL_3D25:
.db	$00, $00, $00, $00, $00, $8D, $8D, $8E, $8E, $8E, $8E, $8E, $8E, $00, $00
.db $00, $00

LABEL_3D36:
	cp   $20
	jr   nc, LABEL_3D4E
	add  a, a
	add  a, a
	add  a, a
	ld   l, a
	ld   h, $00
	ld   de, LABEL_3DA6-3
	add  hl, de
	jp   LABEL_3D96

LABEL_3D47:
	ld   a, ($C29E)
	cp   $20
	jr   c, LABEL_3D64
LABEL_3D4E:
	ld   hl, $D000
	ld   de, $D002
	ld   bc, $05FE
	ld   (hl), $00
	inc  hl
	ld   (hl), $08
	dec  hl
	ldir
	xor  a
	ld   ($C2D3), a
	ret

LABEL_3D64:
	add  a, a
	add  a, a
	add  a, a
	ld   l, a
	ld   h, $00
	ld   de, LABEL_3DA6-8
	add  hl, de
	ld   a, (hl)
	ld   ($FFFF), a
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	ld   de, $C240
	ld   bc, $0010
	ldir
	ld   hl, LABEL_3D1D
	ld   c, $08
	ldir
	pop  hl
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	ld   de, $4000
	call	LABEL_3FA
	pop  hl
	inc  hl
LABEL_3D96:
	xor  a
	ld   ($C2D3), a
	ld   a, (hl)
	ld   ($FFFF), a
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	jp   LABEL_6B62


LABEL_3DA6:
.db $10, $00, $80, $20, $80, $0F, $00, $80
.db	$10, $16, $8F, $36, $8F, $0F, $33, $83
.db $10, $72, $9C, $82, $9C, $0F, $E9, $86
.db	$10, $72, $9C, $82, $9C, $0F, $A0, $89
.db $10, $F6, $B3, $06, $B4, $0F, $80, $8C
.db	$10, $10, $80, $20, $80, $0F, $46, $8E
.db $10, $00, $80, $20, $80, $0F, $16, $91
.db	$11, $40, $86, $50, $86, $0F, $7B, $94
.db $11, $C4, $97, $D4, $97, $0F, $0A, $97
.db	$11, $B1, $A4, $C1, $A4, $0F, $2C, $9A

LABEL_3DF6:
.db $11, $58, $AF, $68, $AF, $0F, $11, $9C
.db	$10, $26, $8F, $36, $8F, $0F, $33, $83
.db	$16, $7D, $AC, $8D, $AC, $16, $32, $BC
.db	$0B, $00, $80, $10, $80, $16, $2A, $BE
.db $16, $9E, $3E, $8D, $AC, $16, $32, $BC
.db	$17, $9F, $AA, $6F, $AB, $17, $00, $80
.db $17, $AF, $AA, $6F, $AB, $17, $1E, $83
.db	$17, $BF, $AA, $6F, $AB, $17, $54, $86
.db $17, $CF, $AA, $6F, $AB, $17, $DD, $88
.db	$17, $DF, $AA, $6F, $AB, $17, $A6, $8B
.db $17, $EF, $AA, $6F, $AB, $17, $8E, $8F
.db	$17, $FF, $AA, $6F, $AB, $17, $ED, $92
.db $17, $0F, $AB, $6F, $AB, $17, $1B, $96
.db	$17, $1F, $AB, $6F, $AB, $17, $49, $99
.db $17, $2F, $AB, $6F, $AB, $17, $A3, $9C
.db	$17, $3F, $AB, $6F, $AB, $17, $E3, $9F
.db $17, $4F, $AB, $6F, $AB, $17, $10, $A3
.db	$17, $5F, $AB, $6F, $AB, $17, $4C, $A6


.db $09, $14, $BB, $24, $BB, $09, $8B, $B7
.db	$14, $DA, $A4, $EA, $A4, $1B, $63, $BD
.db $13, $00, $80, $10, $80, $0D, $B1, $BD
.db	$30, $00, $3F, $0B, $06, $1A, $2F, $2A
.db $08, $15, $15, $0B, $06, $1A, $2F, $28
.db	$A6, $8B, $17, $EF, $AA, $6F, $AB, $17
.db $8E, $8F, $17

GameMode_NameInput:
	ld a, (Game_is_paused)
	or a
	call nz, PauseLoop
	ld ix, $C784
	ld a, $08
	call WaitForVInt
	call LABEL_40C5
	ld a, (Ctrl_1_pressed)
	and Button_1_Mask|Button_2_Mask
	jp z, LABEL_3F73
	and $10
	jp nz, +++
	ld a, ($C788)
	cp $5C
	jr z, +
	jr nc, ++
	ld de, ($C781)
	ld d, $C7
	ld (de), a
	call LABEL_4117
	ld a, (de)
	di
	call LABEL_414F
	ei
+:	
	ld hl, $C781
	ld a, (hl)
	cp $25
	ret z
	inc (hl)
	ret

++:	
	cp $5E
	jr z, ++++
-:	
	ld a, ($C780)
	ld c, $00
	rra
	jr c, +
	ld c, $21
+:	
	ld hl, $C781
	ld a, (hl)
	cp c
	ret z
	dec (hl)
	ret

+++:	
	ld de, ($C781)
	ld d, $C7
	ld a, $20
	ld (de), a
	call LABEL_4117
	ld a, (de)
	di
	call LABEL_414F
	ei
	jp -

++++:	
	ld hl, $C721
	ld de, $C778
	ld bc, $0005
	ldir
	ld hl, ($C2C5)
	add hl, hl
	ld de, LABEL_3F69-2
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, $D19A
	ld bc, $000A
	ld a, $08
	ld ($FFFC), a
	ldir
	ld c, $08
	ex de, hl
	add hl, bc
	ex de, hl
	ld c, $36
	add hl, bc
	ld c, $0A
	ldir
	ld a, $80
	ld ($FFFC), a
	ld a, ($C316)
	cp $0B ; GameMode_Dungeon
	ld a, $0A ; GameMode_LoadDungeon
	jr z, +
	ld a, $0C ; GameMode_LoadInteraction
+:	
	ld (Game_mode), a
	ret

LABEL_3F69:
.db $18, $81, $3C, $81, $60, $81, $84, $81, $A8, $81

LABEL_3F73:	
	ld a, (Ctrl_1_pressed)
	rra
	jr c, LABEL_3FB7
	rra
	jr c, LABEL_3FCE
	rra
	jr c, LABEL_3FEB
	rra
	jr c, +
	ld a, (Ctrl_1_held)
	rra
	jr c, ++
	rra
	jr c, +++
	rra
	jr c, LABEL_3FD5
	rra
	ret nc
	call LABEL_402C
	ret nz
-:	
	ld bc, $C808
	ld de, $0002
	ld iy, $C784
	jr LABEL_3FF2

+:	
	ld a, $18
	ld ($C789), a
	jr -

++:	
	call LABEL_402C
	ret nz
-:	
	ld bc, $60F0
	ld de, $FF80
	ld iy, $C785
	jr LABEL_3FF2

LABEL_3FB7:	
	ld a, $18
	ld ($C789), a
	jr -

+++:	
	call LABEL_402C
	ret nz
-:	
	ld bc, $9010
	ld de, $0080
	ld iy, $C785
	jr LABEL_3FF2

LABEL_3FCE:	
	ld a, $18
	ld ($C789), a
	jr -

LABEL_3FD5:	
	call LABEL_402C
	ret nz
-:	
	ld bc, $28F8
	ld a, ($C788)
	cp $5C
	ret z
	ld de, $FFFE
	ld iy, $C784
	jr LABEL_3FF2

LABEL_3FEB:	
	ld a, $18
	ld ($C789), a
	jr -

LABEL_3FF2:
	ld	a, (iy+0)
	cp	b
	ret	z
	add	a, c
	ld	(iy+0), a
	ld	hl, ($C786)
	add	hl, de
	
; The next 3 bytes are translated as ld	($C786), hl, but since the instruction is split
;  across 2 banks, I can't use it. This will have to do until I find a workaround
.db $22


.BANK 1 SLOT 1
.ORG $0000


.db $86, $C7

	ld a, (hl)
	or a
	jr z, LABEL_3FF2
	cp (ix+4)
	jr z, LABEL_3FF2
	ld ($C788), a
	cp $5C
	ret c
	ld c, $88
	ld hl, $D4A2
	jr z, +
	cp $5D
	ld l, $AA
	ld c, $A8
	jr z, +
	ld c, $C8
	ld l, $B2
+:	
	ld ($C786), hl
	ld a, c
	ld ($C784), a
	ret

LABEL_402C:
	ld hl, $C789
	dec (hl)
	ret nz
	ld (hl), $05
	ret

GameMode_LoadNameInput:
	call FadeOut2
	ld de, $7800
	ld bc, $0300
	ld hl, $0000
	di
	call LABEL_363
	ei
	ld hl, Game_mode
	inc (hl) ; GameMode_NameInput
	ld hl, $C781
	ld (hl), $00
	ld de, $C782
	ld bc, $007E
	ldir
	ld hl, $D000
	ld de, $D001
	ld bc, $0600
	ld (hl), $00
	ldir
	call LABEL_4166
	ld hl, $C700
	ld de, $C701
	ld bc, $0037
	ld (hl), $00
	ldir
	ld a, $21
	ld ($C781), a
	ld de, $78C0
	ld hl, $D0C0
	ld bc, $0540
	di
	call LABEL_346
	ei
	call LABEL_41DB
	ld hl, LABEL_41FC
	ld de, $C240
	ld bc, $0020
	ldir
	ld de, $6000
	ld hl, LABEL_421C
	ld bc, $0020
	di
	call LABEL_346
	ei
	ld de, $C784
	ld hl, LABEL_40C0
	ld bc, $0005
	ldir
	xor a
	ld ($C304), a
	ld ($C300), a
	ld ($C2D3), a
	ld de, $8006
	di
	rst $08
	ei
	jp LABEL_2FD
	

LABEL_40C0:	
.db $28, $60, $0A, $D3, $41

LABEL_40C5:
	call LABEL_4117
	ld de, $3040
	add hl, de
	add hl, hl
	add hl, hl
	ld de, $C900
	ld a, h
	add a, a
	add a, a
	add a, a
	ld (de), a
	ld a, ($C788)
	cp $5C
	ld a, ($C785)
	inc de
	ld (de), a
	jr c, +
	inc e
	ld (de), a
	inc e
	ld (de), a
+:	
	inc e
	ld a, $D0
	ld (de), a
	ld e, $80
	ex de, hl
	ld a, e
	ld bc, $0300
	ld (hl), a
	inc l
	ld (hl), c
	ld a, ($C784)
-:	
	inc l
	ld (hl), a
	inc l
	ld (hl), c
	sub $08
	djnz -
	ret


LABEL_4100:
	ld	hl, $C781
	ld	(hl), $38
	ld	d, $C7
	
-:
	dec	(hl)
	ret	m
	ld	e, (hl)
	push	hl
	call	LABEL_4117
	ld	a, (de)
	push	de
	call	LABEL_413A
	pop	de
	pop	hl
	jr	-

LABEL_4117:
	ld a, ($C781)
	ld hl, $D146
	sub $18
	jr c, +
	ld l, $C6
	sub $18
	jr c, +
	ld hl, $D246
	sub $18
+:	
	add a, $18
	ld c, a
	add a, a
	add a, l
	ld l, a
	ld a, c
	rra
	rra
	and $06
	add a, l
	ld l, a
	ret

LABEL_413A:
	push hl
	ex de, hl
	ld hl, $7CD7
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld c, (hl)
	inc hl
	ld a, (hl)
	ld (de), a
	ld hl, $FFC0
	add hl, de
	ld (hl), c
	pop hl
	ret

LABEL_414F:
	call LABEL_413A
	ld b, a
	ld a, h
	sub $58
	ld h, a
	ex de, hl
	rst $08
	ld a, b
	out (Port_VDPData), a
	ld hl, $FFC0
	add hl, de
	ex de, hl
	rst $08
	ld a, c
	out (Port_VDPData), a
	ret

LABEL_4166:
	ld hl, LABEL_423C
	ld de, $D100
--:	
	ld a, (hl)
	inc hl
	or a
	jr z, +++
	jp p, ++
	bit 6, a
	jr nz, +
	and $3F
	ld b, a
	ld a, (hl)
-:	
	ld (de), a
	inc de
	inc de
	ex de, hl
	ld (hl), $C0
	ex de, hl
	inc de
	inc de
	inc a
	djnz -
	inc hl
	jr --

+:	
	and $3F
	ld c, a
	ld b, $00
-:	
	ldi
	inc de
	jp pe, -
	jr --

++:	
	ld b, a
	ld a, (hl)
-:	
	ld (de), a
	inc de
	inc de
	djnz -
	inc hl
	jr --

+++:	
	ld hl, $D146
	ld de, $F301
	call +
	inc hl
	ld bc, $1805
	call LABEL_41D5
	ld (hl), $07
	ld hl, $D137
	ld (hl), $03
	ld hl, $D107
	ld bc, $1801
	call LABEL_41D5
	ld hl, $D176
	ld de, $F303
+:	
	ld a, $0D
	ld bc, $003F
-:	
	ld (hl), d
	inc l
	ld (hl), e
	add hl, bc
	dec a
	jr nz, -
	ret

LABEL_41D5:
	ld (hl), c
	inc l
	inc l
	djnz LABEL_41D5
	ret

LABEL_41DB:
	ld hl, LABEL_4280
	ld de, $D30A
	ld a, $04
--:	
	ld bc, $000B
-:	
	ldi
	inc de
	ex de, hl
	ld (hl), $00
	ex de, hl
	inc de
	inc de
	jp pe, -
	ex de, hl
	ld bc, $0054
	add hl, bc
	ex de, hl
	dec a
	jr nz, --
	ret

LABEL_41FC:
.db	$00, $00, $3F, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $3C, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00

LABEL_421C:
.db	$FF, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00

.db $00, $00, $00, $00

LABEL_423C:
.db	$03, $C0, $01, $F1
.db $17, $F2, $01, $F1, $0C, $C0, $D0, $D3
.db $D8, $DA, $DF, $DE, $C0, $E3, $D9, $DF
.db $DC, $C0, $D8, $CB, $D7, $CF, $E7, $58
.db $C0, $55, $C0, $8B, $CB, $2A, $C0, $8B
.db $D6, $1E, $C0, $01, $EB, $0B, $C0, $8A
.db $E1, $36, $C0, $CB, $CB, $CE, $E0, $C0
.db $DC, $DF, $CC, $C0, $CF, $D8, $CE, $09
.db $C0, $01, $F1, $17, $F2, $01, $F1, $00

LABEL_4280:
.db $41, $42, $43, $44, $45, $46, $47, $48
.db $49, $4A, $4B, $4C, $4D, $4E, $4F, $50
.db $51, $52, $53, $54, $55, $56, $57, $58
.db $59, $5A, $2C, $3B, $2E, $21, $3F, $2D
.db $22, $5C, $5C, $5C, $5C, $5C, $5C, $5C
.db $5D, $5D, $5E, $5E

LABEL_42AC:
	ld a, $D7
	ld ($C004), a
	call FadeOut2
	ld hl, $FFFF
	ld (hl), :Bank23
	ld hl, LABEL_B23_B767
	ld de, $C240
	ld bc, $0011
	ldir
	ld hl, LABEL_B23_B778
	ld de, $4000
	call LABEL_3FA
	ld hl, $FFFF
	ld (hl), :Bank28
	ld hl, LABEL_B28_BE00
	call LABEL_6B62
	ld hl, $D000
	ld de, $D300
	ld bc, $0300
	ldir
	ld hl, $D000
	ld bc, $0100
	ldir
	xor a
	ld ($C300), a
	ld a, $80
	ld ($C304), a
	ld hl, $D000
	ld de, $7800
	ld bc, $0700
	di
	call LABEL_346
	ei
	ld a, $8C
	ld ($C004), a
	call FadeIn2
	ld a, $02
	ld ($C264), a
	ld a, $02
	ld ($C307), a
-:	
	ld a, $0E
	call WaitForVInt
	ld a, (Ctrl_1_pressed)
	and Button_1_Mask|Button_2_Mask
	jr nz, +
	call LABEL_43AA
	ld a, ($C307)
	cp $01
	jr nz, -
	ld a, ($C304)
	cp $80
	jr nz, -
	call LABEL_2D37
+:	
	xor a
	ld ($C264), a
	ld ($C307), a
	call FadeOut2
	ld a, $08
	ld ($C29E), a
	call LABEL_3D47
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, LABEL_B16_BAD8
	ld de, $5800
	call LABEL_3FA
	ld hl, LABEL_B16_BD58
	ld de, $7E00
	call LABEL_3FA
	xor a
	ld ($C304), a
	ld ($C300), a
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld hl, $FFFF
	ld (hl), :Bank18
	ld hl, LABEL_B18_BEF4
	ld de, $7886
	ld bc, $0528
	call LABEL_3A68
	call LABEL_2D37
	call LABEL_467C
	ld a, $00
	call LABEL_46D1
	ld hl, LABEL_B49B
	call LABEL_337D
	ld a, $01
	call LABEL_46D1
	ld hl, LABEL_B4FC
	call LABEL_337D
	ld a, $02
	call LABEL_46D1
	ld hl, LABEL_B5D5
	call LABEL_337D
	ld a, $D7
	ld ($C004), a
	ret

LABEL_43AA:	
	ld de, $0001
	ld a, ($C304)
	add a, e
	cp $E0
	jr c, +
	ld d, $01
	add a, $20
+:	
	ld ($C304), a
	ld a, ($C307)
	sub d
	ld ($C307), a
	cp $01
	ret nz
	ld a, d
	or a
	ret z
	ld hl, LABEL_B28_BE88
	jp LABEL_6B62

LABEL_43CF:	
	call LABEL_467C
	ld a, $8A
	ld ($C004), a
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_B617
	call LABEL_337D
	ld a, $04
	call LABEL_46D1
	ld hl, LABEL_B646
	call LABEL_337D
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_B64D
	call LABEL_337D
	ld a, $04
	call LABEL_46D1
	ld hl, LABEL_B66E
	call LABEL_337D
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_B6C1
	call LABEL_337D
	ld a, $D8
	ld ($C004), a
	ret

LABEL_4414:
	call LABEL_467C
	ld a, $8A
	ld ($C004), a
	ld a, $05
	call LABEL_46D1
	ld hl, LABEL_B6F3
	call LABEL_337D
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_B746
	call LABEL_337D
	ld a, $05
	call LABEL_46D1
	ld hl, LABEL_B786
	call LABEL_337D
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_B7B9
	call LABEL_337D
	ld a, $05
	call LABEL_46D1
	ld hl, LABEL_B7D1
	call LABEL_337D
	call FadeOut2
	call LABEL_FF3
	ld a, $D8
	ld ($C004), a
	jp FadeIn2

LABEL_4461:	
	call LABEL_467C
	ld a, $8A
	ld ($C004), a
	ld a, $03
	ld hl, Char_stats
	bit 0, (hl)
	jr nz, +
	ld a, $05
	ld hl, Odin_stats
	bit 0, (hl)
	jr nz, +
	ld a, $04
+:	
	call LABEL_46D1
	ld hl, LABEL_B85C
	call LABEL_337D
	ld a, $06
	call LABEL_46D1
	ld hl, LABEL_B884
	call LABEL_337D
	ld a, $D8
	ld ($C004), a
	ret

LABEL_4497:
	ld a, ($C309)
	cp $17
	jr nz, +
	call LABEL_4517
	ld hl, LABEL_4514
	jp LABEL_4509

+:	
	call LABEL_467C
	ld a, $8A
	ld ($C004), a
	ld a, $07
	call LABEL_46D1
	ld hl, LABEL_B929
	call LABEL_337D
	ld a, $08
	call LABEL_46D1
	ld hl, LABEL_B97C
	call LABEL_337D
	call LABEL_4517
	ld a, $0E
	ld ($C29E), a
	call LABEL_3D47
	ld a, $0C
	call WaitForVInt
	ld hl, $C250
	ld b, $10
-:	
	ld (hl), $30
	inc hl
	djnz -
	call FadeIn2
	call LABEL_2D33
	ld hl, $FFFF
	ld (hl), :Bank11
	ld hl, LABEL_B11_8000
	ld de, $C250
	ld bc, $0008
	ldir
	ld a, $46
	ld ($C2E6), a
	call LABEL_5FFE
	call LABEL_100F
	ld a, (Game_mode)
	cp $02 ; GameMode_LoadIntro
	ret z
	ld hl, LABEL_4511
LABEL_4509:	
	ld a, $08 ; GameMode_LoadMap
	ld (Game_mode), a
	jp LABEL_787B


LABEL_4511:	
.db $17 $28 $1F


LABEL_4514:	
.db $00 $40 $4C

LABEL_4517:	
	call FadeOut2
	ld a, $0F
	ld ($C29E), a
	call LABEL_3D47
	ld hl, $FFFF
	ld (hl), :Bank22
	ld hl, LABEL_B22_B9D8
	ld de, $C251
	ld bc, $000F
	ldir
	ld hl, LABEL_B22_B9E7
	ld de, $6000
	call LABEL_3FA
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $15
	ld ($C800), a
	call LABEL_18B9
	jp FadeOut2

LABEL_454E:	
	call FadeOut2
	ld a, $D0
	ld ($C900), a
	ld a, $8B
	ld ($C004), a
	ld a, $0D
	ld ($C29E), a
	call LABEL_3D47
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld b, $80
	call LABEL_2D49
	call LABEL_7CE4
	ld hl, LABEL_B12_BEB6
	call ShowDialogue_B12
	ld hl, LABEL_B12_BED0
	call ShowDialogue_B12
	ld hl, LABEL_B12_BEE8
	call ShowDialogue_B12
	ld hl, LABEL_B12_BEFD
	call ShowDialogue_B12
	ld hl, LABEL_B12_BF09
	call ShowDialogue_B12
	ld hl, LABEL_B12_BF21
	call ShowDialogue_B12
	call LABEL_3464
	call LABEL_467C
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_B9E8
	call LABEL_337D
	ld a, $05
	call LABEL_46D1
	ld hl, LABEL_B9F0
	call LABEL_337D
	ld a, $06
	call LABEL_46D1
	ld hl, LABEL_B9FB
	call LABEL_337D
	ld a, $04
	call LABEL_46D1
	ld hl, LABEL_BA06
	call LABEL_337D
	ld a, $03
	call LABEL_46D1
	ld hl, LABEL_BA12
	call LABEL_337D
	ld hl, LABEL_BA54
	call LABEL_337D
	call FadeOut2
	ld hl, $FFFF
	ld (hl), :Bank31
	ld hl, LABEL_B31_9676
	ld de, $C240
	ld bc, $0011
	ldir
	ld hl, LABEL_B31_9687
	ld de, $4000
	call LABEL_3FA
	ld hl, $FFFF
	ld (hl), :Bank24
	ld hl, $D000
	ld de, $D001
	ld bc, $0600
	ld (hl), $00
	ldir
	ld hl, LABEL_B24_A5E0
	ld de, $D0D4
	ld bc, $1316
	call LABEL_6E64
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	call LABEL_2D47
	ld hl, LABEL_3DF6+1
	ld (Dungeon_position), hl
	xor a
	ld (Dungeon_direction), a
	call LABEL_661C
	ld hl, $FFFF
	ld (hl), :Bank15
	ld hl, LABEL_B15_BDEE
	ld de, $5820
	call LABEL_3FA
	ld a, $01
	ld ($C2F5), a
	ld a, $91
	ld ($C004), a
	ld hl, LABEL_B15_BF80
-:	
	ld a, :Bank15
	ld ($FFFF), a
	ld a, (hl)
	cp $FF
	jr z, ++
	cp $0F
	jr nz, +
	ld b, $B4
	call LABEL_2D49
	inc hl
	jr -

+:	
	push hl
	ld (Ctrl_1_held), a
	call LABEL_65EE
	pop hl
	inc hl
	jr -

++:	
	ld a, $D7
	ld ($C004), a
	xor a
	ld ($C2F5), a
	ld b, $B4
	call LABEL_2D49
	ld a, $02 ; GameMode_LoadIntro
	ld (Game_mode), a
	ret

LABEL_467C:
	call FadeOut2
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, LABEL_B16_BAD8
	ld de, $5800
	call LABEL_3FA
	ld hl, LABEL_B16_BD58
	ld de, $7E00
	call LABEL_3FA
	ld hl, $FFFF
	ld (hl), :Bank24
	ld hl, $C240
	ld de, $C241
	ld (hl), $00
	ld bc, $000F
	ldir
	ld hl, LABEL_B24_A57A
	ld bc, $0010
	ldir
	ld hl, LABEL_B24_A58A
	ld de, $4000
	call LABEL_3FA
	ld hl, LABEL_B24_A484
	call LABEL_6B62
	xor a
	ld ($C304), a
	ld ($C300), a
	ld ($C2D3), a
	ld a, $0C
	call WaitForVInt
	jp LABEL_2FD

LABEL_46D1:
	push	af
	call	FadeOut
	pop	af
	ld	l, a
	add	a, a
	add	a, a
	add	a, l
	ld	l, a
	ld	h, $00
	ld	de, LABEL_471E
	add	hl, de
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	e, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	push	hl
	ex   de, hl
	ld   de, $C240
	ld   bc, $0010
	ldir
	ld   de, $6000
	call	LABEL_3FA
	ld   hl, $FFFF
	ld   (hl), :Bank24
	pop  hl
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   de, $78CC
	ld   bc, $0C28
	di
	call	LABEL_390
	ld   de, $7C00
	ld   bc, $0100
	ld   hl, $0800
	call	LABEL_363
	ei
	jp   FadeIn


LABEL_471E:
.db	$1F, $00, $80, $90, $A8, $1E, $00, $80, $70, $AA, $1E, $62, $8F, $50, $AC, $1E
.db	$2B, $9C, $30, $AE, $1F, $DB, $8A, $10, $B0, $1D, $2A, $B6, $F0, $B1, $12, $88
.db	$B3, $D0, $B3, $1E, $4E, $AA, $B0, $B5, $1E, $0C, $B3, $90, $B7
	

LABEL_474B:
	ld   a, ($C2DB)
	or   a
	jp   z, LABEL_1BE1
	ld   de, LABEL_4773-2
	call	LABEL_4769
	ld   a, ($C29E)
	or   a
	jp   nz, LABEL_3464
	call	LABEL_3464
	jp   LABEL_15DC


LABEL_4765:
	pop	hl
	jp	LABEL_2D25

LABEL_4769:
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, de
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	jp   (hl)


LABEL_4773:
.dw	LABEL_48DF
.dw	LABEL_48FC
.dw	LABEL_4922
.dw	LABEL_4928
.dw	LABEL_492E
.dw	LABEL_4934
.dw	LABEL_493A
.dw	LABEL_4940
.dw	LABEL_495A
.dw	LABEL_4960
.dw	LABEL_4966
.dw	LABEL_4973
.dw	LABEL_4991
.dw	LABEL_4997
.dw	LABEL_499D
.dw	LABEL_49A3
.dw	LABEL_49A9
.dw	LABEL_49AF
.dw	LABEL_49B5
.dw	LABEL_49B5
.dw	LABEL_49E0
.dw	LABEL_49E6
.dw	LABEL_4A3E
.dw	LABEL_4A44
.dw	LABEL_4A4A
.dw	LABEL_4A50
.dw	LABEL_4AA9
.dw	LABEL_4ABE
.dw	LABEL_4AD3
.dw	LABEL_4B43
.dw	LABEL_4B52
.dw	LABEL_4B61
.dw	LABEL_4B67
.dw	LABEL_4B6D
.dw	LABEL_4B73
.dw	LABEL_4B79
.dw	LABEL_4B7F
.dw	LABEL_4B85
.dw	LABEL_4B8B
.dw	LABEL_4B91
.dw	LABEL_4B97
.dw	LABEL_4B9D
.dw	LABEL_4BBD
.dw	LABEL_4BD1
.dw	LABEL_4BD7
.dw	LABEL_4BDD
.dw	LABEL_4BE3
.dw	LABEL_4BE9
.dw	LABEL_4BEF
.dw	LABEL_4BF5
.dw	LABEL_4BFB
.dw	LABEL_4C01
.dw	LABEL_4C07
.dw	LABEL_4C0D
.dw	LABEL_4C70
.dw	LABEL_4D74
.dw	LABEL_4D7A
.dw	LABEL_4D9F
.dw	LABEL_4DA5
.dw	LABEL_4DAB
.dw	LABEL_4DD4
.dw	LABEL_4DFB
.dw	LABEL_4E9C
.dw	LABEL_4EB3
.dw	LABEL_4EB9
.dw	LABEL_4EBF
.dw	LABEL_4EC5
.dw	LABEL_4ED9
.dw	LABEL_4EDF
.dw	LABEL_4EE5
.dw	LABEL_4EEB
.dw	LABEL_4EF1
.dw	LABEL_4EF7
.dw	LABEL_4EFD
.dw	LABEL_4F03
.dw	LABEL_4F09
.dw	LABEL_4F0F
.dw	LABEL_4F15
.dw	LABEL_4F34
.dw	LABEL_4F3A
.dw	LABEL_4F40
.dw	LABEL_4F46
.dw	LABEL_4F4C
.dw	LABEL_4F52
.dw	LABEL_4F58
.dw	LABEL_4F71
.dw	LABEL_4F77
.dw	LABEL_4F7D
.dw	LABEL_4F83
.dw	LABEL_4F89
.dw	LABEL_4F8F
.dw	LABEL_4F95
.dw	LABEL_4F9B
.dw	LABEL_4FD8
.dw	LABEL_4FDE
.dw	LABEL_4FE4
.dw	LABEL_4FEA
.dw	LABEL_4FF0
.dw	LABEL_4FF6
.dw	LABEL_4FFC
.dw	LABEL_5002
.dw	LABEL_5008
.dw	LABEL_500E
.dw	LABEL_5014
.dw	LABEL_501A
.dw	LABEL_5020
.dw	LABEL_5026
.dw	LABEL_502C
.dw	LABEL_5040
.dw	LABEL_5046
.dw	LABEL_504C
.dw	LABEL_5058
.dw	LABEL_505E
.dw	LABEL_5064
.dw	LABEL_506A
.dw	LABEL_5070
.dw	LABEL_50A6
.dw	LABEL_50BA
.dw	LABEL_50C0
.dw	LABEL_50C6
.dw	LABEL_50DA
.dw	LABEL_5101
.dw	LABEL_5107
.dw	LABEL_510D
.dw	LABEL_5157
.dw	LABEL_516F
.dw	LABEL_51B1
.dw	LABEL_51D6
.dw	LABEL_51DC
.dw	LABEL_521D
.dw	LABEL_5249
.dw	LABEL_5270
.dw	LABEL_5284
.dw	LABEL_528A
.dw	LABEL_5290
.dw	LABEL_52A4
.dw	LABEL_52B2
.dw	LABEL_52B8
.dw	LABEL_52BE
.dw	LABEL_52C4
.dw	LABEL_52CA
.dw	LABEL_52D0
.dw	LABEL_5337
.dw	LABEL_4F8F
.dw	LABEL_4F95
.dw	LABEL_4F9B
.dw	LABEL_534B
.dw	LABEL_5395
.dw	LABEL_539B
.dw	LABEL_53A1
.dw	LABEL_53A7
.dw	LABEL_53AD
.dw	LABEL_53B3
.dw	LABEL_53B9
.dw	LABEL_53BF
.dw	LABEL_5401
.dw	LABEL_5430
.dw	LABEL_54D0
.dw	LABEL_54FB
.dw	LABEL_552F
.dw	LABEL_5535
.dw	LABEL_5535
.dw	LABEL_5538
.dw	LABEL_5595
.dw	LABEL_55A3
.dw	LABEL_55A9
.dw	LABEL_55BB
.dw	LABEL_55CD
.dw	LABEL_55E1
.dw	LABEL_55EF
.dw	LABEL_5619
.dw	LABEL_5666
.dw	LABEL_569C
.dw	LABEL_56A2
.dw	LABEL_5535
.dw	LABEL_5535
.dw	LABEL_56CD
.dw	LABEL_56D3
.dw	LABEL_56D9
.dw	LABEL_56E9
.dw	LABEL_56F9
.dw	LABEL_5535


LABEL_48DF:
	ld hl, $C501
	ld a, (hl)
	or a
	jr nz, +
	ld (hl), $01
	ld hl, $0002
	call ShowDialogue_B2
+:	
	ld hl, $0006
	call ShowDialogue_B2
	ld a, $C1
	ld ($C004), a
	jp LABEL_2A6D

LABEL_48FC:
	ld a, ($C502)
	or a
	jr nz, +
	ld hl, $0008
	call ShowDialogue_B2
	ld a, ItemID_LaconiaPot
	ld ($C2C4), a
	call Inventory_AddItem
	ld a, $38
	call Inventory_FindFreeSlot
	jr nz, +
	ld a, $01
	ld ($C502), a
+:	
	ld hl, $0010
	jp ShowDialogue_B2

LABEL_4922:
	ld	hl, $12
	jp	ShowDialogue_B2

LABEL_4928:
	ld	hl, $14
	jp	ShowDialogue_B2

LABEL_492E:
	ld	hl, $16
	jp	ShowDialogue_B2

LABEL_4934:
	ld	hl, $18
	jp	ShowDialogue_B2

LABEL_493A:
	ld	hl, $1A
	jp	ShowDialogue_B2

LABEL_4940:
	ld hl, $0062
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0060
	jr z, +
	ld hl, $0003
	ld ($C2C5), hl
	ld hl, $0064
+:	
	jp ShowDialogue_B2

LABEL_495A:
	ld	hl, $1C
	jp	ShowDialogue_B2

LABEL_4960:
	ld	hl, $1E
	jp	ShowDialogue_B2

LABEL_4966:
	ld a, $33
	call Inventory_FindFreeSlot
	jr z, +
	ld hl, $0020
	jp ShowDialogue_B2

LABEL_4973:
	ld a, $33
	call Inventory_FindFreeSlot
	jr z, +
	ld hl, $0022
	jp ShowDialogue_B2

+:	
	ld hl, $0024
	call ShowDialogue_B2
	ld a, ($C309)
	rrca
	dec a
	and $03
	ld ($C2E9), a
	ret

LABEL_4991:
	ld	hl, $26
	jp	ShowDialogue_B2

LABEL_4997:
	ld	hl, $28
	jp	ShowDialogue_B2

LABEL_499D:
	ld	hl, $2A
	jp	ShowDialogue_B2

LABEL_49A3:
	ld	hl, $2E
	jp	ShowDialogue_B2

LABEL_49A9:
	ld	hl, $30
	jp	ShowDialogue_B2

LABEL_49AF:
	ld	hl, $32
	jp	ShowDialogue_B2

LABEL_49B5:
	ld a, ($C504)
	cp $07
	jp nc, LABEL_4A8C
	ld hl, $0070
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0020
	jr nz, +
	ld a, $34
	call Inventory_FindFreeSlot
	ld hl, $00CE
	jr nz, +
	ld a, $06
	ld ($C2E9), a
	ld hl, $0024
+:	
	jp ShowDialogue_B2

LABEL_49E0:
	ld	hl, $286
	jp	ShowDialogue_B2

LABEL_49E6:
	ld a, $47
	ld ($C2E6), a
	call LABEL_5FFE
	ld a, (Myau_stats)
	or a
	jr z, +
	ld hl, $0296
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld a, $AE
	ld ($C004), a
	ld a, $01
	ld ($C2C2), a
	ld hl, LABEL_B12_B728
	call ShowDialogue_B12
	ld hl, $0000
	ld (Myau_stats), hl
	ld hl, $0298
	jr ++

+:	
	ld hl, $029A
++:	
	call ShowDialogue_B2
	call LABEL_3464
	ld a, (Party_curr_num)
	or a
	jr z, +
	ld a, $38
	call Inventory_FindFreeSlot
	jr z, +
	ld hl, $C518
	ld ($C2E1), hl
	ld a, $38
	ld ($C2DF), a
+:	
	jp LABEL_5389

LABEL_4A3E:
	ld	hl, $6A
	jp	ShowDialogue_B2

LABEL_4A44:
	ld	hl, $6C
	jp	ShowDialogue_B2

LABEL_4A4A:
	ld	hl, $6E
	jp	ShowDialogue_B2

LABEL_4A50:
	ld a, ($C504)
	cp $07
	jr nc, LABEL_4A8C
	ld hl, $0070
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $0020
	jp ShowDialogue_B2

+:	
	ld a, $34
	call Inventory_FindFreeSlot
	jr z, +
	ld hl, $00CE
	jp ShowDialogue_B2

+:	
	ld hl, $0024
	call ShowDialogue_B2
	ld a, ($C305)
	cp $60
	ld hl, LABEL_4AA3
	jr nz, +
	ld hl, LABEL_4AA6
+:	
	call LABEL_787B
	ret

LABEL_4A8C:	
	ld hl, $019E
	call ShowDialogue_B2
	ld a, $34
	call Inventory_FindFreeSlot
	ret nz
	push bc
	call Inventory_RemoveItem2
	pop bc
	ld hl, $01A0
	jp ShowDialogue_B2

LABEL_4AA3:
.db $05, $20, $17

LABEL_4AA6:
.db	$05, $21, $15

LABEL_4AA9:
	ld a, $33
	call Inventory_FindFreeSlot
	ld hl, $0020
	jr nz, +
	ld a, $04
	ld ($C2E9), a
	ld hl, $0024
+:	
	jp ShowDialogue_B2

LABEL_4ABE:
	ld a, $33
	call Inventory_FindFreeSlot
	ld hl, $0022
	jr nz, +
	ld a, $05
	ld ($C2E9), a
	ld hl, $0024
+:	
	jp ShowDialogue_B2

LABEL_4AD3:
	ld hl, $0072
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $007C
	jp ShowDialogue_B2

+:	
	ld hl, $0074
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld hl, $007E
	jp ShowDialogue_B2

+:	
	ld hl, $0076
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld hl, $007E
	jp ShowDialogue_B2

+:	
	ld hl, $64
	ld ($C2C5), hl
	ld hl, $0078
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $007C
	jp ShowDialogue_B2

+:	
	ld de, $0064
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, LABEL_B12_BD57
	jp ShowDialogue_B12

+:	
	ld (Current_money), hl
	ld hl, $007A
	call ShowDialogue_B2
	ld a, ItemID_Passport
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	ret z
	jp Inventory_AddItem

LABEL_4B43:
	ld a, (Party_curr_num)
	or a
	ld hl, $0034
	jr z, +
	ld hl, $003A
+:	
	jp ShowDialogue_B2

LABEL_4B52:
	ld a, (Party_curr_num)
	or a
	ld hl, $003C
	jr z, +
	ld hl, $0040
+:	
	jp ShowDialogue_B2

LABEL_4B61:
	ld	hl, $42
	jp	ShowDialogue_B2

LABEL_4B67:
	ld	hl, $44
	jp	ShowDialogue_B2

LABEL_4B6D:
	ld	hl, $46
	jp	ShowDialogue_B2

LABEL_4B73:
	ld	hl, $48
	jp	ShowDialogue_B2

LABEL_4B79:
	ld	hl, $4A
	jp	ShowDialogue_B2

LABEL_4B7F:
	ld	hl, $4C
	jp	ShowDialogue_B2

LABEL_4B85:
	ld	hl, $4E
	jp	ShowDialogue_B2

LABEL_4B8B:
	ld	hl, $50
	jp	ShowDialogue_B2

LABEL_4B91:
	ld	hl, $52
	jp	ShowDialogue_B2

LABEL_4B97:
	ld	hl, $54
	jp	ShowDialogue_B2

LABEL_4B9D:
	ld hl, $0056
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0060
	jr nz, ++
	ld a, $2D
	call Inventory_FindFreeSlot
	jr z, +
	ld hl, $C604
	ld (hl), $00
+:	
	ld hl, $0058
++:	
	jp ShowDialogue_B2

LABEL_4BBD:
	ld hl, $005C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0060
	jr z, +
	ld hl, $005E
+:	
	jp ShowDialogue_B2

LABEL_4BD1:
	ld	hl, $80
	jp	ShowDialogue_B2

LABEL_4BD7:
	ld	hl, $82
	jp	ShowDialogue_B2

LABEL_4BDD:
	ld	hl, $84
	jp	ShowDialogue_B2

LABEL_4BE3:
	ld	hl, $86
	jp	ShowDialogue_B2

LABEL_4BE9:
	ld	hl, $88
	jp	ShowDialogue_B2

LABEL_4BEF:
	ld	hl, $8A
	jp	ShowDialogue_B2

LABEL_4BF5:
	ld	hl, $8C
	jp	ShowDialogue_B2

LABEL_4BFB:
	ld	hl, $8E
	jp	ShowDialogue_B2

LABEL_4C01:
	ld	hl, $90
	jp	ShowDialogue_B2

LABEL_4C07:
	ld	hl, $288
	jp	ShowDialogue_B2

LABEL_4C0D:
	ld a, (Party_curr_num)
	or a
	jr z, +
	ld hl, $028A
	jp ShowDialogue_B2

+:	
	ld hl, $000A
	ld ($C2C5), hl
	ld hl, $0092
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld hl, $0094
	jp ShowDialogue_B2

+:	
	ld a, ItemID_LaconiaPot
	call Inventory_FindFreeSlot
	jr nz, +
	push hl
	ld hl, $0096
	call ShowDialogue_B2
	call ShowYesNoPrompt
	pop hl
	jr nz, +
	push bc
	call Inventory_RemoveItem2
	pop bc
	ld hl, $009A
	call ShowDialogue_B2
	call LABEL_3464
	pop hl
	ld iy, Myau_stats
	call UnlockCharacter
	ld a, $01
	ld (Party_curr_num), a
	ld a, ItemID_Alsulin
	ld ($C2C4), a
	call Inventory_AddItem
	jp LABEL_43CF

+:	
	ld hl, $007C
	jp ShowDialogue_B2

LABEL_4C70:
	ld a, ($C516)
	or a
	jr z, +
	ld hl, $02A6
	call ShowDialogue_B2
	call LABEL_3464
	pop hl
	ld hl, $22E6
	ld (Dungeon_position), hl
	xor a
	ld (Dungeon_direction), a
	ld hl, Game_mode
	ld (hl), $0B ; GameMode_Dungeon
	call LABEL_661C
	ld a, $85
	jp LABEL_C97

+:	
	ld a, $35
	call LABEL_617D
	call LABEL_576A
	ld a, (Party_curr_num)
	cp $03
	jr nc, +
	ld a, $37
	call Inventory_FindFreeSlot
	jr nz, ++
+:	
	ld hl, $029E
	call ShowDialogue_B2
	ld hl, $00AA
	jp ShowDialogue_B2

++:	
	ld hl, $00A4
	call ShowDialogue_B2
	push bc
	ld a, ItemID_Letter
	ld ($C2C4), a
	call Inventory_AddItem
	pop bc
	ld a, $37
	call Inventory_FindFreeSlot
	ret nz
	ld hl, $029C
	call ShowDialogue_B2
	call FadeOut2
	call LABEL_3464
	ld a, $20
	ld ($C29E), a
	call LABEL_3D47
	ld a, $D0
	ld ($C900), a
	ld a, $0C
	call WaitForVInt
	ld hl, LABEL_4D6C
	ld de, $C240
	ld bc, $0008
	ldir
	call FadeIn2
	ld hl, $02A0
	call ShowDialogue_B2
	call LABEL_3464
	ld a, $A0
	ld ($C004), a
	call LABEL_2D47
	ld a, $4A
	ld ($C2E6), a
	call LABEL_5FFE
	ld a, (Alis_stats)	; get status
	push af
	ld a, (Myau_stats)
	push af
	ld a, (Odin_stats)
	push af
	call LABEL_100F
	pop af
	ld (Odin_stats), a
	pop af
	ld (Myau_stats), a
	pop af
	ld (Char_stats), a
	call FadeOut2
	call LABEL_3D47
	ld a, $D0
	ld ($C900), a
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld hl, $02A2
	call ShowDialogue_B2
	call FadeOut2
	ld a, $1D
	ld ($C29E), a
	call LABEL_3D47
	call LABEL_2A6D
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $35
	call LABEL_617D
	call LABEL_576A
	ld hl, $00AA
	jp ShowDialogue_B2

LABEL_4D6C:
.db	$00, $00, $3F, $00, $00, $00, $00
.db $00

LABEL_4D74:
	ld	hl, $B4
	jp	ShowDialogue_B2

LABEL_4D7A:
	ld hl, $00B6
	call ShowDialogue_B2
	call FadeOut2
	call LABEL_3464
	ld a, $A0
	ld ($C004), a
	call LABEL_2D47
	call LABEL_2A6D
	ld a, $C1
	ld ($C004), a
	call FadeIn2
	ld hl, $00B8
	jp ShowDialogue_B2

LABEL_4D9F:
	ld	hl, $102
	jp	ShowDialogue_B2

LABEL_4DA5:
	ld	hl, $106
	jp	ShowDialogue_B2

LABEL_4DAB:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00C2
	jp ShowDialogue_B2

+:	
	ld a, $24
	call Inventory_FindFreeSlot
	jr nz, +
	push bc
	call Inventory_RemoveItem2
	pop bc
	ld hl, $00BC
	jp ShowDialogue_B2

+:	
	ld hl, $020E
	jp ShowDialogue_B2

LABEL_4DD4:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00C2
	jp ShowDialogue_B2

+:	
	ld a, $24
	call Inventory_FindFreeSlot
	jr nz, +
	call Inventory_RemoveItem2
	ld hl, $00C4
	jp ShowDialogue_B2

+:	
	ld hl, $020E
	jp ShowDialogue_B2

LABEL_4DFB:
	ld a, ($C504)
	or a
	jp z, LABEL_4765
	ld a, $34
	call LABEL_617D
	call LABEL_576A
	ld a, ($C504)
	cp $07
	jr c, +
	ld hl, $00D8
	jp ShowDialogue_B2

+:	
	cp $02
	jr nc, +
	ld hl, $00CA
	jp ShowDialogue_B2

+:	
	cp $03
	jr nc, ++
	ld hl, $04B0
	ld ($C2C5), hl
	ld hl, $028C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00DA
	jp ShowDialogue_B2

+:	
	ld de, $04B0
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, $00D0
	jp ShowDialogue_B2

+:	
	ld (Current_money), hl
	ld a, $03
	ld ($C504), a
	ld hl, $0290
	jp ShowDialogue_B2

++:	
	cp $05
	jr nc, +
	inc a
	ld ($C504), a
	ld hl, $0292
	jp ShowDialogue_B2

+:	
	cp $06
	jr nc, +
	inc a
	ld ($C504), a
	ld hl, $00D2
	call ShowDialogue_B2
	ld a, $32
	call Inventory_FindFreeSlot
	jr z, ++
	ld hl, $00D6
	call ShowDialogue_B2
+:	
	ld a, $32
	call Inventory_FindFreeSlot
	jr z, ++
	ld hl, $0104
	jp ShowDialogue_B2

++:	
	ld a, $07
	ld ($C504), a
	ld hl, $0294
	jp ShowDialogue_B2

LABEL_4E9C:
	ld hl, $C504
	ld a, (hl)
	cp $02
	jp c, LABEL_4765
	ld a, $10
	call LABEL_617D
	call LABEL_576A
	ld hl, $00DC
	jp ShowDialogue_B2

LABEL_4EB3:
	ld	hl, $118
	jp	ShowDialogue_B2

LABEL_4EB9:
	ld	hl, $10E
	jp	ShowDialogue_B2

LABEL_4EBF:
	ld	hl, $112
	jp	ShowDialogue_B2

LABEL_4EC5:
	ld hl, $0114
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0116
	jr nz, +
	ld hl, $013C
+:	
	jp ShowDialogue_B2

LABEL_4ED9:
	ld	hl, $10C
	jp	ShowDialogue_B2

LABEL_4EDF:
	ld	hl, $11C
	jp	ShowDialogue_B2

LABEL_4EE5:
	ld	hl, $11E
	jp	ShowDialogue_B2

LABEL_4EEB:
	ld	hl, $120
	jp	ShowDialogue_B2

LABEL_4EF1:
	ld	hl, $126
	jp	ShowDialogue_B2

LABEL_4EF7:
	ld	hl, $128
	jp	ShowDialogue_B2

LABEL_4EFD:
	ld	hl, $12E
	jp	ShowDialogue_B2

LABEL_4F03:
	ld	hl, $130
	jp	ShowDialogue_B2

LABEL_4F09:
	ld	hl, $132
	jp	ShowDialogue_B2

LABEL_4F0F:
	ld	hl, $134
	jp	ShowDialogue_B2

LABEL_4F15:
	ld hl, $013A
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $013C
	jr z, ++
	ld a, ($C507)
	or a
	jr nz, +
	ld a, $01
	ld ($C507), a
+:	
	ld hl, $013E
++:	
	jp ShowDialogue_B2

LABEL_4F34:
	ld	hl, $136
	jp	ShowDialogue_B2

LABEL_4F3A:
	ld	hl, $166
	jp	ShowDialogue_B2

LABEL_4F40:
	ld	hl, $168
	jp	ShowDialogue_B2

LABEL_4F46:
	ld	hl, $16A
	jp	ShowDialogue_B2

LABEL_4F4C:
	ld	hl, $16C
	jp	ShowDialogue_B2

LABEL_4F52:
	ld	hl, $170
	jp	ShowDialogue_B2

LABEL_4F58:
	ld hl, $0172
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $017C
	jr nz, +
	ld a, $01
	ld ($C508), a
	ld hl, $0174
+:	
	jp ShowDialogue_B2

LABEL_4F71:
	ld	hl, $17E
	jp	ShowDialogue_B2

LABEL_4F77:
	ld	hl, $180
	jp	ShowDialogue_B2

LABEL_4F7D:
	ld	hl, $184
	jp	ShowDialogue_B2

LABEL_4F83:
	ld	hl, $186
	jp	ShowDialogue_B2

LABEL_4F89:
	ld	hl, $188
	jp	ShowDialogue_B2

LABEL_4F8F:
	ld	hl, $18C
	jp	ShowDialogue_B2

LABEL_4F95:
	ld	hl, $190
	jp	ShowDialogue_B2

LABEL_4F9B:
	ld hl, $03E8
	ld ($C2C5), hl
	ld hl, $0194
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $019C
	jp ShowDialogue_B2

+:	
	ld de, $03E8
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, $019A
	jp ShowDialogue_B2

+:	
	ld (Current_money), hl
	ld hl, $0198
	call ShowDialogue_B2
	ld a, ItemID_GasShield
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	ret z
	jp Inventory_AddItem

LABEL_4FD8:
	ld	hl, $1A2
	jp	ShowDialogue_B2

LABEL_4FDE:
	ld	hl, $1A4
	jp	ShowDialogue_B2

LABEL_4FE4:
	ld	hl, $1A6
	jp	ShowDialogue_B2

LABEL_4FEA:
	ld	hl, $1AA
	jp	ShowDialogue_B2

LABEL_4FF0:
	ld	hl, $1B2
	jp	ShowDialogue_B2

LABEL_4FF6:
	ld	hl, $1B8
	jp	ShowDialogue_B2

LABEL_4FFC:
	ld	hl, $1BA
	jp	ShowDialogue_B2

LABEL_5002:
	ld	hl, $1BC
	jp	ShowDialogue_B2

LABEL_5008:
	ld	hl, $1BE
	jp	ShowDialogue_B2

LABEL_500E:
	ld	hl, $1C4
	jp	ShowDialogue_B2

LABEL_5014:
	ld	hl, $1C8
	jp	ShowDialogue_B2

LABEL_501A:
	ld	hl, $1CA
	jp	ShowDialogue_B2

LABEL_5020:
	ld	hl, $1CC
	jp	ShowDialogue_B2

LABEL_5026:
	ld	hl, $1D0
	jp	ShowDialogue_B2

LABEL_502C:
	ld hl, $01D6
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $01DA
	jr z, +
	ld hl, $01D8
+:	
	jp ShowDialogue_B2

LABEL_5040:
	ld	hl, $1DC
	jp	ShowDialogue_B2

LABEL_5046:
	ld	hl, $1DE
	jp	ShowDialogue_B2

LABEL_504C:
	ld hl, $000A
	ld ($C2C5), hl
	ld hl, $01E0
	jp ShowDialogue_B2

LABEL_5058:
	ld	hl, $1E2
	jp	ShowDialogue_B2

LABEL_505E:
	ld	hl, $1E4
	jp	ShowDialogue_B2

LABEL_5064:
	ld	hl, $1E6
	jp	ShowDialogue_B2

LABEL_506A:
	ld	hl, $1E8
	jp	ShowDialogue_B2

LABEL_5070:
	ld hl, $0190
	ld ($C2C5), hl
	ld hl, $01EA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $01F0
	jp ShowDialogue_B2

+:	
	ld de, $0190
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, $01F2
	jp ShowDialogue_B2

+:	
	ld (Current_money), hl
	ld a, $01
	ld ($C509), a
	ld hl, $01F4
	jp ShowDialogue_B2

LABEL_50A6:
	ld hl, $01FA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $01FC
	jr z, +
	ld hl, $01FE
+:	
	jp ShowDialogue_B2

LABEL_50BA:
	ld	hl, $200
	jp	ShowDialogue_B2

LABEL_50C0:
	ld	hl, $202
	jp	ShowDialogue_B2

LABEL_50C6:
	ld hl, $0204
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0206
	jr z, +
	ld hl, $0208
+:	
	jp ShowDialogue_B2

LABEL_50DA:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $020C
	jp ShowDialogue_B2

+:	
	ld a, $24
	call Inventory_FindFreeSlot
	jr nz, +
	call Inventory_RemoveItem2
	ld hl, $020A
	jp ShowDialogue_B2

+:	
	ld hl, $020E
	jp ShowDialogue_B2
	

LABEL_5101:
	ld	hl, $210
	jp	ShowDialogue_B2

LABEL_5107:
	ld	hl, $26A
	jp	ShowDialogue_B2

LABEL_510D:
	ld hl, $0118
	ld ($C2C5), hl
	ld hl, $024A
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, LABEL_B12_B7E3
	jp ShowDialogue_B12

+:	
	ld de, $0118
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, LABEL_B12_BD57
	jp ShowDialogue_B12

+:	
	ld a, (Inventory_curr_num)
	cp $18
	jr c, +
	ld hl, LABEL_B12_B813
	jp ShowDialogue_B12

+:	
	ld (Current_money), hl
	ld hl, $020A
	call ShowDialogue_B2
	ld a, ItemID_Cake
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	ret z
	jp Inventory_AddItem

LABEL_5157:
	ld a, $08
	ld ($C2E6), a
	call LABEL_5FFE
	ld a, (Party_curr_num)
	cp $03
	ld hl, $00AC
	jr nz, +
	ld hl, $00B2
+:	
	jp ShowDialogue_B2

LABEL_516F:
	ld a, (Party_curr_num)
	cp $03
	jp nc, LABEL_4765
	ld a, $3B
	call LABEL_617D
	call LABEL_576A
	ld hl, $00AE
	call ShowDialogue_B2
	ld a, ItemID_Letter
	call Inventory_FindFreeSlot
	ret nz
	call Inventory_RemoveItem2
	pop hl
	call LABEL_3464
	call LABEL_2D25
	ld a, $01
	ld ($C506), a
	ld iy, Noah_stats
	ld (iy+weapon), ItemID_WoodCane
	ld (iy+armor), ItemID_WhiteMantle
	call UnlockCharacter
	ld a, $03
	ld (Party_curr_num), a
	jp LABEL_4461

LABEL_51B1:
	ld hl, $C504
	ld a, (hl)
	cp $02
	jp nc, LABEL_4765
	ld a, $10
	call LABEL_617D
	call LABEL_576A
	ld hl, $C504
	ld a, (hl)
	cp $01
	ld de, $00DC
	jr nz, +
	ld (hl), $02
	ld de, $00F6
+:	
	ex de, hl
	jp ShowDialogue_B2

LABEL_51D6:
	ld	hl, $F8
	jp	ShowDialogue_B2

LABEL_51DC:
	ld a, ($C504)
	or a
	jp nz, LABEL_4765
	ld a, $34
	call LABEL_617D
	call LABEL_576A
	ld hl, $C503
	ld a, (hl)
	or a
	jr nz, +
	inc (hl)
	ld hl, $00DE
	jp ShowDialogue_B2

+:	
	cp $01
	jr nz, +
	inc (hl)
	ld hl, $00E0
	jp ShowDialogue_B2

+:	
	ld hl, $00E2
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $00D4
	jr nz, +
	ld hl, $C504
	ld (hl), $01
	ld hl, $00E4
+:	
	jp ShowDialogue_B2

LABEL_521D:
	ld a, $2E
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $00E6
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld a, $33
	call Inventory_FindFreeSlot
	jr nz, +
	ld hl, $0024
	jp ShowDialogue_B2

+:	
	ld hl, $00E8
	call ShowDialogue_B2
	call LABEL_3464
	jp LABEL_5389

LABEL_5249:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00C2
	jp ShowDialogue_B2

+:	
	ld a, $24
	call Inventory_FindFreeSlot
	jr nz, +
	call Inventory_RemoveItem2
	ld hl, $00EA
	jp ShowDialogue_B2

+:	
	ld hl, $00CE
	jp ShowDialogue_B2

LABEL_5270:
	ld hl, $00EC
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $013C
	jr z, +
	ld hl, $0124
+:	
	jp ShowDialogue_B2

LABEL_5284:
	ld	hl, $EE
	jp	ShowDialogue_B2

LABEL_528A:
	ld	hl, $F0
	jp	ShowDialogue_B2

LABEL_5290:
	ld hl, $00F2
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $014C
	jr z, +
	ld hl, $013C
+:	
	jp ShowDialogue_B2

LABEL_52A4:
	ld a, $16
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $00F4
	jp ShowDialogue_B2

LABEL_52B2:
	ld	hl, $FC
	jp	ShowDialogue_B2

LABEL_52B8:
	ld	hl, $FE
	jp	ShowDialogue_B2

LABEL_52BE:
	ld	hl, $100
	jp	ShowDialogue_B2

LABEL_52C4:
	ld	hl, $10A
	jp	ShowDialogue_B2

LABEL_52CA:
	ld	hl, $21A
	jp	ShowDialogue_B2

LABEL_52D0:
	ld hl, $0148
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +

LABEL_52DB:	
	ld hl, $0152
	jp ShowDialogue_B2

+:	
	ld hl, $014E
	call ShowDialogue_B2
	ld hl, $0150
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, LABEL_52DB
	ld hl, $014E
	call ShowDialogue_B2
	ld hl, $0154
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, LABEL_52DB
	ld hl, $014E
	call ShowDialogue_B2
	ld hl, $0156
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld hl, $0158
	jp ShowDialogue_B2

+:	
	ld hl, $015A
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, LABEL_52DB
	ld hl, $015C
	call ShowDialogue_B2
	ld a, ItemID_Crystal
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	ret z
	jp Inventory_AddItem

LABEL_5337:
	ld hl, $0160
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0162
	jr z, +
	ld hl, $0164
+:	
	jp ShowDialogue_B2

LABEL_534B:
	ld a, $2E
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $021C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld a, $33
	call Inventory_FindFreeSlot
	jr nz, +
	ld hl, $021E
	call ShowDialogue_B2
	call LABEL_3464
	pop hl
	ld hl, $159C
	ld (Dungeon_position), hl
	ld a, $01
	ld (Dungeon_direction), a
	ld hl, Game_mode
	ld (hl), $0A ; GameMode_LoadDungeon
	ret

+:	
	ld hl, $00E8
	call ShowDialogue_B2
	call LABEL_3464
LABEL_5389:	
	call LABEL_100F
	ld a, ($C800)
	or a
	call nz, LABEL_1BE1
	pop hl
	ret

LABEL_5395:
	ld	hl, $222
	jp	ShowDialogue_B2

LABEL_539B:
	ld	hl, $224
	jp	ShowDialogue_B2

LABEL_53A1:
	ld	hl, $226
	jp	ShowDialogue_B2

LABEL_53A7:
	ld	hl, $22E
	jp	ShowDialogue_B2

LABEL_53AD:
	ld	hl, $232
	jp	ShowDialogue_B2

LABEL_53B3:
	ld	hl, $218
	jp	ShowDialogue_B2

LABEL_53B9:
	ld	hl, $214
	jp	ShowDialogue_B2

LABEL_53BF:
	ld a, $2E
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $009C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00A2
	call ShowDialogue_B2
	jr ++

+:	
	ld a, $36
	call Inventory_FindFreeSlot
	jr nz, +
	push bc
	call Inventory_RemoveItem2
	pop bc
	ld a, $FF
	ld ($C511), a
	ld hl, $009E
	jp ShowDialogue_B2

+:	
	ld hl, $00A0
	call ShowDialogue_B2
++:	
	pop hl
	call LABEL_3464
	call LABEL_15DC
	jp LABEL_688C

LABEL_5401:
	ld hl, $023E
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $0246
	jp ShowDialogue_B2

+:	
	ld a, $3A
	call Inventory_FindFreeSlot
	jr nz, +
	call Inventory_RemoveItem2
	ld a, ItemID_EclipseTorch
	ld ($C2C4), a
	call Inventory_AddItem
	ld hl, $0244
	jp ShowDialogue_B2

+:	
	ld hl, $0248
	jp ShowDialogue_B2

LABEL_5430:
	ld a, $31
	ld ($C2E6), a
	call LABEL_5FFE
	ld a, (Noah_stats+armor)
	ld b, a
	ld a, $18
	cp b
	jr z, +
	call Inventory_FindFreeSlot
	jr nz, ++
+:	
	ld hl, $0258
	jp ShowDialogue_B2

++:	
	ld a, (Party_curr_num)
	cp $03
	jr nc, ++
	ld hl, $025A
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $025E
	jr z, +
	ld hl, $0260
+:	
	jp ShowDialogue_B2

++:	
	ld hl, $024C
	call ShowDialogue_B2
	ld a, (Noah_stats)
	or a
	jr nz, +
	ld hl, $02A8
	jp ShowDialogue_B2

+:	
	ld hl, $024E
	call ShowDialogue_B2
	call LABEL_3464
	ld a, (Noah_stats+curr_hp)
	push af
	ld a, (Alis_stats)
	push af
	ld a, (Myau_stats)
	push af
	ld a, (Odin_stats)
	push af
	xor a
	ld (Alis_stats), a
	ld (Myau_stats), a
	ld (Odin_stats), a
	call LABEL_100F
	pop af
	ld (Odin_stats), a
	pop af
	ld (Myau_stats), a
	pop af
	ld (Alis_stats), a
	pop af
	ld b, a
	ld a, (Noah_stats+curr_hp)
	or a
	jr nz, +
	ld a, b
	ld (Noah_stats+curr_hp), a
	ld a, $01
	ld (Noah_stats), a
	ld hl, $0256
	jp ShowDialogue_B2

+:	
	ld hl, $0250
	call ShowDialogue_B2
	ld a, ItemID_FradeMantle
	ld ($C2C4), a
	jp Inventory_AddItem

LABEL_54D0:
	ld a, $3E
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $0262
	call ShowDialogue_B2
	call LABEL_3464
	call LABEL_54EF
	ld a, $FF
	ld ($C517), a
	ld hl, $0266
	jp ShowDialogue_B2
	
LABEL_54EF:	
	call LABEL_100F
	ld a, (Game_mode)
	cp $02 ; GameMode_LoadIntro
	ret nz
	pop hl
	pop hl
	ret

LABEL_54FB:
	ld a, ($C516)
	or a
	jp nz, LABEL_4765
	ld a, $48
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $026C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $026E
	jr z, +
	ld hl, $0270
+:	
	call ShowDialogue_B2
	call LABEL_3464
	call LABEL_54EF
	ld a, $01
	ld ($C516), a
	ld hl, $02AA
	jp ShowDialogue_B2

LABEL_552F:
	ld	hl, LABEL_B12_B7AA
	jp	ShowDialogue_B12

LABEL_5535:
	call	LABEL_2D25

LABEL_5538:
	call LABEL_1BE1
	pop hl
	ret

LABEL_553D:	
	ld hl, LABEL_B12_B569
	call ShowDialogue_B12
	jp LABEL_3464

LABEL_5546:
	ld a, ItemID_Hapsby
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	jr z, LABEL_553D
	call LABEL_3464
	ld hl, $C801
	inc (hl)
	call LABEL_576A
	call LABEL_2D25
	ld hl, $012C
	call ShowDialogue_B2
	jp Inventory_AddItem

LABEL_5566:
	ld a, ($C508)
	or a
	jr z, LABEL_553D
	ld a, ItemID_Hapsby
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	jr nz, LABEL_553D
	ld a, ItemID_Hovercraft
	ld ($C2C4), a
	call Inventory_FindFreeSlot
	jr z, LABEL_553D
	ld hl, $0178
	call ShowDialogue_B2
	call LABEL_3464
	jp Inventory_AddItem

LABEL_558C:
	ld hl, $00FA
	call ShowDialogue_B2
	jp LABEL_3464

LABEL_5595:
	ld a, $2B
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $0234
	jp ShowDialogue_B2

LABEL_55A3:
	ld	hl, $234
	jp	ShowDialogue_B2

LABEL_55A9:
	ld a, $1B
	ld ($C2E6), a
	call LABEL_5FFE
	xor a
	ld ($CBC3), a
	ld hl, $0238
	jp ShowDialogue_B2

LABEL_55BB:
	ld a, $26
	ld ($C2E6), a
	call LABEL_5FFE
	pop hl
	ld hl, $0000
	ld ($C2DD), hl
	jp LABEL_100F

LABEL_55CD:
	ld hl, $0228
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $022C
	jr z, +
	ld hl, $022A
+:	
	jp ShowDialogue_B2

LABEL_55E1:
	ld a, $08
	ld ($C2E6), a
	call LABEL_5FFE
	ld hl, $0212
	jp ShowDialogue_B2

LABEL_55EF:
	ld a, ($C504)
	cp $07
	jr nc, +
	ld hl, $0282
	jp ShowDialogue_B2

+:	
	ld hl, $0284
	call ShowDialogue_B2
	ld a, ($C301)
	cp $40
	ld hl, LABEL_5613
	jr nc, +
	ld hl, LABEL_5616
+:	
	call LABEL_787B
	ret
		
LABEL_5613:
.db $07, $1B, $1B

LABEL_5616:
.db	$07, $1B, $1D

LABEL_5619:
	ld a, $93
	ld ($C004), a
	call LABEL_2D47
	ld a, $1F
	ld ($C29E), a
	call LABEL_3D47
	ld hl, $FFFF
	ld (hl), :Bank19
	ld hl, LABEL_B19_8000
	ld de, $C250
	ld bc, $0010
	ldir
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $49
	ld ($C2E6), a
	call LABEL_5FFE
	call LABEL_2D33
	ld a, $20
	ld ($C29E), a
	call LABEL_54EF
	call LABEL_3464
	ld a, (Char_stats)
	or a
	jr nz, LABEL_5666
	ld hl, LABEL_B12_BF64
	call ShowDialogue_B12
	call LABEL_3464

LABEL_5666:
	call FadeOut2
	ld a, $1D
	ld ($C29E), a
	call LABEL_3D47
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $35
	call LABEL_617D
	call LABEL_576A
	ld hl, $0272
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0212
	jr z, +
	ld hl, $0230
+:	
	call ShowDialogue_B2
	call LABEL_3464
	pop hl
	jp LABEL_454E

LABEL_569C:
	ld	hl, $2A4
	jp	ShowDialogue_B2

LABEL_56A2:
	ld a, ($C2F0)
	ld d, a
	ld e, $00
-:	
	ld a, e
	ld ($C2C2), a
	rr d
	push de
	ld hl, LABEL_B12_B728
	call c, ShowDialogue_B12
	pop de
	inc e
	ld a, e
	cp $04
	jr nz, -
	ld b, $04
-:	
	ld a, b
	dec a
	call LABEL_187D
	jr nz, +
	djnz -
	jp LABEL_1602

+:	
	jp LABEL_3464

LABEL_56CD:
	ld	hl, $23A
	jp	ShowDialogue_B2

LABEL_56D3:
	ld	hl, $27A
	jp	ShowDialogue_B2

LABEL_56D9:
	ld hl, LABEL_B12_BDCE
	call ShowDialogue_B12
	call ShowYesNoPrompt
	ret nz
	ld a, $81
	ld ($C2E9), a
	ret

LABEL_56E9:
	ld hl, LABEL_B12_BDE6
	call ShowDialogue_B12
	call ShowYesNoPrompt
	ret nz
	ld a, $82
	ld ($C2E9), a
	ret

LABEL_56F9:
	ld hl, LABEL_B12_B754
	call ShowDialogue_B12
	push bc
	call LABEL_3A21
	bit 4, c
	pop bc
	ret nz
	ld d, a
	ld a, ($C309)
	rrca
	rrca
	rrca
	and $03
	ld e, a
	cp d
	jr nz, ++
	or a
	ld hl, LABEL_B12_B799
	jr z, +
	dec a
	ld hl, LABEL_B12_B790
	jr z, +
	ld hl, LABEL_B12_B785
+:	
	call ShowDialogue_B12
	jr LABEL_56F9

++:	
	ld a, d
	or a
	ld hl, LABEL_B12_B77B
	jr z, +
	dec a
	ld hl, LABEL_B12_B76F
	jr z, +
	ld hl, LABEL_B12_B761
+:	
	push de
	call ShowDialogue_B12
	call ShowYesNoPrompt
	pop de
	jr nz, LABEL_56F9
	ld a, e
	add a, a
	add a, e
	add a, d
	ld d, $00
	ld e, a
	ld hl, LABEL_5752
	add hl, de
	ld a, (hl)
	ld ($C2E9), a
	ret

LABEL_5752:
.db	$81
.db $83, $84, $85, $82, $86, $87, $88

ShowDialogue_B2:
	ld a, :Bank02
	ld ($FFFF), a
	ld de, DialogueBlock-2
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp LABEL_31D4

LABEL_576A:
	ld   hl, $C289
	ld   ($C287), hl
	ld   de, $C28B
	ld   bc, $000E
	ld   (hl), $00
	inc  hl
	ld   (hl), $FF
	dec  hl
	ldir
	ld   hl, $C900
	ld   ($C217), hl
	ld   hl, $C980
	ld   ($C219), hl
	ld   iy, $C800
	ld   bc, $0800
LABEL_5791:
	ld   a, (iy+0)
	and  $7F
	jr   z, LABEL_57B1
	push	bc
	ld   hl, LABEL_5827-2
	call	GetPtrAndJump
	pop  bc
	or   a
	jp   z, LABEL_57B1
	ld   hl, ($C287)
	ld   a, (iy+2)
	ld   (hl), a
	inc  hl
	ld   (hl), c
	inc  hl
	ld   ($C287), hl
LABEL_57B1:
	ld   de, $0020
	add  iy, de
	inc  c
	djnz	LABEL_5791
	ld   de, $C289
	ld   b, $03
LABEL_57BE:
	push	bc
	ld   l, e
	ld   h, d
	inc  hl
	inc  hl
LABEL_57C3:
	ld   a, (de)
	cp   (hl)
	jr   nc, LABEL_57D4
	ld   c, a
	ld   a, (hl)
	ld   (hl), c
	ld   (de), a
	inc  hl
	inc  de
	ld   a, (de)
	ld   c, a
	ld   a, (hl)
	ld   (hl), c
	ld   (de), a
	dec  hl
	dec  de
LABEL_57D4:
	inc  hl
	inc  hl
	djnz	LABEL_57C3
	inc  de
	inc  de
	pop  bc
	djnz	LABEL_57BE
	ld   hl, $C28A
	ld   b, $08
LABEL_57E2:
	ld   a, (hl)
	cp   $FF
	jr   z, LABEL_580E
	push	bc
	push	hl
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, $C800
	add  hl, de
	push	hl
	pop  iy
	cp   $04
	ld   a, :Bank03
	ld   bc, LABEL_B03_96F4
	jr   c, LABEL_5806
	ld   a, :Bank21
	ld   bc, LABEL_B21_8000
LABEL_5806:
	ld   ($FFFF), a
	call	LABEL_5853
	pop  hl
	pop  bc
LABEL_580E:
	inc  hl
	inc  hl
	djnz	LABEL_57E2
	ld   hl, ($C217)
	ld   (hl), $D0
	ret


LABEL_5818:
	push iy
	pop hl
	inc hl
	ld e, l
	ld d, h
	inc de
	xor a
	ld (hl), a
	ld bc, $001E
	ldir
	ret


LABEL_5827:
.dw	LABEL_599F
.dw	LABEL_59D4
.dw	LABEL_59E0
.dw	LABEL_59E5
.dw	LABEL_59F1
.dw	LABEL_59F6
.dw	LABEL_5A02
.dw	LABEL_5A07
.dw	LABEL_5A4F
.dw	LABEL_5A70
.dw	LABEL_5B87
.dw	LABEL_5BCE
.dw	LABEL_5C63
.dw	LABEL_5C99
.dw	LABEL_5DA0
.dw	LABEL_5E2B
.dw	LABEL_5E2E
.dw	LABEL_5E72
.dw	LABEL_5EAE
.dw	LABEL_5EEA
.dw	LABEL_5D30
.dw	LABEL_5D5B

LABEL_5853:
	ld   l, (iy+1)
	ld   h, $00
	add  hl, hl
	add  hl, bc
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   b, (hl)
	push	bc
	inc  hl
	ld   de, ($C217)
	ld   c, (iy+2)
LABEL_5868:
	ld   a, (hl)
	add  a, c
	ld   (de), a
	inc  de
	inc  hl
	djnz	LABEL_5868
	ld   ($C217), de
	pop  bc
	ld   de, ($C219)
	ld   c, (iy+4)
LABEL_587B:
	ld   a, (hl)
	add  a, c
	ld   (de), a
	inc  de
	inc  hl
	ld   a, (hl)
	ld   (de), a
	inc  hl
	inc  de
	djnz	LABEL_587B
	ld   ($C219), de
	ret


; Data from 588B to 5FFD (1907 bytes)
LABEL_588B:
	ld	hl, $C900
	ld	de, $7F00
	rst	$08
	ld	c, $BE
	call	LABEL_591E
	ld	hl, $C980
	ld	de, $7F80
	rst	$08
	
LABEL_589E:
.REPEAT 64
	outi
.ENDR

LABEL_591E:
.REPEAT 32
	outi
.ENDR

LABEL_595E:
.REPEAT 32
	outi
.ENDR
	ret

LABEL_599F:	
	ld b, $01
LABEL_59A1:	
	push bc
	call LABEL_5818
	inc (iy+0)
	pop bc
	ld (iy+2), $60
	ld a, ($C2EA)
	and $03
	ld a, $84
	jr nz, +
	ld a, $80
+:	
	ld (iy+4), a
	ld (iy+18), $01
	ld (iy+1), b
	ld (iy+17), $01
	ld a, c
	or a
	ld a, $00
	jr nz, +
	ld a, $03
+:	
	ld (iy+10), a
	ld a, $FF
	ret

LABEL_59D4:
	ld de, LABEL_5A13
	ld hl, LABEL_5A17
	call LABEL_5A98
	ld a, $FF
	ret

LABEL_59E0:
	ld b, $02
	jp LABEL_59A1

LABEL_59E5:
	ld de, LABEL_5A27
	ld hl, LABEL_5A2B
	call LABEL_5A98
	ld a, $FF
	ret

LABEL_59F1:
	ld b, $03
	jp LABEL_59A1

LABEL_59F6:
	ld de, $5A13
	ld hl, LABEL_5A17
	call LABEL_5A98
	ld a, $FF
	ret

LABEL_5A02:
	ld b, $04
	jp LABEL_59A1

LABEL_5A07:
	ld de, LABEL_5A3B
	ld hl, LABEL_5A3F
	call LABEL_5A98
	ld a, $FF
	ret

LABEL_5A13:
.db $01, $00, $09, $0C

LABEL_5A17:
.db	$05, $06, $07, $06
.db $02, $03, $04, $03, $08, $09, $0A, $09
.db $0B, $0C, $0D, $0C

LABEL_5A27:
.db	$05, $00, $08, $0B

LABEL_5A2B:
.db $04, $05, $06, $05, $01, $02, $03, $02
.db $07, $08, $09, $08, $0A, $0B, $0C, $0B

LABEL_5A3B:
.db $01, $00, $0E, $0F

LABEL_5A3F:
.db	$05, $06, $07, $06
.db $02, $03, $04, $03, $08, $09, $0A, $0A
.db $0B, $0C, $0D, $0D

LABEL_5A4F:
	call LABEL_5818
	inc (iy+0)
	ld (iy+2), $60
	ld (iy+4), $80
	ld (iy+1), $05
	ld a, ($C30E)
	sub $04
	ld (iy+16), a
	ld (iy+17), $01
	ld a, $FF
	ret

LABEL_5A70:
	call +
	ld a, $FF
	ret

+:	
	call LABEL_7143
	ld a, ($C264)
	and $0F
	ret z
	ld c, $FF
-:	
	rrca
	inc c
	jp nc, -
	ld hl, LABEL_5A94
	ld b, $00
	add hl, bc
	ld a, ($C30E)
	add a, (hl)
	ld (iy+16), a
	ret

LABEL_5A94:
.db	$FC, $FE, $FF, $FD


LABEL_5A98:
	ld a, c
	or a
	call z, LABEL_7143
	ld a, ($C265)
	or a
	jp z, LABEL_5AFC
	cp $0F
	jp nz, LABEL_5B30
	ld a, c
	or a
	jp nz, +
	ld a, (iy+18)
	ld (iy+19), a
	ld a, ($C264)
	and $0F
	jp z, LABEL_5AFC
	ld b, $FF
-:	
	rrca
	inc b
	jp nc, -
	ld (iy+18), b
	jp LABEL_5B30

+:	
	bit 0, (iy+10)
	jr z, +
	set 1, (iy+10)
+:	
	ld a, (iy-28)
	cp (iy+4)
	jr nz, +
	ld a, (iy-30)
	cp (iy+2)
	jr z, ++
+:	
	bit 1, (iy-22)
	jr z, ++
	set 0, (iy+10)
++:	
	ld a, (iy+18)
	ld (iy+19), a
	ld a, (iy-13)
	ld (iy+18), a
	jp LABEL_5B30

LABEL_5AFC:	
	ld a, ($C264)
	and $0F
	jp nz, LABEL_5B30
--:	
	ld a, (iy+18)
	ld (iy+19), a
	ld a, c
	or a
	jr nz, +
	ld a, (Ctrl_1_held)
	and ButtonUp_Mask|ButtonDown_Mask|ButtonLeft_Mask|ButtonRight_Mask
	jr z, +
	ld l, $FF
-:	
	rrca
	inc l
	jp nc, -
	jr ++

+:	
	ld a, c
	or a
	ld l, (iy+18)
	jr z, ++
	ld l, (iy-13)
++:	
	ld h, $00
	add hl, de
	ld a, (hl)
	ld (iy+16), a
	ret

LABEL_5B30:	
	ld a, c
	or a
	call nz, +
	ld a, ($C2E9)
	or a
	jr nz, --
	dec (iy+14)
	ret p
	ld (iy+14), $07
	ld a, (iy+18)
	add a, a
	add a, a
	ld b, a
	ld a, (iy+13)
	inc a
	and $03
	ld (iy+13), a
	add a, b
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld (iy+16), a
	ret

+:	
	bit 0, (iy+10)
	ld a, (iy+18)
	call nz, +
	ld a, ($C812)
	xor $01
+:	
	cp $02
	jp nc, ++
	or a
	jr nz, +
	dec a
+:	
	add a, (iy+2)
	ld (iy+2), a
	ret

++:	
	sub $02
	jr nz, +
	dec a
+:	
	add a, (iy+4)
	ld (iy+4), a
	ret


LABEL_5B87:
	ld a, (iy+10)
	push af
	call LABEL_5818
	pop af
	inc (iy+0)
	ld hl, $FFFF
	ld (hl), :Bank18
	add a, a
	ld e, a
	add a, a
	add a, e
	ld e, a
	ld d, $00
	ld hl, LABEL_5BF1
	add hl, de
	ld a, (hl)
	ld ($C004), a
	inc hl
	ld a, (hl)
	ld (iy+24), a
	inc hl
	ld a, (hl)
	ld (iy+1), a
	inc hl
	ld a, (hl)
	ld (iy+15), a
	inc hl
	ld a, ($C894)
	ld (iy+2), a
	ld a, ($C895)
	ld (iy+4), a
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $7400
	call LABEL_3FA
	xor a
	ret

LABEL_5BCE:
	call +
	ld a, $FF
	ret

+:	
	dec (iy+14)
	ret p
	ld a, (iy+24)
	ld (iy+14), a
	ld a, (iy+1)
	inc a
	cp (iy+15)
	jr nc, +
	ld (iy+1), a
	ret

+:	
	xor a
	ld (iy+0), a
	pop hl
	ret

LABEL_5BF1:
.db	$A2, $03
.db $66, $6B, $2A, $AD, $A2, $03, $05, $0A
.db $00, $9C, $A2, $03, $05, $0A, $00, $9C
.db $A2, $03, $05, $0A, $00, $9C, $A2, $03
.db $05, $0A, $00, $9C, $A2, $03, $6A, $72
.db $91, $AF, $A2, $03, $71, $76, $77, $B1
.db $A2, $03, $05, $0A, $00, $9C, $A2, $03
.db $05, $0A, $00, $9C, $A7, $03, $18, $21
.db $70, $A2, $A2, $03, $6A, $72, $91, $AF
.db $A6, $03, $11, $19, $36, $A0, $A3, $03
.db $5E, $63, $C0, $AA, $A5, $03, $09, $12
.db $D7, $9D, $A4, $03, $62, $67, $9D, $AB
.db $A4, $03, $75, $7A, $44, $B2, $A8, $03
.db $20, $29, $BC, $A3, $A9, $03, $28, $32
.db $E0, $A5, $AA, $03, $31, $3A, $FD, $A7

LABEL_5C63:
	call LABEL_5818
	inc (iy+0)
	ld (iy+2), $58
	ld (iy+4), $60
	ld (iy+1), $3A
	ld (iy+14), $07
	call LABEL_5B1
	ld b, a
	ld c, $3D
	ld a, ($C2E0)
	or a
	jr z, ++
	cp $F0
	jr nc, +
	cp b
	jr c, ++
+:	
	rrca
	ld c, $3E
	jr nc, ++
	ld c, $43
++:	
	ld (iy+15), c
	ld a, $FF
	ret

LABEL_5C99:
	call +
	ld a, $FF
	ret

+:	
	bit 0, (iy+10)
	ret z
	bit 1, (iy+10)
	jr nz, +
	dec (iy+14)
	ret p
	ld (iy+14), $07
	ld a, (iy+1)
	inc a
	ld (iy+1), a
	cp $3D
	ret nz
	ld (iy+14), $17
	set 1, (iy+10)
	ret

+:	
	bit 2, (iy+10)
	jr nz, ++
	dec (iy+14)
	ret p
	ld (iy+14), $03
	ld a, (iy+15)
	ld (iy+1), a
	set 2, (iy+10)
	cp $3D
	jr nz, +
	ld (iy+0), $00
	ret

+:	
	cp $3E
	ld a, $B1
	jr z, +
	inc a
+:	
	ld ($C004), a
	ret

++:	
	dec (iy+14)
	ret p
	ld (iy+14), $03
	ld a, (iy+15)
	cp $3E
	jr nz, +
	ld a, (iy+1)
	inc a
	ld (iy+1), a
	push af
	cp $42
	call z, LABEL_7BC4
	pop af
	cp $43
	ret c
	ld (iy+1), $3D
	ld (iy+0), $00
	ret

+:	
	ld a, (iy+1)
	inc a
	ld (iy+1), a
	cp $47
	ret c
	call LABEL_7BC4
	ld (iy+1), $3D
	ld (iy+0), $00
	ret

LABEL_5D30:
	call LABEL_5818
	inc (iy+0)
	ld a, ($C309)
	cp $17
	ld a, $84
	ld de, $88D0
	jr nz, +
	ld a, $88
	ld de, $3050
+:	
	ld (iy+2), d
	ld (iy+4), e
	ld (iy+1), a
	ld (iy+15), a
	ld a, $B9
	ld ($C004), a
	ld a, $FF
	ret

LABEL_5D5B:
	call +
	ld a, $FF
	ret

+:	
	dec (iy+14)
	ret p
	ld (iy+14), $07
	ld a, (iy+13)
	inc (iy+13)
	and $03
	add a, (iy+15)
	ld (iy+1), a
	ld a, ($C309)
	cp $17
	jr z, +
	dec (iy+4)
	dec (iy+2)
	ld a, (iy+4)
	cp $90
	ret nz
-:	
	ld (iy+0), $00
	ret

+:	
	inc (iy+2)
	ld a, (iy+2)
	cp $78
	jr z, -
	and $07
	ret nz
	dec (iy+4)
	ret

LABEL_5DA0:
	call +
	ld a, (iy+1)
	ret

+:	
	ld a, ($C29F)
	or a
	ret z
	ld a, ($C800)
	or a
	ret nz
LABEL_5DB1:	
	dec (iy+14)
	ret p
	ld a, (iy+24)
	ld (iy+14), a
	ld hl, $FFFF
	ld (hl), :Bank03
	ld c, (iy+13)
	ld l, c
	ld h, $00
	bit 7, (iy+10)
	ld e, (iy+27)
	ld d, (iy+28)
	jr nz, LABEL_5DD8
	ld e, (iy+25)
	ld d, (iy+26)
LABEL_5DD8:	
	add hl, de
	ld a, (hl)
	or a
	jr nz, +
	bit 0, (iy+10)
	jr z, ++
	ld ($C29F), a
	ld (iy+10), a
	ld ($C2ED), a
	ld c, a
	ld a, (de)
+:	
	inc c
	ld (iy+13), c
	ld (iy+1), a
	ret

++:	
	set 0, (iy+10)
	inc c
	ld (iy+13), c
	bit 7, (iy+10)
	jr z, +
	ld a, ($C2E6)
	cp $48
	jr z, LABEL_5E1D
	ld a, $11
	ld ($C800), a
	ret

+:	
	ld a, ($C2ED)
	or a
	jr nz, LABEL_5E1D
	ld a, $BB
	ld ($C004), a
	ret

LABEL_5E1D:	
	ld a, $AE
	ld ($C004), a
	call LABEL_7BC4
	ld a, ($C2EE)
	jp LABEL_2FA1

LABEL_5E2B:
	ld a, $FF
	ret

LABEL_5E2E:
	call LABEL_5818
	inc (iy+0)
	ld hl, $FFFF
	ld (hl), :Bank11
	ld a, ($C88A)
	bit 6, a
	ld hl, LABEL_5EA2
	jr z, +
	ld hl, LABEL_5EA8
+:	
	ld a, (hl)
	ld ($C004), a
	inc hl
	ld a, (hl)
	ld (iy+24), a
	inc hl
	ld a, (hl)
	ld (iy+1), a
	inc hl
	ld a, (hl)
	ld (iy+15), a
	inc hl
	ld a, ($C896)
	ld (iy+2), a
	ld a, ($C897)
	ld (iy+4), a
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $7400
	call LABEL_3FA
	xor a
	ret

LABEL_5E72:
	call +
	ld a, $FF
	ret

+:	
	dec (iy+14)
	ret p
	ld a, (iy+24)
	ld (iy+14), a
	ld a, (iy+1)
	inc a
	cp (iy+15)
	jr nc, +
	ld (iy+1), a
	ret

+:	
	xor a
	ld (iy+0), a
	pop hl
	ld a, ($C2EF)
	and $80
	jp z, LABEL_5E1D
	ld a, $BB
	ld ($C004), a
	ret

LABEL_5EA2:
.db	$A8
.db $03, $46, $4F, $01, $99

LABEL_5EA8:
.db	$A9, $03, $79
.db $82, $F0, $9A

LABEL_5EAE:
	call +
	ld a, (iy+1)
	ret

+:	
	ld a, ($C29F)
	or a
	ret z
	dec (iy+14)
	ret p
	ld a, (iy+24)
	ld (iy+14), a
	ld hl, $FFFF
	ld (hl), :Bank03
	ld a, ($C2EE)
	or a
	ld de, LABEL_B03_94F6
	jr z, +
	dec a
	ld de, LABEL_B03_9506
	jr z, +
	dec a
	ld de, LABEL_B03_9511
	jr z, +
	ld de, LABEL_B03_951C
+:	
	ld c, (iy+13)
	ld l, c
	ld h, $00
	jp LABEL_5DD8

LABEL_5EEA:
	call +
	ld a, (iy+1)
	ret

+:	
	ld a, ($C29F)
	or a
	ret z
	ld a, (iy+12)
	cp $02
	jr nc, +
	dec (iy+11)
	ret p
	ld (iy+11), $07
	inc (iy+12)
	or a
	ld hl, LABEL_B18_BF50
	jr z, LABEL_5F11
	ld hl, LABEL_B18_BF80

LABEL_5F11:	
	ld a, :Bank24
	ld ($FFFF), a
	ld de, $7A5C
	ld bc, $0608
	di
	call LABEL_390
	ei
	ret

+:	
	cp $03
	jr nc, ++
	call LABEL_5DB1
	ld a, (iy+13)
	cp $13
	jr nz, +
	ld (iy+2), $47
+:	
	ld a, ($C29F)
	or a
	ret nz
	dec a
	ld ($C29F), a
	inc (iy+12)
	ld (iy+2), $4F
	ret

++:	
	dec (iy+11)
	ret p
	ld (iy+11), $07
	inc (iy+12)
	cp $04
	ld hl, LABEL_B18_BF50
	jr nz, LABEL_5F11
	xor a
	ld (iy+12), a
	ld ($C29F), a
	ld hl, LABEL_B18_BF20
	jr LABEL_5F11

LABEL_5F63:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld a, ($C308)
	cp $03
	jp nc, LABEL_5FF9
	ld h, a
	ld l, $00
	srl h
	rr l
	ld de, LABEL_B03_8000
	add hl, de
	ld de, ($C305)
	ld a, e
	add a, $60
	jr c, +
	cp $C0
	ccf
+:	
	ld a, $00
	adc a, d
	and $07
	add a, a
	add a, a
	add a, a
	ld c, a
	ld de, ($C301)
	ld a, e
	add a, $80
	ld a, $00
	adc a, d
	and $07
	add a, c
	add a, a
	ld d, $00
	ld e, a
	add hl, de
	ld b, (hl)
	ld a, ($C30E)
	or a
	jr z, +
	srl b
	srl b
+:	
	call LABEL_5B1
	cp b
	jp nc, LABEL_5FF9
	inc hl
	ld b, $00
	ld c, (hl)
	ld a, ($C2E5)
	ld l, a
	ld h, $00
	ld de, LABEL_B03_85A0
	add hl, de
	ld a, ($C308)
	or a
	jr z, +
	ld a, $0A
+:	
	add a, (hl)
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, LABEL_B03_8470
	add hl, de
	add hl, bc
	ld a, (hl)

LABEL_5FD8:
	or a
	ret z
	ld hl, $FFFF
	ld (hl), :Bank03
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, LABEL_B03_8178
	add hl, de
	call LABEL_5B1
	and $07
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld ($C2E6), a
	ld a, $FF
	ret

LABEL_5FF9:
	xor a
	ld ($C29D), a
	ret

LABEL_5FFE:
	ld   hl, $FFFF
	ld   (hl), :Bank03
	ld   hl, $C800
	ld   de, $C801
	ld   bc, $00FF
	ld   (hl), $00
	ldir
	ld   hl, $C440
	ld   de, $C441
	ld   bc, $007F
	ld   (hl), $00
	ldir
	ld   a, ($C2E6)
	ld   a, a
	and  $7F
	ret  z

	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, B03_EnemyData
	add  hl, de
	ld   de, CurrentBattle_EnemyName
	ld   bc, $0008
	ldir
	ld   de, $C258
	ld   bc, $0008
	ldir
	ld   b, (hl)
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	ld   a, b
	ld   ($FFFF), a
	ld   de, $6000
	call	LABEL_3FA
	pop  hl
	inc  hl
	ld   a, :Bank03
	ld   ($FFFF), a
	ld   a, (hl)
	push	hl
	call	LABEL_60FD
	pop  hl
	inc  hl
	ld   a, :Bank03
	ld   ($FFFF), a
	ld   a, (hl)
	bit  7, a
	jr   nz, LABEL_607F
	and  $0F
	ld   b, a
	ld   a, (Party_curr_num)
	inc  a
	add  a, a
	cp   b
	jr   nc, LABEL_6075
	ld   b, a
LABEL_6075:
	call	LABEL_5B1
	and  $07
	cp   b
	jp   nc, LABEL_6075
	inc  a
LABEL_607F:
	and  $0F
	ld   b, a
	ld   ($C2C7), a
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	ld   e, (hl)
	inc  hl
	push	hl
	ex   de, hl
	ld   ix, $C440
	ld   de, $0010
LABEL_6095:
	ld   (ix+0), $01
	ld   (ix+1), a
	ld   (ix+6), a
	ld   (ix+8), h
	ld   (ix+9), l
	add  ix, de
	djnz	LABEL_6095
	pop  hl
	ld   a, (hl)
	ld   ($C2DF), a
	inc  hl
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	push	hl
	ld   a, ($C2C7)
	ld   c, a
	ld   b, $00
	call	LABEL_44C
	ld   ($C2DD), hl
	pop  hl
	inc  hl
	ld   a, (hl)
	ld   ($C2E0), a
	inc  hl
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	push	hl
	ld   a, ($C2C7)
	ld   c, a
	ld   b, $00
	call	LABEL_44C
	ld   (CurrentBattle_EXPReward), hl
	pop  hl
	inc  hl
	ld   a, (hl)
	ld   ($C2E8), a
	inc  hl
	ld   a, (hl)
	ld   ($C2E7), a
	ld   hl, $C500
	ld   ($C2E1), hl
	call	LABEL_576A
	call	LABEL_576A
	ld   hl, $C240
	ld   de, $C220
	ld   bc, $0020
	ldir
	ld   a, $10
	jp   WaitForVInt

LABEL_60FD:
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   e, l
	ld   d, h
	add  hl, hl
	add  hl, de
	ld   de, LABEL_B03_8FC7-$18
	add  hl, de
	ld   de, $C880
	ld   bc, $0003
	ldir
	inc  de
	ldi
	ld   de, $C894
	ld   bc, $0009
	ldir
	ld   a, ($C898)
	ld   ($C88E), a
	ld   a, $01
	ld   ($C88D), a
	ld   c, (hl)
	inc  hl
	ld   b, (hl)
	inc  hl
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, c
	ld   c, a
	ld   a, h
	ld   h, b
	ld   b, a
	or   c
	ld   a, :Bank24
	ld   ($FFFF), a
	call	nz, LABEL_615A
	pop  hl
	inc  hl
	ld   a, :Bank03
	ld   ($FFFF), a
	ld   de, $C8A0
	ld   bc, $0003
	ldir
	inc  de
	ldi
	ld   a, (hl)
	ld   ($C2F1), a
	ret

LABEL_615A:
	push	bc
	push	de
	ld   c, $FF
LABEL_615E:
	ld   a, (hl)
	or   a
	jp   z, LABEL_6176
	ldi
	ldi
LABEL_6167:
	djnz	LABEL_615E
	pop  de
	ex   de, hl
	ld   bc, $0040
	add  hl, bc
	ex   de, hl
	pop  bc
	dec  c
	jp   nz, LABEL_615A
	ret

LABEL_6176:
	inc  hl
	inc  de
	inc  hl
	inc  de
	jp   LABEL_6167

LABEL_617D:
	or   a
	ret  z

	ld   hl, $FFFF
	ld   (hl), :Bank03
	ld   hl, $C800
	ld   de, $C801
	ld   bc, $00FF
	ld   (hl), $00
	ldir
	ld   hl, $C440
	ld   de, $C441
	ld   bc, $007F
	ld   (hl), $00
	ldir
	ld   l, a
	ld   h, $00
	add  hl, hl
	ld   de, LABEL_B03_9540
	add  hl, de
	ld   a, (hl)
	push	hl
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, LABEL_B03_95BC
	add  hl, de
	push	hl
	ld   de, $C258
	ld   bc, $0008
	ldir
	pop  hl
	ld   de, $C238
	ld   bc, $0008
	ldir
	pop  hl
	inc  hl
	ld   a, (hl)
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, LABEL_B03_966C
	add  hl, de
	ld   de, $C800
	ld   bc, $0003
	ldir
	inc  de
	ldi
	inc  hl
	ld   b, (hl)
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   a, b
	ld   ($FFFF), a
	ld   de, $6000
	call	LABEL_3FA
	call	LABEL_576A
	ld   a, $16
	jp   WaitForVInt


LABEL_61F5:
	ld hl, $FFFF
	ld (hl), :Bank28
	ld ix, $C800
	ld b, $04
-:	
	ld a, (ix+16)
	cp (ix+17)
	jp z, +
	ld (ix+17), a
	ld d, a
	ld a, (ix+1)
	or a
	ld hl, LABEL_621F-2
	jp nz, GetPtrAndJump
+:	
	ld de, $0020
	add ix, de
	djnz -
	ret


LABEL_621F:
.dw	LABEL_6229
.dw	LABEL_6246
.dw	LABEL_6263
.dw	LABEL_6280
.dw	LABEL_6293


LABEL_6229:
	ld e, $00
	srl d
	rr e
	ld l, e
	ld h, d
	srl d
	rr e
	add hl, de
	ld de, LABEL_B28_8000
	add hl, de
	ld de, $7540
	rst $08
	ld c, $BE
	call LABEL_589E
	jp LABEL_591E

LABEL_6246:
	ld e, $00
	srl d
	rr e
	ld l, e
	ld h, d
	srl d
	rr e
	add hl, de
	ld de, LABEL_B28_8A80
	add hl, de
	ld de, $7600
	rst $08
	ld c, $BE
	call LABEL_589E
	jp LABEL_591E

LABEL_6263:
	ld e, $00
	srl d
	rr e
	ld l, e
	ld h, d
	srl d
	rr e
	add hl, de
	ld de, LABEL_B28_9440
	add hl, de
	ld de, $76C0
	rst $08
	ld c, $BE
	call LABEL_589E
	jp LABEL_591E

LABEL_6280:
	ld e, $00
	srl d
	rr e
	ld hl, LABEL_B28_9EC0
	add hl, de
	ld de, $7780
	rst $08
	ld c, $BE
	jp LABEL_589E

LABEL_6293:
	ld a, (Game_mode)
	cp $05 ; GameMode_Ship
	jr z, +
	cp $09 ; GameMode_Map
	ret nz
+:	
	ld hl, $FFFF
	ld (hl), :Bank18
	ld l, $00
	ld h, d
	add hl, hl
	ld de, LABEL_B18_8000
	add hl, de
	ld de, $7540
	rst $08
	ld c, $BE
	call LABEL_589E
	call LABEL_589E
	call LABEL_589E
	jp LABEL_589E

LABEL_62BC:
	ld hl, $FFFF
	ld (hl), :Bank14
	ld hl, $C26F
	ld de, LABEL_6345
	ld bc, $0C10
	call LABEL_630A
	ld hl, $C273
	ld de, LABEL_6355
	ld bc, $0340
	call LABEL_630A
	ld hl, $C277
	ld de, LABEL_6365
	ld bc, $044C
	call LABEL_630A
	ld hl, $C27B
	ld de, LABEL_6375
	ld bc, $065C
	call LABEL_630A
	ld hl, $C27F
	ld de, LABEL_6385
	ld bc, $0874
	call LABEL_630A
	ld hl, $C283
	ld de, LABEL_6395
	ld bc, $1094
	call LABEL_630A
	ret

LABEL_630A:	
	ld a, (hl)
	or a
	ret z
	inc hl
	ld a, (hl)
	inc hl
	dec (hl)
	ret p
	ld (hl), a
	inc hl
	ld a, ($C2E9)
	cp $04
	jr c, +
	dec (hl)
	jr ++

+:	
	inc (hl)
++:	
	ld a, (hl)
	and $07
	ld l, a
	ld h, $00
	add hl, hl
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ex de, hl
	ld l, c
	ld h, $08
	add hl, hl
	add hl, hl
	add hl, hl
	ex de, hl
	rst $08
	ld c, $BE
	ld a, b
--:	
	ld b, $20
-:	
	outi
	nop
	jp nz, -
	dec a
	jp nz, --
	pop hl
	ret


LABEL_6345:
.dw	LABEL_B14_A3E8
.dw	LABEL_B14_A3E8
.dw	LABEL_B14_A568
.dw	LABEL_B14_A6E8
.dw	LABEL_B14_A6E8
.dw	LABEL_B14_A568
.dw	LABEL_B14_A868
.dw	LABEL_B14_A9E8
	

LABEL_6355:	
.dw	LABEL_B14_AB68
.dw	LABEL_B14_AB68
.dw	LABEL_B14_ABC8
.dw	LABEL_B14_ABC8
.dw	LABEL_B14_AC28
.dw	LABEL_B14_AC28
.dw	LABEL_B14_AC88
.dw	LABEL_B14_AC88
	

LABEL_6365:	
.dw	LABEL_B14_BAE8
.dw	LABEL_B14_BAE8
.dw	LABEL_B14_BB68
.dw	LABEL_B14_BB68
.dw	LABEL_B14_BBE8
.dw	LABEL_B14_BBE8
.dw	LABEL_B14_BB68
.dw	LABEL_B14_BB68
	

LABEL_6375:	
.dw	LABEL_B14_ACE8
.dw	LABEL_B14_ACE8
.dw	LABEL_B14_ADA8
.dw	LABEL_B14_ADA8
.dw	LABEL_B14_AE68
.dw	LABEL_B14_AE68
.dw	LABEL_B14_AF28
.dw	LABEL_B14_AF28
	

LABEL_6385:	
.dw	LABEL_B14_AFE8
.dw	LABEL_B14_AFE8
.dw	LABEL_B14_B0E8
.dw	LABEL_B14_B0E8
.dw	LABEL_B14_B1E8
.dw	LABEL_B14_B1E8
.dw	LABEL_B14_B0E8
.dw	LABEL_B14_B0E8
	

LABEL_6395:	
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B6E8
.dw	LABEL_B14_B8E8
.dw	LABEL_B14_B2E8


LABEL_63A5:
	ld a, ($C2D6)
	or a
	ret z
	ld a, ($C29E)
	or a
	ret z
	cp $0C
	ret nc
	ld hl, LABEL_63B8-2
	jp GetPtrAndJump


LABEL_63B8:
.dw	LABEL_63CE
.dw	LABEL_63CE
.dw	LABEL_63CF
.dw	LABEL_63F6
.dw	LABEL_63CE
.dw	LABEL_63CE
.dw	LABEL_6442
.dw	LABEL_63CE
.dw	LABEL_63CE
.dw	LABEL_63CE
.dw	LABEL_64CF

LABEL_63CE:
	ret

LABEL_63CF:
	call LABEL_64A3
	ld hl, $C2BC
	dec (hl)
	ret p
	ld (hl), $0B
	inc hl
	ld a, (hl)
	inc a
	cp $09
	jr c, +
	xor a
+:	
	ld (hl), a
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, LABEL_6506
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld b, $04
	jp LABEL_641B

LABEL_63F6:
	call LABEL_64A3
	ld hl, $C2BC
	dec (hl)
	ret p
	ld (hl), $0F
	inc hl
	ld a, (hl)
	inc a
	cp $0E
	jr c, +
	xor a
+:	
	ld (hl), a
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, LABEL_654E
	add a, a
	ld e, a
	add a, a
	add a, e
	ld e, a
	ld d, $00
	add hl, de
	ld b, $03

LABEL_641B:	
	push bc
	ld e, (hl)
	ld d, $02
	ex de, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ex de, hl
	rst $08
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ld e, $00
	srl d
	rr e
	ld hl, LABEL_B16_A8F6
	add hl, de
	ld bc, $8000|Port_VDPData
-:	
	outi
	jp nz, -
	pop hl
	pop bc
	djnz LABEL_641B
	ret

LABEL_6442:
	ld hl, $C2BC
	dec (hl)
	ret p
	ld (hl), $0F
	inc hl
	ld a, (hl)
	inc a
	cp $06
	jr c, +
	xor a
+:	
	ld (hl), a
	ld hl, $FFFF
	ld (hl), :Bank17
	add a, a
	ld b, a
	add a, a
	add a, b
	ld e, a
	ld d, $00
	ld hl, LABEL_65A2
	add hl, de
	ld de, $4020
	rst $08
	ld b, $04
--:	
	push bc
	ld d, (hl)
	inc hl
	ld e, $00
	srl d
	rr e
	ld bc, LABEL_B17_8000
	ex de, hl
	add hl, bc
	ld bc, $8000|Port_VDPData
-:	
	outi
	jp nz, -
	pop bc
	ex de, hl
	djnz --
	ld b, $02
--:	
	push bc
	ld d, (hl)
	inc hl
	ld e, $00
	srl d
	rr e
	srl d
	rr e
	ld bc, LABEL_B17_8000
	ex de, hl
	add hl, bc
	ld bc, $4000|Port_VDPData
-:	
	outi
	jp nz, -
	pop bc
	ex de, hl
	djnz --
	ret

LABEL_64A3:
	ld a, (Fade_timer)
	or a
	ret nz
	ld a, (Game_mode)
	cp $0D ; GameMode_Interaction
	ret nz
	ld hl, $C213
	dec (hl)
	ret p
	ld (hl), $1F
	ld de, $C00D
	rst $08
	inc hl
	ld a, (hl)
	inc a
	and $03
	ld (hl), a
	ld e, a
	ld d, $00
	ld hl, LABEL_65C6
	add hl, de
	ld bc, $0300|Port_VDPData
-:	
	outi
	jp nz, -
	ret

LABEL_64CF:
	ld a, (Fade_timer)
	or a
	ret nz
	ld a, (Game_mode)
	cp $0D ; GameMode_Interaction
	ret nz
	ld hl, $C213
	dec (hl)
	ret p
	ld (hl), $07
	ld de, $C008
	rst $08
	inc hl
	ld a, (hl)
	dec a
	and $0F
	ld (hl), a
	ld e, a
	ld d, $00
	ld hl, LABEL_65CE
	add hl, de
	ld bc, $0400|Port_VDPData
-:	
	outi
	jp nz, -
	ld hl, LABEL_65D6
	add hl, de
	ld b, $04
-:	
	outi
	jp nz, -
	ret


LABEL_6506:	
.db	$01, $15, $25, $09, $29, $0A, $29, $0A, $01, $00, $05, $0B, $01, $00, $05, $0B
.db	$05, $01, $09, $0D, $05, $01, $09, $0D, $09, $02, $0D, $0D, $09, $02, $0D, $0D
.db $0D, $03, $11, $0E, $0D, $03, $11, $0E, $11, $04, $15, $0E, $11, $04, $15, $0E
.db $15, $05, $19, $0F, $15, $05, $19, $0F, $19, $06, $21, $0F, $19, $06, $21, $0F
.db	$21, $08, $01, $10, $25, $0C, $29, $11
	

LABEL_654E:	
.db	$25, $09, $29, $0A, $29, $0A, $25, $09, $29, $0A, $29, $0A, $25, $09, $29, $0C
.db	$29, $0C, $21, $08, $25, $0F, $29, $14, $21, $0F, $25, $13, $29, $14, $19, $06
.db	$1D, $0F, $21, $12, $15, $05, $19, $0E, $1D, $12, $15, $0E, $19, $12, $19, $12
.db	$15, $0E, $19, $12, $19, $12, $15, $05, $19, $0E, $1D, $12, $19, $06, $1D, $0F
.db	$21, $12, $1D, $07, $21, $0F, $25, $13, $21, $08, $25, $0C, $29, $11, $25, $09
.db	$29, $0C, $29, $0C
	
LABEL_65A2:	
.db	$00, $02, $05, $08, $15, $18, $00, $03, $06, $09, $16, $14, $01, $04, $07, $05
.db	$17, $14, $02, $00, $08, $05, $18, $15, $03, $00, $09, $06, $14, $16, $04, $01
.db	$05, $07, $14, $17
	

LABEL_65C6:	
.db	$3F, $3C, $38, $38, $3F, $3C, $38, $38


LABEL_65CE:	
.db	$06, $06, $06, $06, $06, $06, $06, $06
	

LABEL_65D6:	
.db	$06, $06, $06, $06, $25, $2A, $3E, $3F, $06, $06, $06, $06, $06, $06, $06, $06
.db	$06, $06, $06, $06, $06, $06, $06, $06


LABEL_65EE:
	ld   a, (Dungeon_position)
	ld   l, a
	ld   h, $CB
	ld   a, (hl)
	cp   $08
	jp   nz, LABEL_66E1
	ld   c, l
	ld   a, (Dungeon_index)
	ld   b, a
	ld   hl, $FFFF
	ld   (hl), :Bank03
	ld   hl, LABEL_B03_AF5C
	ld   de, $0006
LABEL_660A:
	ld   a, (hl)
	cp   $FF
	jr   z, LABEL_661C
	inc  hl
	cp   b
	jr   nz, LABEL_6618
	ld   a, (hl)
	cp   c
	jp   z, LABEL_66E1
LABEL_6618:
	add  hl, de
	jp   LABEL_660A

LABEL_661C:
	ld   de, $7E00
	ld   hl, $00C0
	ld   bc, $0080
	di
	call	LABEL_363
	ei
	ld   a, $C0
	ld   ($C004), a
	xor  a
	ld   ($C304), a
	ld   b, $0C
LABEL_6635:
	push	bc
	ld   a, ($C304)
	add  a, $10
	ld   ($C304), a
	ld   a, $08
	call	WaitForVInt
	ld   a, b
	sub  $0C
	neg
	ld   c, $00
	ld   b, a
	srl  b
	rr   c
	ld   hl, $7800
	add  hl, bc
	ex   de, hl
	ld   hl, $00C0
	ld   bc, $0040
	di
	call	LABEL_363
	ei
	pop  bc
	djnz	LABEL_6635
	ld   a, (Dungeon_index)
	sub  $01
	jr   nc, LABEL_666A
	xor  a
LABEL_666A:
	ld   (Dungeon_index), a
	call	LABEL_6D56
	xor  a
	call	LABEL_6AED
	ld   hl, $C240
	ld   de, $C220
	ld   bc, $0020
	ldir
	ld   a, $16
	call	WaitForVInt
	ld   a, $10
	ld   ($C304), a
	ld   b, $0C
LABEL_668B:
	push	bc
	ld   a, ($C304)
	add  a, $10
	ld   ($C304), a
	ld   a, $08
	call	WaitForVInt
	ld   a, b
	sub  $0C
	neg
	ld   c, $00
	ld   b, a
	srl  b
	rr   c
	ld   hl, $7800
	add  hl, bc
	ex   de, hl
	ld   hl, $D000
	add  hl, bc
	ld   bc, $0080
	di
	call	LABEL_346
	ei
	pop  bc
	djnz	LABEL_668B
	ld   b, $05
LABEL_66BB:
	ld   a, ($C304)
	or   a
	ld   a, $D8
	jr   z, LABEL_66C4
	xor  a
LABEL_66C4:
	ld   ($C304), a
	ld   a, $08
	call	WaitForVInt
	djnz	LABEL_66BB
	ld   hl, $FFFF
	ld   (hl), :Bank16
	ld   hl, LABEL_B16_BD58
	ld   de, $7E00
	call	LABEL_3FA
	ld   b, $01
	jp   LABEL_6963

LABEL_66E1:
	ld   a, (Ctrl_1_held)
	and  ButtonUp_Mask|ButtonDown_Mask|ButtonLeft_Mask|ButtonRight_Mask
	jp   z, LABEL_6802
	ld   c, a
	bit  0, c
	jp   z, LABEL_677A
	ld   b, $01
	call	LABEL_6BE9
	ld   b, a
	and  $07
	jp   z, LABEL_6758
	sub  $02
	jp   c, LABEL_677A
	cp   $05
	jp   z, LABEL_6755
	cp   $02
	jp   nc, LABEL_6729
	ld   c, a
	ld   a, $C3
	ld   ($C004), a
	ld   a, c
	bit  3, b
	jp   nz, LABEL_68BC
	or   a
	ld   b, $01
	jr   z, LABEL_671C
	ld   b, $FF
LABEL_671C:
	ld   a, (Dungeon_index)
	add  a, b
	ld   (Dungeon_index), a
	call	LABEL_6D56
	jp   LABEL_6731

LABEL_6729:
	bit  7, (hl)
	ret  z

	bit  3, b
	jp   nz, LABEL_68BC
LABEL_6731:
	call	FadeOut2
	ld   a, (Dungeon_direction)
	and  $03
	ld   hl, $6ADF
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, (Dungeon_position)
	add  a, (hl)
	add  a, (hl)
	ld   (Dungeon_position), a
	xor  a
	call	LABEL_6AE5
	call	FadeIn2
	ld	b, $01
	jp	LABEL_6963

LABEL_6755:
	call	LABEL_6758
LABEL_6758:
	ld   a, $00
	call	LABEL_6A58
	ld   a, (Dungeon_direction)
	and  $03
	ld   hl, LABEL_6AE1-2
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, (Dungeon_position)
	add  a, (hl)
	ld   (Dungeon_position), a
	xor  a
	call	LABEL_6AE5
	ld	b, $01
	jp	LABEL_6963

LABEL_677A:
	bit  1, c
	jr   z, LABEL_67AB
	ld   b, $0B
	call	LABEL_6BCA
	jr   nz, LABEL_67AB
	call	LABEL_6792
	ld	b, $01
	call	LABEL_6963
	ld	b, $0B
	jp	LABEL_6963

LABEL_6792:
	ld   a, (Dungeon_direction)
	and  $03
	ld   hl, LABEL_6AE1
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, (Dungeon_position)
	add  a, (hl)
	ld   (Dungeon_position), a
	ld   a, $01
	jp   LABEL_6A58

LABEL_67AB:
	bit  2, c
	jr   z, LABEL_67D7
	call	LABEL_67B7
	ld	b, $01
	jp	LABEL_6963

LABEL_67B7:
	ld   a, (Dungeon_direction)
	dec  a
	and  $03
	ld   (Dungeon_direction), a
	ld   h, $02
	ld   b, $0D
	call	LABEL_6BCA
	jr   z, LABEL_67CB
	inc  h
	inc  h
LABEL_67CB:
	ld   b, $01
	call	LABEL_6BCA
	jr   z, LABEL_67D3
	inc  h
LABEL_67D3:
	ld   a, h
	jp   LABEL_6A58

LABEL_67D7:
	bit  3, c
	ret  z
	call	LABEL_67E2
	ld	b, $01
	jp	LABEL_6963

LABEL_67E2:
	ld   a, (Dungeon_direction)
	inc  a
	and  $03
	ld   (Dungeon_direction), a
	ld   h, $06
	ld   b, $0C
	call	LABEL_6BCA
	jr   z, LABEL_67F6
	inc  h
	inc  h
LABEL_67F6:
	ld   b, $01
	call	LABEL_6BCA
	jr   z, LABEL_67FE
	inc  h
LABEL_67FE:
	ld   a, h
	jp   LABEL_6A58

LABEL_6802:
	ld   a, (Ctrl_1_pressed)
	and  Button_1_Mask|Button_2_Mask
	ret  z

	ld   b, $01
	call	LABEL_6BCA
	cp   $04
	jr   nz, LABEL_6817
	ld   c, $02
	call	LABEL_681B
	ret  z

LABEL_6817:
	call	LABEL_1BE1
	ret

LABEL_681B:
	ld   b, $01
	call	LABEL_6BE9
	bit  7, (hl)
	ret  nz

	set  7, (hl)
	ld   a, $BD
	ld   ($C004), a
	ld   h, c
	ld   l, $00
	ld   b, $03
LABEL_682F:
	push	bc
LABEL_6830:
	push	hl
	ld   a, h
	call	LABEL_6E4C
	ld   a, $0C
	call	WaitForVInt
	pop  hl
	ld   a, h
	ld   bc, $0040
	add  hl, bc
	cp   h
	jr   z, LABEL_6830
	inc  h
	inc  h
	pop  bc
	djnz	LABEL_682F
	xor  a
	ret


LABEL_684A:
	ld b, $01
	call LABEL_6BE9
	cp $08
	jr nz, ++
	ld c, l
	ld a, (Dungeon_index)
	ld b, a
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, LABEL_B03_AF5C
	ld de, $0006
-:	
	ld a, (hl)
	cp $FF
	jr z, +++
	inc hl
	cp b
	jr nz, +
	ld a, (hl)
	cp c
	jr z, ++
+:	
	add hl, de
	jp -

++:	
	xor a
	ret

+++:	
	ld a, $FF
	or a
	ret

LABEL_687A:
	ld b, $0B
	call LABEL_6BCA
	ret z
	ld b, $0C
	call LABEL_6BCA
	ret z
	ld b, $0D
	call LABEL_6BCA
	ret

LABEL_688C:
	ld b, $0B
	call LABEL_6BCA
	jr z, +++
	ld b, $0C
	call LABEL_6BCA
	jr nz, ++
	ld b, $0D
	call LABEL_6BCA
	jr nz, +
	call LABEL_5B1
	rrca
	jr nc, ++
+:	
	call LABEL_67E2
	jr +++

++:	
	call LABEL_67B7
+++:	
	call LABEL_6792
	ld b, $01
	call LABEL_6963
	ld b, $0B
	jp LABEL_6963

LABEL_68BC:
	ld   b, $01
	call	LABEL_6BE9
	and  $08
	ret  z

	ld   c, l
	ld   a, (Dungeon_index)
	ld   b, a
	ld   hl, $FFFF
	ld   (hl), :Bank03
	ld   hl, LABEL_B03_B473
	ld   de, $0004
LABEL_68D4:
	ld   a, (hl)
	cp   $FF
	jr   z, LABEL_68E6
	inc  hl
	cp   b
	jr   nz, LABEL_68E1
	ld   a, (hl)
	cp   c
	jr   z, LABEL_68EC
LABEL_68E1:
	add  hl, de
	jp   LABEL_68D4

	
	ret


LABEL_68E6:
	ld   hl, Game_mode
	ld   (hl), $08 ; GameMode_LoadMap
	ret

LABEL_68EC:
	inc  hl
	ld   a, (hl)
	ld   d, a
	dec  hl
	cp   $80
	ld   a, $08
	jp   c, LABEL_7877
	ld   a, d
	cp   $FF
	jr   nz, LABEL_6947
	push	hl
	call	FadeOut2
	ld   hl, $FFFF
	ld   (hl), :Bank09
	ld   hl, LABEL_B09_B471
	ld   de, $4000
	call	LABEL_3FA
	ld   hl, LABEL_B09_B130
	call	LABEL_6B62
	ld   a, $0F
	ld   ($C29E), a
	xor  a
	ld   ($C250), a
LABEL_691D:
	ld   a, $0C
	call	WaitForVInt
	call	FadeIn2
LABEL_6925:
	ld   hl, $FFFF
	ld   (hl), :Bank03
	pop  hl
	inc  hl
	inc  hl
	call	LABEL_6A2F
	ld   a, (Game_mode)
	cp   $0B ; GameMode_Dungeon
	ret  nz

	call	FadeOut2
	xor  a
	call	LABEL_6AE5
	call	LABEL_6D7F
	call	LABEL_6DE2
	call	FadeIn2
	ret

LABEL_6947:
	push	hl
	push	af
	call	FadeOut2
	pop  af
	ld   c, $0D
	cp   $FE
	jr   z, LABEL_6959
	ld   c, $1E
	cp   $FD
	jr   nz, LABEL_6925
LABEL_6959:
	ld   a, c
	ld   ($C29E), a
	call	LABEL_3D47
	jp   LABEL_691D

LABEL_6963:
	call	LABEL_6BE9
	cp   $08
	ret  nz

	ld   c, l
	push	bc
	ld   a, (Dungeon_index)
	ld   b, a
	ld   hl, $FFFF
	ld   (hl), :Bank03
	ld   hl, LABEL_B03_AF5C
	ld   de, $0006
LABEL_697A:
	ld   a, (hl)
	cp   $FF
	jp   z, LABEL_698C
	inc  hl
	cp   b
	jr   nz, LABEL_6988
	ld   a, (hl)
	cp   c
	jr   z, LABEL_698E
LABEL_6988:
	add  hl, de
	jp   LABEL_697A

LABEL_698C:
	pop  bc
	ret

LABEL_698E:
	pop  bc
	inc  hl
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	ld   a, (de)
	cp   $FF
	ret  z

	ld   ($C2E1), de
	ld   a, $FF
	ld   ($C2D2), a
	inc  hl
	ld   a, (hl)
	inc  hl
	or   a
	jr   nz, LABEL_69B8
	ld   a, (hl)
	ld   ($C2DF), a
	inc  hl
	ld   a, (hl)
	ld   ($C2E0), a
	ld   hl, $0000
	ld   ($C2DD), hl
	jp   LABEL_69C7

LABEL_69B8:
	cp   $01
	jr   nz, LABEL_69E1
	xor  a
	ld   ($C2DF), a
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   ($C2DD), hl
LABEL_69C7:
	ld   a, b
	cp   $01
	ret  nz

	ld   hl, LABEL_B12_BD97
	call	ShowDialogue_B12
	push	bc
	call	LABEL_16B2
	pop  bc
	call	LABEL_28DB
	ld	a, ($C800)
	or	a
	ret	z
	jp	LABEL_1BE1

LABEL_69E1:
	cp   $02
	jr   nz, LABEL_6A1A
	ld   a, b
	cp   $01
	jr   z, LABEL_69F7
	push	hl
	call	LABEL_67B7
	call	LABEL_67B7
	ld   hl, $FFFF
	ld   (hl), :Bank03
	pop  hl
LABEL_69F7:
	ld   a, (hl)
	ld   ($C2E6), a
	or   a
	ret  z

	inc  hl
	ld   a, (hl)
	push	af
	ld   hl, ($C2E1)
	push	hl
	call	LABEL_5FFE
	pop  hl
	ld   ($C2E1), hl
	pop  af
	ld   ($C2DF), a
	call	LABEL_100F
	ld   a, ($C800)
	or   a
	ret  z

	jp   LABEL_1BE1

LABEL_6A1A:
	cp   $03
	ret  nz

	ld   a, b
	cp   $01
	jr   z, LABEL_6A2F
	push	hl
	call	LABEL_67E2
	call	LABEL_67E2
	ld   hl, $FFFF
	ld   (hl), :Bank03
	pop  hl
LABEL_6A2F:
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   ($C2DB), hl
	ld   a, ($C2DC)
	call	LABEL_617D
	call	LABEL_474B
	ld   a, $D0
	ld   ($C900), a
	xor  a
	ld   ($C800), a
	ld   ($C29D), a
	ld   ($C29E), a
	ld   ($C2D5), a
	ld   hl, $0000
	ld   ($C2DB), hl
	ret

LABEL_6A58:
	ld   l, a
	ld   h, $00
	add  hl, hl
	ld   de, LABEL_6A76
	add  hl, de
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   a, $FF
	ld   ($C2D2), a
	
-:
	ld   a, (hl)
	cp   $FF
	ret  z
	push	hl
	call	LABEL_6AE5
	pop	hl
	inc	hl
	jp	-

LABEL_6A76:
.db	$8A, $6A, $90, $6A, $97, $6A, $A0, $6A, $A9, $6A, $B2
.db $6A, $BB, $6A, $C4, $6A, $CD, $6A, $D6, $6A, $01, $02, $03, $04, $05, $FF, $05
.db $04, $03, $02, $01, $00, $FF, $07, $08, $09, $0A, $0B, $0C, $0D, $00, $FF, $17
.db $18, $19, $1A, $1B, $1C, $1D, $00, $FF, $1F, $20, $21, $22, $23, $24, $25, $00
.db $FF, $0F, $10, $11, $12, $13, $14, $15, $00, $FF, $0D, $0C, $0B, $0A, $09, $08
.db $07, $00, $FF, $25, $24, $23, $22, $21, $20, $1F, $00, $FF, $1D, $1C, $1B, $1A
.db $19, $18, $17, $00, $FF, $15, $14, $13, $12, $11, $10, $0F, $00, $FF, $F0, $01

LABEL_6AE1:
.db $10, $FF, $F0, $01

LABEL_6AE5:
	call	LABEL_6AED
	ld   a, $0C
	jp   WaitForVInt

LABEL_6AED:
	and  $3F
	jr   nz, LABEL_6AFC
	ld   b, $01
	call	LABEL_6BCA
	ld   a, $00
	jr   z, LABEL_6AFC
	ld   a, $06
LABEL_6AFC:
	ld   c, a
	add  a, a
	ld   b, a
	add  a, a
	add  a, b
	ld   hl, LABEL_7060-1
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	push	bc
	ld   a, (hl)
	ld   ($FFFF), a
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	rr   c
	ld   d, $40
	jr   nc, LABEL_6B1C
	ld   d, $60
LABEL_6B1C:
	di
	xor  a
	out  (Port_VDPAddress), a
	ld   a, d
	out  (Port_VDPAddress), a
	ei
	call	LABEL_6B8E
	pop  hl
	inc  hl
	ld   a, (hl)
	ld   ($FFFF), a
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	call	LABEL_6B62
	pop  bc
	call	LABEL_6C46
	ret

LABEL_6B3A:
	ld   b, $01
	call	LABEL_6BCA
	ld   a, $00
	jr   z, LABEL_6B45
	ld   a, $06
LABEL_6B45:
	ld   c, a
	add  a, a
	ld   e, a
	add  a, a
	add  a, e
	ld   e, a
	ld   d, $00
	ld   hl, LABEL_7062
	add  hl, de
	push	bc
	ld   a, (hl)
	ld   ($FFFF), a
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	call	LABEL_6B62
	pop  bc
	jp   LABEL_6C46

LABEL_6B62:
	ld   b, $00
	ld   de, $D000
	call	LABEL_6B6E
	inc  hl
	ld   de, $D001
LABEL_6B6E:
	ld   a, (hl)
	or   a
	ret  z

	jp   m, LABEL_6B81
	ld   c, a
	inc  hl
LABEL_6B76:
	ldi
	dec  hl
	inc  de
	jp   pe, LABEL_6B76
	inc  hl
	jp   LABEL_6B6E

LABEL_6B81:
	and  $7F
	ld   c, a
	inc  hl
LABEL_6B85:
	ldi
	inc  de
	jp   pe, LABEL_6B85
	jp   LABEL_6B6E

LABEL_6B8E:
	ld   c, $BE
LABEL_6B90:
	ld   a, (hl)
	or   a
	ret  z

	jp   m, LABEL_6BB1
	ld   b, a
	inc  hl
LABEL_6B98:
	ld   a, (hl)
	outi
	inc  b
	or   (hl)
	outi
	inc  b
	or   (hl)
	outi
	dec  hl
	dec  hl
	dec  hl
	out  (Port_VDPData), a
	jp   nz, LABEL_6B98
	inc  hl
	inc  hl
	inc  hl
	jp   LABEL_6B90

LABEL_6BB1:
	and  $7F
	ld   b, a
	inc  hl
LABEL_6BB5:
	ld   a, (hl)
	outi
	inc  b
	or   (hl)
	outi
	inc  b
	or   (hl)
	outi
	push	af
	pop  af
	out  (Port_VDPData), a
	jp   nz, LABEL_6BB5
	jp   LABEL_6B90

LABEL_6BCA:
	push	hl
	ld   a, (Dungeon_direction)
	and  $03
	add  a, a
	add  a, a
	add  a, a
	add  a, a
	ld   e, a
	ld   d, $00
	ld   hl, LABEL_6C06
	add  hl, de
	ld   e, b
	add  hl, de
	ld   a, (Dungeon_position)
	add  a, (hl)
	ld   h, $CB
	ld   l, a
	ld   a, (hl)
	and  $07
	pop  hl
	ret

LABEL_6BE9:
	ld   a, (Dungeon_direction)
	and  $03
	add  a, a
	add  a, a
	add  a, a
	add  a, a
	ld   e, a
	ld   d, $00
	ld   hl, LABEL_6C06
	add  hl, de
	ld   e, b
	add  hl, de
	ld   a, (Dungeon_position)
	add  a, (hl)
	ld   h, $CB
	ld   l, a
	ld   a, (hl)
	and  $7F
	ret


LABEL_6C06:
.db $00, $F0, $EF, $F1, $E0, $DF, $E1, $D0, $CF, $D1, $C0, $10, $FF, $01, $00, $00
.db $00, $01, $F1, $11, $02, $F2, $12, $03, $F3, $13, $04, $FF, $F0, $10, $00, $00
.db $00, $10, $11, $0F, $20, $21, $1F, $30, $31, $2F, $40, $F0, $01, $FF, $00, $00
.db $00, $FF, $0F, $EF, $FE, $0E, $EE, $FD, $0D, $ED, $FC, $01, $10, $F0, $00, $00

LABEL_6C46:
	ld   a, c
	cp   $06
	jp   z, LABEL_6E38
	ret  nc

	ld   hl, $FFFF
	ld   (hl), :Bank06
	add  a, a
	ld   l, a
	add  a, a
	add  a, a
	ld   h, a
	add  a, a
	add  a, h
	add  a, l
	ld   l, a
	ld   h, $00
	ld   e, l
	ld   d, h
	add  hl, hl
	add  hl, de
	ld   de, LABEL_6E8B
	add  hl, de
	ld   b, $04
	call	LABEL_6BCA
	jr   z, LABEL_6C85
	call	LABEL_6D13
	ld   b, $02
	call	LABEL_6BCA
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	push	bc
	call	LABEL_6D34
	ld   b, $03
	call	LABEL_6BCA
	pop  bc
	jp   LABEL_6D34

LABEL_6C85:
	ld   de, $000C
	add  hl, de
	ld   b, $02
	call	LABEL_6BCA
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	push	bc
	call	LABEL_6D45
	ld   b, $03
	call	LABEL_6BCA
	pop  bc
	call	LABEL_6D45
	ld   b, $07
	call	LABEL_6BCA
	jr   z, LABEL_6CBF
	call	LABEL_6D13
	ld   b, $05
	call	LABEL_6BCA
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	push	bc
	call	LABEL_6D34
	ld   b, $06
	call	LABEL_6BCA
	pop  bc
	jp   LABEL_6D34

LABEL_6CBF:
	ld   de, $000C
	add  hl, de
	ld   b, $05
	call	LABEL_6BCA
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	push	bc
	call	LABEL_6D45
	ld   b, $06
	call	LABEL_6BCA
	pop  bc
	call	LABEL_6D45
	ld   b, $0A
	call	LABEL_6BCA
	jr   z, LABEL_6CF9
	call	LABEL_6D13
	ld   b, $08
	call	LABEL_6BCA
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	push	bc
	call	LABEL_6D34
	ld   b, $09
	call	LABEL_6BCA
	pop  bc
	jp   LABEL_6D34

LABEL_6CF9:
	ld   de, $000C
	add  hl, de
	ld   b, $08
	call	LABEL_6BCA
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	push	bc
	call	LABEL_6D45
	ld   b, $09
	call	LABEL_6BCA
	pop  bc
	jp   LABEL_6D45

LABEL_6D13:
	push	af
	call	LABEL_6D21
	pop  af
	cp   $07
	jr   z, LABEL_6D21
	cp   $01
	jr   nc, LABEL_6D21
	xor  a
LABEL_6D21:
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	ld   b, (hl)
	inc  hl
	ld   c, (hl)
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	call	nz, LABEL_6E64
	pop  hl
	inc  hl
	ret

LABEL_6D34:
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	inc  hl
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	call	z, LABEL_6E64
	pop  hl
	inc  hl
	ret

LABEL_6D45:
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	ld   a, (hl)
	inc  hl
	push	hl
	ld   h, (hl)
	ld   l, a
	call	z, LABEL_6E64
	pop  hl
	inc  hl
	inc  hl
	inc  hl
	ret

LABEL_6D56:
	ld   hl, $FFFF
	ld   (hl), :Bank15
	ld   a, (Dungeon_index)
	ld   h, a
	ld   l, $00
	srl  h
	rr   l
	ld   de, B15_DungeonLayouts
	add  hl, de
	ld   de, Dungeon_layout
	ld   b, $80
LABEL_6D6E:
	ld   a, (hl)
	rrca
	rrca
	rrca
	rrca
	and  $0F
	ld   (de), a
	inc  de
	ld   a, (hl)
	and  $0F
	ld   (de), a
	inc  de
	inc  hl
	djnz	LABEL_6D6E
	
LABEL_6D7F:
	ld   hl, $FFFF
	ld   (hl), :Bank03
	ld   hl, LABEL_6DF7
	ld   de, $C251
	ld   bc, $0007
	ldir
	ld   a, (Dungeon_index)
	add  a, a
	add  a, a
	ld   l, a
	ld   h, $00
	ld   de, LABEL_B03_B619
	add  hl, de
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	ld   ($C2E3), de
	inc  hl
	ld   a, ($C315)
	or   a
	ld   a, (hl)
	jr   nz, LABEL_6DBB
	ld   e, a
	ld   a, (Dungeon_index)
	ld   hl, LABEL_6DFE
	ld   bc, $0006
	cpir
	ld   a, e
	jr   z, LABEL_6DBB
	ld   a, $FF
LABEL_6DBB:
	inc  a
	ld   ($C315), a
	add  a, a
	add  a, a
	add  a, a
	ld   l, a
	ld   h, $00
	ld   de, LABEL_B03_B5B9
	add  hl, de
	ld   a, (hl)
	ld   ($C240), a
	ld   de, $C248
	ld   bc, $0008
	ldir
	ld   a, ($C249)
	ld   ($C248), a
	ld   a, ($C24D)
	ld   ($C250), a
	ret


LABEL_6DE2:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld a, (Dungeon_index)
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld de, LABEL_B03_B61C
	add hl, de
	ld a, (hl)
	jp LABEL_C97

LABEL_6DF7:
.db	$00, $3F, $30, $38, $03, $0B, $0F

LABEL_6DFE:
.db	$01, $02, $14, $15, $16, $21

LABEL_6E04:
	ld   a, ($C2F5)
	or   a
	ret  z

	inc  a
	ld   ($C2F5), a
	ld   hl, $FFFF
	ld   (hl), :Bank20
	ld   h, $00
	ld   l, a
	add  hl, hl
	ld   de, LABEL_B20_BDB8
	add  hl, de
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   b, (hl)
	inc  hl
LABEL_6E20:
	push	bc
	ld   e, (hl)
	inc  hl
	ld   d, (hl)
	inc  hl
	ld   b, (hl)
	inc  hl
LABEL_6E27:
	ld   a, (hl)
	add  a, $80
	cp   $C0
	jr   c, LABEL_6E2F
	ld   (de), a
LABEL_6E2F:
	inc  de
	inc  de
	inc  hl
	djnz	LABEL_6E27
	pop  bc
	djnz	LABEL_6E20
	ret

LABEL_6E38:
	ld   b, $01
	call	LABEL_6BE9
	and  $07
	cp   $07
	jr   z, LABEL_6E04
	sub  $02
	ret  c

	bit  7, (hl)
	jr   z, LABEL_6E4C
	add  a, $06
LABEL_6E4C:
	ld   hl, $FFFF
	ld   (hl), :Bank06
	add  a, a
	ld   hl, LABEL_6E75
	add  a, l
	ld   l, a
	adc  a, h
	sub  l
	ld   h, a
	ld   a, (hl)
	inc  hl
	ld   h, (hl)
	ld   l, a
	ld   de, $D114
	ld   bc, $1218
LABEL_6E64:
	push	bc
	push	de
	ld   b, $00
	ldir
	ex   de, hl
	pop  hl
	ld   bc, $0040
	add  hl, bc
	ex   de, hl
	pop  bc
	djnz	LABEL_6E64
	ret


LABEL_6E75:
.dw	LABEL_B06_AC50
.dw	LABEL_B06_AE00
.dw	LABEL_B06_AFB0
.dw	LABEL_B06_B160
.dw	LABEL_B06_B670
.dw	LABEL_B06_B310
.dw	LABEL_B06_B310
.dw	LABEL_B06_B820
.dw	LABEL_B06_B4C0
.dw	LABEL_B06_B4C0
.dw	LABEL_B06_B9D0

LABEL_6E8B:
.db	$D4, $D1
.db $08, $18, $90, $80, $1C, $D2, $07, $08
.db $F4, $82, $0C, $06, $50, $D1, $A0, $81
.db $30, $82, $6A, $D1, $E8, $81, $78, $82
.db $18, $D2, $06, $10, $30, $80, $5C, $D2
.db $05, $08, $CC, $82, $06, $02, $18, $D2
.db $70, $81, $88, $81, $26, $D2, $7C, $81
.db $94, $81, $5A, $D2, $04, $0C, $00, $80
.db $9E, $D2, $03, $04, $C0, $82, $04, $02
.db $5A, $D2, $50, $81, $60, $81, $64, $D2
.db $58, $81, $68, $81, $94, $D1, $0A, $18
.db $BC, $83, $1A, $D2, $08, $0C, $B0, $87
.db $0E, $0A, $0C, $D1, $4C, $85, $64, $86
.db $2A, $D1, $D8, $85, $F0, $86, $18, $D2
.db $06, $10, $5C, $83, $5C, $D2, $05, $08
.db $88, $87, $08, $04, $D6, $D1, $CC, $84
.db $0C, $85, $E6, $D1, $EC, $84, $2C, $85
.db $5A, $D2, $04, $0C, $2C, $83, $9E, $D2
.db $03, $04, $7C, $87, $04, $02, $5A, $D2
.db $AC, $84, $BC, $84, $64, $D2, $B4, $84
.db $C4, $84, $92, $D1, $0A, $1C, $A0, $88
.db $1A, $D2, $08, $0C, $EC, $8D, $12, $0C
.db $88, $D0, $58, $8A, $08, $8C, $AC, $D0
.db $30, $8B, $E0, $8C, $18, $D2, $06, $10
.db $40, $88, $5C, $D2, $05, $08, $C4, $8D
.db $08, $04, $D6, $D1, $D8, $89, $18, $8A
.db $E6, $D1, $F8, $89, $38, $8A, $5A, $D2
.db $04, $0C, $10, $88, $9E, $D2, $03, $04
.db $B8, $8D, $04, $02, $5A, $D2, $B8, $89
.db $C8, $89, $64, $D2, $C0, $89, $D0, $89

.db $50, $D1, $0C, $20, $DC, $8E, $DA, $D1
.db $0A, $0C, $E0, $97, $16, $12, $00, $D0
.db $7C, $91, $20, $96, $2E, $D0, $08, $93
.db $94, $94, $18, $D2, $06, $10, $7C, $8E
.db $5C, $D2, $05, $08, $B8, $97, $08, $06
.db $D4, $D1, $BC, $90, $1C, $91, $E6, $D1
.db $EC, $90, $4C, $91, $5A, $D2, $04, $0C
.db $4C, $8E, $9E, $D2, $03, $04, $AC, $97
.db $06, $04, $18, $D2, $5C, $90, $8C, $90
.db $24, $D2, $74, $90, $A4, $90, $0C, $D1
.db $0E, $28, $00, $99, $D8, $D1, $0B, $10
.db $28, $A1, $16, $0E, $00, $D0, $10, $9C
.db $78, $9E, $32, $D0, $44, $9D, $AC, $9F
.db $16, $D2, $06, $14, $88, $98, $5C, $D2
.db $05, $08, $00, $A1, $08, $04, $D4, $D1
.db $90, $9B, $D0, $9B, $E8, $D1, $B0, $9B
.db $F0, $9B, $5A, $D2, $04, $0C, $58, $98
.db $5C, $D2, $04, $08, $E0, $A0, $06, $04
.db $18, $D2, $30, $9B, $60, $9B, $24, $D2
.db $48, $9B, $78, $9B, $88, $D0, $12, $30
.db $C0, $A2, $96, $D1, $0E, $14, $38, $AB
.db $16, $0A, $00, $D0, $70, $A7, $28, $A9
.db $36, $D0, $4C, $A8, $04, $AA, $D6, $D1
.db $08, $14, $20, $A2, $5C, $D2, $06, $08
.db $08, $AB, $0A, $06, $92, $D1, $80, $A6
.db $F8, $A6, $A8, $D1, $BC, $A6, $34, $A7
.db $1A, $D2, $06, $0C, $D8, $A1, $5C, $D2
.db $05, $08, $E0, $AA, $06, $04, $18, $D2
.db $20, $A6, $50, $A6, $24, $D2, $38, $A6
.db $68, $A6, $07

LABEL_7060:
.db	$00, $80

LABEL_7062:
.db	$04, $0F, $8B
.db $07, $4B, $8A, $04, $D4, $8E, $07, $1E
.db $95, $04, $A4, $92, $07, $6B, $9F, $04

.db $73, $96, $07, $13, $AA, $04, $34, $9A
.db $08, $00, $80, $04, $02, $9E, $08, $ED
.db $89, $04, $06, $89, $08, $23, $A4, $04
.db $D3, $A1, $09, $D1, $83, $04, $35, $A5
.db $07, $22, $B4, $04, $80, $A8, $05, $AF
.db $B1, $04, $A6, $AB, $07, $22, $B4, $04
.db $5B, $AF, $09, $D1, $83, $04, $3D, $B3
.db $08, $23, $A4, $04, $6C, $B7, $08, $ED
.db $89, $04, $06, $89, $08, $3F, $96, $1C
.db $C0, $A6, $08, $06, $9D, $1C, $35, $A9
.db $05, $27, $AA, $1C, $D0, $AB, $09, $00
.db $80, $1C, $C9, $AE, $05, $27, $AA, $1C
.db $0C, $B2, $08, $06, $9D, $1C, $C2, $B5
.db $08, $3F, $96, $1C, $5A, $B9, $08, $ED
.db $89, $04, $06, $89, $09, $4A, $8F, $05
.db $00, $80, $09, $BD, $9A, $05, $67, $83
.db $09, $0D, $A6, $05, $95, $86, $08, $75
.db $AF, $05, $7A, $89, $04, $00, $80, $05
.db $62, $8C, $05, $30, $B8, $05, $18, $8F
.db $08, $26, $B9, $05, $8F, $91, $08, $ED
.db $89, $04, $06, $89, $08, $26, $B9, $05
.db $C6, $93, $05, $30, $B8, $05, $2E, $97
.db $04, $00, $80, $05, $AD, $9A, $08, $75
.db $AF, $05, $7E, $9E, $09, $0D, $A6, $05
.db $48, $A2, $09, $BD, $9A, $05, $12, $A6
.db $09, $4A, $8F, $04, $BE, $BB

LABEL_7143:
	push bc
	push de
	push hl
	call +
	pop hl
	pop de
	pop bc
	ret

+:	
	ld hl, $C265
	ld a, (hl)
	dec (hl)
	jp m, +
	ld a, ($C264)
	ld c, a
	jp ++

+:	
	ld (hl), $00
	ld a, (Ctrl_1_held)
	and ButtonUp_Mask|ButtonDown_Mask|ButtonLeft_Mask|ButtonRight_Mask
	or $80
	ld c, a
	ld a, ($C30E)
	or a
	ld a, $0F
	jr z, +
	ld a, $07
+:	
	ld ($C265), a
++:	
	ld de, $0001
	ld a, ($C30E)
	or a
	jr z, +
	inc e
+:	
	ld a, ($C304)
	ld d, a
	ld hl, ($C305)
	ld b, h
	bit 0, c
	jr z, ++
	ld a, $02
	bit 7, c
	call nz, LABEL_74E4
	jr nz, ++
	ld a, d
	sub e
	cp $E0
	jr c, +
	sub $20
+:	
	ld d, a
	ld a, l
	sub e
	cp $C0
	jr c, +
	sub $40
	dec h
+:	
	ld l, a
	ld a, $01
	jp +++

++:	
	bit 1, c
	jr z, ++++
	ld a, $04
	bit 7, c
	call nz, LABEL_74E4
	jr nz, ++++
	ld a, d
	add a, e
	cp $E0
	jr c, +
	add a, $20
+:	
	ld d, a
	ld a, l
	add a, e
	cp $C0
	jr c, +
	add a, $40
	inc h
+:	
	ld l, a
	ld a, $02
+++:	
	ld ($C264), a
	ld a, $FF
	ld ($C2D2), a
	ld a, d
	ld ($C304), a
	ld a, h
	and $07
	ld h, a
	ld ($C305), hl
	cp b
	call nz, LABEL_723D
	jp LABEL_733A

++++:	
	ld d, $00
	ld hl, ($C301)
	ld b, h
	bit 2, c
	jr z, +
	ld a, $06
	bit 7, c
	call nz, LABEL_74E4
	jr nz, +
	or a
	sbc hl, de
	ld a, $04
	jp ++

+:	
	bit 3, c
	jr z, +++
	ld a, $08
	bit 7, c
	call nz, LABEL_74E4
	jr nz, +++
	add hl, de
	ld a, $08
++:	
	ld ($C264), a
	ld a, $FF
	ld ($C2D2), a
	ld a, l
	neg
	ld ($C300), a
	ld a, h
	and $07
	ld h, a
	ld ($C301), hl
	cp b
	jp nz, LABEL_723D
	jp LABEL_72A6

+++:	
	ld a, $D6
	ld ($C004), a
	xor a
	ld ($C2D2), a
	ld ($C264), a
	ld ($C265), a
	ret

LABEL_723D:
	ld a, ($C262)
	ld ($FFFF), a
	ld a, ($C306)
	add a, a
	ld e, a
	add a, a
	add a, a
	add a, a
	add a, e
	ld e, a
	ld a, ($C302)
	add a, a
	add a, e
	ld e, a
	ld d, $00
	ld hl, ($C260)
	add hl, de
	ld a, (hl)
	inc hl
	push hl
	ld h, (hl)
	ld l, a
	ld de, $CC00
	call +
	pop hl
	push hl
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $CD00
	call +
	pop hl
	ld de, $11
	add hl, de
	ld a, (hl)
	inc hl
	push hl
	ld h, (hl)
	ld l, a
	ld de, $CE00
	call +
	pop hl
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $CF00
+:	
	ld b, $00
--:	
	ld a, (hl)
	or a
	ret z
	jp m, +
	ld b, a
	inc hl
	ld a, (hl)
-:	
	ld (de), a
	inc de
	djnz -
	inc hl
	jp --

+:	
	and $7F
	ld c, a
	inc hl
	ldir
	jp --

LABEL_72A6:
	ld a, ($C264)
	and $0C
	ret z
	ld b, a
	ld a, ($C263)
	ld ($FFFF), a
	ld c, $00
	ld a, ($C301)
	and $07
	jr z, +
	ld a, b
	and $08
	jr nz, +
	ld c, $08
+:	
	ld a, ($C304)
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, ($C301)
	add a, c
	rrca
	rrca
	and $3C
	add a, l
	ld e, a
	ld a, h
	add a, $D0
	ld d, a
	ld h, $CC
	ld a, ($C305)
	and $F0
	ld l, a
	ld a, ($C301)
	add a, c
	jr nc, +
	inc h
+:	
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, l
	ld l, a
	ld a, b
	and $08
	jr z, +
	inc h
+:	
	ld b, $0E
-:	
	push bc
	push hl
	ld l, (hl)
	ld h, $10
	add hl, hl
	add hl, hl
	add hl, hl
	ldi
	ldi
	ldi
	ldi
	ld a, $3C
	add a, e
	ld e, a
	adc a, d
	sub e
	ld d, a
	ldi
	ldi
	ldi
	ldi
	pop hl
	ld a, $10
	add a, l
	cp $C0
	jr c, +
	sub $C0
	inc h
	inc h
+:	
	ld l, a
	ld a, $3C
	add a, e
	ld e, a
	adc a, d
	sub e
	sub $D7
	jr nc, +
	add a, $07
+:	
	add a, $D0
	ld d, a
	pop bc
	djnz -
	ret

LABEL_733A:
	ld a, ($C264)
	and $03
	ret z
	ld b, a
	and $01
	ld a, ($C263)
	ld ($FFFF), a
	ld a, ($C304)
	ld b, $00
	jr nz, ++
	cp $20
	jr c, +
	add a, $20
+:	
	ld b, $C0
	add a, b
++:	
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, ($C301)
	rrca
	rrca
	and $3C
	add a, l
	ld e, a
	ld a, h
	add a, $D0
	ld d, a
	ld a, ($C305)
	and $F0
	add a, b
	ld l, a
	adc a, $00
	sub l
	ld h, a
	ld a, ($C301)
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, l
	ld l, a
	ld bc, $00C0
	or a
	sbc hl, bc
	ld a, $CE
	jr nc, +
	add hl, bc
	ld a, $CC
+:	
	ld h, a
	ld b, $10
-:	
	push bc
	push hl
	ld l, (hl)
	ld h, $10
	add hl, hl
	add hl, hl
	add hl, hl
	ldi
	ldi
	ldi
	ldi
	push de
	ld a, $3C
	add a, e
	ld e, a
	adc a, d
	sub e
	ld d, a
	ldi
	ldi
	ldi
	ldi
	pop de
	ld a, e
	and $3F
	jr nz, +
	ld a, e
	sub $40
	ld e, a
+:	
	pop hl
	ld a, l
	and $F0
	ld b, a
	inc l
	ld a, l
	and $F0
	cp b
	jr z, +
	inc h
	ld l, b
+:	
	pop bc
	djnz -
	ret

LABEL_73D0:
	ld a, ($C264)
	and $0F
	ret z
	ld b, a
	and $03
	ld a, ($C263)
	ld ($FFFF), a
	jp nz, ++
	ld c, $00
	ld a, ($C301)
	and $07
	jr z, +
	ld a, b
	and $08
	jr nz, +
	ld c, $08
+:	
	ld a, ($C301)
	add a, c
	rrca
	rrca
	and $3E
	ld e, a
	ld l, a
	ld d, $78
	ld h, $D0
	ld bc, $1C00|Port_VDPData
-:	
	push bc
	rst $08
	nop
	nop
	nop
	outi
	nop
	nop
	nop
	outi
	ld bc, $003E
	add hl, bc
	ex de, hl
	ld c, $40
	add hl, bc
	ex de, hl
	pop bc
	djnz -
	ret

++:	
	ld a, b
	and $01
	ld a, ($C304)
	ld b, $00
	jr nz, ++
	cp $20
	jr c, +
	add a, $20
+:	
	ld b, $C0
	add a, b
++:	
	and $F8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	add a, $78
	ld d, a
	ld e, l
	rst $08
	ld a, h
	add a, $D0
	ld h, a
	ld bc, $4000|Port_VDPData
-:	
	outi
	nop
	jp nz, -
	ret

LABEL_744B:
	call LABEL_7602
	ld a, ($C263)
	ld ($FFFF), a
	ld a, ($C304)
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, ($C301)
	rrca
	rrca
	and $3C
	add a, l
	ld e, a
	ld a, h
	add a, $D0
	ld d, a
	ld a, ($C305)
	and $F0
	ld l, a
	ld a, ($C301)
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, l
	ld l, a
	ld h, $CC
	ld b, $0C
LABEL_7481:
	push bc
	push hl
	ld b, $10
-:	
	push bc
	push hl
	ld l, (hl)
	ld h, $10
	add hl, hl
	add hl, hl
	add hl, hl
	ldi
	ldi
	ldi
	ldi
	push de
	ld a, $3C
	add a, e
	ld e, a
	adc a, d
	sub e
	ld d, a
	ldi
	ldi
	ldi
	ldi
	pop de
	ld a, e
	and $3F
	jr nz, +
	ld a, e
	sub $40
	ld e, a
+:	
	pop hl
	ld a, l
	and $F0
	ld b, a
	inc l
	ld a, l
	and $F0
	cp b
	jr z, +
	inc h
	ld l, b
+:	
	pop bc
	djnz -
	ld a, $80
	add a, e
	ld e, a
	adc a, d
	sub e
	sub $D7
	jr nc, +
	add a, $07
+:	
	add a, $D0
	ld d, a
	pop hl
	ld a, $10
	add a, l
	cp $C0
	jr c, +
	sub $C0
	inc h
	inc h
+:	
	ld l, a
	pop bc
	djnz LABEL_7481
	ld a, $12
	jp WaitForVInt

LABEL_74E4:
	push bc
	push hl
	ld c, a
	ld a, ($C2E9)
	or a
	jr nz, +
	ld a, ($C30E)
	or a
	jr nz, ++
	ld b, $00
	ld hl, LABEL_7A21
	add hl, bc
	ld a, (hl)
	call LABEL_7764
	and $01
	pop hl
	pop bc
	ret

+:	
	xor a
	pop hl
	pop bc
	ret

++:	
	cp $04
	jr nz, ++
	push de
	ld b, $00
	ld hl, LABEL_7A2B
	add hl, bc
	ex de, hl
	ld a, (de)
	call LABEL_7764
	and $01
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $01
+:	
	pop de
	pop hl
	pop bc
	ret

++:	
	cp $08
	jr nz, ++
	push de
	ld b, $00
	ld hl, LABEL_7A2B
	add hl, bc
	ex de, hl
	ld a, (de)
	call LABEL_7764
	and $0A
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0A
+:	
	pop de
	pop hl
	pop bc
	ret

++:	
	push de
	ld b, $00
	ld hl, LABEL_7A2B
	add hl, bc
	ld e, b
	ld a, (hl)
	inc hl
	ld d, (hl)
	call ++
	and $01
	ld c, a
	ld a, d
	ld d, c
	call ++
	and $01
	or d
	push af
	ld a, e
	or a
	jr z, +
	ld a, $B7
	ld ($C004), a
+:	
	pop af
	pop de
	pop hl
	pop bc
	ret

++:	
	ld hl, LABEL_7A8D
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, $CC
	ld a, ($C305)
	add a, c
	jr c, +
	cp $C0
	jr c, ++
+:	
	add a, $40
	inc h
	inc h
++:	
	and $F0
	ld l, a
	ld a, ($C301)
	add a, b
	jr nc, +
	inc h
+:	
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, l
	ld l, a
	ld a, (hl)
	cp $D8
	jr c, LABEL_75E8
	cp $E0
	jr nc, LABEL_75E8
	ld (hl), $D7
	push de
	ld a, ($C304)
	add a, c
	jr nc, +
	add a, $20
+:	
	cp $E0
	jr c, +
	add a, $20
+:	
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, ($C301)
	add a, b
	rrca
	rrca
	and $3C
	add a, l
	ld e, a
	ld a, h
	add a, $78
	ld d, a
	ld hl, LABEL_7AB9
	di
	ld bc, $0200|Port_VDPData
--:	
	push bc
	rst $08
	ld b, $04
-:	
	outi
	nop
	jp nz, -
	ex de, hl
	ld bc, $0040
	add hl, bc
	ex de, hl
	pop bc
	djnz --
	ei
	pop de
	ld a, $D7
	ld e, a
LABEL_75E8:	
	ld ($C2E5), a
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, LABEL_B03_BC6F
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, ($C308)
	cp $04
	jr c, +
	inc h
+:	
	ld a, (hl)
	ret

LABEL_7602:
	ld a, ($C308)
	cp $02
	ret nz
	ld a, ($C30E)
	cp $0C
	ret nz
	ld a, $0A
	call +
	ld a, $0C
	call +
	ld a, $12
	call +
	ld a, $14
+:	
	ld hl, LABEL_7A8D
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, $CC
	ld a, ($C305)
	add a, c
	jr c, +
	cp $C0
	jr c, ++
+:	
	add a, $40
	inc h
	inc h
++:	
	and $F0
	ld l, a
	ld a, ($C301)
	add a, b
	jr nc, +
	inc h
+:	
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, l
	ld l, a
	ld a, (hl)
	cp $D8
	ret c
	cp $E0
	ret nc
	ld (hl), $D7
	ret

LABEL_7656:
	ld bc, $0400
-:	
	push bc
	ld b, $00
	ld hl, LABEL_7A35
	add hl, bc
	ex de, hl
	ld a, (de)
	call LABEL_7764
	and $0D
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0D
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0D
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0D
	jr z, ++
+:	
	pop bc
	ld a, c
	add a, $04
	ld c, a
	djnz -
	ld a, $FF
	or a
	ret

++:	
	pop bc
	ld a, c
	or a
	ret z
	ld de, $0010
	cp $04
	jr z, ++
	cp $08
	jr nz, +
	ld de, $0000
+:	
	ld hl, ($C305)
	ld a, l
	add a, $10
	cp $C0
	jr c, +
	add a, $40
	inc h
+:	
	ld l, a
	ld ($C305), hl
	ld ($C311), hl
++:	
	ld hl, ($C301)
	add hl, de
	ld ($C301), hl
	ld ($C313), hl
	xor a
	ret

LABEL_76C1:
	ld bc, $0800
-:	
	push bc
	ld b, $00
	ld hl, LABEL_7A45
	add hl, bc
	ex de, hl
	ld a, (de)
	call LABEL_7764
	and $0A
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0A
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0A
	jr nz, +
	inc de
	ld a, (de)
	call LABEL_7764
	and $0A
	jr z, ++
+:	
	pop bc
	ld a, c
	add a, $06
	ld c, a
	djnz -
	ld a, $FF
	or a
	ret

++:	
	ld hl, LABEL_7A49

LABEL_76FD:	
	pop bc
	ld b, $00
	add hl, bc
	ld de, ($C305)
	ld a, e
	add a, (hl)
	cp $C0
	jr c, ++
	bit 7, (hl)
	jr nz, +
	add a, $40
	inc d
	jr ++

+:	
	sub $40
	dec d
++:	
	ld e, a
	ld ($C305), de
	ld ($C311), de
	inc hl
	ld a, (hl)
	ld e, a
	rlca
	sbc a, a
	ld d, a
	ld hl, ($C301)
	add hl, de
	ld ($C301), hl
	ld ($C313), hl
	xor a
	ret

LABEL_7732:
	ld a, ($C2D7)
	and $03
	ld c, a
	add a, a
	add a, c
	add a, a
	ld c, a
	ld b, $08
-:	
	push bc
	ld b, $00
	ld hl, LABEL_7A75
	add hl, bc
	ld a, (hl)
	call LABEL_7764
	and $0D
	jr z, ++
	pop bc
	ld a, c
	add a, $03
	cp $18
	jr c, +
	sub $18
+:	
	ld c, a
	djnz -
	ld a, $FF
	or a
	ret

++:	
	ld hl, LABEL_7A76
	jp LABEL_76FD

LABEL_7764:
	ld hl, LABEL_7A8D
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, $CC
	ld a, ($C305)
	add a, c
	jr c, +
	cp $C0
	jr c, ++
+:	
	add a, $40
	inc h
	inc h
++:	
	and $F0
	ld l, a
	ld a, ($C301)
	add a, b
	jr nc, +
	inc h
+:	
	rrca
	rrca
	rrca
	rrca
	and $0F
	add a, l
	ld l, a
	ld a, (hl)
	ld ($C2E5), a
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, LABEL_B03_BC6F
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, ($C308)
	cp $04
	jr c, +
	inc h
+:	
	ld a, (hl)
	ret

LABEL_77AC:
	ld hl, $C2D5
	ld a, ($C265)
	or a
	jp z, +
	ld (hl), $00
	ret

+:	
	ld a, (hl)
	or a
	ret nz
	ld (hl), $FF
	ld a, $14
	ld e, a
	call LABEL_7764
	ld b, a
	rrca
	rrca
	rrca
	rrca
	and $0F
	ld ($C29E), a
	ld a, b
	and $08
	jr nz, ++
	ld a, b
	and $04
	jp nz, LABEL_792A
	ld a, ($C30E)
	or a
	jr z, +
	ld a, $12
	ld e, a
	call LABEL_7764
	and $08
	jr nz, ++
	ld a, $0A
	ld e, a
	call LABEL_7764
	and $08
	jr nz, ++
	ld a, $0C
	ld e, a
	call LABEL_7764
	and $08
	jr nz, ++
	ld a, $14
	ld e, a
	call LABEL_7764
+:	
	ld hl, ($C305)
	ld ($C311), hl
	ld hl, ($C301)
	ld ($C313), hl
	ret

++:	
	ld a, e
	ld hl, LABEL_7A8D
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld de, ($C305)
	ld a, e
	add a, (hl)
	jr c, +
	cp $C0
	jr c, ++
+:	
	add a, $40
	inc d
++:	
	ld e, a
	ex de, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ex de, hl
	inc hl
	ld c, (hl)
	ld b, $00
	ld hl, ($C301)
	add hl, bc
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, h
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, ($C2D9)
-:	
	ld a, (hl)
	cp $FF
	ret z
	push hl
	ld a, (hl)
	cp d
	jr z, ++
	inc a
	ld b, a
	and $0F
	cp $0C
	ld a, b
	jr c, +
	add a, $10
	and $70
+:	
	cp d
	jr nz, +++
++:	
	inc hl
	ld a, (hl)
	cp e
	jr z, ++++
	inc a
	cp e
	jr z, ++++
+++:	
	pop hl
	ld bc, $0006
	add hl, bc
	jp -

++++:	
	pop hl
	inc hl
	inc hl
	ld a, (hl)
	cp $08
	jp nz, LABEL_78BD

LABEL_7877:
	ld   (Game_mode), a
	inc  hl
LABEL_787B:
	ld   a, (hl)
	ld   ($C308), a
	ld   ($C309), a
	inc  hl
	ld   e, (hl)
	ld   d, $00
	ex   de, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   a, l
	sub  $60
	jr   c, LABEL_7894
	cp   $C0
	jr   c, LABEL_7897
LABEL_7894:
	sub  $40
	dec  h
LABEL_7897:
	ld   l, a
	ld   a, h
	and  $07
	ld   h, a
	ld   ($C305), hl
	ld   ($C311), hl
	ex   de, hl
	inc  hl
	ld   a, (hl)
	sub  $08
	and  $7F
	ld   l, a
	ld   h, $00
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   ($C301), hl
	ld   ($C313), hl
	xor  a
	ld   ($C30E), a
	jp   LABEL_7908


LABEL_78BD:
	cp $0A
	jp nz, +
	ld (Game_mode), a
	inc hl
	ld d, (hl)
	inc hl
	ld e, (hl)
	ld (Dungeon_position), de
	inc hl
	ld a, (hl)
	ld (Dungeon_direction), a
	ld hl, ($C311)
	ld ($C305), hl
	ld hl, ($C313)
	ld ($C301), hl
	xor a
	ld ($C30E), a
	jp LABEL_7908

+:	
	cp $0C
	ret nz
	ld (Game_mode), a
	inc hl
	ld a, (hl)
	ld ($C29E), a
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld ($C2DB), hl
	xor a
	ld ($C29D), a
	ld hl, ($C311)
	ld ($C305), hl
	ld hl, ($C313)
	ld ($C301), hl

LABEL_7908:
	ld   a, ($C810)
	ld   ($C2D7), a
	ld   hl, $C26F
	ld   de, $C270
	ld   bc, $0017
	ld   (hl), $00
	ldir
	ld   hl, $C800
	ld   de, $C801
	ld   bc, $00FF
	ld   (hl), $00
	ldir
	pop  hl
	ret


LABEL_792A:
	ld a, ($C2E5)
	cp $4C
	jp nz, +
	ld a, ($C309)
	cp $05
	ret nz
	ld a, ($C506)
	or a
	ret z
	ld a, $0A ; GameMode_LoadDungeon
	ld (Game_mode), a
	ld hl, $00DE
	ld (Dungeon_position), hl
	ld a, $00
	ld (Dungeon_direction), a
	ld hl, ($C311)
	ld ($C305), hl
	ld hl, ($C313)
	ld ($C301), hl
	jp LABEL_7908

+:	
	cp $5E
	jp nz, +
	ld a, ($C30E)
	or a
	ret nz
	ld a, $35
	call Inventory_FindFreeSlot
	ret z
	ld hl, $00A0
	ld ($C2DB), hl
LABEL_7972:	
	ld a, $0C ; GameMode_LoadInteraction
	ld (Game_mode), a
	ld hl, ($C311)
	ld ($C305), hl
	ld hl, ($C313)
	ld ($C301), hl
	jp LABEL_7908

+:	
	cp $5F
	ret c
	cp $64
	jp nc, +
	ld a, ($C30E)
	cp $08
	ret z
	call LABEL_7BC4
	ld c, $02
	jp LABEL_79E2

+:	
	cp $AD
	jp nz, +
	ld a, ($C309)
	sub $04
	ret c
	ld l, a
	ld h, $00
	ld e, l
	ld d, h
	add hl, hl
	add hl, de
	ld de, LABEL_7AC0
	add hl, de
	ld a, $08
	jp LABEL_7877

+:	
	cp $C3
	ret c
	cp $C7
	jp nc, +
	ld a, ($C30E)
	or a
	ret nz
	ld a, $FF
	ld ($C29D), a
	ld a, $19
	ld ($C2E6), a
	jp LABEL_7972

+:	
	cp $C7
	ret c
	cp $D2
	ret nc
	ld a, $3B
	call Inventory_FindFreeSlot
	ret z
	call LABEL_7BC4
	ld c, $1E

LABEL_79E2:	
	ld b, $00
	ld a, $03
	call +
	ld a, $02
	call +
	ld a, $01
	call +
	ld a, $00
	call +
	ld a, b
	or a
	ret z
	ld ($C2F0), a
	ld hl, $00AE
	ld ($C2DB), hl
	ld a, $0C ; GameMode_LoadInteraction
	ld (Game_mode), a
	jp LABEL_7908

+:	
	call LABEL_187D
	jr z, ++
	inc hl
	ld a, (hl)
	sub c
	jr nc, +
	xor a
+:	
	ld (hl), a
	jr nz, ++
	dec hl
	ld (hl), a
	sub $01
++:	
	rl b
	ret

LABEL_7A21:
.db	$14, $14, $0C, $0C, $1C, $1C, $12, $12, $16
.db $16

LABEL_7A2B:
.db	$0A, $14, $02, $04, $1A, $1C, $08, $10, $0E, $16

LABEL_7A35:
.db	$0A, $0C, $12, $14, $0C
.db $0E, $14, $16, $12, $14, $1A, $1C, $14, $16, $1C, $1E

LABEL_7A45:
.db	$02, $04, $0A, $0C

LABEL_7A49:
.db	$F0
.db $00, $04, $06, $0C, $0E, $F0, $10, $0E, $26, $16, $28, $00, $20, $16, $28, $1E
.db $2A, $10, $20, $1C, $1E, $22, $24, $20, $10, $1A, $1C, $20, $22, $20, $00, $10
.db $12, $18, $1A, $10, $F0, $08, $0A, $10, $12, $00, $F0

LABEL_7A75:
.db	$02

LABEL_7A76:
.db	$E0, $F0, $04, $E0
.db $00, $0E, $F0, $10, $16, $00, $10, $1C, $10, $00, $1A, $10, $F0, $10, $00, $E0
.db $08, $F0, $E0

LABEL_7A8D:
.db	$40, $60, $40, $70, $40, $80, $40, $90, $50, $60, $50, $70, $50
.db $80, $50, $90, $60, $60, $60, $70, $60, $80, $60, $90, $70, $60, $70, $70, $70
.db $80, $70, $90, $80, $70, $80, $80, $80, $90, $50, $A0, $60, $A0, $70, $A0

LABEL_7AB9:
.db	$91
.db $01, $92, $01, $93, $01, $94

LABEL_7AC0:
.db	$01, $00, $39, $55, $00, $39, $55, $00, $48, $49
.db $00, $47, $38, $00, $66, $55, $00, $25, $42, $00, $14, $0F, $00, $41, $1A, $00
.db $66, $75, $00, $38, $66, $01, $27, $64, $01, $53, $73, $01, $27, $64, $01, $71
.db $5A, $01, $26, $29, $02, $5B, $2C, $02, $38, $49, $02, $5B, $2C, $02, $38, $49
.db $00, $16, $6A

FadeOut:
	ld hl, $1009
	ld (Fade_timer), hl
	jr LABEL_7B0B

FadeOut2:
	ld   hl, $2009
	ld   (Fade_timer), hl
LABEL_7B0B:
	ld   a, $16
	call	WaitForVInt
	ld   a, (Fade_timer)
	or   a
	jp   nz, LABEL_7B0B
	ret

FadeIn:
	ld   hl, $1089
	ld   (Fade_timer), hl
	jr   LABEL_7B33

FadeIn2:
	ld   hl, $2089
	ld   (Fade_timer), hl
	ld   hl, $C220
	ld   de, $C221
	ld   bc, $001F
	ld   (hl), $00
	ldir
LABEL_7B33:
	ld   a, $16
	call	WaitForVInt
	ld   a, (Fade_timer)
	or   a
	jp   nz, LABEL_7B33
	ret


LABEL_7B40:
	ld hl, $C21D
	dec (hl)
	ret p
	ld (hl), $03
	ld hl, Fade_timer
	ld a, (hl)
	bit 7, a
	jp nz, ++
	or a
	ret z
	dec (hl)
	inc hl
	ld b, (hl)
	ld hl, $C220
-:	
	call +
	inc hl
	djnz -
	ret

+:	
	ld a, (hl)
	or a
	ret z
	and $03
	jr z, +
	dec (hl)
	ret

+:	
	ld a, (hl)
	and $0C
	jr z, +
	ld a, (hl)
	sub $04
	ld (hl), a
	ret

+:	
	ld a, (hl)
	and $30
	ret z
	sub $10
	ld (hl), a
	ret

++:	
	cp $80
	jr nz, +
	ld (hl), $00
	ret

+:	
	dec (hl)
	inc hl
	ld b, (hl)
	ld hl, $C240
	ld de, $C220
-:	
	call +
	inc hl
	inc de
	djnz -
	ret

+:	
	ld a, (de)
	cp (hl)
	ret z
	add a, $10
	cp (hl)
	jr z, +
	jr nc, ++
+:	
	ld (de), a
	ret

++:	
	ld a, (de)
	add a, $04
	cp (hl)
	jr z, +
	jr nc, ++
+:	
	ld (de), a
	ret

++:	
	ex de, hl
	inc (hl)
	ex de, hl
	ret

LABEL_7BAC:
	ld a, $0A
	ld ($C2BE), a
	ld hl, $0D13
	ld ($C2C0), hl
-:	
	ld a, $16
	call WaitForVInt
	ld a, ($C2BE)
	or a
	jp nz, -
	ret

LABEL_7BC4:
	ld a, $0A
	ld ($C2BE), a
	ld hl, $0E03
	ld a, ($C2E6)
	cp $46
	jr z, +
	cp $49
	jr z, +
	cp $4A
	jr z, +
	ld hl, $0D03
+:	
	ld ($C2C0), hl
-:	
	ld a, $16
	call WaitForVInt
	ld a, ($C2BE)
	or a
	jp nz, -
	ret

LABEL_7BEE:
	ld a, ($C2BE)
	or a
	ret z
	dec a
	ld ($C2BE), a
	rrca
	jp c, +
	ld hl, $C240
	ld de, $C220
	ld bc, $0020
	ldir
	ret

+:	
	ld hl, ($C2C0)
	ld b, h
	ld a, l
	ld hl, $C220
	add a, l
	ld l, a
	ld a, $3F
-:	
	ld (hl), a
	inc hl
	djnz -
	ret

LABEL_7C18:
	ld a, ($C30E)
	or a
	ret z
	cp $10
	jp z, LABEL_7C79
	cp $11
	jp z, LABEL_7C79
	cp $0E
	ret nc
	ld b, a
	ld c, $D1
	cp $08
	jp z, +
	ld c, $D0
	ld a, ($C265)
	or a
	ret z
+:	
	ld hl, $C310
	dec (hl)
	ret p
	ld (hl), $03
	dec hl
	ld a, c
	ld ($C004), a
	ld a, (hl)
	inc a
	cp $03
	jr c, +
	xor a
+:	
	ld (hl), a
	ld c, a
	ld a, b
	cp $08
	ld hl, LABEL_7C6D
	ld de, $C01D
	jp nz, +
	ld hl, LABEL_7C73
	ld de, $C017
+:	
	ld b, $00
	add hl, bc
	rst $08
	ld bc, $0300|Port_VDPData
-:	
	outi
	jp nz, -
	ret


LABEL_7C6D:
.db	$2F, $2A, $25
.db $2F, $2A, $25

LABEL_7C73:
.db	$3C, $2F, $2A, $3C, $2F
.db $2A

LABEL_7C79:
	ld hl, $C220
	ld de, $C000
	rst $08
	ld c, $BE
	jp LABEL_595E


LABEL_7C85:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, LABEL_B03_BE1D
	ld a, $6F
-:	
	push af
	and $0F
	ld de, $C238
	ld bc, $0008
	jr nz, +
	ldir
+:	
	ld a, $16
	call WaitForVInt
	pop af
	dec a
	jr nz, -
	ret

LABEL_7CA6:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, LABEL_B03_BE4D
	ld de, $C23B
	ld bc, $0005
	ldir
	ld a, $16
	jp WaitForVInt

LABEL_7CBB:
	ld hl, $FFFF
	ld (hl), :Bank03
	call +
	call +
	call +
	ld hl, LABEL_B03_BE82
	ld b, $0D
--:	
	push bc
	ld de, $C22A
	ld bc, $0006
	ldir
	ld b, $08
-:	
	ld a, $16
	call WaitForVInt
	djnz -
	pop bc
	djnz --
	ret

LABEL_7CE4:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, LABEL_B03_BED0
	ld bc, $0918
	jr LABEL_7CF7

+:	
	ld hl, LABEL_B03_BE52
	ld bc, $1803

LABEL_7CF7:	
	push bc
	ld a, (hl)
	ld ($C220), a
	ld b, $06
	ld de, $C22A
-:	
	ld (de), a
	inc de
	djnz -
	inc hl
	ld a, (hl)
	ld ($C227), a
	inc hl
	ld b, c
-:	
	ld a, $16
	call WaitForVInt
	djnz -
	pop bc
	djnz LABEL_7CF7
	ret


LABEL_7D17:
.db	$C0

LABEL_7D18:
.db $C0, $C0, $E8, $EB, $C0, $C0, $C0, $C0
.db $C0, $C0, $C0, $C0, $C0, $E5, $C0, $C0
.db $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
.db $E5, $C0, $EA, $C0, $E7, $C0, $C0, $C0
.db $C1, $C0, $C2, $C0, $C3, $C0, $C4, $C0
.db $C5, $C0, $C6, $C0, $C7, $C0, $C8, $C0
.db $C9, $C0, $CA, $C0, $C0, $C0, $E6, $C0
.db $C0, $C0, $C0, $C0, $C0, $C0, $E9, $E5
.db $C0, $C0, $CB, $C0, $CC, $C0, $CD, $C0
.db $CE, $C0, $CF, $C0, $D0, $C0, $D1, $C0
.db $D2, $C0, $D3, $C0, $D4, $C0, $D5, $C0
.db $D6, $C0, $D7, $C0, $D8, $C0, $D9, $C0
.db $DA, $C0, $DB, $C0, $DC, $C0, $DD, $C0
.db $DE, $C0, $DF, $C0, $E0, $C0, $E1, $C0
.db $E2, $C0, $E3, $C0, $E4, $C0, $C0, $C0
.db $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
.db $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
.db $C0, $C0, $C0

LABEL_7DA3:
.db	"        "
.db	"WOODCANE"
.db	"SHT. SWD"
.db	"IRN. SWD"
.db	"WAND", $65, $20, $20, $20
.db	"IRN.FANG"
.db	"IRN. AXE"
.db	"TIT. SWD"
.db	"CRC. SWD"
.db	"NEEDLGUN"
.db	"SIL.FANG"
.db	"HEAT.GUN"
.db	"LGT.SABR"
.db	"LASR.GUN"
.db	"LAC. SWD"
.db	"LAC. AXE"
.db	"LTH.ARMR"
.db	"WHT.MANT"
.db	"LGT.SUIT"
.db	"IRN.ARMR"
.db	"THCK.FUR"
.db	"ZIR.ARMR"
.db	"DMD.ARMR"
.db	"LAC.ARMR"
.db	"FRD.MANT"
.db	"LTH. SLD"
.db	"BRNZ.SLD"
.db	"IRN. SLD"
.db	"CRC. SLD"
.db	"GLOVE", $65, $20, $20
.db	"LASR.SLD"
.db	"MIRR.SLD"
.db	"LAC. SLD"
.db	"LANDROVR"
.db	"HOVRCRFT"
.db	"ICE DIGR"
.db	"COLA", $65, $20, $20, $20
.db	"BURGER", $65, $20
.db	"FLUTE", $65, $20, $20
.db	"FLASH", $65, $20, $20
.db	"ESCAPER", $65
.db	"TRANSER",$65
.db	"MAGC HAT"
.db	"ALSULIN", $65
.db	"POLYMTRL"
.db	"DUGN KEY"
.db	"SPHERE", $65, $20
.db	"TORCH", $65, $20, $20
.db	"PRISM", $65, $20, $20
.db	"NUTS", $65, $20, $20, $20
.db	"HAPSBY", $65, $20
.db	"ROADPASS"
.db	"PASSPORT"
.db	"COMPASS", $65
.db	"CAKE", $65, $20, $20, $20
.db	"LETTER", $65, $20
.db	"LAC. POT"
.db	"MAG.LAMP"
.db	"AMBR EYE"
.db	"GAS. SLD"
.db	"CRYSTAL", $65
.db	"M SYSTEM"
.db	"MRCL KEY"
.db	"ZILLION", $65
.db	"SECRETS", $65

LABEL_7FAB:
.db	$00, $D0, $D0, $50, $D0
.db $20, $40, $50, $50, $40, $20, $40, $50
.db $40, $50, $40, $51, $81, $51, $41, $21
.db $51, $51, $41, $81, $52, $42, $52, $52
.db $22, $D2, $46, $52, $04, $04, $04, $00
.db $00, $00, $00, $00, $00, $00, $04, $00
.db $04, $00, $04, $04, $04, $04, $04, $00
.db $04, $00, $04, $04, $00, $04, $00, $00
.db $00, $04, $00, $FF, $FF, $FF, $FF, $FF
	

RomHeader:
.db	"TMR SEGA"
.db	$FF, $FF	; Reserved
.dw	$EAD8		; Checksum
.dw	$9500		; Product Code
.db	$03			; Version
.db	$40			; Region Code (SMS Export)


.BANK 2 SLOT 2
.ORG $0000
Bank02:

; Pointer table, when ShowDialogue_B2 is called,
; the value passed in via hl is used as an index into it

DialogueBlock:
.dw Dialogue_Index_0002, Dialogue_Index_0004, Dialogue_Index_0006, Dialogue_Index_0008, Dialogue_Index_000A, Dialogue_Index_000C, Dialogue_Index_000E, Dialogue_Index_0010
.dw Dialogue_Index_0012, Dialogue_Index_0014, Dialogue_Index_0016, Dialogue_Index_0018, Dialogue_Index_001A, Dialogue_Index_001C, Dialogue_Index_001E, Dialogue_Index_0020
.dw Dialogue_Index_0022, Dialogue_Index_0024, Dialogue_Index_0026, Dialogue_Index_0028, Dialogue_Index_002A, Dialogue_Index_002C, Dialogue_Index_002E, Dialogue_Index_0030
.dw Dialogue_Index_0032, Dialogue_Index_0034, Dialogue_Index_0036, Dialogue_Index_0038, Dialogue_Index_003A, Dialogue_Index_003C, Dialogue_Index_003E, Dialogue_Index_0040
.dw Dialogue_Index_0042, Dialogue_Index_0044, Dialogue_Index_0046, Dialogue_Index_0048, Dialogue_Index_004A, Dialogue_Index_004C, Dialogue_Index_004E, Dialogue_Index_0050
.dw Dialogue_Index_0052, Dialogue_Index_0054, Dialogue_Index_0056, Dialogue_Index_0058, Dialogue_Index_005A, Dialogue_Index_005C, Dialogue_Index_005E, Dialogue_Index_0060
.dw Dialogue_Index_0062, Dialogue_Index_0064, Dialogue_Index_0066, Dialogue_Index_0068, Dialogue_Index_006A, Dialogue_Index_006C, Dialogue_Index_006E, Dialogue_Index_0070
.dw Dialogue_Index_0072, Dialogue_Index_0074, Dialogue_Index_0076, Dialogue_Index_0078, Dialogue_Index_007A, Dialogue_Index_007C, Dialogue_Index_007E, Dialogue_Index_0080
.dw Dialogue_Index_0082, Dialogue_Index_0084, Dialogue_Index_0086, Dialogue_Index_0088, Dialogue_Index_008A, Dialogue_Index_008C, Dialogue_Index_008E, Dialogue_Index_0090
.dw Dialogue_Index_0092, Dialogue_Index_0094, Dialogue_Index_0096, Dialogue_Index_0098, Dialogue_Index_009A, Dialogue_Index_009C, Dialogue_Index_009E, Dialogue_Index_00A0
.dw Dialogue_Index_00A2, Dialogue_Index_00A4, Dialogue_Index_00A6, Dialogue_Index_00A8, Dialogue_Index_00AA, Dialogue_Index_00AC, Dialogue_Index_00AE, Dialogue_Index_00B0
.dw Dialogue_Index_00B2, Dialogue_Index_00B4, Dialogue_Index_00B6, Dialogue_Index_00B8, Dialogue_Index_00BA, Dialogue_Index_00BC, Dialogue_Index_00BE, Dialogue_Index_00C0
.dw Dialogue_Index_00C2, Dialogue_Index_00C4, Dialogue_Index_00C6, Dialogue_Index_00C8, Dialogue_Index_00CA, Dialogue_Index_00CC, Dialogue_Index_00CE, Dialogue_Index_00D0
.dw Dialogue_Index_00D2, Dialogue_Index_00D4, Dialogue_Index_00D6, Dialogue_Index_00D8, Dialogue_Index_00DA, Dialogue_Index_00DC, Dialogue_Index_00DE, Dialogue_Index_00E0
.dw Dialogue_Index_00E2, Dialogue_Index_00E4, Dialogue_Index_00E6, Dialogue_Index_00E8, Dialogue_Index_00EA, Dialogue_Index_00EC, Dialogue_Index_00EE, Dialogue_Index_00F0
.dw Dialogue_Index_00F2, Dialogue_Index_00F4, Dialogue_Index_00F6, Dialogue_Index_00F8, Dialogue_Index_00FA, Dialogue_Index_00FC, Dialogue_Index_00FE, Dialogue_Index_0100
.dw Dialogue_Index_0102, Dialogue_Index_0104, Dialogue_Index_0106, Dialogue_Index_0108, Dialogue_Index_010A, Dialogue_Index_010C, Dialogue_Index_010E, Dialogue_Index_0110
.dw Dialogue_Index_0112, Dialogue_Index_0114, Dialogue_Index_0116, Dialogue_Index_0118, Dialogue_Index_011A, Dialogue_Index_011C, Dialogue_Index_011E, Dialogue_Index_0120
.dw Dialogue_Index_0122, Dialogue_Index_0124, Dialogue_Index_0126, Dialogue_Index_0128, Dialogue_Index_012A, Dialogue_Index_012C, Dialogue_Index_012E, Dialogue_Index_0130
.dw Dialogue_Index_0132, Dialogue_Index_0134, Dialogue_Index_0136, Dialogue_Index_0138, Dialogue_Index_013A, Dialogue_Index_013C, Dialogue_Index_013E, Dialogue_Index_0140
.dw Dialogue_Index_0142, Dialogue_Index_0144, Dialogue_Index_0146, Dialogue_Index_0148, Dialogue_Index_014A, Dialogue_Index_014C, Dialogue_Index_014E, Dialogue_Index_0150
.dw Dialogue_Index_0152, Dialogue_Index_0154, Dialogue_Index_0156, Dialogue_Index_0158, Dialogue_Index_015A, Dialogue_Index_015C, Dialogue_Index_015E, Dialogue_Index_0160
.dw Dialogue_Index_0162, Dialogue_Index_0164, Dialogue_Index_0166, Dialogue_Index_0168, Dialogue_Index_016A, Dialogue_Index_016C, Dialogue_Index_016E, Dialogue_Index_0170
.dw Dialogue_Index_0172, Dialogue_Index_0174, Dialogue_Index_0176, Dialogue_Index_0178, Dialogue_Index_017A, Dialogue_Index_017C, Dialogue_Index_017E, Dialogue_Index_0180
.dw Dialogue_Index_0182, Dialogue_Index_0184, Dialogue_Index_0186, Dialogue_Index_0188, Dialogue_Index_018A, Dialogue_Index_018C, Dialogue_Index_018E, Dialogue_Index_0190
.dw Dialogue_Index_0192, Dialogue_Index_0194, Dialogue_Index_0196, Dialogue_Index_0198, Dialogue_Index_019A, Dialogue_Index_019C, Dialogue_Index_019E, Dialogue_Index_01A0
.dw Dialogue_Index_01A2, Dialogue_Index_01A4, Dialogue_Index_01A6, Dialogue_Index_01A8, Dialogue_Index_01AA, Dialogue_Index_01AC, Dialogue_Index_01AE, Dialogue_Index_01B0
.dw Dialogue_Index_01B2, Dialogue_Index_01B4, Dialogue_Index_01B6, Dialogue_Index_01B8, Dialogue_Index_01BA, Dialogue_Index_01BC, Dialogue_Index_01BE, Dialogue_Index_01C0
.dw Dialogue_Index_01C2, Dialogue_Index_01C4, Dialogue_Index_01C6, Dialogue_Index_01C8, Dialogue_Index_01CA, Dialogue_Index_01CC, Dialogue_Index_01CE, Dialogue_Index_01D0
.dw Dialogue_Index_01D2, Dialogue_Index_01D4, Dialogue_Index_01D6, Dialogue_Index_01D8, Dialogue_Index_01DA, Dialogue_Index_01DC, Dialogue_Index_01DE, Dialogue_Index_01E0
.dw Dialogue_Index_01E2, Dialogue_Index_01E4, Dialogue_Index_01E6, Dialogue_Index_01E8, Dialogue_Index_01EA, Dialogue_Index_01EC, Dialogue_Index_01EE, Dialogue_Index_01F0
.dw Dialogue_Index_01F2, Dialogue_Index_01F4, Dialogue_Index_01F6, Dialogue_Index_01F8, Dialogue_Index_01FA, Dialogue_Index_01FC, Dialogue_Index_01FE, Dialogue_Index_0200
.dw Dialogue_Index_0202, Dialogue_Index_0204, Dialogue_Index_0206, Dialogue_Index_0208, Dialogue_Index_020A, Dialogue_Index_020C, Dialogue_Index_020E, Dialogue_Index_0210
.dw Dialogue_Index_0212, Dialogue_Index_0214, Dialogue_Index_0216, Dialogue_Index_0218, Dialogue_Index_021A, Dialogue_Index_021C, Dialogue_Index_021E, Dialogue_Index_0220
.dw Dialogue_Index_0222, Dialogue_Index_0224, Dialogue_Index_0226, Dialogue_Index_0228, Dialogue_Index_022A, Dialogue_Index_022C, Dialogue_Index_022E, Dialogue_Index_0230
.dw Dialogue_Index_0232, Dialogue_Index_0234, Dialogue_Index_0236, Dialogue_Index_0238, Dialogue_Index_023A, Dialogue_Index_023C, Dialogue_Index_023E, Dialogue_Index_0240
.dw Dialogue_Index_0242, Dialogue_Index_0244, Dialogue_Index_0246, Dialogue_Index_0248, Dialogue_Index_024A, Dialogue_Index_024C, Dialogue_Index_024E, Dialogue_Index_0250
.dw Dialogue_Index_0252, Dialogue_Index_0254, Dialogue_Index_0256, Dialogue_Index_0258, Dialogue_Index_025A, Dialogue_Index_025C, Dialogue_Index_025E, Dialogue_Index_0260
.dw Dialogue_Index_0262, Dialogue_Index_0264, Dialogue_Index_0266, Dialogue_Index_0268, Dialogue_Index_026A, Dialogue_Index_026C, Dialogue_Index_026E, Dialogue_Index_0270
.dw Dialogue_Index_0272, Dialogue_Index_0274, Dialogue_Index_0276, Dialogue_Index_0278, Dialogue_Index_027A, Dialogue_Index_027C, Dialogue_Index_027E, Dialogue_Index_0280
.dw Dialogue_Index_0282, Dialogue_Index_0284, Dialogue_Index_0286, Dialogue_Index_0288, Dialogue_Index_028A, Dialogue_Index_028C, Dialogue_Index_028E, Dialogue_Index_0290
.dw Dialogue_Index_0292, Dialogue_Index_0294, Dialogue_Index_0296, Dialogue_Index_0298, Dialogue_Index_029A, Dialogue_Index_029C, Dialogue_Index_029E, Dialogue_Index_02A0
.dw Dialogue_Index_02A2, Dialogue_Index_02A4, Dialogue_Index_02A6, Dialogue_Index_02A8, Dialogue_Index_02AA

Dialogue_Index_0002:
.db "I", Dialogue_Apostrophe, "M SUELO. I ", $BE, Dialogue_NewLine
.db "HOW ", $CE, " FEEL,", Dialogue_NewPage
.db "DEAR,NO ", $FD, " CAN", Dialogue_NewLine
.db "STOP ", $E1, $FE, Dialogue_NewPage
.db "DOING WHAT ", $E1, Dialogue_NewLine
.db $BE, " ", $CE, " DO.", Dialogue_NewPage

Dialogue_Index_0004:
.db "BUT IF ", $E1, "SHOULD", Dialogue_NewLine
.db "EVER BE WOUNDED", Dialogue_NewPage
.db "IN BATTLE,COME", Dialogue_NewLine
.db $D2, " TO ", $BF, ".", Dialogue_Terminator65

Dialogue_Index_0006:
.db $C9, $BF, Dialogue_NewLine
.db $A9, ".", Dialogue_NewPage
.db $E1, $EC, $E0, Dialogue_NewLine
.db $D2, " AT ", $F6, $9F, ".", Dialogue_Terminator65

Dialogue_Index_0008:
.db "I", Dialogue_Apostrophe, "M NEKISE. ", $FD, Dialogue_NewLine
.db "HEARS LOTS OF", Dialogue_NewPage

Dialogue_Index_000A:
.db "STORIES, ", $E1, $BE, ",BUT ", $D5, " SAY ", $DC, Dialogue_NewPage
.db "A FIGHTER ", $E7, Dialogue_NewLine
.db "ODIN LIVES IN A", Dialogue_NewPage
.db $B9, " CALLED ", $96, ".", Dialogue_NewLine

Dialogue_Index_000C:
.db "ALSO, I ", $E3, "A", Dialogue_NewPage
.db $A6, " GIVEN", Dialogue_NewLine

Dialogue_Index_000E:
.db "BY ", $B2, ". ", $DC, Dialogue_NewPage
.db "WOULD BE HELPFUL", Dialogue_NewLine
.db "TO ", $E1, "IN ", $E2, Dialogue_NewPage
.db "TASK.", Dialogue_Terminator65

Dialogue_Index_0010:
.db "I ", $97, " I COULD", Dialogue_NewLine
.db $CA, " ", $E1, "MORE.", Dialogue_NewPage
.db "I PRAY FOR ", $E2, Dialogue_NewLine
.db "SAFETY.", Dialogue_Terminator65

Dialogue_Index_0012:
.db $DE, "CAMINEET", Dialogue_NewLine
.db $D6, Dialogue_NewPage
.db "IS UNDER", Dialogue_NewLine
.db "MARTIAL LAW.", Dialogue_Terminator65

Dialogue_Index_0014:
.db $E1, "NEED A", Dialogue_NewLine
.db $D8, " KEY TO", Dialogue_NewPage
.db "OPEN LOCKED DOORS.", Dialogue_Terminator65

Dialogue_Index_0016:
.db "IN ", $D5, " ", $D8, "S", Dialogue_NewLine
.db $CB, " ", $F8, "GET", Dialogue_NewPage
.db "FAR WITHOUT ", $D5, Dialogue_NewLine
.db "SORT OF LIGHT.", Dialogue_Terminator65

Dialogue_Index_0018:
.db $DA, " A", Dialogue_NewLine
.db $98, " TO ", $DE, Dialogue_NewPage
.db "WEST OF CAMINEET.", Dialogue_Terminator65

Dialogue_Index_001A:
.db "IF ", $E1, $F9, "TO", Dialogue_NewLine
.db "MAKE A DEAL, ", $E1, Dialogue_NewPage
.db "SHOULD HEAD FOR", Dialogue_NewLine
.db $DE, "PORT ", $B9, ".", Dialogue_Terminator65

Dialogue_Index_001C:
.db $E1, "HAD BETTER", Dialogue_NewLine
.db $F8, "LEAVE ", $DE, Dialogue_NewPage
.db $D6, ".", Dialogue_Terminator65

Dialogue_Index_001E:
.db "UNLESS ", $E1, "HOPE TODIE, ", $E1, "HAD BEST", Dialogue_NewPage
.db "STAY ", $D2, ".", Dialogue_Terminator65

Dialogue_Index_0020:
.db $E1, "MAY ", $F8, $A2, ".", Dialogue_Terminator65

Dialogue_Index_0022:
.db $E1, $88, " ", $A2, Dialogue_NewLine
.db "WITHOUT ", $A0, ".", Dialogue_Terminator65

Dialogue_Index_0024:
.db $E1, "MAY PROCEED.", Dialogue_Terminator65

Dialogue_Index_0026:
.db $E4, "IS PAROLIT", Dialogue_NewLine
.db $D6, ".", Dialogue_Terminator65

Dialogue_Index_0028:
.db $DE, $C4, " IS A", Dialogue_NewLine
.db "DANGEROUS PLACE.", Dialogue_Terminator65

Dialogue_Index_002A:
.db $EA, " HAS BEEN", Dialogue_NewLine
.db "REBORN AND LIVES", Dialogue_NewPage
.db "IN A CAVE TO ", $DE, Dialogue_NewLine
.db "SOUTH. IF ", $E1, "SEE", Dialogue_NewPage

Dialogue_Index_002C:
.db "HER, ", $CB, " BE", Dialogue_NewLine
.db $91, ".", Dialogue_Terminator65

Dialogue_Index_002E:
.db "TO ", $DE, "EAST LIES", Dialogue_NewLine
.db "A PORT ", $B9, Dialogue_NewPage
.db "CALLED ", $96, ".", Dialogue_Terminator65

Dialogue_Index_0030:
.db $FE, $DE, $98, Dialogue_NewLine
.db $E1, "CAN GO TO", Dialogue_NewPage
.db "PASEO ON ", $94, ".", Dialogue_Terminator65

Dialogue_Index_0032:
.db $DA, " AN", Dialogue_NewLine
.db "UNDERGROUND", Dialogue_NewPage
.db $BA, " TO ", $DE, Dialogue_NewLine
.db $95, " ", $C4, Dialogue_NewPage
.db $D5, $D0, " TO ", $DE, Dialogue_NewLine
.db "WEST OF PAROLIT.", Dialogue_Terminator65

Dialogue_Index_0034:
.db "ODIN SET OFF TO", Dialogue_NewLine
.db "KILL ", $EA, ". HE", Dialogue_NewPage

Dialogue_Index_0036:
.db "WENT WITH AN", Dialogue_NewLine
.db "ANIMAL ", $DC, " CAN", Dialogue_NewPage
.db "SPEAK! ", $DE, "ANIMAL", Dialogue_NewLine
.db "HAD A BOTTLE OF", Dialogue_NewPage

Dialogue_Index_0038:
.db "MEDICINE HANGING", Dialogue_NewLine
.db $FE, "ITS NECK, BUT", Dialogue_NewPage
.db "I DON", Dialogue_Apostrophe, "T ", $BE, " WHAT", Dialogue_NewLine
.db $DC, " IS FOR.", Dialogue_Terminator65

Dialogue_Index_003A:
.db "I HEAR ", $E1, $EC, Dialogue_NewLine
.db "GOING TO TRY", Dialogue_NewPage
.db "TO KILL ", $D4, ".", Dialogue_NewLine
.db "BEST OF LUCK!", Dialogue_Terminator65

Dialogue_Index_003C:
.db "I RECENTLY FOUND ATALKING BEAST IN", Dialogue_NewPage
.db $DE, "CAVE ", $D0, Dialogue_NewLine
.db $EA, " LIVES.", Dialogue_NewPage

Dialogue_Index_003E:
.db "I SOLD HIM FOR A", Dialogue_NewLine
.db "GOOD PRICE TO A", Dialogue_NewPage
.db "MERCHANT ", $FE, Dialogue_NewLine
.db "PASEO!", Dialogue_Terminator65

Dialogue_Index_0040:
.db "TIMES ", $EC, "HARD.", Dialogue_NewLine
.db $D1, " DOESN", Dialogue_Apostrophe, "T SEEM", Dialogue_NewPage
.db "TO BE ", $F6, "WAY TO", Dialogue_NewLine
.db "MAKE M", $FD, "Y.", Dialogue_Terminator65

Dialogue_Index_0042:
.db "A CAVE CALLED IALACAN BE FOUND ON", Dialogue_NewPage
.db $DE, "PENINSULA TO", Dialogue_NewLine
.db $DE, "SOUTH OF ", $96, Dialogue_Terminator65

Dialogue_Index_0044:
.db $E4, "IS ", $DE, "PORT", Dialogue_NewLine
.db $B9, " ", $96, ".", Dialogue_NewPage
.db "LONG AGO, WE", Dialogue_NewLine
.db "THRIVED ON TRADE.", Dialogue_Terminator65

Dialogue_Index_0046:
.db $E1, "NEED A COMPASSTO ", $A2, " ", $DD, Dialogue_NewPage
.db $DE, "EPPI ", $C4, ".", Dialogue_Terminator65

Dialogue_Index_0048:
.db "A DOOR LOCKED WITH", $84, "CAN ONLY BE", Dialogue_NewPage
.db "OPENED WITH ", $EF, ".", Dialogue_Terminator65

Dialogue_Index_004A:
.db $DA, " A ", $AB, Dialogue_NewLine
.db $E7, $C2, Dialogue_NewPage
.db "TO ", $DE, "NORTH OF", Dialogue_NewLine
.db $E4, $B9, ".", Dialogue_NewPage
.db "BUT N", $FD, " OF US", Dialogue_NewLine
.db "D", $EC, "APPROACH IT.", Dialogue_Terminator65

Dialogue_Index_004C:
.db "A CAVE CALLED", Dialogue_NewLine
.db "NAULA LIES ON ", $DE, Dialogue_NewPage
.db "NORTH COAST OF", Dialogue_NewLine
.db $C2, ".", Dialogue_Terminator65

Dialogue_Index_004E:
.db $DE, $AA, " OF", Dialogue_NewLine
.db $94, " MIGHT", Dialogue_NewPage
.db "POSSIBLY ", $CA, " ", $E1, "WELL.", Dialogue_Terminator65

Dialogue_Index_0050:
.db "NOAH LIVES ON", Dialogue_NewLine
.db $94, ".", Dialogue_Terminator65

Dialogue_Index_0052:
.db "DR.", $AD, " HAD A", Dialogue_NewLine
.db $BD, " IN ", $DE, Dialogue_NewPage
.db $95, " ", $C4, " LONGAGO, IT IS SAID.", Dialogue_Terminator65

Dialogue_Index_0054:
.db $E0, "TO EPPI.", Dialogue_Terminator65

Dialogue_Index_0056:
.db $EC, $E1, "LOOKING", Dialogue_NewLine
.db "FOR A ", $D8, " KEY?", Dialogue_Terminator62

Dialogue_Index_0058:
.db "I", Dialogue_Apostrophe, "VE HIDDEN A", Dialogue_NewLine
.db $D8, " KEY IN THE", Dialogue_NewPage

Dialogue_Index_005A:
.db "WAREHOUSE IN ", $DE, Dialogue_NewLine
.db "OUTSKIRTS OF ", $DE, Dialogue_NewPage
.db "CAMINEET.", Dialogue_Terminator65

Dialogue_Index_005C:
.db $C3, " WHAT", Dialogue_NewLine
.db $DE, "HARDEST,", Dialogue_NewPage
.db "STRONGEST MATERIALIN OUR ", $B5, " IS?", Dialogue_Terminator62

Dialogue_Index_005E:
.db "IT", Dialogue_Apostrophe, "S ", $BC, "!", Dialogue_NewLine
.db "ARMS MADE WITH", Dialogue_NewPage
.db $BC, " ", $EC, $DE, Dialogue_NewLine
.db "BEST TO HAVE.", Dialogue_Terminator65

Dialogue_Index_0060:
.db "O.K. GOOD DAY.", Dialogue_Terminator65

Dialogue_Index_0062:
.db $C3, " ABOUT", Dialogue_NewLine
.db $DE, $B8, " OF", Dialogue_NewPage
.db $DE, $9B, " STAR", Dialogue_NewLine
.db $9C, "?", Dialogue_Terminator62

Dialogue_Index_0064:
.db $DB, " THREE", Dialogue_NewLine
.db $B8, "; ", $CF, Dialogue_NewPage
.db $94, " AND", Dialogue_NewLine
.db $93, ".", Dialogue_NewPage

Dialogue_Index_0066:
.db $CF, " IS A ", $B5, Dialogue_NewLine
.db "OF GREEN.", Dialogue_NewPage
.db $94, " IS A ", $B5, Dialogue_NewLine
.db "OF SAND.", Dialogue_NewPage
.db $93, " IS A ", $B5, Dialogue_NewLine
.db "OF ICE.", Dialogue_NewPage

Dialogue_Index_0068:
.db $DE, $9B, " STAR", Dialogue_NewLine
.db $9C, " IS", Dialogue_NewPage
.db $90, " ", $FB, Dialogue_NewLine
.db "A ", $E6, "CRISIS.", Dialogue_Terminator65

Dialogue_Index_006A:
.db $E4, "IS PALMA", Dialogue_Apostrophe, "S", Dialogue_NewLine
.db $98, ".", Dialogue_NewPage
.db $FE, $DE, $98, Dialogue_NewLine
.db $E1, "CAN GO TO", Dialogue_NewPage
.db "PASEO ON ", $94, ".", Dialogue_Terminator65

Dialogue_Index_006C:
.db $DE, $AA, " IS INPASEO. HE RULES", Dialogue_NewPage
.db "ALL OF ", $94, ".", Dialogue_Terminator65

Dialogue_Index_006E:
.db "LONG AGO, A", Dialogue_NewLine
.db $E8, " WAS", Dialogue_NewPage
.db "BUILT IN ", $DE, Dialogue_NewLine
.db $95, " ", $BD, ".", Dialogue_Terminator65

Dialogue_Index_0070:
.db $C5, " ", $E2, Dialogue_NewLine
.db $99, "?", Dialogue_Terminator62

Dialogue_Index_0072:
.db $E1, "CAN FILE FOR A", Dialogue_NewLine
.db $99, " ", $D2, ".", Dialogue_NewPage
.db $C6, " ", $F9, "A", Dialogue_NewLine
.db $99, "?", Dialogue_Terminator62

Dialogue_Index_0074:
.db $E3, $E1, "EVER D", $FD, Dialogue_NewLine
.db $F6, $F7, " ILLEGAL? ", Dialogue_Terminator62

Dialogue_Index_0076:
.db $C6, " CURRENTLY", Dialogue_NewLine
.db $E3, "AN ILLNESS?", Dialogue_Terminator62

Dialogue_Index_0078:
.db $DE, $99, " FEE", Dialogue_NewLine
.db "IS 100 ", Dialogue_Mesetas, ".", Dialogue_NewPage
.db "WOULD ", $E1, "PAY IT?", Dialogue_Terminator62

Dialogue_Index_007A:
.db $E2, $99, " IS", Dialogue_NewLine
.db "READY, ", $D2, ".", Dialogue_Terminator65

Dialogue_Index_007C:
.db $B7, ". ", $E3, "A GOODDAY.", Dialogue_Terminator65

Dialogue_Index_007E:
.db $DC, Dialogue_Apostrophe, "S ", $F8, "GOOD.", Dialogue_NewLine
.db "YOU", Dialogue_Apostrophe, "LL ", $E3, "TO", Dialogue_NewPage
.db "COME BACK LATER.", Dialogue_Terminator65

Dialogue_Index_0080:
.db $E0, "TO ", $DE, Dialogue_NewLine
.db "PASEO ", $98, Dialogue_NewPage
.db "ON ", $94, ".", Dialogue_Terminator65

Dialogue_Index_0082:
.db "IT IS SAID ", $DC, Dialogue_NewLine
.db $A3, "S ROAM", Dialogue_NewPage
.db "IN ", $DE, "DESERT.", Dialogue_Terminator65

Dialogue_Index_0084:
.db $DA, " A CAKE", Dialogue_NewLine
.db "SHOP IN ", $DE, "CAVE", Dialogue_NewPage
.db "CALLED NAULA ON", Dialogue_NewLine
.db $CF, "!", Dialogue_Terminator65

Dialogue_Index_0086:
.db $94, Dialogue_Apostrophe, "S ", $AA, "AND ", $D4, " ", $EC, "NOT", Dialogue_NewPage
.db "ON GOOD TERMS, IT", Dialogue_NewLine
.db "IS SAID.", Dialogue_Terminator65

Dialogue_Index_0088:
.db "A GIFT IS NEEDED", Dialogue_NewLine
.db "IF ", $E1, $97, " TO SEE", Dialogue_NewPage
.db $DE, $AA, ".", Dialogue_Terminator65

Dialogue_Index_008A:
.db $DE, $AA, " LOVESSWEETS, I HEAR.", Dialogue_Terminator65

Dialogue_Index_008C:
.db $DA, " A CAVE", Dialogue_NewLine
.db "CALLED ", $A7, " IN", Dialogue_NewPage
.db "A ", $E5, " TO ", $DE, Dialogue_NewLine
.db "NORTH OF PASEO.", Dialogue_Terminator65

Dialogue_Index_008E:
.db $E4, "IS PASEO", Dialogue_NewLine
.db $94, Dialogue_Apostrophe, "S CAPITAL.", Dialogue_Terminator65

Dialogue_Index_0090:
.db "IT", Dialogue_Apostrophe, "S ", $F8, "POSSIBLE", Dialogue_NewLine
.db "TO ", $A2, " ", $DD, Dialogue_NewPage
.db $A3, " ON FOOT.", Dialogue_Terminator65

Dialogue_Index_0092:
.db "I ", $E3, "AN RARE", Dialogue_NewLine
.db "ANIMAL ", $D2, ". WOULD", Dialogue_NewPage
.db $E1, "PAY 1 BILLION", Dialogue_NewLine
.db Dialogue_Mesetas, " FOR IT?", Dialogue_Terminator62

Dialogue_Index_0094:
.db $E1, $EC, "A LIAR!", Dialogue_Terminator65

Dialogue_Index_0096:
.db $B7, " ", $E1, $E3, "A", Dialogue_NewLine
.db $AC, " POT.", Dialogue_NewPage

Dialogue_Index_0098:
.db "SHALL I TRADE ", $DE, Dialogue_NewLine
.db "ANIMAL FOR IT?", Dialogue_Terminator62

Dialogue_Index_009A:
.db "ALL RIGHT, ", $D1, Dialogue_NewLine
.db $E1, "GO WITH HIM.", Dialogue_Terminator65

Dialogue_Index_009C:
.db $C5, " A", Dialogue_NewLine
.db $DF, " TO GIVE TO", Dialogue_NewPage
.db $DE, $AA, "?", Dialogue_Terminator62

Dialogue_Index_009E:
.db "I", Dialogue_Apostrophe, "LL TAKE ", $DE, Dialogue_NewLine
.db "SHORTCAKE NOW.", Dialogue_Terminator65

Dialogue_Index_00A0:
.db "I DON", Dialogue_Apostrophe, "T THINK ", $E1, Dialogue_NewLine
.db $E3, "A SUITABLE", Dialogue_NewPage
.db $DF, ".", Dialogue_Terminator65

Dialogue_Index_00A2:
.db "GO BACK TO ", $E2, Dialogue_NewLine
.db "HOME NOW.", Dialogue_Terminator65

Dialogue_Index_00A4:
.db "I", Dialogue_Apostrophe, "M ", $DE, $AA, ".", Dialogue_NewLine
.db "I", Dialogue_Apostrophe, "M TOLD ", $DC, " ", $E1, Dialogue_NewPage
.db "INTEND TO TRY TO", Dialogue_NewLine
.db "KILL ", $D4, ".", Dialogue_NewPage

Dialogue_Index_00A6:
.db "I ADMIRE ", $E2, Dialogue_NewLine
.db "COURAGE. IN ", $DE, Dialogue_NewPage
.db $A7, " CAVE LIVES", Dialogue_NewLine
.db "AN ESPAR ", $E7, Dialogue_NewPage

Dialogue_Index_00A8:
.db "NOAH. ", $CC, " GIVE", Dialogue_NewLine
.db $E1, "A LETTER OF", Dialogue_NewPage
.db "INTRODUCTION TO", Dialogue_NewLine
.db $DF, " TO HER.", Dialogue_NewPage

Dialogue_Index_00AA:
.db "I ", $E3, "FAITH ", $DC, Dialogue_NewLine
.db $CB, " KILL", Dialogue_NewPage
.db $D4, " AND RETURN", Dialogue_NewLine
.db $D2, " EVENTUALLY.", Dialogue_Terminator65

Dialogue_Index_00AC:
.db "IF ", $DE, $AA, Dialogue_NewLine
.db "ORDERS NOAH TO DO", Dialogue_NewPage
.db $D5, $F7, ",HE WILL", Dialogue_NewLine
.db "LIKELY OBEY.", Dialogue_Terminator65

Dialogue_Index_00AE:
.db "WHO ", $EC, "YOU? I", Dialogue_Apostrophe, "M", Dialogue_NewLine
.db "BUSY WITH MY", Dialogue_NewPage

Dialogue_Index_00B0:
.db "TRAINING NOW! DO", Dialogue_NewLine
.db $F8, "BE A NUISANCE!", Dialogue_Terminator65

Dialogue_Index_00B2:
.db "HELLO!", Dialogue_Terminator65

Dialogue_Index_00B4:
.db "ZZZ...ZZZ...", Dialogue_Terminator65

Dialogue_Index_00B6:
.db $C9, $BF, " ", $E2, Dialogue_NewLine
.db "WEARY B", $FD, "S.", Dialogue_Terminator65

Dialogue_Index_00B8:
.db "I AM PRAYING FOR", Dialogue_NewLine
.db $E2, "SAFETY.", Dialogue_Terminator65

Dialogue_Index_00BA:
.db "COULD YA SP", $EC, "ME", Dialogue_NewLine
.db "A CUP OF COLA?", Dialogue_Terminator62

Dialogue_Index_00BC:
.db $B3, "! ", $E4, "WAS", Dialogue_NewLine
.db "ONCE ", $DE, "LAB. OF", Dialogue_NewPage

Dialogue_Index_00BE:
.db "DR.", $AD, ". HE WENTBONKERS, THOUGH", Dialogue_NewPage

Dialogue_Index_00C0:
.db "AND BE INPRIS", $FD, "D", Dialogue_NewLine
.db "IN TRIADA TO ", $DE, Dialogue_NewPage
.db "SOUTH OF ", $D2, ".", Dialogue_Terminator65

Dialogue_Index_00C2:
.db "I GOT NOTHIN", Dialogue_Apostrophe, " TO", Dialogue_NewLine
.db "SAY T", Dialogue_Apostrophe, "YA!GET LOST!", Dialogue_Terminator65

Dialogue_Index_00C4:
.db "DON", Dialogue_Apostrophe, "T GO NEAR ", $DE, Dialogue_NewLine
.db $9D, " AT ", $DE, "FAR", Dialogue_NewPage

Dialogue_Index_00C6:
.db "END OF ", $DE, "NARROW", Dialogue_NewLine
.db "ROAD WHICH GOES", Dialogue_NewPage
.db $FE, $DE, $95, Dialogue_NewLine
.db $C4, " ", $DD, " THE", Dialogue_NewPage

Dialogue_Index_00C8:
.db $E5, "S. A ", $EF, "BEAST LIVES ", $D1, ".", Dialogue_NewPage
.db "LOOK AT IT AND YA", Dialogue_NewLine
.db "TURN TO ST", $FD, ".", Dialogue_Terminator65

Dialogue_Index_00CA:
.db "AH, IT", Dialogue_Apostrophe, "S GETTING", Dialogue_NewLine
.db "LATE! FETCH MY", Dialogue_NewPage

Dialogue_Index_00CC:
.db "ASSISTANT. HE", Dialogue_Apostrophe, "S", Dialogue_NewLine
.db "LIKELY HIDING", Dialogue_NewPage
.db "IN ", $DE, "UNDERGROUND", $BA, ".", Dialogue_Terminator65

Dialogue_Index_00CE:
.db $EB, Dialogue_Terminator65

Dialogue_Index_00D0:
.db $E1, "DON", Dialogue_Apostrophe, "T ", $E3, Dialogue_NewLine
.db "ENOUGH. COME BACK", Dialogue_NewPage
.db "AGAIN WHEN ", $E1, Dialogue_NewLine
.db $E3, "ENOUGH FUNDS.", Dialogue_Terminator65

Dialogue_Index_00D2:
.db "SUCCESS! I ", $DF, "A SUPERB ", $E8, Dialogue_NewPage
.db $DE, $AD, ".", Dialogue_Terminator65

Dialogue_Index_00D4:
.db "IF ", $E1, "DON", Dialogue_Apostrophe, "T OBEY", Dialogue_NewLine
.db "ME, I ", $88, " ", $CA, ".", Dialogue_Terminator65

Dialogue_Index_00D6:
.db "BUT ", $E1, $88, " FLY", Dialogue_NewLine
.db "A ", $E8, ".", Dialogue_Terminator65

Dialogue_Index_00D8:
.db "HOW IS ", $DE, $AD, "?USE IT WELL.", Dialogue_Terminator65

Dialogue_Index_00DA:
.db $DC, Dialogue_Apostrophe, "S TOO BAD.", Dialogue_NewLine
.db "AND ", $E1, $E3, "COME", Dialogue_NewPage
.db "SO FAR, TOO.", Dialogue_Terminator65

Dialogue_Index_00DC:
.db "I", Dialogue_Apostrophe, "M BUSY.DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db "BOTHER ME.", Dialogue_Terminator65

Dialogue_Index_00DE:
.db "I", Dialogue_Apostrophe, "M ", $AD, ". IF", Dialogue_NewLine
.db "YOU", Dialogue_Apostrophe, "VE COME FOR", Dialogue_NewPage
.db $CA, ", ", $E1, "HAD BESTFORGET IT. LEAVE!", Dialogue_Terminator65

Dialogue_Index_00E0:
.db $E1, $F9, "ME TO", Dialogue_NewLine
.db "BUILD A ", $E8, Dialogue_NewPage
.db "FOR ", $E1, "? ", $F8, "A", Dialogue_NewLine
.db "CHANCE! I CAN", Dialogue_Apostrophe, "T", Dialogue_NewPage
.db "ACCEPT SUCH", Dialogue_NewLine
.db "RESPONSIBILITY.", Dialogue_Terminator65

Dialogue_Index_00E2:
.db $E1, $EC, "CERTAINLY", Dialogue_NewLine
.db "PERSISITENT. WELL,", Dialogue_NewPage
.db "IF ", $CB, " DO AS", Dialogue_NewLine
.db "I SAY, ", $CC, " ", $CA, Dialogue_NewPage
.db "YOU. IS IT A DEAL?", Dialogue_Terminator62

Dialogue_Index_00E4:
.db "O.K. ", $CC, " GO TO", Dialogue_NewLine
.db $95, " ", $9E, Dialogue_NewPage
.db "NEARBY TO MAKE", Dialogue_NewLine
.db "PREPARATIONS. COME", Dialogue_NewPage
.db "THEN. DO ", $F8, "WASTEWORRY ON ME.", Dialogue_Terminator65

Dialogue_Index_00E6:
.db $C5, " ", $E2, Dialogue_NewLine
.db $A0, "?", Dialogue_Terminator62

Dialogue_Index_00E8:
.db $E1, $EC, "A FOOL!", Dialogue_NewLine
.db $CB, " DIE!", Dialogue_Terminator65

Dialogue_Index_00EA:
.db "SPIDER MONSTERS", Dialogue_NewLine
.db $EC, "ACTUALLY", Dialogue_NewPage
.db "VERY INTELLIGENT.", Dialogue_Terminator65

Dialogue_Index_00EC:
.db $C3, " ", $DE, Dialogue_NewLine
.db "ROBOT ", $8A, "?", Dialogue_Terminator62

Dialogue_Index_00EE:
.db "ON ", $DE, "FAR SIDE OF", $DE, $E5, "S LIES", Dialogue_NewPage
.db "A POOL OF MOLTEN", Dialogue_NewLine
.db "LAVA CREATED BY A", Dialogue_NewPage
.db "VOLCANIC ERUPTION.", Dialogue_Terminator65

Dialogue_Index_00F0:
.db $DE, $9D, " DEEP IN", Dialogue_NewLine
.db $DE, $95, Dialogue_NewPage
.db $E5, "S IS KNOWNAS ", $EA, Dialogue_Apostrophe, "S ", $9D, ".", Dialogue_Terminator65

Dialogue_Index_00F2:
.db "I HAVEN", Dialogue_Apostrophe, "T SEEN", Dialogue_NewLine
.db $F6, $FD, " FOR A LONG", Dialogue_NewPage
.db $9F, ". ", $CD, Dialogue_NewLine
.db "TALK WITH ME?", Dialogue_Terminator62

Dialogue_Index_00F4:
.db "POLYMETERAL ", $C7, Dialogue_NewLine
.db "DISSOLVE ALL", Dialogue_NewPage
.db "MATERIALS EXCEPT", Dialogue_NewLine
.db "FOR ", $BC, ".", Dialogue_Terminator65

Dialogue_Index_00F6:
.db "WHAT? DR.", $AD, Dialogue_NewLine
.db "HAS RETURNED?", Dialogue_NewPage
.db "HE ", $C7, " BUILD", Dialogue_NewLine
.db "ANOTHER ", $E8, "?", Dialogue_NewPage
.db "I ", $C7, " BE ", $D1, Dialogue_NewLine
.db "RIGHT AWAY.", Dialogue_Terminator65

Dialogue_Index_00F8:
.db "NO MAN ", $DC, " GOES", Dialogue_NewLine
.db "INTO ", $DE, "ROOM IN", Dialogue_NewPage
.db $DE, "FAR CORNER HASEVER COME OUT", Dialogue_NewPage
.db "ALIVE! AHA-HA-HA!", Dialogue_Terminator65

Dialogue_Index_00FA:
.db "IT SEEMS TO BE A", Dialogue_NewLine
.db "MAN WHO HAS BEEN", Dialogue_NewPage
.db $91, "!", Dialogue_NewLine
.db "I WONDER IF HE CAN", Dialogue_NewPage
.db "BE RETURNED TO HISORIGINAL FORM?", Dialogue_Terminator65

Dialogue_Index_00FC:
.db $CB, " SOON FIND", Dialogue_NewLine
.db "OUT ", $DE, "TRUTH!", Dialogue_Terminator65

Dialogue_Index_00FE:
.db "HALT! GO BACK!", Dialogue_NewLine
.db $E2, "LAST CHANCE!", Dialogue_Terminator65

Dialogue_Index_0100:
.db "HOW BRAVE! BUT BE", Dialogue_NewLine
.db $ED, " OF TRAPS!", Dialogue_Terminator65

Dialogue_Index_0102:
.db $A8, " IS MY", Dialogue_NewLine
.db "TURF. DON", Dialogue_Apostrophe, "T YA", Dialogue_NewPage
.db "MESS ", Dialogue_Apostrophe, "ROUND ", $D2, ",", Dialogue_NewLine
.db "NOW GIT!", Dialogue_Terminator65

Dialogue_Index_0104:
.db $CE, " FIND A", Dialogue_NewLine
.db "ROBOT ", $E7, Dialogue_NewPage
.db $8A, ". HE CAN FLYA ", $E8, ".", Dialogue_Terminator65

Dialogue_Index_0106:
.db "IN ", $E4, "PILE OF", Dialogue_NewLine
.db "JUNK, ", $D5, $D0, ",", Dialogue_NewPage

Dialogue_Index_0108:
.db $DA, " S", Dialogue_Apostrophe, "PPOSED", Dialogue_NewLine
.db "T", Dialogue_Apostrophe, "BE A USABLE", Dialogue_NewPage
.db "ROBOT,BUT ", $E1, $BE, Dialogue_NewLine
.db "HOW RUMORS BE.", Dialogue_Terminator65

Dialogue_Index_010A:
.db "POLYMETERAL IS FOR", Dialogue_NewLine
.db "SALE IN ABION.", Dialogue_Terminator65

Dialogue_Index_010C:
.db $E4, $B9, " IS", Dialogue_NewLine
.db "CALLED LOAR.", Dialogue_NewPage
.db "WE ", $E3, "BEEN IN", Dialogue_NewLine
.db "DECLINE ", $B3, " TO", Dialogue_NewPage
.db $DE, "WORK OF", Dialogue_NewLine
.db $D4, ".", Dialogue_Terminator65

Dialogue_Index_010E:
.db $E3, $E1, "HEARD OF", Dialogue_NewLine
.db "A GEM CALLED \"", $DE, Dialogue_NewPage
.db "AMBER EYE\"?", Dialogue_NewLine

Dialogue_Index_0110:
.db $D5, " SAY ", $DE, "CASBA", Dialogue_NewPage
.db "DRAGON HAS ", $FD, ".", Dialogue_Terminator65

Dialogue_Index_0112:
.db $DA, " A ", $9E, "CALLED ABION ON", Dialogue_NewPage
.db $DE, "WESTERN EDGE", Dialogue_NewLine
.db "ON ", $E4, "ISLAND.", Dialogue_Terminator65

Dialogue_Index_0114:
.db $C3, " ABOUT", Dialogue_NewLine
.db $D7, " TREES?", Dialogue_Terminator62

Dialogue_Index_0116:
.db "THEY GROW ON ", $DE, Dialogue_NewLine
.db "ALTIPLANO PLATEAU", Dialogue_NewPage
.db "ON ", $DE, $9A, Dialogue_NewLine
.db $93, ".", Dialogue_Terminator65

Dialogue_Index_0118:
.db $E1, $EC, "GOING TO", Dialogue_NewLine
.db "TRY TO KILL ", $D4, Dialogue_NewPage
.db "I HEAR. ", $DC, Dialogue_Apostrophe, "S", Dialogue_NewLine
.db "GREAT!", Dialogue_NewPage

Dialogue_Index_011A:
.db "I ", $E3, "HEARD ", $DC, Dialogue_NewLine
.db "A CERTAIN", Dialogue_NewPage
.db "CRYSTAL ", $C7, " BLOCK", Dialogue_NewLine
.db "EVIL ", $EF, ".", Dialogue_Terminator65

Dialogue_Index_011C:
.db $E0, "TO ABION.", Dialogue_Terminator65

Dialogue_Index_011E:
.db $CA, "! ", $D4, " HAS", Dialogue_NewLine
.db "COME TO ", $E4, $B9, "!", Dialogue_Terminator65

Dialogue_Index_0120:
.db "A ", $AC, " MAN CAMETO ", $E4, $B9, ". HE", Dialogue_NewPage
.db "SEEMS TO BE", Dialogue_NewLine
.db "PERFORMING ANIMAL", Dialogue_NewPage

Dialogue_Index_0122:
.db "EXPERIMENTS. HE", Dialogue_NewLine
.db "BROUGHT A LARGE", Dialogue_NewPage
.db "POT OR ", $D5, $F7, ".", Dialogue_Terminator65

Dialogue_Index_0124:
.db "IT", Dialogue_Apostrophe, "S A ROBOT MADE", Dialogue_NewLine
.db "OF ", $BC, ". BUT", Dialogue_NewPage
.db "IT HAS BEEN", Dialogue_NewLine
.db "ABAND", $FD, "D", Dialogue_NewPage
.db $D5, $D0, " AS", Dialogue_NewLine
.db "BEING USELESS.", Dialogue_Terminator65

Dialogue_Index_0126:
.db "I", Dialogue_Apostrophe, "D LIKE TO TRAVELIN OUTER SPACE.", Dialogue_Terminator65

Dialogue_Index_0128:
.db $D5, " CATS, IF THEYEAT A CERTAIN TYPE", Dialogue_NewPage
.db "OF NUT,THEY BECOMEHUGE AND CAN FLY.", Dialogue_NewPage

Dialogue_Index_012A:
.db "IT", Dialogue_Apostrophe, "S REALLY VERY", Dialogue_NewLine
.db "WIERD.", Dialogue_Terminator65

Dialogue_Index_012C:
.db "I", Dialogue_Apostrophe, "M ", $8A, ".", Dialogue_NewLine
.db $B3, " FOR FINDING", Dialogue_NewPage
.db "ME. I CAN FLY ", $DE, Dialogue_NewLine
.db $AD, " FOR YOU.", Dialogue_Terminator65

Dialogue_Index_012E:
.db $E4, $B9, " IS", Dialogue_NewLine
.db "CALLED UZO.", Dialogue_Terminator65

Dialogue_Index_0130:
.db "IF ", $E1, "USE A", Dialogue_NewLine
.db "VEHICLE CALLED THE", Dialogue_NewPage
.db "LAND ROVER, ", $DE, Dialogue_NewLine
.db $A3, " ", $C7, " NOT", Dialogue_NewPage
.db "BE ABLE TO HARM", Dialogue_NewLine
.db "YOU.", Dialogue_Terminator65

Dialogue_Index_0132:
.db $DA, " A ", $B9, Dialogue_NewLine
.db "CALLED CASBA TO", Dialogue_NewPage
.db $DE, "SOUTH OF ", $D2, ".", Dialogue_Terminator65

Dialogue_Index_0134:
.db $DB, " DRAGONS", Dialogue_NewLine
.db "LIVING IN ", $DE, Dialogue_NewPage
.db "CASBA CAVE. THESE", Dialogue_NewLine
.db "DRAGONS ", $E3, "GEMS", Dialogue_NewPage
.db "IN THEIR HEADS!", Dialogue_Terminator65

Dialogue_Index_0136:
.db $E3, $E1, "HEARD", Dialogue_NewLine
.db "ABOUT MANTLES MADE", Dialogue_NewPage
.db "OF FRAD FIBERS?", Dialogue_NewLine

Dialogue_Index_0138:
.db "THEY ", $EC, "LIGHT,", Dialogue_NewPage
.db "BUT PROVIDE ", $E6, Dialogue_NewLine
.db "PROTECTION.", Dialogue_Terminator65

Dialogue_Index_013A:
.db $E3, $E1, "HEARD", Dialogue_NewLine
.db "ABOUT ", $DE, Dialogue_NewPage
.db $A4, "?", Dialogue_Terminator62

Dialogue_Index_013C:
.db "OH, NEVER MIND.", Dialogue_Terminator65

Dialogue_Index_013E:
.db "IT", Dialogue_Apostrophe, "S A ", $A5, ", BUTI BURIED ", $FD, " AT", Dialogue_NewPage
.db $DE, "OUTSKIRTS OF", Dialogue_NewLine
.db $DE, $B9, " OF ", $95, Dialogue_NewPage

Dialogue_Index_0140:
.db "ON ", $CF, ". DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db "TELL ", $F6, $FD, ".", Dialogue_Terminator65

Dialogue_Index_0142:
.db "I DON", Dialogue_Apostrophe, "T ", $BE, " WHO", Dialogue_NewLine
.db "TOLD ", $E1, $DC, ".", Dialogue_NewPage
.db $E1, "HAD BEST", Dialogue_NewLine
.db "FORGET IT.", Dialogue_Terminator65

Dialogue_Index_0144:
.db "I TELL ", $E1, "NO ", $FD, Dialogue_NewLine
.db "CAN DO.GO ON BACK", Dialogue_NewPage
.db "TO WHEREVER ", $E1, Dialogue_NewLine
.db "CAME FROM.", Dialogue_Terminator65

Dialogue_Index_0146:
.db "ALL RIGHT, ALL", Dialogue_NewLine
.db "RIGHT. I GIVE UP.", Dialogue_NewPage
.db "BUT DON", Dialogue_Apostrophe, "T TELL", Dialogue_NewLine
.db $F6, $FD, " ", $D0, " ", $E1, Dialogue_NewPage
.db "GOT THIS, O.K.?", Dialogue_Terminator65

Dialogue_Index_0148:
.db "I", Dialogue_Apostrophe, "M ", $DE, $E6, Dialogue_NewLine
.db "DAMOR, ", $BB, "!", Dialogue_NewPage

Dialogue_Index_014A:
.db $C6, " BELIEVE IN", Dialogue_NewLine
.db "MY PROPHECIES?", Dialogue_Terminator62

Dialogue_Index_014C:
.db "I", Dialogue_Apostrophe, "VE GOT A FRIEND", Dialogue_NewLine
.db "IN ", $A8, ". HE", Dialogue_Apostrophe, "S", Dialogue_NewPage
.db "PROBABLY HAVING A", Dialogue_NewLine
.db "HARD ", $9F, " BECAUSE", Dialogue_NewPage
.db "OF ", $DE, "LAVA. WHY", Dialogue_NewLine
.db $F8, "VISIT HIM?", Dialogue_Terminator65

Dialogue_Index_014E:
.db "GOOD!", Dialogue_Terminator65

Dialogue_Index_0150:
.db "YOU", Dialogue_Apostrophe, "RE SEARCHING", Dialogue_NewLine
.db "FOR ", $D5, $F7, "?", Dialogue_Terminator62

Dialogue_Index_0152:
.db "LEAVE MY SIGHT,", Dialogue_NewLine
.db "UNBELIEVER!", Dialogue_Terminator65

Dialogue_Index_0154:
.db $E1, $EC, "SEARCHING", Dialogue_NewLine
.db "FOR ALEX OSSALE?", Dialogue_Terminator62

Dialogue_Index_0156:
.db "EVERY", $F7, " I", Dialogue_Apostrophe, "VE", Dialogue_NewLine
.db "SAID IS CORRECT?", Dialogue_Terminator62

Dialogue_Index_0158:
.db "THEN, COME AGAIN,", Dialogue_NewLine
.db $F6, $9F, ".", Dialogue_Terminator65

Dialogue_Index_015A:
.db $C6, " CONTRADICT", Dialogue_NewLine
.db $DE, $E6, "DAMOR?!?", Dialogue_Terminator62

Dialogue_Index_015C:
.db "OF COURSE NOT!YOU", Dialogue_NewLine
.db $EC, "A PROMISING", Dialogue_NewPage
.db "YOUNG LASS! ", $CC

Dialogue_Index_015E:
.db "GIVE ", $E1, "A ", $EF, Dialogue_NewPage
.db "CRYSTAL FOR A", Dialogue_NewLine
.db "REWARD.", Dialogue_Terminator65

Dialogue_Index_0160:
.db $C6, " COME IN", Dialogue_NewLine
.db "FULL KNOWLEDGE OF", Dialogue_NewPage
.db $DE, $9D, " OF ", $C0, Dialogue_NewLine
.db $C1, "?", Dialogue_Terminator62

Dialogue_Index_0162:
.db $CB, " SURELY", Dialogue_NewLine
.db "INCUR ", $DE, "WRATH", Dialogue_NewPage
.db "OF ", $DE, "HEAVENS!", Dialogue_Terminator65

Dialogue_Index_0164:
.db "GO BACK BEFORE IT", Dialogue_NewLine
.db "IS TOO LATE.", Dialogue_Terminator65

Dialogue_Index_0166:
.db $E4, $B9, " IS", Dialogue_NewLine
.db "CALLED CASBA.", Dialogue_Terminator65

Dialogue_Index_0168:
.db "FIERCE DRAGONS", Dialogue_NewLine
.db "LIVE IN ", $DE, "CAVE", Dialogue_NewPage
.db "NEAR ", $D2, ",AND I", Dialogue_Apostrophe, "M", Dialogue_NewLine
.db "SCARED OF THEM.", Dialogue_Terminator65

Dialogue_Index_016A:
.db "DON", Dialogue_Apostrophe, "T BELIEVE YOUR", Dialogue_NewLine
.db "OWN EYES IN ", $DE, Dialogue_NewPage
.db "DEPTH OF ", $DE, Dialogue_NewLine
.db $D8, "S.", Dialogue_Terminator65

Dialogue_Index_016C:
.db $DB, " LEGENDS", Dialogue_NewLine
.db "OF A MYSTIC ", $B6, Dialogue_NewPage
.db "IN A ", $9E, Dialogue_NewLine
.db "SURROUNDED IN MIST", Dialogue_NewPage

Dialogue_Index_016E:
.db "IT IS ", $DE, $B6, Dialogue_NewLine
.db "PERSEUS USED IN", Dialogue_NewPage
.db "DAYS TO CONQUER", Dialogue_NewLine
.db $84, "BEASTS.", Dialogue_Terminator65

Dialogue_Index_0170:
.db $DA, " POISON", Dialogue_NewLine
.db "GAS ABOVE ", $DE, "SEA", Dialogue_NewPage
.db "TO ", $DE, "WEST. NO", Dialogue_NewLine
.db $FD, " CAN GO NEAR", Dialogue_NewPage
.db $D1, " WITHOUT ", $D5, "PROTECTION.", Dialogue_Terminator65

Dialogue_Index_0172:
.db $E3, $E1, "HEARD OF", Dialogue_NewLine
.db "VEHICLE CALLED", Dialogue_NewPage
.db $DE, "HOVERCRAFT?", Dialogue_Terminator62

Dialogue_Index_0174:
.db "I BOUGHT IT IN", Dialogue_NewLine
.db $96, " ON ", $CF, Dialogue_NewPage
.db "BUT IT SEEMED", Dialogue_NewLine
.db "BROKEN SO I", Dialogue_NewPage
.db "ABAND", $FD, "D IT IN", Dialogue_NewLine

Dialogue_Index_0176:
.db $A8, ". IT", Dialogue_NewPage
.db "PROBABLY CAN STILLBE USED, THOUGH.", Dialogue_Terminator65

Dialogue_Index_0178:
.db $E1, "FOUND ", $DE, Dialogue_NewLine
.db "HOVERCRAFT.", $8A, Dialogue_NewPage
.db "HAS RESTORED IT TO", Dialogue_NewLine

Dialogue_Index_017A:
.db "WORKING ORDER.", Dialogue_Terminator65

Dialogue_Index_017C:
.db "IT", Dialogue_Apostrophe, "S A GOOD ", $F7, Dialogue_NewLine
.db "TO HAVE. IT ", $F3, "S", Dialogue_NewPage
.db "ACROSS WATER.", Dialogue_Terminator65

Dialogue_Index_017E:
.db $E0, "TO DRASGOW-- A SMALL ", $B9, Dialogue_NewPage
.db "ON ", $DE, "OCEAN.", Dialogue_Terminator65

Dialogue_Index_0180:
.db $E1, $EC, "DARING TO", Dialogue_NewLine
.db $E3, "FOUND ", $E2, Dialogue_NewPage
.db "WAY ", $D2, " EVEN", Dialogue_NewLine

Dialogue_Index_0182:
.db "THOUGH ", $DE, "SEA", Dialogue_NewPage
.db "LANES ", $EC, "CLOSED", Dialogue_NewLine
.db "TO SHIPS.", Dialogue_Terminator65

Dialogue_Index_0184:
.db $DA, " A ", $EF, Dialogue_NewLine
.db "SWORD IN A ", $9D, Dialogue_NewPage
.db "ON A FORGOTTEN", Dialogue_NewLine
.db "ISLAND.", Dialogue_Terminator65

Dialogue_Index_0186:
.db "LONG AGO, I SAW A", Dialogue_NewLine
.db "GIANT ROCK FLOAT", Dialogue_NewPage
.db $DD, " ", $DE, "SKY.", Dialogue_Terminator65

Dialogue_Index_0188:
.db $DE, "TOP OF ", $DE, Dialogue_NewLine
.db $AB, " CALLED ", $C0, Dialogue_NewPage
.db $C1, " IS ALWAYS", Dialogue_NewLine
.db "HIDDEN BY CLOUDS.", Dialogue_NewPage

Dialogue_Index_018A:
.db $D5, $F7, " ", $C8, " BE", Dialogue_NewLine
.db "UP ", $D1, "!", Dialogue_Terminator65

Dialogue_Index_018C:
.db "I HEARD ", $DC, " THEY", Dialogue_NewLine
.db "SELL GAS ", $B6, Dialogue_NewPage
.db $D2, ", BUT I DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db $BE, " ", $D0, " ", $DE, Dialogue_NewPage
.db "SHOP IS!", Dialogue_NewLine

Dialogue_Index_018E:
.db "WHAT A MESS!", Dialogue_Terminator65

Dialogue_Index_0190:
.db $E0, "TO OUR", Dialogue_NewLine
.db "STORE. WHAT CAN I", Dialogue_NewPage
.db $CA, " ", $E1, "WITH?", Dialogue_NewPage

Dialogue_Index_0192:
.db "AHH, I WAS PULLING", $E2, "LEG! WHAT", Dialogue_Apostrophe, "S", Dialogue_NewPage
.db "A MATTER, CAN", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db $E1, "TAKE A JOKE?", Dialogue_Terminator65

Dialogue_Index_0194:
.db "I BET ", $E1, $EC, Dialogue_NewLine
.db "SURPRISED TO SEE A", Dialogue_NewPage
.db "SHOP IN A PLACE", Dialogue_NewLine
.db "LIKE THIS!", Dialogue_NewPage

Dialogue_Index_0196:
.db "A GAS ", $B6, " IS", Dialogue_NewLine
.db "ONLY 1000 ", Dialogue_Mesetas, "!", Dialogue_NewPage
.db "PRETTY CHEAP, HUH?", $CD, " BUY ", $FD, "?", Dialogue_Terminator62

Dialogue_Index_0198:
.db $B3, "! SEE ", $E1, Dialogue_NewLine
.db "AGAIN.", Dialogue_Terminator65

Dialogue_Index_019A:
.db $E1, "DON", Dialogue_Apostrophe, "T ", $E3, Dialogue_NewLine
.db "ENOUGH M", $FD, "Y!", Dialogue_Terminator65

Dialogue_Index_019C:
.db "SORRY, ", $DC, " WAS", Dialogue_NewLine
.db $E2, "ONLY CHANCE.", Dialogue_Terminator65

Dialogue_Index_019E:
.db $DE, $98, " IS", Dialogue_NewLine
.db "CLOSED.", Dialogue_Terminator65

Dialogue_Index_01A0:
.db $8B, "CONFISCAT-", Dialogue_NewLine
.db "ING ", $E2, $99, ".", Dialogue_Terminator65

Dialogue_Index_01A2:
.db $E0, "TO SKURE", Dialogue_NewLine
.db "ON ", $93, ".", Dialogue_NewPage
.db "IT", Dialogue_Apostrophe, "S FREEZING", Dialogue_NewLine
.db "OUTSIDE, ISN", Dialogue_Apostrophe, "T IT?", Dialogue_Terminator65

Dialogue_Index_01A4:
.db "MOST EMIGRANTS", Dialogue_NewLine
.db $FE, $CF, Dialogue_NewPage
.db "SETTLE ", $D2, ".", Dialogue_Terminator65

Dialogue_Index_01A6:
.db "I DON", Dialogue_Apostrophe, "T ", $BE, " A LOTABOUT ", $E4, $9A, ",", Dialogue_NewPage

Dialogue_Index_01A8:
.db "BUT WORD HAS IT", Dialogue_NewLine
.db $DC, " ", $DA, " A", Dialogue_NewPage
.db $B9, " OF NATIVE", Dialogue_NewLine
.db $F4, "S IN ", $DE, Dialogue_NewPage
.db "FAR REACHES OF THE", $E5, "S.", Dialogue_Terminator65

Dialogue_Index_01AA:
.db "IF ", $E1, "REALLY HOPETO KILL ", $D4, ",", Dialogue_NewPage

Dialogue_Index_01AC:
.db $E1, "HAD BEST FIND", Dialogue_NewLine
.db "A SWORD, AXE,", Dialogue_NewPage
.db $B6, ", ARMOR", Dialogue_NewLine
.db "MADE OF ", $BC, ".", Dialogue_NewPage

Dialogue_Index_01AE:
.db "SUCH WEAPONS ", $EC, Dialogue_NewLine
.db "STRONGEST.", Dialogue_NewPage

Dialogue_Index_01B0:
.db "I PRAY FOR ", $E2, Dialogue_NewLine
.db "SAFETY.", Dialogue_Terminator65

Dialogue_Index_01B2:
.db "ARMS MADE OF", Dialogue_NewLine
.db $BC, " CONCEAL", Dialogue_NewPage
.db "HOLY POWER. ", $D4

Dialogue_Index_01B4:
.db "FEARS ", $E4, "POWER", Dialogue_NewPage
.db "AND HAS BEEN", Dialogue_NewLine
.db "RUNNING AND HIDING", Dialogue_NewPage
.db "IN DIFFERENT", Dialogue_NewLine

Dialogue_Index_01B6:
.db "PLACES IN ", $DE, Dialogue_NewPage
.db $B8, " OF ", $DE, Dialogue_NewLine
.db $9B, " ", $9C, ".", Dialogue_Terminator65

Dialogue_Index_01B8:
.db $93, " IS A", Dialogue_NewLine
.db $B5, " OF ICE.", Dialogue_Terminator65

Dialogue_Index_01BA:
.db $DB, " PLACES", Dialogue_NewLine
.db "IN ", $DE, $E5, "S", Dialogue_NewPage
.db "WHERE THE ICE IS", Dialogue_NewLine
.db "SOFT AND", Dialogue_NewPage
.db "IMPASSABLE TO", Dialogue_NewLine
.db "THOSE ON FOOT.", Dialogue_Terminator65

Dialogue_Index_01BC:
.db $DE, "ALTIPLANO", Dialogue_NewLine
.db "PLATEAU IS AT ", $DE, Dialogue_NewPage
.db "TOP OF ", $DE, "ICE", Dialogue_NewLine
.db $E5, ".", Dialogue_Terminator65

Dialogue_Index_01BE:
.db "AN ECLIPSE OCCURS", Dialogue_NewLine
.db "ON ", $E4, $9A, Dialogue_NewPage
.db "ONCE EVERY HUNDREDYEARS. A TORCH", Dialogue_NewPage

Dialogue_Index_01C0:
.db "LIT DURING AN", Dialogue_NewLine
.db "ECLIPSE IS CALLED", Dialogue_NewPage
.db "AN \"ECLIPSE TORCH\""

Dialogue_Index_01C2:
.db "AND IS REGARDED", Dialogue_NewPage
.db "AS HOLY BY ", $DE, Dialogue_NewLine
.db $F4, "S.", Dialogue_Terminator65

Dialogue_Index_01C4:
.db $DE, "DEAD GUARON", Dialogue_NewLine
.db "MORGUE ", $E3, "BEEN", Dialogue_NewPage
.db "CALLED BACK TO", Dialogue_NewLine

Dialogue_Index_01C6:
.db "LIFE! WHAT FEAR!", Dialogue_Terminator65

Dialogue_Index_01C8:
.db $DE, "NEIBORING", Dialogue_NewLine
.db $9E, " ", $EC, "ALL", Dialogue_NewPage
.db "LIARS! DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db "LISTEN TO THEM!", Dialogue_Terminator65

Dialogue_Index_01CA:
.db "ZE CORONA ", $9D, Dialogue_NewLine
.db "STANDS ON ZE", Dialogue_NewPage
.db "FAR SIDE OF ZE", Dialogue_NewLine
.db $E5, " TO ZE", Dialogue_NewPage
.db "NORTH OF ZIS", Dialogue_NewLine
.db $9E, ".", Dialogue_Terminator65

Dialogue_Index_01CC:
.db "TO ZE WEST OF ZE", Dialogue_NewLine
.db "CORONA ", $9D, " IS", Dialogue_NewPage
.db "ZE ", $93, " CAVE.", Dialogue_NewLine

Dialogue_Index_01CE:
.db "OUR FRIENDS ", $EC, "IN", Dialogue_NewPage
.db "ZERE. GIVE ZEM", Dialogue_NewLine
.db "OUR BEST, O.K.?", Dialogue_Terminator65

Dialogue_Index_01D0:
.db $D7, " TREES GROW", Dialogue_NewLine
.db "ZE ", $D7, " BERRIES.", Dialogue_NewPage

Dialogue_Index_01D2:
.db "ZOSE BERRIES ", $EC, Dialogue_NewLine
.db "OUR MOST IMPORTANT", Dialogue_NewPage
.db "FOOD, BUT IT", Dialogue_NewLine
.db "SHRIVELS UP AFTER", Dialogue_NewPage
.db "A FEW MOMENTS,", Dialogue_NewLine

Dialogue_Index_01D4:
.db "UNLESS IT IS PUT", Dialogue_NewPage
.db "IN ", $A6, ".", Dialogue_Terminator65

Dialogue_Index_01D6:
.db $C3, " WHAT", Dialogue_NewLine
.db "AN AEROPRISM IS?", Dialogue_Terminator62

Dialogue_Index_01D8:
.db "IT LETS ", $E1, "SEE", Dialogue_NewLine
.db "ANOTHER ", $B5, ".", Dialogue_Terminator65

Dialogue_Index_01DA:
.db "I", Dialogue_Apostrophe, "D LIKE TO SEE", Dialogue_NewLine
.db $FD, " ", $D5, $9F, ".", Dialogue_Terminator65

Dialogue_Index_01DC:
.db "WE OF ZIS ", $B9, Dialogue_NewLine
.db "HATE ", $E9, ".", Dialogue_Terminator65

Dialogue_Index_01DE:
.db $DA, " A SPRING", Dialogue_NewLine
.db "OF LIFE IN ", $DE, Dialogue_NewPage
.db "CORONA ", $9D, ",", Dialogue_NewLine
.db $DA, ", YES.", Dialogue_Terminator65

Dialogue_Index_01E0:
.db $E1, "CAN WARP ", $FE, Dialogue_NewLine
.db $DE, "10TH LEVEL OF", Dialogue_NewPage
.db $DE, $D8, " UNDER", Dialogue_NewLine
.db $93, ",YES.", Dialogue_Terminator65

Dialogue_Index_01E2:
.db $D7, " BERRIES ARE", Dialogue_NewLine
.db "BLUE ", $D7, " NUTS", Dialogue_NewLine
.db "USED IN DYES,YES,", Dialogue_NewPage
.db "THEY ", $EC, ", ", $D3, ".", Dialogue_Terminator65

Dialogue_Index_01E4:
.db "IF ", $E1, "USE A", Dialogue_NewLine
.db "CRYSTAL IN FRONT", Dialogue_NewPage
.db "OF A ", $D7, " TREE,", Dialogue_NewLine
.db "IT ", $C7, " BECOME,", Dialogue_NewPage
.db "YES, A ", $D7, " NUT,YES, ", $D3, ".", Dialogue_Terminator65

Dialogue_Index_01E6:
.db $E4, $B9, " WELCOMESALL ", $E9, ",YES,", Dialogue_NewPage
.db $D3, ", WE DO.", Dialogue_Terminator65

Dialogue_Index_01E8:
.db $E4, $B9, " IS", Dialogue_NewLine
.db "CALLED SOPIA.", Dialogue_NewPage
.db $E1, $EC, "BRAVE TO", Dialogue_NewLine
.db "PENETRATE ", $DE, "GAS.", Dialogue_Terminator65

Dialogue_Index_01EA:
.db "I", Dialogue_Apostrophe, "M ", $DE, "HEAD OF", Dialogue_NewLine
.db $E4, $9E, ".", Dialogue_NewPage

Dialogue_Index_01EC:
.db "BECAUSE OF ", $DE, Dialogue_NewLine
.db "CLOUD OF GAS,", Dialogue_NewPage
.db $8B, "CUT OFF", Dialogue_NewLine
.db $FE, "OTHER TOWNS,", Dialogue_NewPage
.db $8B, "THEREFORE", Dialogue_NewLine
.db "VERY POOR.", Dialogue_NewPage

Dialogue_Index_01EE:
.db $CD, " DONATE", Dialogue_NewLine
.db "400 ", Dialogue_Mesetas, "?", Dialogue_Terminator62

Dialogue_Index_01F0:
.db $B7, ". WE ", $C8, " GO", Dialogue_NewLine
.db "ON SUFFERING...", Dialogue_Terminator65

Dialogue_Index_01F2:
.db $E1, $E3, "A LITTLE", Dialogue_NewLine
.db "M", $FD, "Y,TOO, ", $B7, ".", Dialogue_Terminator65

Dialogue_Index_01F4:
.db $B3, "! ACCORDING", Dialogue_NewLine
.db "TO OUR LEGENDS,", Dialogue_NewPage

Dialogue_Index_01F6:
.db $DE, "VERY ", $B6, ",", Dialogue_NewLine
.db "PERSEUS USED TO", Dialogue_NewPage
.db "OVERCOME ", $EA, ",ISBURIED ON ", $DE, Dialogue_NewPage

Dialogue_Index_01F8:
.db "SMALL ISLAND IN", Dialogue_NewLine
.db $DE, "MIDDLE OF A", Dialogue_NewPage
.db "LAKE.", Dialogue_Terminator65

Dialogue_Index_01FA:
.db "HI! I", Dialogue_Apostrophe, "M MIKI!", Dialogue_NewLine
.db $C6, " LIKE", Dialogue_NewPage
.db "SEGA ", $FA, "S?", Dialogue_Terminator62

Dialogue_Index_01FC:
.db "OF COURSE! SEGA", Dialogue_NewLine
.db $FA, "S ", $EC, "BEST.", Dialogue_Terminator65

Dialogue_Index_01FE:
.db "I CAN", Dialogue_Apostrophe, "T BELIEVE", Dialogue_NewLine
.db "IT. IF ", $E1, "DON", Dialogue_Apostrophe, "T", Dialogue_NewPage
.db "LIKE ", $DE, $FA, ",....", Dialogue_NewLine
.db "WHY ", $E3, $E1, Dialogue_NewPage
.db "PLAYED SO FAR!?!", Dialogue_Terminator65

Dialogue_Index_0200:
.db "BEFORE ", $D4, " CAMETO POWER, EVEN OUR", Dialogue_NewPage
.db $B9, " HAD PLENTY.", Dialogue_Terminator65

Dialogue_Index_0202:
.db $DA, " A MONK", Dialogue_NewLine
.db $E7, "TAJIM IN THE", Dialogue_NewPage
.db $E5, "S TO ", $DE, Dialogue_NewLine
.db "SOUTH OF ", $DE, "LAKE.", Dialogue_Terminator65

Dialogue_Index_0204:
.db "I", Dialogue_Apostrophe, "VE HEARD ", $DC, Dialogue_NewLine
.db $DE, $CF, " IS A", Dialogue_NewPage
.db "BEAUTIFUL ", $9A, ".", Dialogue_NewLine
.db "IS ", $DC, " TRUE?", Dialogue_Terminator62

Dialogue_Index_0206:
.db "I", Dialogue_Apostrophe, "D LIKE TO GO", Dialogue_NewLine
.db "VISITING ", $D5, "DAY.", Dialogue_Terminator65

Dialogue_Index_0208:
.db "NO? I", Dialogue_Apostrophe, "D LIKE TO GO", $D5, $D0, " ", $DE, "AIR", Dialogue_NewPage
.db "IS MORE CLEAN", Dialogue_NewLine
.db "AND FRESH.", Dialogue_Terminator65

Dialogue_Index_020A:
.db $B3, "!", Dialogue_NewLine
.db "COME AGAIN!", Dialogue_Terminator65

Dialogue_Index_020C:
.db "TIGHTWAND!", Dialogue_Terminator65

Dialogue_Index_020E:
.db $EB, Dialogue_Terminator65

Dialogue_Index_0210:
.db "..........", Dialogue_Terminator65

Dialogue_Index_0212:
.db "THEN ", $E1, $EC, $DE, Dialogue_NewLine
.db "VERY ", $B0, " OF ", $DE, Dialogue_NewPage
.db "ENTIRE ", $9C, ". I", Dialogue_NewLine
.db $C7, " ASSIST ", $E1, "IN", Dialogue_NewPage
.db "ALL WAYS POSSIBLE.", Dialogue_Terminator65

Dialogue_Index_0214:
.db $E1, $E3, "BEEN", Dialogue_NewLine
.db "LOCKED UP,TOO", Dialogue_NewPage

Dialogue_Index_0216:
.db $DA, " A WAY", Dialogue_NewLine
.db "OUT, BUT I LIKE", Dialogue_NewPage
.db "IT IN ", $D2, ",", Dialogue_NewLine
.db "MYSELF.", Dialogue_Terminator65

Dialogue_Index_0218:
.db $DB, " GUARDS", Dialogue_NewLine
.db "UP AHEAD!", Dialogue_Terminator65

Dialogue_Index_021A:
.db "IF ", $E1, "PLAN TO GO", Dialogue_NewLine
.db "BACK, NOW IS ", $DE, Dialogue_NewPage
.db $9F, " TO LEAVE.", Dialogue_Terminator65

Dialogue_Index_021C:
.db $C5, " ", $E2, Dialogue_NewLine
.db $A0, "?", Dialogue_Terminator62

Dialogue_Index_021E:
.db $E4, "IS A FAKE!", Dialogue_NewLine

Dialogue_Index_0220:
.db $C6, " THINK ", $E1, Dialogue_NewPage
.db "CAN FOOL A ROBOT?", Dialogue_NewLine
.db "OFF TO JAIL WE GO!", Dialogue_Terminator65

Dialogue_Index_0222:
.db "GET ME OUT ", $D2, "?", Dialogue_NewLine
.db "BUT IT", Dialogue_Apostrophe, "S IN VAIN.", Dialogue_Terminator65

Dialogue_Index_0224:
.db "IT", Dialogue_Apostrophe, "S FOOLISH TO", Dialogue_NewLine
.db "TRY TO GET ", $D4, "!", Dialogue_Terminator65

Dialogue_Index_0226:
.db $D4, " IS GONNA", Dialogue_NewLine
.db "SACRIFICE US! AGH!", Dialogue_Terminator65

Dialogue_Index_0228:
.db $E3, $E1, "FOUND THE", Dialogue_NewLine
.db "ARMOR IN GUARON?", Dialogue_Terminator62

Dialogue_Index_022A:
.db "IT CAN BE FOUND AT", $DE, "FAR SIDE OF", Dialogue_NewPage
.db "A PIT TRAP.", Dialogue_Terminator65

Dialogue_Index_022C:
.db "WELL,AREN", Dialogue_Apostrophe, "T ", $E1, Dialogue_NewLine
.db $D5, $F7, "?", Dialogue_Terminator65

Dialogue_Index_022E:
.db "ALL WHO FACE", Dialogue_NewLine
.db $D4, " LOSE THEIR", Dialogue_NewPage
.db "SOULS TO HIS", Dialogue_NewLine
.db $EF, "!", Dialogue_Terminator65

Dialogue_Index_0230:
.db "NO? ", $DC, Dialogue_Apostrophe, "S FINE,", Dialogue_NewLine
.db "IF ", $E1, "SO DESIRE.", Dialogue_NewPage
.db $CB, " ALWAYS BE", $E0, $D2, ".", Dialogue_Terminator65

Dialogue_Index_0232:
.db $DA, " A ", $9D, Dialogue_NewLine
.db "OF ", $DE, "TOP OF", Dialogue_NewPage
.db $C2, ".", Dialogue_NewLine
.db $D5, $F7, " ", $A5, Dialogue_NewPage
.db "IS HIDDEN AT ", $DE, Dialogue_NewLine
.db "TOP OF ", $DE, $9D, "!", Dialogue_Terminator65

Dialogue_Index_0234:
.db "WHAT ", $E3, $E1, "COMEFOR? ", $C6, " INTEND", Dialogue_NewPage
.db $D5, " MISCHIEF?", Dialogue_Terminator65

Dialogue_Index_0236:
.db "I ", $E3, "AN UNEASY", Dialogue_NewLine
.db "FEELING.", Dialogue_Terminator65

Dialogue_Index_0238:
.db "BE ", $ED, " UP", Dialogue_NewLine
.db "AHEAD. AT ", $DE, Dialogue_NewPage
.db "BREAK IN ", $DE, "ROAD,GO TO ", $DE, "LEFT!", Dialogue_Terminator65

Dialogue_Index_023A:
.db $D4, " LIVES IN", Dialogue_NewLine
.db "FEAR OF ", $DE, Dialogue_NewPage
.db "CRYSTAL POSSESSED", Dialogue_NewLine
.db "BY ", $DE, $BB, Dialogue_NewPage

Dialogue_Index_023C:
.db $E7, "DAMOR. ", $D1, "IS ", $D5, $F7, Dialogue_NewPage
.db "SPECIAL ABOUT IT,", Dialogue_NewLine
.db "WITHOUT A DOUBT.", Dialogue_Terminator65

Dialogue_Index_023E:
.db $E4, "FIRE WAS LIT", Dialogue_NewLine
.db "DURING ", $DE, "ECLIPSE", Dialogue_NewPage
.db "WHICH OCCURS ONCE", Dialogue_NewLine
.db "EVERY 100 YEARS.", Dialogue_NewPage

Dialogue_Index_0240:
.db "IF ", $E1, "GIVE ME A", Dialogue_NewLine
.db "GEM ", $FE, "A DRAGON,", Dialogue_NewPage
.db "I", Dialogue_Apostrophe, "LL GIVE ", $E1, $D5, "OF ", $E4, "FIRE.", Dialogue_NewPage

Dialogue_Index_0242:
.db "HOW ABOUT IT?", Dialogue_Terminator62

Dialogue_Index_0244:
.db $D2, ", TAKE ", $E4, Dialogue_NewLine
.db "ECLIPSE TORCH.", Dialogue_Terminator65

Dialogue_Index_0246:
.db "NO? THEN WHAT DID", Dialogue_NewLine
.db $E1, "COME FOR?", Dialogue_Terminator65

Dialogue_Index_0248:
.db $E1, $E3, "NO GEM!", Dialogue_NewLine
.db "DO I LOOK LIKE A", Dialogue_NewPage
.db "FOOL OR ", $D5, $F7, "?", Dialogue_Terminator65

Dialogue_Index_024A:
.db "I", Dialogue_Apostrophe, "M SORRY I ", $E3, "A", Dialogue_NewLine
.db "SHOP IN SUCH A", Dialogue_NewPage
.db "PLACE. SHORTCAKE", Dialogue_NewLine
.db "FOR 1000 ", Dialogue_Mesetas, "!", Dialogue_NewPage
.db $CD, " BUY ", $FD, "?", Dialogue_Terminator62

Dialogue_Index_024C:
.db "AH,MY YOUNG PUPIL,NOAH. ", $E1, $EC, Dialogue_NewPage
.db "PREPARING TO FACE", Dialogue_NewLine
.db $D4, "?", Dialogue_Terminator65

Dialogue_Index_024E:
.db "COME,", $CE, " ", $A2, Dialogue_NewLine
.db $E2, "FINAL TEST---", Dialogue_NewPage
.db "WE ", $C7, " DUEL!", Dialogue_Terminator65

Dialogue_Index_0250:
.db $E1, $E3, "BECOME", Dialogue_NewLine
.db "MUCH STRONGER...", Dialogue_NewPage

Dialogue_Index_0252:
.db $E1, $EC, "WELL", Dialogue_NewLine
.db "PREPARED.", Dialogue_NewPage

Dialogue_Index_0254:
.db "I", Dialogue_Apostrophe, "LL GIVE ", $E1, "A", Dialogue_NewLine
.db "FRAD MANTLE AS A", Dialogue_NewPage
.db "GIFT. IT PROTECTS", Dialogue_NewLine
.db $E1, $FE, "DANGER!", Dialogue_Terminator65

Dialogue_Index_0256:
.db $E1, $EC, $F8, "YET", Dialogue_NewLine
.db "READY! ", $CE, " GO", Dialogue_NewPage
.db "STILL UNDERGO MORETRAINING.", Dialogue_Terminator65

Dialogue_Index_0258:
.db "I ", $E3, "NO", $F7, " TO", Dialogue_NewLine
.db "TEACH ", $E1, "MORE.", Dialogue_Terminator65

Dialogue_Index_025A:
.db "AND WHO ", $EC, "YOU?", Dialogue_NewLine
.db "FIND MY PUPIL NOAH", Dialogue_NewPage
.db "IN ", $DE, $A7, Dialogue_NewLine

Dialogue_Index_025C:
.db "CAVE.", $C3, Dialogue_NewPage
.db "HIM?", Dialogue_Terminator62

Dialogue_Index_025E:
.db "I", Dialogue_Apostrophe, "VE ", $D5, $F7, Dialogue_NewLine
.db "I ", $C8, " TELL HIM.", Dialogue_NewPage
.db "BRING HIM ", $D2, ".", Dialogue_Terminator65

Dialogue_Index_0260:
.db "IN ", $DC, " CASE,", Dialogue_NewLine
.db $DA, " NO POINT", Dialogue_NewPage
.db "IN FURTHER", Dialogue_NewLine
.db "CONVERSATION.", Dialogue_Terminator65

Dialogue_Index_0262:
.db "I ", $E3, "WATCHED", Dialogue_NewLine
.db "ALL ", $E2, "ACTIONS.", Dialogue_NewPage

Dialogue_Index_0264:
.db $82, " ME NOW, IF", Dialogue_NewLine
.db $E1, "DARE.", Dialogue_Terminator65

Dialogue_Index_0266:
.db "I", Dialogue_Apostrophe, "M BUT ONLY", Dialogue_NewLine
.db $D4, Dialogue_Apostrophe, "S SHADOW!", Dialogue_NewPage

Dialogue_Index_0268:
.db "EVEN IF ", $E1, "DEFEATME, YOU", Dialogue_Apostrophe, "VE GAINED", Dialogue_NewPage
.db "NO", $F7, " AT ALL!", Dialogue_Terminator65

Dialogue_Index_026A:
.db "DON", Dialogue_Apostrophe, "T GO AGAINST", Dialogue_NewLine
.db $D4, "!", Dialogue_Terminator65

Dialogue_Index_026C:
.db "AH, MY CHILDREN,", Dialogue_NewLine
.db $E1, $E3, "D", $FD, " VERY", Dialogue_NewPage
.db "WELL TO COME ", $E4, Dialogue_NewLine
.db "FAR. ", $E1, $EC, "VERY", Dialogue_NewPage
.db "LUCKY ", $D3, ". DO", Dialogue_NewLine
.db $E1, "REALLY ", $97, " TO", Dialogue_NewPage
.db "KILL AN OLD MAN?", Dialogue_Terminator62

Dialogue_Index_026E:
.db "ALL RIGHT! THEN", Dialogue_NewLine
.db "WE ", $C7, " FORGET", Dialogue_NewPage
.db $E4, "AS AN UNFOR-", Dialogue_NewLine
.db "TUNATE MISTAKE.", Dialogue_Terminator65

Dialogue_Index_0270:
.db "EVEN NOW ", $E1, "TRY", Dialogue_NewLine
.db "TO FOOL WITH ME?", Dialogue_NewPage
.db $E1, "SHALL REPENT!", Dialogue_Terminator65

Dialogue_Index_0272:
.db "I", Dialogue_Apostrophe, "M SORRY, I ", $C8, Dialogue_NewLine
.db $E3, "BEEN", Dialogue_NewPage

Dialogue_Index_0274:
.db "POSSESSED BODY ANDSOUL BY EVIL.", Dialogue_NewPage

Dialogue_Index_0276:
.db $E1, "RESCUED OUR", Dialogue_NewLine
.db $B5, " JUST IN ", $DE, Dialogue_NewPage
.db "NICK OF ", $9F, "! IF", Dialogue_NewLine
.db $E1, "HAD COME ", $F6, Dialogue_NewPage

Dialogue_Index_0278:
.db "LATER, IT MIGHT", Dialogue_NewLine
.db $E3, "BEEN TOO LATE", Dialogue_NewPage
.db "WE ALL ", $B4, Dialogue_NewLine
.db $FE, $DE, "BOTTOM", Dialogue_NewPage
.db "OF OUR HEARTS.", Dialogue_NewLine
.db $80, ", ", $E2, $B1, Dialogue_NewPage
.db "WAS ONCE ", $AF, " OF", Dialogue_NewLine
.db $9B, ". ", $DE, "DARK", Dialogue_NewPage
.db $89, " HAS BEEN", Dialogue_NewLine
.db "DESTROYED, ", $D4, Dialogue_NewPage
.db "KILLED... ", $C6, ",", Dialogue_NewLine
.db $80, ",", $97, " TO", Dialogue_NewPage
.db "ASCEND ", $E2, Dialogue_NewLine
.db $B1, Dialogue_Apostrophe, "S THR", $FD, Dialogue_NewPage
.db "AND BECOME ", $DE, Dialogue_NewLine
.db $B0, " OF ", $9B, "?", Dialogue_Terminator62

Dialogue_Index_027A:
.db "RAISE ", $DE, Dialogue_NewLine
.db "AEROPRISM TOWARDS", Dialogue_NewPage
.db $DE, "HEAVENS- ", $E1, Dialogue_NewLine
.db "SHOULD THEN BE", Dialogue_NewPage
.db "ABLE TO SEE ", $DE, Dialogue_NewLine
.db "DARK ", $89, ".", Dialogue_Terminator65

Dialogue_Index_027C:
.db "ALRIGHT! ", $E1, "SAVEDALL OF ", $9B, "!", Dialogue_Terminator65

Dialogue_Index_027E:
.db $8B, " ALL", Dialogue_NewLine
.db "THANKFUL FOR ", $E2, Dialogue_NewPage
.db "BRAVE DEEDS! WE", Dialogue_NewLine
.db "LOVE ", $E1, "!", Dialogue_Terminator65

Dialogue_Index_0280:
.db "REPORT QUICKLY TO", Dialogue_NewLine
.db $DE, $AA, "!", Dialogue_Terminator65

Dialogue_Index_0282:
.db $E1, $88, " COME", Dialogue_NewLine
.db $DD, " ", $D2, ".", Dialogue_NewPage
.db $E4, "IS MY AREA.", Dialogue_Terminator65

Dialogue_Index_0284:
.db "WELL,IF DR.", $AD, Dialogue_NewLine
.db "SENT ", $E1, ",I GUESS", Dialogue_NewPage
.db "I ", $E3, "TO LET ", $E1, Dialogue_NewLine
.db $DD, ".", Dialogue_Terminator65

Dialogue_Index_0286:
.db "THEY SAY ", $DC, Dialogue_NewLine
.db $DB, " ", $94, "N", Dialogue_NewPage
.db "LIVING ON ", $94, Dialogue_NewLine
.db "AND ", $F4, "N ON", Dialogue_NewPage
.db $93, ". I", Dialogue_Apostrophe, "D SURE", Dialogue_NewLine
.db "LIKE A CHANCE TO", Dialogue_NewPage
.db "TALK TO ", $D5, $FD, ".", Dialogue_Terminator65

Dialogue_Index_0288:
.db $D5, " INTELLIGENT", Dialogue_NewLine
.db "MONSTERS ", $E3, Dialogue_NewPage
.db "THEIR OWN", Dialogue_NewLine
.db $D9, ".", Dialogue_Terminator65

Dialogue_Index_028A:
.db "I SOLD ", $DC, Dialogue_NewLine
.db $A6, " FOR", Dialogue_NewPage
.db "A ", $E6, "DEAL OF", Dialogue_NewLine
.db "M", $FD, "Y. ", $B3, ".", Dialogue_Terminator65

Dialogue_Index_028C:
.db "NOW ", $DC, " MY STAFF", Dialogue_NewLine
.db "IS ASSEMBLED", Dialogue_NewPage
.db "I CAN BEGIN.", $D1, Dialogue_NewLine
.db "IS HOWERVER, A", Dialogue_NewPage

Dialogue_Index_028E:
.db "SLIGHT FEE OF 1200", Dialogue_Mesetas, " INVOLVED.", Dialogue_NewPage
.db $CD, " PAY?", Dialogue_Terminator62

Dialogue_Index_0290:
.db $B4, ". I CAN", Dialogue_NewLine
.db "NOW GET TO WORK.", Dialogue_NewPage
.db $C9, "WAIT ", $FD, Dialogue_NewLine
.db "MOMENT.", Dialogue_Terminator65

Dialogue_Index_0292:
.db "IT ", $88, " BE", Dialogue_NewLine
.db "HURRIED! ", $C9, Dialogue_NewPage
.db "SHOW A BIT MORE", Dialogue_NewLine
.db "PATIENCE!", Dialogue_Terminator65

Dialogue_Index_0294:
.db "WE CAN BOARD ", $DE, Dialogue_NewLine
.db $AD, " AND BE ON", Dialogue_NewPage
.db "OUR WAY!", Dialogue_Terminator65

Dialogue_Index_0296:
.db "HEY, BRING ", $DC, Dialogue_NewLine
.db "CAT OVER ", $D2, "!", Dialogue_Terminator62

Dialogue_Index_0298:
.db "OOHH,HA,HA! ", $DE, Dialogue_NewLine
.db "CAT ", $C7, " DIE!", Dialogue_Terminator65

Dialogue_Index_029A:
.db "I ", $C7, " KILL ", $F6, Dialogue_NewLine
.db "WHO INTERFERE!", Dialogue_Terminator65

Dialogue_Index_029C:
.db $E1, "SHOULD ", $BF, Dialogue_NewLine
.db $D2, " AWHILE AFTER", Dialogue_NewPage
.db $E2, "LONG JOURNEY.", Dialogue_Terminator65

Dialogue_Index_029E:
.db $DC, " WAS QUICK-OH,", Dialogue_NewLine
.db $B7, ",", $E1, $EC, $F8, Dialogue_NewPage
.db $DD, " WITH", Dialogue_NewLine
.db $D4, ". ", $E1, "HAD", Dialogue_NewPage
.db "BEST ", $BF, " AT ", $DE, Dialogue_NewLine
.db "INN.", Dialogue_Terminator65

Dialogue_Index_02A0:
.db $E1, "FELL INTO A", Dialogue_NewLine
.db "DEEP SLEEP.", Dialogue_Terminator63

Dialogue_Index_02A2:
.db $E1, "HAD A BAD", Dialogue_NewLine
.db "DREAM.", Dialogue_Terminator65

Dialogue_Index_02A4:
.db $D2, " IS ", $DE, "HOME", Dialogue_NewLine
.db "OF ", $80, ".", Dialogue_Terminator65

Dialogue_Index_02A6:
.db "IT HAS ", $D5, $F7, Dialogue_NewLine
.db $AC, ".", Dialogue_NewPage
.db $D0, " IS ", $DE, Dialogue_NewLine
.db $AA, ",I WONDER?", Dialogue_Terminator65

Dialogue_Index_02A8:
.db $E1, $E3, "GOTTEN", Dialogue_NewLine
.db $A9, " KILLED?", Dialogue_NewPage
.db "COME, LET", Dialogue_Apostrophe, "S TRY", Dialogue_NewLine
.db $FD, " MORE ", $9F, ".", Dialogue_Terminator65

Dialogue_Index_02AA:
.db $D4, " HAS DIED.", Dialogue_NewLine
.db $80, " ACCOMPLISHED", Dialogue_NewPage
.db "HER ", $97, ". ", $B2, " IS", Dialogue_NewLine
.db "SATISFIED NOW IN", Dialogue_NewPage
.db "HEAVEN. HURRY TO", Dialogue_NewLine
.db $DE, $AA, "!", Dialogue_Terminator65

LABEL_B49B:
.db "SCUM! DO NOT SNIFF", Dialogue_NewLine
.db "AROUND IN ", $D4, Dialogue_Apostrophe, "S", Dialogue_NewLine
.db "AFFAIRS! LEARN", Dialogue_NewLine
.db "THIS LESSON WELL!", Dialogue_NewPage
.db $B2, "! WHAT HAPP-", Dialogue_NewLine
.db "ENED! DON", Dialogue_Apostrophe, "T DIE!", Dialogue_Terminator65

LABEL_B4FC:
.db $80, ",LISTEN!", Dialogue_NewLine
.db $D4, " IS LEADING", Dialogue_NewLine
.db "OUR ", $B5, " TO", Dialogue_NewLine
.db "DESTRUCTION. I", Dialogue_NewPage
.db "TRIED TO DISCOVER", Dialogue_NewLine
.db "HIS PLANS, BUT I", Dialogue_NewLine
.db "C", $FF, " NOT DO MUCH", Dialogue_NewLine
.db "BY MYSELF.", Dialogue_NewPage
.db "I ", $E3, "HEARD OF A", Dialogue_NewLine
.db "MAN WITH ", $E6, Dialogue_NewLine
.db "STRENGTH ", $E7, Dialogue_NewLine
.db "\"ODIN.\" MAYBE THE", Dialogue_NewPage
.db "TWO OF ", $E1, "CAN", Dialogue_NewLine
.db "STOP ", $D4, ".", Dialogue_NewLine
.db $80, ",IT", Dialogue_Apostrophe, "S TOO LATE", Dialogue_NewLine
.db "FOR ME. BE STRONG.", Dialogue_Terminator65

LABEL_B5D5:
.db "I ", $C7, " MAKE SURE", Dialogue_NewLine
.db $DC, " ", $92, Dialogue_NewLine
.db "DIED NOT IN VAIN!", Dialogue_NewLine
.db "WATCH OVER AND", Dialogue_NewPage
.db "PROTECT ME, ", $B2, "!", Dialogue_Terminator65

LABEL_B617:
.db "WE ", $C7, " BE FELLOW", Dialogue_NewLine
.db "TRAVELERS.", Dialogue_NewLine
.db "I", Dialogue_Apostrophe, "M ", $80, "; WHAT", Dialogue_Apostrophe, "S", Dialogue_NewLine
.db $E2, "NAME?", Dialogue_Terminator65

LABEL_B646:
.db "I", Dialogue_Apostrophe, "M ", $81, ".", Dialogue_Terminator65

LABEL_B64D:
.db $81, ", ", $E3, $E1, Dialogue_NewLine
.db "EVER HEARD OF A", Dialogue_NewLine
.db "MAN ", $E7, "ODIN?", Dialogue_Terminator65

LABEL_B66E:
.db "YES, BUT HE IS", Dialogue_NewLine
.db $91, "!", Dialogue_NewLine
.db "IF HE DRINKS THIS", Dialogue_NewLine
.db "MEDICINE, HE", Dialogue_Apostrophe, "LL BE", Dialogue_NewPage
.db "O.K., BUT I ", $88, Dialogue_NewLine
.db "OPEN ", $DE, "BOTTLE.", Dialogue_Terminator65

LABEL_B6C1:
.db "WELL, THEN, WE", Dialogue_Apostrophe, "D", Dialogue_NewLine
.db "BETTER GO ", $8F, Dialogue_NewLine
.db "ODIN TOGETHER,", Dialogue_NewLine
.db "O.K.?", Dialogue_Terminator65

LABEL_B6F3:
.db $B3, " FOR SAVING", Dialogue_NewLine
.db "ME. I GUESS IF", Dialogue_NewLine
.db $EA, " CAN STOP", Dialogue_NewLine
.db "ME, I DON", Dialogue_Apostrophe, "T ", $E3, Dialogue_NewPage
.db "MUCH HOPE OF", Dialogue_NewLine
.db "KILLING ", $D4, ",", Dialogue_NewLine
.db "DO I?", Dialogue_Terminator65

LABEL_B746:
.db $92, " DIED", Dialogue_NewLine
.db "TRYING TO KILL", Dialogue_NewLine
.db $D4, ". BEFORE HE", Dialogue_NewLine
.db "DIED, HE TOLD ME", Dialogue_NewPage
.db "TO SEEK ", $E2, $CA, ".", Dialogue_Terminator65

LABEL_B786:
.db "IS ", $DC, " SO? WELL,", Dialogue_NewLine
.db "I ", $C8, " NOT LET", Dialogue_NewLine
.db $E2, "BROTHER DIE", Dialogue_NewLine
.db "UNAVENGED.", Dialogue_Terminator65

LABEL_B7B9:
.db "WHY DID ", $E1, "TRY TO", Dialogue_NewLine
.db "KILL ", $EA, "?", Dialogue_Terminator65

LABEL_B7D1:
.db "BECAUSE ", $EA, " HAS", Dialogue_NewLine
.db "A MYSTIC AXE.", Dialogue_NewLine
.db "UNFORTUNATELY, SHE", Dialogue_NewLine
.db "GOT AWAY ", $FE, "ME.", Dialogue_NewPage
.db "ANYHOW, I ", $E3, Dialogue_NewLine
.db "STASHED A COMPASS", Dialogue_NewLine
.db "IN ONE OF THE", Dialogue_NewLine
.db $BA, "S OF ", $E4, Dialogue_NewPage
.db "CAVE. LET", Dialogue_Apostrophe, "S GO AND", Dialogue_NewLine
.db "GET IT", Dialogue_Terminator65

LABEL_B85C:
.db "I", Dialogue_Apostrophe, "VE RECEIVED A", Dialogue_NewLine
.db "LETTER ", $FE, $DE, Dialogue_NewLine
.db $AA, ". ", $C9, Dialogue_NewLine
.db "READ IT.", Dialogue_Terminator65

LABEL_B884:
.db "LET ME SEE IT.....", Dialogue_NewLine
.db "OUR DUTY IS CLEAR;", Dialogue_NewLine
.db "WE ", $C8, " PROTECT", Dialogue_NewLine
.db $DE, $B8, " OF THE", Dialogue_NewPage
.db $9B, " ", $9C, " ", $FE, Dialogue_NewLine
.db "EVIL.", Dialogue_NewLine
.db "WE ", $C8, " FIRST GO", Dialogue_NewLine
.db "TO ", $DE, $95, Dialogue_NewPage
.db "FORESTS AND FIND", Dialogue_NewLine
.db "DR.", $AD, ". WE CAN", Dialogue_NewLine
.db "USE AN UNDERGROUND", Dialogue_NewLine
.db $BA, " ", $FE, "A", Dialogue_NewPage
.db "MANHOLE IN THE", Dialogue_NewLine
.db $98, ".", Dialogue_Terminator65

LABEL_B929:
.db "WHEN ", $81, " EATS THE", Dialogue_NewLine
.db "NUTS OF ", $D7, ", HE", Dialogue_NewLine
.db "BECOMES CLOTHED IN", Dialogue_NewLine
.db "FLAME AND EMITS A", Dialogue_NewPage
.db "BLINDING LIGHT.", Dialogue_Terminator65

LABEL_B97C:
.db "WHEN HE IS VISIBLE", Dialogue_NewLine
.db "AGAIN, HE HAS BEEN", Dialogue_NewLine
.db "TRANSFORMED INTO", Dialogue_NewPage
.db "A BEAUTIFUL", Dialogue_NewLine
.db "WINGED BEAST.", Dialogue_NewLine
.db $81, " FLAPS HIS", Dialogue_NewLine
.db "WINGS PLOUDLY.", Dialogue_Terminator65

LABEL_B9E8:
.db Dialogue_NewLine
.db "     ", $80, Dialogue_Terminator63

LABEL_B9F0:
.db Dialogue_NewLine
.db "     ODIN", Dialogue_Terminator63

LABEL_B9FB:
.db Dialogue_NewLine
.db "     NOAH", Dialogue_Terminator63

LABEL_BA06:
.db Dialogue_NewLine
.db "     AND ", $81, Dialogue_Terminator63

LABEL_BA12:
.db "EVEN THOUGH THE", Dialogue_NewLine
.db "MEMORIES OF EVIL", Dialogue_NewLine
.db "FADE AWAY, THEIR", Dialogue_NewLine
.db "NAMES ", $C7, " BE KEPT", Dialogue_Terminator63

LABEL_BA54:
.db $5F, "IN ", $DE, "HEARTS OF", Dialogue_NewLine
.db $DE, "PEOPLE OF ", $DE, Dialogue_NewLine
.db "ALGOL FOREVER!!!", Dialogue_Terminator63


; This is a pointer table for the strings below
; TODO: Add labels for the strings and generate automatically when building ROM
; See DialogueBlock for example on how to do it
.dw $BB81, $BB86, $BB8B, $BB92
.dw $BB9C, $BBA3, $BBA8, $BBAF
.dw $BBB8, $BBBF, $BBC6, $BBCD
.dw $BBD5, $BBE1, $BBE7, $BBF1
.dw $BBF6, $BC00, $BC10, $BC1B
.dw $BC23, $BC2B, $BC32, $BC38
.dw $BC3D, $BC47, $BC50, $BC57
.dw $BC5D, $BC64, $BC6A, $BC72
.dw $BC77, $BC80, $BC88, $BC8D
.dw $BC96, $BCA5, $BCAC, $BCB9
.dw $BCC0, $BCC8, $BCD1, $BCDA
.dw $BCDF, $BCE7, $BCEE, $BCF6
.dw $BCFB, $BD01, $BD08, $BD0D
.dw $BD14, $BD1E, $BD24, $BD2B
.dw $BD31, $BD39, $BD3E, $BD46
.dw $BD51, $BD59, $BD64, $BD69
.dw $BD6E, $BD73, $BD79, $BD84
.dw $BD90, $BD97, $BDA3, $BDAA
.dw $BDAF, $BDB4, $BDBC, $BDC1
.dw $BDCA, $BDD1, $BDDA, $BDE3
.dw $BDE9, $BDEF, $BDF5, $BDFA
.dw $BE01, $BE08, $BE0D, $BE1E
.dw $BE25, $BE2D, $BE36, $BE3F
.dw $BE49, $BE4E, $BE56, $BE5B
.dw $BE63, $BE6C, $BE71, $BE77
.dw $BE7D, $BE83, $BE8C, $BE93
.dw $BE9A, $BEA4, $BEAC, $BEB3
.dw $BEC4, $BEC9, $BED1, $BED8
.dw $BEDE, $BEEC, $BEF6, $BEFC
.dw $BF01, $BF0A, $BF11, $BF15
.dw $BF1B, $BF20, $BF26, $BF2B
.dw $BF33, $BF3A, $BF3E, $BF44


.db "ALIS", Dialogue_Terminator65
.db "MYAU", Dialogue_Terminator65
.db "ATTACK", Dialogue_Terminator65
.db "EFFECTIVE", Dialogue_Terminator65
.db "MAGIC ", Dialogue_Terminator65
.db "WALL", Dialogue_Terminator65
.db "HEALED", Dialogue_Terminator65
.db "DEFLECTS", Dialogue_Terminator65
.db "CANNOT", Dialogue_Terminator65
.db "CASTLE", Dialogue_Terminator65
.db "HAPSBY", Dialogue_Terminator65
.db "WE ARE ", Dialogue_Terminator65
.db "HEADING FOR", Dialogue_Terminator65
.db "CARRY", Dialogue_Terminator65
.db "RESURRECT", Dialogue_Terminator65
.db "SAVE", Dialogue_Terminator65
.db "CURRENTLY", Dialogue_Terminator65
.db "TURNED TO STONE", Dialogue_Terminator65
.db "MY BROTHER", Dialogue_Terminator65
.db "DEZORIS", Dialogue_Terminator65
.db "MOTAVIA", Dialogue_Terminator65
.db "GOTHIC", Dialogue_Terminator65
.db "SCION", Dialogue_Terminator65
.db "WISH", Dialogue_Terminator65
.db "SPACEPORT", Dialogue_Terminator65
.db "PASSPORT", Dialogue_Terminator65
.db "PLANET", Dialogue_Terminator65
.db "ALGOL", Dialogue_Terminator65
.db "SYSTEM", Dialogue_Terminator65
.db "TOWER", Dialogue_Terminator65
.db "VILLAGE", Dialogue_Terminator65
.db "TIME", Dialogue_Terminator65
.db "ROADPASS", Dialogue_Terminator65
.db "MESETAS", Dialogue_Terminator65
.db "PASS", Dialogue_Terminator65
.db "ANT LION", Dialogue_Terminator65
.db "SOOTHING FLUTE", Dialogue_Terminator65
.db "SECRET", Dialogue_Terminator65
.db "LACONIAN POT", Dialogue_Terminator65
.db "MAHARU", Dialogue_Terminator65
.db "BORTEVO", Dialogue_Terminator65
.db "YOURSELF", Dialogue_Terminator65
.db "GOVERNOR", Dialogue_Terminator65
.db "HILL", Dialogue_Terminator65
.db "STRANGE", Dialogue_Terminator65
.db "LUVENO", Dialogue_Terminator65
.db "HOWEVER", Dialogue_Terminator65
.db "KING", Dialogue_Terminator65
.db "QUEEN", Dialogue_Terminator65
.db "FATHER", Dialogue_Terminator65
.db "NERO", Dialogue_Terminator65
.db "THANKS", Dialogue_Terminator65
.db "THANK YOU", Dialogue_Terminator65
.db "WORLD", Dialogue_Terminator65
.db "SHIELD", Dialogue_Terminator65
.db "I SEE", Dialogue_Terminator65
.db "PLANETS", Dialogue_Terminator65
.db "TOWN", Dialogue_Terminator65
.db "PASSAGE", Dialogue_Terminator65
.db "SOOTHSAYER", Dialogue_Terminator65
.db "LACONIA", Dialogue_Terminator65
.db "LABORATORY", Dialogue_Terminator65
.db "KNOW", Dialogue_Terminator65
.db "REST", Dialogue_Terminator65
.db "BAYA", Dialogue_Terminator65
.db "MALAY", Dialogue_Terminator65
.db "BAYA MALAY", Dialogue_Terminator65
.db "DO YOU KNOW", Dialogue_Terminator65
.db "FOREST", Dialogue_Terminator65
.db "DO YOU HAVE", Dialogue_Terminator65
.db "DO YOU", Dialogue_Terminator65
.db "WILL", Dialogue_Terminator65
.db "MUST", Dialogue_Terminator65
.db "PLEASE ", Dialogue_Terminator65
.db "HELP", Dialogue_Terminator65
.db "YOU WILL", Dialogue_Terminator65
.db "I WILL", Dialogue_Terminator65
.db "WILL YOU", Dialogue_Terminator65
.db "YOU MUST", Dialogue_Terminator65
.db "PALMA", Dialogue_Terminator65
.db "WHERE", Dialogue_Terminator65
.db "THERE", Dialogue_Terminator65
.db "HERE", Dialogue_Terminator65
.db "INDEED", Dialogue_Terminator65
.db "LASSIC", Dialogue_Terminator65
.db "SOME", Dialogue_Terminator65
.db "RESIDENTIAL AREA", Dialogue_Terminator65
.db "LAERMA", Dialogue_Terminator65
.db "DUNGEON", Dialogue_Terminator65
.db "LANGUAGE", Dialogue_Terminator65
.db "THERE IS", Dialogue_Terminator65
.db "THERE ARE", Dialogue_Terminator65
.db "THAT", Dialogue_Terminator65
.db "THROUGH", Dialogue_Terminator65
.db "THE ", Dialogue_Terminator65
.db "PRESENT", Dialogue_Terminator65
.db "WELCOME ", Dialogue_Terminator65
.db "YOU ", Dialogue_Terminator65
.db "YOUR ", Dialogue_Terminator65
.db "HAVE ", Dialogue_Terminator65
.db "THIS ", Dialogue_Terminator65
.db "MOUNTAIN", Dialogue_Terminator65
.db "GREAT ", Dialogue_Terminator65
.db "NAMED ", Dialogue_Terminator65
.db "SPACESHIP", Dialogue_Terminator65
.db "PALMANS", Dialogue_Terminator65
.db "MEDUSA", Dialogue_Terminator65
.db "DON", Dialogue_Apostrophe, "T BE A FOOL!", Dialogue_Terminator65
.db "ARE ", Dialogue_Terminator65
.db "CAREFUL", Dialogue_Terminator65
.db "DELETE", Dialogue_Terminator65
.db "MAGIC", Dialogue_Terminator65
.db "SABRUS CABRUS", Dialogue_Terminator65
.db "TREASURE ", Dialogue_Terminator65
.db "CHEST", Dialogue_Terminator65
.db "MOVE", Dialogue_Terminator65
.db "DEZORIAN", Dialogue_Terminator65
.db "EMBARK", Dialogue_Terminator65
.db "ANY", Dialogue_Terminator65
.db "THING", Dialogue_Terminator65
.db "NOT ", Dialogue_Terminator65
.db "WANT ", Dialogue_Terminator65
.db "GAME", Dialogue_Terminator65
.db "FACING ", Dialogue_Terminator65
.db "SELECT", Dialogue_Terminator65
.db "ONE", Dialogue_Terminator65
.db "FROM ", Dialogue_Terminator65
.db "OULD", Dialogue_Terminator65


.BANK 3
.ORG $0000
Bank03:

; Data from C000 to FFFF (16384 bytes)
.include "banks\bank03.asm"


.BANK 4
.ORG $0000
Bank04:

; Data from 10000 to 13FFF (16384 bytes)
.include "banks\bank04.asm"


.BANK 5
.ORG $0000
Bank05:

; Data from 14000 to 17FFF (16384 bytes)
.include "banks\bank05.asm"


.BANK 6
.ORG $0000
Bank06:

; Data from 18000 to 1BFFF (16384 bytes)
.include "banks\bank06.asm"


.BANK 7
.ORG $0000
Bank07:

; Data from 1C000 to 1FFFF (16384 bytes)
.include "banks\bank07.asm"


.BANK 8
.ORG $0000
Bank08:

; Data from 20000 to 23FFF (16384 bytes)
.include "banks\bank08.asm"


.BANK 9
.ORG $0000
Bank09:

; Data from 24000 to 27FFF (16384 bytes)
.include "banks\bank09.asm"


.BANK 10
.ORG $0000
Bank10:

; Data from 28000 to 2BFFF (16384 bytes)
.include "banks\bank10.asm"


.BANK 11
.ORG $0000
Bank11:

; Data from 2C000 to 2FFFF (16384 bytes)
.include "banks\bank11.asm"


.BANK 12
.ORG $0000
Bank12:

; Data from 30000 to 33FFF (16384 bytes)
.include "sound\sound_driver.asm"


.BANK 13
.ORG $0000
Bank13:

; Data from 34000 to 37FFF (16384 bytes)
.include "banks\bank13.asm"


.BANK 14
.ORG $0000
Bank14:

; Data from 38000 to 3BFFF (16384 bytes)
.include "banks\bank14.asm"


.BANK 15
.ORG $0000
Bank15:

; Data from 3C000 to 3FFFF (16384 bytes)
.include "banks\bank15.asm"


.BANK 16
.ORG $0000
Bank16:

; Data from 40000 to 43FFF (16384 bytes)
.include "banks\bank16.asm"


.BANK 17
.ORG $0000
Bank17:

; Data from 44000 to 47FFF (16384 bytes)
.include "banks\bank17.asm"


.BANK 18
.ORG $0000
Bank18:

; Data from 48000 to 4BFFF (16384 bytes)
.include "banks\bank18.asm"


.BANK 19
.ORG $0000
Bank19:

; Data from 4C000 to 4FFFF (16384 bytes)
.include "banks\bank19.asm"


.BANK 20
.ORG $0000
Bank20:

; Data from 50000 to 53FFF (16384 bytes)
.include "banks\bank20.asm"


.BANK 21
.ORG $0000
Bank21:

; Data from 54000 to 57FFF (16384 bytes)
.include "banks\bank21.asm"


.BANK 22
.ORG $0000
Bank22:

; Data from 58000 to 5BFFF (16384 bytes)
.include "banks\bank22.asm"


.BANK 23
.ORG $0000
Bank23:

; Data from 5C000 to 5FFFF (16384 bytes)
.include "banks\bank23.asm"


.BANK 24
.ORG $0000
Bank24:

; Data from 60000 to 63FFF (16384 bytes)
.include "banks\bank24.asm"


.BANK 25
.ORG $0000
Bank25:

; Data from 64000 to 67FFF (16384 bytes)
.include "banks\bank25.asm"


.BANK 26
.ORG $0000
Bank26:

; Data from 68000 to 6BFFF (16384 bytes)
.include "banks\bank26.asm"


.BANK 27
.ORG $0000
Bank27:

; Data from 6C000 to 6FFFF (16384 bytes)
.include "banks\bank27.asm"


.BANK 28
.ORG $0000
Bank28:

; Data from 70000 to 73FFF (16384 bytes)
.include "banks\bank28.asm"


.BANK 29
.ORG $0000
Bank29:

; Data from 74000 to 77FFF (16384 bytes)
.include "banks\bank29.asm"


.BANK 30
.ORG $0000
Bank30:

; Data from 78000 to 7BFFF (16384 bytes)
.include "banks\bank30.asm"


.BANK 31
.ORG $0000
Bank31:

; Data from 7C000 to 7FFFF (16384 bytes)
.include "banks\bank31.asm"

