;  =========================================================================
; |           Phantasy Star Disassembly for Sega Master System              |
;  =========================================================================
;
; Source code created by SMS Examine V1.2a
; Size: 524288 bytes
;
; 	Credits
;
; - Veo for researching and documenting the ROM locations and data on stuff like items, enemies, dungeons, etc.
;
; - Isotarge for contributions on relabeling, documenting code, RAM constants.
;
; - Maxim for lots of documentation, relabeling, constants, decompression, pointers, etc.


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
	im	1
	ld	sp, System_stack
	jr	MainSetup

_RST_08H:
; Set VRAM address to DE
	ld	a, e
	out	(Port_VDPAddress), a
	ld	a, d
	out	(Port_VDPAddress), a
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
	in	a, (Port_VDPStatus)
	jp	VInt


DisableDisplay:
	ld	a, (VDP_reg_1)
	and	$BF
	jr	+

EnableDisplay:
	ld	a, (VDP_reg_1)
	or	$40
+
	ld	(VDP_reg_1), a
	ld	e, a
	ld	d, $81
	rst	$08
	ret

WaitForVInt:
	ld	(V_int_routine), a
-
	ld	a, (V_int_routine)
	or	a
	jr	nz, -
	ret


; Data from 5C to 65 (10 bytes)
.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; We get here after the pause button is pressed
_NMI_HANDLER:
	push	af
	ld	a, (Game_mode)
	cp	$05 ; GameMode_Ship
	jr	z, LABEL_7A
	cp	$09 ; GameMode_Map
	jr	z, LABEL_7A
	cp	$0B ; GameMode_Dungeon
	jr	z, LABEL_7A
	cp	$0D ; GameMode_Scene
	jr	nz, LABEL_81
LABEL_7A:
	ld	a, (Game_is_paused)
	cpl
	ld	(Game_is_paused), a
LABEL_81:
	pop	af
	retn

MainSetup:
	di
	ld	sp, System_stack
	ld	hl, $FFFC
	ld	(hl), $80	; Enable ROM write
	inc	hl
	ld	(hl), $00	; Page 0 - ROM bank 0
	inc	hl
	ld	(hl), $01	; Page 1 - ROM bank 1
	inc	hl
	ld	(hl), $02	; Page 2 - ROM bank 2

; Clear work RAM
	ld	hl, $C000
	ld	de, $C001
	ld	bc, $1FFF
	ld	(hl), l	; clear byte in $C000
	ldir			; then do the rest (until bc = 0)

	call	CallSndInit
	call	VDPInitRegs
	call	DetectNTSC
	call	CheckSRAM
	ei

MainGameLoop:
	ld	hl, Game_mode
	ld	a, (hl)
	and	$1F
	ld	hl, GameModeTbl
	call	GetPtrAndJump
	jp	MainGameLoop


GameModeTbl:
.dw	GameMode_InitTitleScreen	; 0
.dw	GameMode_InitTitleScreen	; 1
.dw	GameMode_LoadTitleScreen	; 2
.dw	GameMode_TitleScreen	; 3
.dw	GameMode_LoadShip	; 4
.dw	GameMode_Ship	; 5
.dw	GameMode_Nothing	; 6
.dw	GameMode_Nothing	; 7
.dw	GameMode_LoadMap	; 8
.dw	GameMode_Map	; 9
.dw	GameMode_LoadDungeon	; $A
.dw	GameMode_Dungeon	; $B
.dw	GameMode_LoadScene	; $C
.dw	GameMode_Scene	; $D
.dw	GameMode_LoadRoad	; $E
.dw	GameMode_Road	; $F
.dw	GameMode_LoadNameInput	; $10
.dw	GameMode_NameInput	; $11
.dw	GameMode_FadeToPicture	; $12
.dw	GameMode_FadeToPicture	; $13


GetPtrAndJump:
	add	a, a
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	jp	(hl)


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
	ld	a, ($FFFC)
	push	af
	ld	a, ($FFFF)
	push	af
	ld	a, $80
	ld	($FFFC), a
	in	a, (Port_IOPort2)
	and	$10     ; check for reset button
	ld	hl, Reset_button
	ld	c, (hl)         ; c = old value of Reset_button
	ld	(hl), a
	xor	c
	and	c
	jp	nz, MainSetup	; if 1, reset game
	ld	a, (Region_setting)
	or	a
	jp	nz, +
	ld	b, $00
-
	djnz	-
-
	djnz	-
+
	ld	a, (Game_is_paused)
	or	a
	jp	nz, VIntPaused
	ld	a, (V_int_routine)
	and	$1F
	ld	hl, VIntRoutines
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	jp	(hl)


VIntRoutineEnd:
	xor	a
	ld	(V_int_routine), a
VIntEnd:
	pop	af
	ld	($FFFF), a
	pop	af
	ld	($FFFC), a
	pop	iy
	pop	ix
	pop	hl
	pop	de
	pop	bc
	pop	af
	ei
	ret


VInt_EnableDisplay:
	call	EnableDisplay
	jp	VIntRoutineEnd

VInt_PaletteEffects:
	ld	a, (H_scroll)
	out (Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	UpdateSpriteTable
	call	FadePaletteInRAM
	call	FlashPaletteInRAM
	ld	hl, Normal_palette
	ld	de, $C000
	rst	$08
	ld	c, Port_VDPData
	call	GoToOuti32
	call	AnimateEnemyTile
	call	CallSndUpdate
	jp	VIntRoutineEnd


; =================================================================
VIntRoutines:
.dw	VInt_SoundUpdate
.dw	VInt_SoundUpdate
.dw	VInt_SoundUpdate
.dw	VInt_SoundUpdate
.dw	VInt_Menu
.dw VInt_Enemy
.dw Vint_UpdateTilemap
.dw VInt_Scrolling
.dw Vint_10
.dw Vint_12
.dw VInt_EnableDisplay
.dw VInt_PaletteEffects
; =================================================================


VInt_SoundUpdate:
	call	CallSndUpdate
	jp	VIntRoutineEnd

VInt_Menu:
	ld	a, (H_scroll)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	UpdateSpriteTable
	call	AnimateEnemyTile
	call	ReadJoypad
	call	CursorBlink
	call	CallSndUpdate
	jp	VIntRoutineEnd

VInt_Enemy:
	ld	a, (H_scroll)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	UpdateSpriteTable
	call	AnimateEnemyTile
	call	CallSndUpdate
	jp	VIntRoutineEnd

Vint_UpdateTilemap:
	ld	a, (H_scroll)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	ld	hl, $D000
	xor a
	out	(Port_VDPAddress), a
	ld	a, $78
	out	(Port_VDPAddress), a
	ld	c, Port_VDPData
	call	GoToOuti128
	call	GoToOuti128
	call	GoToOuti128
	call	GoToOuti128
	call	GoToOuti128
	call	GoToOuti128
	call	GoToOuti128
	ld	a, $03
	ld	b, $80
-
	outi
	jp	nz, -
	dec	a
	jp	nz, -
	call	CallSndUpdate
	jp	VIntRoutineEnd

VInt_Scrolling:
	ld	a, (H_scroll)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	UpdateSpriteTable
	call	Palette_Rotate
	call	AnimateCharacterSprites
	call	UpdateScrollingTilemap
	call	AnimateMapTiles
	call	ReadJoypad
	call	CallSndUpdate
	jp	VIntRoutineEnd

Vint_10:
	ld	a, (H_scroll)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	UpdateSpriteTable
	ld	hl, Normal_palette
	ld	de, $C000
	rst	$08
	ld	c, Port_VDPData
	call	GoToOuti32
	ld	hl, $D000
	xor	a
	out	(Port_VDPAddress), a
	ld	a, $78
	out	(Port_VDPAddress), a
	ld	c, Port_VDPData
	ld	a, $06
	ld	b, 0
-
	outi
	jp	nz, -
	dec	a
	jp	nz, -
	call	CallSndUpdate
	jp	VIntRoutineEnd

Vint_12:
	ld	a, (H_scroll)
	out	(Port_VDPAddress), a
	ld	a, $88
	out	(Port_VDPAddress), a
	ld	a, (V_scroll)
	out	(Port_VDPAddress), a
	ld	a, $89
	out	(Port_VDPAddress), a
	call	UpdateSpriteTable
	ld	hl, Normal_palette
	ld	de, $C000
	rst	$08
	ld	c, Port_VDPData
	call	GoToOuti32
	ld	hl, $D000
	xor	a
	out	(Port_VDPAddress), a
	ld	a, $78
	out	(Port_VDPAddress), a
	ld	c, Port_VDPData
	ld	a, $07
	ld	b, 0
-
	outi
	jp	nz, -
	dec	a
	jp	nz, -
	call	CallSndUpdate
	jp	VIntRoutineEnd

VIntPaused:
	call	CallSndMute
	jp	VIntEnd


CallSndUpdate:
	ld	hl, $FFFF
	ld	(hl), :Bank12
	jp	Snd_UpdateAll

CallSndInit:
	ld	hl, $FFFF
	ld	(hl), :Bank12
	jp	Snd_InitDriver

CallSndMute:
	ld	hl, $FFFF
	ld	(hl), :Bank12
	jp	Snd_SilencePSG


ClearSpriteTableFadeIn:
	ld	hl, Sprite_table
	ld	de, Sprite_table+1
	ld	bc, $40
	ld	(hl), $E0
	ldir
	ld	c, $BF
	ld	(hl), 0
	ldir
	ld	a, $14
	call	WaitForVInt
	jp	FadeIn2

DetectNTSC:
	ld	hl, $0000
-
	in	a, (Port_VDPStatus)   ; Check VDP status
	or	a
	jp	p, -             ; Wait for bit 7 (VSync) to be 0
-
	in	a, (Port_VDPStatus)
	or	a
	jp	p, -
-
	inc	hl
	in	a, (Port_VDPStatus)
	or	a
	jp	p, -
	xor	a
	ld	de, $0800
	sbc  hl, de
	sbc  a, a
	ld	(Region_setting), a
	ret


ReadJoypad:
	in	a, (Port_IOPort1)	; get controls
	ld	hl, Ctrl_1
	cpl                ; Invert so 1 = pressed
	ld	b, a
	xor	(hl)
	ld	(hl), b			; store held state
	inc	hl				; go to Ctrl_1_pressed
	and	b
	ld	(hl), a			; store pressed state
	ret

DataToVRAM:
	rst  $08
	ld	a, c
	or	a
	jr	z, +
	inc	b
+
	ld	a, b
	ld	b, c
	ld	c, Port_VDPData
-
	outi
	jp	nz, -
	dec  a
	jp	nz, -
	ret


ClearTilemap:
	ld	de, $7800
	ld	bc, $380
	ld	hl, 0

FillVRAMWithHL:
	rst  $08
	ld	a, c
	or	a
	jr	z, +
	inc	b
+
-
	ld	a, l
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, h
	out	(Port_VDPData), a
	dec  c
	jr	nz, -
	djnz	-
	ret


; -----------------------------------------------------------------
OutputTilemapRaw:
	push	bc
	rst	$08
	ld	b, c
	ld	c, $BE
-
	outi
	ld	a, (Tile_map_high_byte)
	nop
	out	(c), a
	jr	nz, -
	ex	de, hl
	ld	bc, $40
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	OutputTilemapRaw
	ret
; -----------------------------------------------------------------


; -----------------------------------------------------------------
OutputTilemapRawDataBox:
	push	bc
	rst  $08
	ld	b, c
	ld	c, $BE
-
	outi
	jp	nz, -
	ex   de, hl
	ld	bc, $40
	add	hl, bc
	ex   de, hl
	pop	bc
	djnz	OutputTilemapRawDataBox
	ret
; -----------------------------------------------------------------


; -----------------------------------------------------------------
VDPInitRegs:
	ld	hl, VDPInitData
	ld	bc, $14BF
	otir
	ld	a, (VDPInitData)
	ld	(VDP_reg_0), a
	ld	a, (VDPInitData+2)
	ld	(VDP_reg_1), a
	ret
; -----------------------------------------------------------------

; =================================================================
VDPInitData:
.db $06, $80
.db $A0, $81
.db $FF, $82	; Tile map
.db $FF, $83
.db $FF, $84
.db $FF, $85	; Sprite table
.db $FF, $86	; Sprite tile set
.db $00, $87	; Border color
.db $00, $88	; H scroll
.db $00, $89	; V scroll
; =================================================================

LoadTiles4BitRLENoDI:
	ld	b, $04
-
	push	bc
	push	de
	call	+
	pop	de
	inc	de
	pop	bc
	djnz	-
	ret

+
--
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
	jp	nz, --
	inc	hl
	jp	--


LoadTiles4BitRLE:
	ld	b, $04
-
	push	bc
	push	de
	call	+
	pop	de
	inc	de
	pop	bc
	djnz	-
	ret

+
--
	ld	a, (hl)
	inc	hl
	or	a
	ret  z

	ld	c, a
	and	$7F
	ld	b, a
	ld	a, c
	and	$80
-
	di
	rst  $08
	ld	a, (hl)
	out	(Port_VDPData), a
	ei
	jp	z, +
	inc	hl
+
	inc	de
	inc	de
	inc	de
	inc	de
	djnz	-
	jp	nz, --
	inc	hl
	jp	--


; -----------------------------------------------------------------
Multiply8Bit:
	ld	d, $00
	ld	l, d
	add	hl, hl
.REPEAT 7
	jr	nc, +
	add	hl, de
+
	add	hl, hl
.ENDR
	ret	nc
	add	hl, de
	ret
; -----------------------------------------------------------------

; -----------------------------------------------------------------
Multiply16Bit:
	or	a		; clear carry
	ld	hl, $0000
.REPEAT 15
	rl   e
	rl   d
	jr	nc, +
	add	hl, bc
	jr	nc, +
	inc	de
+
	add	hl, hl
.ENDR
	rl   e
	rl   d
	ret  nc

	add	hl, bc
	ret  nc

	inc	de
	ret
; -----------------------------------------------------------------


; -----------------------------------------------------------------
Divide16Bit:
	xor	a
	add	hl, hl
.REPEAT 16
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
.ENDR
	ret
; -----------------------------------------------------------------


; -----------------------------------------------------------------
UpdateRNGSeed:
	push	hl
	ld	hl, (RNG_seed)
	ld	a, h
	rrca
	rrca
	xor	h
	rrca
	xor	l
	rrca
	rrca
	rrca
	rrca
	xor	l
	rra
	adc	hl, hl
	jr	nz, +
	ld	hl, $733C
+
	ld	a, r
	xor	l
	ld	(RNG_seed), hl
	pop	hl
	ret
; -----------------------------------------------------------------


GameMode_InitTitleScreen:
	ld	hl, Game_mode
	ld	(hl), $02 ; GameMode_LoadTitleScreen
	ret

GameMode_TitleScreen:
	ld	hl, $7C12
	ld	(CursorTileMapAddress), hl
	ld	a, $01
	ld	(Option_total_num), a
	call	CheckOptionSelect
	or	a
	jp	nz, TitleScreenContinue

InitNewGame:
	ld	hl, Game_data
	ld	de, Game_data+1
	ld	bc, $3FF
	ld	(hl), l
	ldir
	ld	iy, Alis_stats
	ld	(iy+weapon), ItemID_ShortSword
	ld	(iy+armor), ItemID_LeatherArmor
	call	UnlockCharacter
	ld	hl, $C600
	ld	(hl), $FF	; make Compass hidden
	ld	hl, $C604
	ld	(hl), $FF	; make Dungeon Key hidden
	ld	hl, $404
	ld	($C308), hl
	ld	hl, $610
	ld	(H_location), hl
	ld	($C313), hl
	ld	hl, $100
	ld	(V_location), hl
	ld	($C311), hl
	ld	hl, 0
	ld	(Current_money), hl
	call	GoToIntroSequence
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

TitleScreenContinue:
	ld	a, $08
	ld	($FFFC), a
	ld	hl, $8201
	ld	b, $05	; number of slots
-
	ld	a, (hl)
	or	a
	jr	nz, TitleScreen_UsedSlotFound
	inc	hl
	djnz	-
	ld	a, $80
	ld	($FFFC), a
	jp	InitNewGame

TitleScreen_UsedSlotFound:
	ld	a, $80
	ld	($FFFC), a
	call	FadeOut2
	di
	call	ClearTilemap
	ei
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ld	hl, $FFFF
	ld	(hl), :Bank16
	ld	hl, TilesFont_B16
	ld	de, $5800
	call	LoadTiles4BitRLE
	ld	hl, TilesExtraFont_B16
	ld	de, $7E00
	call	LoadTiles4BitRLE
	call	ClearSpriteTableFadeIn
Menu_ContinueOrDelete:
	ld	hl, DialogueContinueOrDelete_B12
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, Menu_Delete
; picked Yes, so continue
	ld	hl, DialogueContinueChooseSlot_B12
	call	ShowDialogue_B12
-
	push	bc
	call	GetSaveGameSelectionCont
	pop	bc
	call	CheckSlotUsed
	jr	z, -
	ld	hl, DialogueContinuingGame_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	ld	a, $08
	ld	($FFFC), a
	ld	a, (NumberToShowInText)
	ld	h, a
	ld	l, 0
	add	hl, hl
	add	hl, hl
	set	7, h
	ld	de, H_scroll
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

Menu_Delete:
	ld	hl, DialogueConfirmDelete_B12
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, Menu_ContinueOrDelete
--
	ld	hl, DialogueChooseDelete_B12
	call	ShowDialogue_B12
-
	push	bc
	call	GetSaveGameSelectionCont
	bit	4, c
	pop	bc
	jr	nz, Menu_Delete
	call	CheckSlotUsed
	jr	z, -
	ld	hl, DialogueSaveDeleteConfirmSlot_B12
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, --
	ld	hl, DialogueSaveBeenDeleted_B12
	call	ShowDialogue_B12
	ld	a, $08
	ld	($FFFC), a
	ld	a, (NumberToShowInText)
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
	ld	(hl), $02 ; GameMode_LoadTitleScreen
	ret


; =================================================================
LABEL_730:
.db $C0, $10, $C0, $10, $C0, $10, $C0, $10, $C0, $10
; =================================================================

CheckSlotUsed:
	ld	a, $08
	ld	($FFFC), a
	ld	a, (NumberToShowInText)
	ld	l, a
	ld	h, $82
	ld	a, (hl)
	or	a
	ld	a, $80
	ld	($FFFC), a
	ret

GameMode_LoadTitleScreen:
	call	FadeOut2
	di
	call	DisableDisplay
	call	CallSndInit
	call	ClearTilemap
	ld	hl, Game_mode
	inc	(hl) ; GameMode_TitleScreen
	ld	hl, $258
	ld	($C20E), hl
	ld	hl, Palette_TitleScreen
	ld	de, Target_palette
	ld	bc, $20
	ldir
	ld	hl, $C260
	ld	de, $C261
	ld	bc, $9F
	ld	(hl), 0
	ldir
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $FF
	ld	(hl), l
	ldir
	ld	hl, $FFFF
	ld	(hl), :Bank31
	ld	hl, TitleScreenTiles_B31
	ld	de, $4000
	call	LoadTiles4BitRLENoDI
	ld	hl, $FFFF
	ld	(hl), :Bank14
	ld	hl, TitleScreenTilemap_B14
	call	DecompressTilemapData
	xor	a
	ld	(V_scroll), a
	ld	(H_scroll), a
	ld	a, $81		; title music
	ld	(Sound_index), a
	ld	de, $8006        ; Enable stretch screen, no scroll lock/column mask/line int/desync
	rst	$08
	ei
	ld	a, $0C
	call	WaitForVInt
	jp	ClearSpriteTableFadeIn


; =================================================================
Palette_TitleScreen:
.db	$00, $00, $3F, $0F, $0B, $06, $2B, $2A
.db	$25, $27, $3B, $01, $3C, $34, $2F, $3C
.db	$00, $00, $3C, $0F, $0B, $06, $2B, $2A
.db	$25, $27, $3B, $01, $3C, $34, $2F, $3C
; =================================================================

CheckSRAM:
	ld	a, $08
	ld	($FFFC), a
	ld	bc, $1000
---
	push	bc
	ld	hl, $8001
	ld	de, SRAMIdentificationData+1
	ld	bc, $20
-
	ld	a, (de)
	inc	de
	cpi
	jr	nz, +
	jp	pe, -
	pop	bc
-
	djnz	---
	ld	a, c
	cp	$08
	jr	nc, InitSRAM
	ld	a, $80
	ld	($FFFC), a
	ret

+
	pop	bc
	inc	c
	jr	-


; =================================================================
SRAMIdentificationData:
.db "PHANTASY STAR         "
.db	"BACKUP RAM"
.db	"PROGRAMMED BY          "
.db	"NAKA YUJI"
; =================================================================


InitSRAM:
	ld	hl, $8000
	ld	de, $8001
	ld	bc, $1FFB
	ld	(hl), l
	ldir
	ld	hl, DefaultSRAMData
	ld	de, $8100
	ld	bc, $D8
	ldir
	ld	hl, SRAMIdentificationData
	ld	de, $8000
	ld	bc, $40
	ldir
	ld	a, $80
	ld	($FFFC), a
	ret


GameMode_Ship:
	ld	hl, $2009	; Fade out, 32 colors
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
	ld	hl, Palette_Space_B23
	ld	de, Target_palette
	ld	bc, $11
	ldir
	call	LoadPlanetPalette
	ld	hl, Ship_SpaceTiles_B23
	ld	de, $4000
	call	LoadTiles4BitRLE
	ld	hl, $FFFF
	ld	(hl), :Bank28
	ld	hl, Ship_TilemapBottomPlanet_B28
	call	DecompressTilemapData
	ld	hl, Tilemap_data
	ld	de, Tilemap_data+$300
	ld	bc, $300
	ldir
	ld	hl, Tilemap_data
	ld	bc, $100
	ldir
	ld	hl, Ship_TilemapSpace_B28
	call	DecompressTilemapData
	xor	a
	ld	(H_scroll), a
	ld	(V_scroll), a
	ld	hl, Tilemap_data
	ld	de, $7800
	ld	bc, $700
	di
	call	DataToVRAM
	ei
	ld	hl, Tilemap_data
	ld	de, Tilemap_data+$300
	ld	bc, $300
	ldir
	ld	a, $8F		; vehicle music
	ld	(Sound_index), a
	call	FadeIn2
	ld	hl, 0
	ld	($C2F2), hl
	ld	a, $08
	ld	(Scroll_screens), a
-
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jr	nz, +
	call	Ship_ScrollToTopPlanet
	ld	a, (Scroll_screens)
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
	ld	de, WorldData-3
	add	hl, de
	xor	a
	ld	(Rotate_palette_flag), a
	ld	(Scroll_direction), a
	ld	($C2E9), a
	ld	(Vehicle_movement_flags), a
	ld	(Scroll_screens), a
	call	LABEL_787B
	ret

LABEL_998:
	ld	de, ($C2F2)
	ld	a, (V_scroll)
	ld	h, a
	ld	b, a
	ld	a, (Scroll_screens)
	ld	l, a
	or	a
	sbc	hl, de
	ld	a, h
	cp	$E0
	jr	c, +
	sub	$20
+
	ld	h, a
	ld	(V_scroll), a
	ld	a, l
	ld	(Scroll_screens), a
	ld	a, b
	sub	h
	and $0F
	ret	z
	ld	e, a
	ld	d, 0
	ld	hl, (V_location)
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
	ld	(V_location), hl
	cp	b
	call	nz, DecompressScrollTilemap
	call	LABEL_733A
	ld	a, ($C2F3)
	cp	$07
	ret	nz
	ld	a, (Fade_timer)
	or	a
	call	nz, FadePaletteInRAM
	ret

Ship_ScrollToTopPlanet:
	ld	de, $02
	ld	a, (V_scroll)
	sub	e             ; Scroll up by 2 lines
	cp	$E0
	jr	c, +
	ld	d, $01
	sub	$20
+
	ld	(V_scroll), a
	ld	a, (Scroll_screens)
	sub	d
	ld	(Scroll_screens), a
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
	ld	de, WorldData-6
	add	hl, de
	ld	a, (hl)
	ld	($C308), a
	call	LoadPlanetPalette
	ld	hl, $C240
	ld	de, Normal_palette
	ld	bc, $20
	ldir
	ld	hl, Ship_TilemapTopPlanet_B28
	jp	DecompressTilemapData

LoadPlanetPalette:
	ld	a, ($C308)
	and	$03
	add	a, a
	ld	l, a
	add	a, a
	add	a, l
	ld	d, 0
	ld	e, a
	ld	hl, Palette_SpacePlanets
	add	hl, de
	ld	de, Target_palette+2
	ld	bc, $06
	ldir
	ret

Palette_SpacePlanets:
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
	ld	de, WorldData-9
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
	ld	de, WorldData-6
	add	hl, de
	ld	de, LABEL_A8C
	push	de
	call	LABEL_787B

LABEL_A8C:
	xor	a
	ld	(Ctrl_1_held), a
	ld	(Scroll_direction), a
	ld	a, ($C2E9)
	cp	$83
	ld	a, $10
	jr	c, +
	inc a
+
	ld	(Vehicle_movement_flags), a
	ld	hl, 0
	ld	($C2F2), hl
	call	GameMode_LoadMap
	ld	hl, Anim_counters
	ld	de, Anim_counters+1
	ld	bc, $17
	ld	(hl), 0
	ldir
	call	BuildSprites
	ld	a, $01
	ld	(Scroll_direction), a
	ret


; =================================================================
; Byte 1 = World number - space?
; Byte 2 = V location
; Byte 3 = H location
; Byte 4 = World number - planet?
; Byte 5 = V location
; Byte 6 = H location
; Byte 7 = World number - ?
; Byte 8 = V location
; Byte 9 = H location
; =================================================================
WorldData:
.db $00, $39, $43, $01, $8B, $69, $10, $53, $17
.db $01, $37, $69, $00, $91, $43, $05, $17, $17
.db $00, $47, $35, $01, $27, $74, $0F, $20, $58
.db $00, $47, $35, $02, $33, $2D, $13, $18, $1B
.db $01, $53, $74, $00, $1B, $35, $07, $25, $13
.db $01, $53, $74, $02, $33, $2D, $13, $18, $1B
.db $02, $5B, $2D, $00, $1B, $35, $07, $25, $13
.db $02, $5B, $2D, $01, $27, $74, $0F, $20, $58
; =================================================================


GameMode_Nothing:
	ret

GameMode_Map:
	ld	a, (Game_is_paused)
	or	a
	call	nz, PauseLoop
	ld	a, $0E
	call	WaitForVInt
	call	BuildSprites
	call	LABEL_77AC
	ld	a, (Rotate_palette_flag)
	or	a
	jr	nz, +
	ld	a, ($C2D2)
	or	a
	jr	z, +
	xor	a
	ld	($C2D2), a
	call	Map_RunRandomBattles
	or	a
	jr	z, +
	ld	a, $FF
	jp	++
+
	ld	a, (Ctrl_1_held)
	and	Button_1_Mask|Button_2_Mask
	ret	z
	ld	a, (Rotate_palette_flag)
	or	a
	ret	nz
	xor	a

++
	ld	(Battle_flag), a
	ld	hl, Game_mode
	ld	(hl), $0C ; GameMode_LoadScene
	ld	a, ($C810)
	ld	($C2D7), a
	ld	hl, Anim_counters
	ld	de, Anim_counters+1
	ld	bc, $17
	ld	(hl), 0
	ldir
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $FF
	ld	(hl), 0
	ldir
	ret

GameMode_LoadMap:
	call	FadeOut2
	di
	call	DisableDisplay
	ei
	ld	hl, Game_mode
	inc	(hl) ; GameMode_Map
	xor	a
	ld	(Scene_anim_flag), a
	ld	(Dungeon_palette_index), a
	inc	a
	ld	($C2D5), a
	ld	a, ($C308)
	cp	$04
	jr	nc, +
	ld	hl, $FFFF
	ld	(hl), :Bank29
	ld	hl, Map_TilesOutside_B29
	ld	de, $4000
	call	LoadTiles4BitRLE
	jr	++
+
	ld	hl, $FFFF
	ld	(hl), :Bank22
	ld	hl, Map_TilesTown_B22
	ld	de, $4000
	call	LoadTiles4BitRLE
++
	call	Map_ResetCharSpriteAttrs
	call	BuildSprites
	ld	b, $04
-
	push	bc
	ld	a, $0A
	call	WaitForVInt
	di
	call	AnimateCharacterSprites
	ei
	pop	bc
	djnz	-
	ld	a, (H_location)
	neg
	ld	(H_scroll), a
	ld	a, (V_location)
	ld	(V_scroll), a
	ld	a, (Location_index)
	ld	e, a
	ld	d, 0
	ld	hl, WorldDataTable
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
	ld	de, WorldDataTable2
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
	ld	(Anim_counters), de
	inc	hl
	ld	e, (hl)
	ld	d, $0F
	ld	(Anim_counters+4), de
	inc	hl
	ld	e, (hl)
	ld	d, $0F
	ld	(Anim_counters+8), de
	inc	hl
	ld	e, (hl)
	ld	d, $03
	ld	(Anim_counters+$C), de
	inc	hl
	ld	e, (hl)
	ld	d, $0F
	ld	(Anim_counters+$10), de
	inc	hl
	ld	e, (hl)
	ld	d, $07
	ld	(Anim_counters+$14), de
	inc	hl
	ld	a, (hl)
	ld	($C263), a
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	ld	de, Target_palette
	ld	bc, $11
	ldir
	ld	a, (Vehicle_movement_flags)
	or	a
	jr	nz, +
	push	hl
	ld	hl, Pal_MapSprite1
	ld	bc, $0D
	ldir
	pop	hl
	ldi
	ldi
	jp	++
+
	ld	hl, Pal_MapSprite2
	ld	bc, $0F
	ldir

++
	pop	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	(Dungeon_entrance_points_addr), hl
	call	DecompressScrollTilemap
	call	FillTilemap
	ld	a, $14
	call	LABEL_7764
	rrca
	rrca
	rrca
	rrca
	and	$0F
	ld	(Scene_type), a
	ld	a, (Vehicle_movement_flags)
	cp	$10
	ld	c, $B8
	jr	nc, +
	or	a
	ld	c, $8F
	jr	nz, +
	ld	a, (Location_index)
	ld	e, a
	ld	d, 0
	ld	hl, WorldMusics
	add	hl, de
	ld	c, (hl)
+
	ld	a, c
	call	Map_CheckMusic
	ld	de, $8026
	di
	rst	$08
	ei
	jp	ClearSpriteTableFadeIn

Map_CheckMusic:
	push	hl
	ld	hl, Current_sound
	cp	(hl)
	jr	nz, +
	pop	hl
	ret
+
	ld	(Sound_index), a
	ld	(hl), a
	pop	hl
	ret

Map_ResetCharSpriteAttrs:
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $FF
	ld	(hl), 0
	ldir
	ld	a, (Vehicle_movement_flags)
	or	a
	jp	z, Map_InitCharSpriteAttrs
	ld	hl, Character_sprite_attributes
	ld	(hl), $09
	ret

Map_InitCharSpriteAttrs:
	ld	de, Character_sprite_attributes
	ld	bc, $20
	ld	hl, Alis_stats
	ld	a, $01
	call	+
	ld	hl, Noah_stats
	ld	a, $03
	call	+
	ld	hl, Odin_stats
	ld	a, $05
	call	+
	ld	hl, Myau_stats
	ld	a, $07

+
	bit 0, (hl)
	ret	z
	ld	(de), a
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ret


; =================================================================
Pal_ScrollArea1:
.db	$08, $00, $3F, $01
.db $03, $0B, $0F, $2F, $06, $38, $3C, $25
.db $2A, $04, $30, $0C, $08

Pal_ScrollArea2:
.db	$08, $00, $3F
.db $01, $03, $0B, $0F, $2F, $06, $38, $3C
.db $25, $2A, $04, $30, $0C, $2F

Pal_ScrollArea3:
.db	$3F, $00
.db $3F, $24, $03, $3C, $0F, $3F, $28, $38
.db $3C, $25, $2A, $04, $30, $0C, $3F

Pal_ScrollArea4:
.db	$09, $00, $3F, $06, $2F, $0B, $0C, $04, $2A
.db $25, $3C, $38, $30, $03, $02, $08, $09
.db $08, $0C

Pal_ScrollArea5:
.db	$08, $00, $3F, $06, $2F, $0B
.db $0C, $04, $2A, $25, $3C, $38, $30, $03
.db $02, $08, $08, $0C, $04

Pal_ScrollArea6:
.db	$2A, $00, $3F
.db $06, $2F, $0B, $0C, $04, $2A, $25, $3C
.db $38, $30, $03, $02, $08, $2A, $2A, $2A

Pal_ScrollArea7:
.db $2F, $00, $3F, $06, $2F, $0B, $0C, $04
.db $2A, $25, $3C, $38, $30, $03, $02, $08
.db $2F, $0B, $06

Pal_ScrollArea8:
.db	$3F, $00, $3F, $06, $2F
.db $0B, $0C, $04, $2A, $25, $3C, $38, $30
.db $03, $02, $3F, $3F, $3C, $38

Pal_ScrollArea9:
.db	$00, $00
.db $3F, $06, $2F, $0B, $0C, $04, $2A, $25
.db $3C, $38, $30, $03, $02, $08, $00, $00
.db $00

Pal_ScrollArea10:
.db	$3C, $00, $3F, $06, $2F, $0B, $0C
.db $04, $2A, $25, $3C, $38, $30, $03, $02
.db $08, $3C, $3C, $3C
; =================================================================


; =================================================================
Pal_MapSprite1:
.db	$00, $3F, $2B, $0B
.db $2F, $37, $0F, $38, $34, $06, $01, $2A
.db $25, $00, $00
; =================================================================


; =================================================================
Pal_MapSprite2:
.db	$00, $3F, $02, $03, $0B
.db $0F, $20, $38, $34, $2F, $2A, $25, $2F
.db $2A, $25
; =================================================================


; =================================================================
WorldDataTable:
.db	$00, $01, $02, $03, $04, $04
.db $04, $05, $05, $05, $05, $05, $06, $06
.db $07, $07, $07, $07, $07, $08, $08, $09
.db $09, $0A
; =================================================================


; =================================================================
WorldMusics:
.db	$82	; Palma
.db	$83	; Motavia
.db	$84	; Dezoris
.db	$84	; Dezoris
.db	$87	; Town
.db	$87	; Town
.db $87	; Town
.db	$88	; Village
.db	$88	; Village
.db	$88	; Village
.db	$88	; Village
.db	$88	; Village
.db	$87	; Town
.db	$87	; Town
.db $87	; Town
.db	$88	; Village
.db	$87	; Town
.db	$88	; Village
.db	$88	; Village
.db	$84	; Dezoris
.db	$84	; Dezoris
.db	$88	; Village
.db $88	; Village
.db	$85	; Final Dungeon
; =================================================================


; =================================================================
WorldDataTable2:
.db	$00, $80, $0D, $01, $01, $00, $01, $01, $00, $1D
.dw	Pal_ScrollArea1
.dw	PalmaDungeonEntrancePoints_B03

.db $76, $A2, $0D, $00, $00, $01, $01, $00, $01, $1D
.dw	Pal_ScrollArea2
.dw	MotaviaDungeonEntrancePoints_B03

.db	$00, $80, $0E, $00, $00, $00, $00, $00, $00, $1D
.dw Pal_ScrollArea3
.dw	DezorisDungeonEntrancePoints_B03

.db	$00, $80, $0E, $00, $00, $00, $00, $00, $00, $1D
.dw	Pal_ScrollArea3
.dw LABEL_AA49_B03

.db	$00, $80, $18, $00, $00, $00, $00, $00, $00, $16
.dw	Pal_ScrollArea4
.dw	LABEL_AA4A_B03

.db $62, $87, $18, $00, $00, $00, $00, $00, $00, $16
.dw	Pal_ScrollArea5
.dw	LABEL_AB70_B03

.db	$42, $8F, $18, $00, $00, $00, $00, $00, $00, $16
.dw Pal_ScrollArea6
.dw	LABEL_AC8B_B03

.db	$D9, $93, $18, $00, $00, $00, $00, $00, $00, $16
.dw	Pal_ScrollArea7
.dw LABEL_ACF7_B03

.db	$07, $9C, $18, $00, $00, $00, $00, $00, $00, $16
.dw	Pal_ScrollArea8
.dw	LABEL_AE5F_B03

.db $8B, $9D, $18, $00, $00, $00, $00, $00, $00, $16
.dw	Pal_ScrollArea9
.dw	LABEL_AE71_B03

.db	$50, $A2, $18, $00, $00, $00, $00, $00, $00, $16
.dw Pal_ScrollArea10
.dw	LABEL_AF37_B03
; =================================================================



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
	call	BuildSprites
	ld	a, (Rotate_palette_flag)
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
	ld	(Rotate_palette_flag), a
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
	ld	a, (Dungeon_moving_flag)
	or	a
	ret	z
	xor	a
	ld	(Dungeon_moving_flag), a
	ld	a, (Battle_rate)
	ld	b, a
	call	UpdateRNGSeed
	cp	b
	ret	nc
	ld	b, $01
	call	Dungeon_GetRelativeSquareType
	ret	nz
	xor	a
	ld	(Dungeon_moving_flag), a
	ld	a, (Battle_enemy_pool_index)
	call	Dungeon_GetEncounter
	or	a
	ret	z
	call	Dungeon_LoadEnemy
	call	Dungeon_EnterBattle
	ld	a, (Character_sprite_attributes)
	or	a
	call	nz, LABEL_1BE1
	ret


GameMode_LoadDungeon:
	call	FadeOut2
	call	Dungeon_ChangeMusic
	ld	hl, Game_mode
	inc	(hl) ; GameMode_Dungeon
	ld	hl, $FFFF
	ld	(hl), :Bank16
	ld	hl, TilesFont_B16
	ld	de, $5800
	call	LoadTiles4BitRLE
	ld	hl, TilesExtraFont_B16
	ld	de, $7E00
	call	LoadTiles4BitRLE
	ld	a, $39
	call	Inventory_FindItem
	jr	nz, +
	ld	a, $FF
	ld	(Dungeon_palette_index), a
+
	call	LABEL_FF3
	xor	a
	ld	(V_scroll), a
	ld	(H_scroll), a
	ld	($C2D5), a
	ld	(Scene_anim_flag), a
	ld	(Text_box_open_flag), a
	ld	de, $8006
	di
	rst	$08
	ei
	call	ClearSpriteTableFadeIn
	ld	b, $01
	call	Dungeon_CheckObjects
	ld	a, (Dungeon_palette_index)
	or	a
	ret	nz
	ld	hl, DialogueDungeonTooDark_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	call	LABEL_1BE1
	ld	a, (Dungeon_palette_index)
	or	a
	jr	z, +
	ld	a, $FF
	ld	(Dungeon_palette_index), a
	call	Dungeon_LoadData
	jp	FadeIn2

+
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

LABEL_FF3:
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $FF
	ld	(hl), $00
	ldir
	ld	a, $D0
	ld	(Sprite_table), a
	call	LoadDungeonMap
	xor	a
	ld	(Scene_type), a
	jp	Dungeon_NextScreen

Dungeon_EnterBattle:
	ld	a, (Battle_enemy_id)
	cp	EnemyID_Lassic
	ld	c, $92
	jr	z, +
	cp	EnemyID_DarkFalz
	jr	z, ++
	ld	c, $89
+
	ld	a, c
	ld	(Sound_index), a
++
	ld	hl, $C2AB
	ld	b, $0C
-
	ld	a, b
	dec  a
	ld	(hl), a
	dec  hl
	djnz	-
	xor	a
	ld	(Magic_wall_active), a
	call	ShowEnemyData
	ld	b, $04
LABEL_1036:
	ld	a, b
	dec  a
	call	IsCharacterAlive
	jp	nz, LABEL_1043
	djnz	LABEL_1036
	jp	LABEL_1656

LABEL_1043:
	ld	b, $04
LABEL_1045:
	ld	a, b
	dec  a
	call	IsCharacterAlive
	inc	hl
	ld	a, (hl)
	or	a
	jp	nz, LABEL_1055
	djnz	LABEL_1045
	jp	LABEL_1656

LABEL_1055:
	ld	hl, $C2AC
	ld	de, $C2AD
	ld	bc, $000F
	ld	(hl), $00
	ldir
	ld	a, $FF
	ld	(Battle_flag), a
	xor	a
	ld	(Battle_current_player), a
	ld	($C2D4), a
	call	ShowCombatMenu
	call	UpdatePartyStats

LABEL_1074:
	call	IsCharacterAlive_FromC267
	jp	z, LABEL_1080
	inc	hl
	ld	a, (hl)
	or	a
	jp	nz, LABEL_108A

LABEL_1080:
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a
	jp	LABEL_10B7

LABEL_108A:
	ld	de, $0C
	add	hl, de
	ld	a, (hl)
	or	a
	jr	nz, LABEL_1080
	call	UpdateEnemyHP
	call	RefreshCombatMenu
	call	LABEL_2EAC
	ld	hl, $7882
	ld	(CursorTileMapAddress), hl
	ld	a, $04
	ld	(Option_total_num), a
	call	CheckOptionSelect
	bit	Button_1, c
	jp	nz, LABEL_1121	; jump if we pressed the 1 button (cancel)
	ld	hl, BattleMenu_OptionTbl
	call	GetPtrAndJump
	call	LABEL_2ECD

LABEL_10B7:
	ld	a, (Battle_current_player)
	cp	$04
	jp	c, LABEL_1074
	cp	$05
	jp	nc, LABEL_163E
	xor	a
	ld	(Battle_current_player), a
	call	HidePartyStats
	call	CloseMenu
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
	ld	hl, Enemy_stats+curr_hp
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
	ld	a, (Battle_current_player)
	cp	$05
	jp	z, LABEL_163E
	djnz	LABEL_10D6
	jp	LABEL_1043

LABEL_1121:
	call	LABEL_2ECD

LABEL_1124:
	ld	a, (Battle_current_player)
	or	a
	jr	z, +
	dec	a
+
	ld	(Battle_current_player), a
	jp	z, LABEL_1074
	call	IsCharacterAlive_FromC267
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
	ld	(Battle_current_player), a
	call	IsCharacterAlive_FromC267
	ret	z
	ld	a, ($C2D4)
	or	a
	ret	nz
	push	hl
	pop	iy
	ld	a, (iy+curr_hp)
	or	a
	ret	z
	ld	a, (iy+tied_up)
	or	a
	jr	z, LABEL_1188
	ld	a, (Battle_current_player)
	ld	(CurrentCharacter), a
	call	UpdateRNGSeed
	and	$01
	inc	a
	ld	b, a
	ld	a, (iy+tied_up)
	sub	b
	jr	nc, +
	xor	a
+
	ld	(iy+tied_up), a
	or	a
	ld	hl, DialogueBattleRemoveBindings_B12
	jr	z, +
	ld	hl, DialogueBattleCannotMove_B12
+
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_1188:
	call	LABEL_2EAC
	call	LABEL_1BCE
	cp	$01
	jp	nz, LABEL_11DC
	ld	a, (Battle_current_player)
	ld	(CurrentCharacter), a
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
	cp	ItemID_NeedleGun
	jr	z, LABEL_11CB
	cp	ItemID_HeatGun
	jr	z, LABEL_11CF
	cp	ItemID_LaserGun
	jr	z, LABEL_11D3
	call	ShowAttackSprites

LABEL_11B5:
	call	UpdateRNGSeed
	and	$07
	add	a, $04
	call	IsCharacterAlive
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
	call	DoGunOrThunderAttack
	jp	LABEL_120B

LABEL_11DC:
	cp	$03
	jp	nz, LABEL_11F1
	ld	a, c
	ld	(CurrentCharacter), a
	ld	a, b
	and	$1F
	ld	hl, BattleMagicActionPointers
	call	GetPtrAndJump
	jp	LABEL_120B

LABEL_11F1:
	cp	$04
	jp	nz, LABEL_120B
	ld	a, (Battle_current_player)
	ld	(CurrentCharacter), a
	ld	a, b
	ld	(CurrentItem), a
	call	Inventory_FindItem
	jr nz, LABEL_1212
	ld	(Selected_inventory_item), hl
	call	ItemAction_Use

LABEL_120B:
	call	UpdateEnemyHP
	call	LABEL_2ECD
	ret

LABEL_1212:
	ld	hl, DialogueBattleItemUsedUp_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	jr	LABEL_120B

LABEL_121D:
	ld	a, (iy+attack)
	bit 7, (iy+status)
	jr	z, +
	ld	c, a
	rrca
	and	$7F
	add	a, c
	jr	nc, +
	ld	a, $FF
+
	call	Battle_RandomReduce
	ld	c, a
	ld	a, (ix+defense)
	call	Battle_RandomReduce
	sub	c
	jr	c, Battle_FlashAndReduceEnemyHp
	cp	$10
	jr	c, LABEL_1251
	rrca
	jr	c, LABEL_1251
	ld	a, $BB
	ld	(Sound_index), a
	ld	hl, DialogueEnemyDodgesAttack_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_1251:
	call	UpdateRNGSeed
	and	$1F
	cp	(iy+level)
	jr	z, +
	jr	nc, LABEL_1251

+
	cpl

Battle_FlashAndReduceEnemyHp:
	push	af
	ld	a, $AD
	ld	(Sound_index), a
	call	ScreenFlash
	pop	af
	add	a, (ix+curr_hp)
	jr	c, +
	xor	a
+
	ld	(ix+curr_hp), a
	ret	nz
	ld	(ix+status), a
	ld	(ix+tied_up), a
	ret

Battle_RandomReduce:
	rrca
	and	$7F
	ld	b, a
	rrca
	and	$3F
	ld	e, a
	call	UpdateRNGSeed
	ld	h, a
	call	Multiply8Bit
	ld	a, e
	add	a, b
	add	a, h
	ret

LABEL_128C:
	call	IsCharacterAlive
	ret	z
	push	hl
	pop	iy
	ld	a, (iy+$D)
	or	a
	jr	z, Battle_GetEnemyAction
	call	UpdateRNGSeed
	and	$01
	inc	a
	ld	b, a
	ld	a, (iy+$D)
	sub	b
	jr	nc, +
	xor	a
+
	ld	(iy+tied_up), a
	or	a
	ld	hl, DialogueBattleEnemyRemovedBindings_B12
	jr	z, +
	ld	hl, DialogueBattleEnemyCannotMove_B12
+
	call	ShowDialogue_B12
	jp	CloseTextBox

Battle_GetEnemyAction:
	ld	a, (Battle_enemy_action)
	and	$07
	ld	hl, BattleEnemyActions
	jp	GetPtrAndJump


; =================================================================
BattleEnemyActions:
.dw Battle_EnemyRegularAttack
.dw Battle_EnemyMagicBind
.dw Battle_EnemyMagicHeal80
.dw Battle_EnemyMagicPowerUp
.dw Battle_EnemyMagicAttack
.dw Battle_EnemyAttackAll40
.dw Battle_EnemyMedusaAttack
.dw Battle_EnemyActionCrystal
; =================================================================



CheckRemoveMagicWall:
	ld	a, (Battle_enemy_action)
	and	$10
	jr	z, LABEL_12FA
	call	UpdateRNGSeed
	and	$03
	ld	c, a
	ld	a, (Magic_wall_active)
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
	ld	(Magic_wall_active), a
	ret

LABEL_12FA:
	xor	a
	ld	(Magic_wall_active), a
	ld	hl, DialogueBattleMagicWallDisappears_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

Battle_EnemyRegularAttack:
	ld	a, (Magic_wall_active)
	or	a
	call	nz, CheckRemoveMagicWall

-
	call	UpdateRNGSeed
	and	$03
	call	IsCharacterAlive
	jp	z, -
	ld	(CurrentCharacter), a
	push	hl
	pop	ix
	push	af
	ld	(Battle_player_target), a
	call	ShowCharacterStatsBox
	call	Battle_EnemyAttackPlayer
	ld	a, (Battle_player_hurt_flag)
	or	a
	push	af
	call	LABEL_18CE
	pop	af
	jr	nz, LABEL_1344
	ld	a, (Magic_wall_active)
	or	a
	ld	hl, DialogueBattleMagicWallDeflects_B12
	jr	nz, +
	ld	hl, DialogueBattlePlayerDodgesAttack_B12
+
	call	ShowDialogue_B12
	call	CloseTextBox

LABEL_1344:
	pop	af
	call	IsCharacterAlive
	jr	nz, LABEL_1379
	ld	hl, DialogueBattlePlayerDied_B12
	call	ShowDialogue_B12
	ld	a, (Battle_enemy_id)
	cp	EnemyID_GdDragn
	jr	nz, LABEL_1376
	ld	a, (CurrentCharacter)
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
	ld	hl, DialogueBattleMyauDiesFlying_B12
	call	ShowDialogue_B12

LABEL_1376:
	call	CloseTextBox

LABEL_1379:
	ld	b, $04

-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	call	HidePartyStats
	ret

Battle_EnemyMagicBind:
	; 3/4 chance of a regular attack
    ; 1/4 chance of casting a bind spell:
    ; - will wear down a magic wall if present
    ; - else "ties up" a player
	call	UpdateRNGSeed
	and	$03
	jp	nz, Battle_EnemyRegularAttack
	ld	a, (Magic_wall_active)
	and	$80
	call	nz, CheckRemoveMagicWall
	ld	a, (Magic_wall_active)
	and	$80
	jr	z, _f
	ld	hl, DialogueBattleMagicWallDeflectsEnemyMagic_B12
	call	ShowDialogue_B12
	jp	CloseTextBox
__
	call	UpdateRNGSeed
	and $03
	call	IsCharacterAlive
	jr	z, _b
	ld	(CurrentCharacter), a
	ld	a, $0D	; stat tied_up
	add	a, l
	ld	l, a
	ld	a, (hl)
	or	a
	jp	nz, Battle_EnemyRegularAttack
	ld	(hl), $03
	ld	a, $A1
	ld	(Sound_index), a
	ld	hl, DialogueBattleMagicPlayerTiedUp_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

Battle_EnemyMagicHeal80:
	; If enemy HP is below 30, always heal.
    ; Else 7/8 chance of a regular attack,
    ; 1/8 chance of healing by up to 80 HP
	ld	a, (iy+1)
	cp	$1E
	jr	c, +
	call	UpdateRNGSeed
	and	$07
	jp	nz, Battle_EnemyRegularAttack
+
	ld	b, (iy+max_hp)
	ld	a, (iy+curr_hp)
	add	a, $50
	jr	nc, +
	ld	a, $FF
+
	cp	b
	jr	c, +
	ld	a, b
+
	ld	(iy+curr_hp), a
	ld	a, $A1
	ld	(Sound_index), a
	call	UpdateEnemyHP
	ld	hl, DialogueBattleEnemyHealed_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

Battle_EnemyMagicPowerUp:
	; 15/16 chance of a regular attack
    ; 1/16 chance of enemy strength boost
	call	UpdateRNGSeed
	and	$0F
	jp	nz, Battle_EnemyRegularAttack
	ld	a, (iy+status)
	and	$80 ; Check if already powered up
	jp	nz, Battle_EnemyRegularAttack
	set	7, (iy+status)
	ld	a, $A1
	ld	(Sound_index), a
	ld	hl, DialogueBattlePowerUp_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

Battle_EnemyMagicAttack:
	; 3/4 chance of a regular attack
    ; 1/4 chance to damage between 7 and 10 HP to two random players
	call	UpdateRNGSeed
	and	$03
	jp	nz, Battle_EnemyRegularAttack
	call	+

+
	ld	a, (Magic_wall_active)
	and	$80
	call	nz, CheckRemoveMagicWall
	ld	b, $04

-
	ld	a, b
	sub	$04
	neg
	call	IsCharacterAlive
	jr	nz, LABEL_1443
	djnz	-
	ret
LABEL_1443
	call	UpdateRNGSeed
	and	$03
	call	IsCharacterAlive
	jp	z, LABEL_1443
	ld	(CurrentCharacter), a
	ld	(Battle_player_target), a
	call	ShowCharacterStatsBox
	call	UpdateRNGSeed
	and	$03
	add	a, $F6
	ld	b, a
	ld	a, (Magic_wall_active)
	and	$80
	ld	a, b
	call	z, Battle_ReducePlayerHP
	ld	a, $80
	ld	($C88A), a
	call	LABEL_18CE
	ld	a, (Magic_wall_active)
	and	$80
	jr	z, +
	ld	hl, DialogueBattleMagicWallDeflectsEnemyMagic_B12
	call	ShowDialogue_B12
	call	CloseTextBox
+
	ld	a, (CurrentCharacter)
	call	IsCharacterAlive
	jr	nz, +
	ld	hl, DialogueBattlePlayerDied_B12
	call	ShowDialogue_B12
	call	CloseTextBox
+
	ld	b, $04

-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	jp	HidePartyStats

Battle_EnemyAttackAll40:
	; 3/4 chance of a regular attack
    ; 1/4 chance of -40 attack on all players
	call	UpdateRNGSeed
	and	$03
	jp	nz, Battle_EnemyRegularAttack
	ld	c, $D8

Battle_EnemyAttackAll40Cont:
	ld	b, $04

LABEL_14A9:
	push	bc
	ld	a, (Magic_wall_active)
	and	$80
	call	nz, CheckRemoveMagicWall
	pop	bc
	push	bc
	ld	a, b
	sub	$04
	neg
	call	IsCharacterAlive
	jr	z, LABEL_1501
	ld	(CurrentCharacter), a
	ld	(Battle_player_target), a
	push	bc
	call	ShowCharacterStatsBox
	pop	bc
	call	LABEL_1505
	ld	a, $C0
	ld	($C88A), a
	call	LABEL_18CE
	ld	a, (Magic_wall_active)
	and	$80
	jr	z, +
	ld	hl, DialogueBattleMagicWallDeflectsEnemyMagic_B12
	call	ShowDialogue_B12
	call	CloseTextBox
+
	ld	a, (CurrentCharacter)
	call	IsCharacterAlive
	jr	nz, +
	ld	hl, DialogueBattlePlayerDied_B12
	call	ShowDialogue_B12
	call	CloseTextBox
+
	ld	b, $04

-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	call	HidePartyStats

LABEL_1501:
	pop	bc
	djnz	LABEL_14A9
	ret

LABEL_1505:
	ld	a, c
	cp	$FF
	jp	z, Battle_EnemyAttackPlayerCont
	ld	a, (Magic_wall_active)
	and	$80
	ret	nz
	call	UpdateRNGSeed
	and	$0F
	add	a, c
	jp	Battle_ReducePlayerHP

Battle_EnemyMedusaAttack:
	; Regular attack if Odin has the Mirror Shield equipped.
    ; Else turn a random player to stone.
	ld	a, (Odin_stats)
	or	a
	jr	z, +
	ld	a, (Odin_stats+shield)
	cp	ItemID_MirrorShield
	jp	z, Battle_EnemyRegularAttack
+
	ld	a, (Magic_wall_active)
	or	a
	call	nz, CheckRemoveMagicWall

-
	call	UpdateRNGSeed
	and	$03
	call	IsCharacterAlive
	jp	z, -
	ld	(CurrentCharacter), a
	ld	(Battle_player_target), a
	push	hl
	call	ShowCharacterStatsBox
	pop	hl
	xor	a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	call	LABEL_18CE
	ld	hl, DialogueBattleTurnedToStone_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	ld	b, $04

-
	ld	a, $08
	call	WaitForVInt
	djnz	-
	jp	HidePartyStats

Battle_EnemyActionCrystal:
	; +1 HP if you have the Crystal
	ld	a, ItemID_Crystal
	ld	(CurrentItem), a
	call	Inventory_FindItem
	ld	c, $01
	jp	nz, Battle_EnemyAttackAll40Cont
	ld	c, $FF
	jp	Battle_EnemyAttackAll40Cont

Battle_EnemyAttackPlayer:
	ld	a, (Magic_wall_active)
	or	a
	jr	nz, LABEL_15AD

Battle_EnemyAttackPlayerCont:
	ld	a, (iy+attack) ; Enemy attack points
	bit	7, (iy+status) ; Check for powered up bit
	jr	z, +
	ld	c, a ; Attack *= 1.5 if powered up
	rrca
	and	$7F
	add	a, c
	jr	nc, +
	ld	a, $FF
+
	bit	6, (iy+status) ; Bit 6 = powered down
	jr	z, +
	ld	c, a ; Attack *= 0.75 if set
	rrca
	rrca
	and	$3F
	ld	b, a
	ld	a, c
	sub	b
+
	call	Battle_RandomReduce
	ld	c, a
	ld	a, (ix+defense)
	call	Battle_RandomReduce
	sub	c
	jr	c, Battle_ReducePlayerHP
	cp	$10
	jr	c, Battle_DoRandomDamage
	rrca
	jr	c, Battle_DoRandomDamage

LABEL_15AD:
	xor	a
	ld	(Battle_player_hurt_flag), a
	ret

Battle_DoRandomDamage:
	; Get a random number between 0 and character's level
	call	UpdateRNGSeed
	and	$1F
	cp	(ix+level)
	jr	z, +
	jr	nc, Battle_DoRandomDamage
+
	rrca ; Divide by 2
	and	$7F
	cpl ; And invert
	; This makes -(rnd() * LV + 1)

Battle_ReducePlayerHP:
	add	a, (ix+curr_hp)
	jr	c, +
	xor	a
+
	ld	(ix+curr_hp), a
	jr	nz, +
	ld	(ix+status), a
	ld	(ix+tied_up), a
+
	ld	a, $FF
	ld	(Battle_player_hurt_flag), a
	ret

Battle_RemoveEnemy:
	call	HideEnemyData
LABEL_15DC:
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $00FF
	ld	(hl), $00
	ldir
	call	BuildSprites
	ld	a, (Scene_type)
	or	a
	jp	nz, LABEL_15F9
	call	LABEL_6B3A
	jp	LABEL_15FC

LABEL_15F9:
	call	LABEL_3D36
LABEL_15FC:
	ld	a, $10
	call	WaitForVInt
	ret


LABEL_1602:
	ld	a, (Battle_enemy_id)
	cp	EnemyID_Tarzimal
	jr	z, LABEL_160D
	cp	EnemyID_Saccubus
	jr	nz, LABEL_1613

LABEL_160D:
	ld	a, $D8
	ld	(Sound_index), a
	ret

LABEL_1613:
	cp	EnemyID_GdDragn
	jr	nz, +
	ld	hl, Normal_palette+$10
	ld	b, $10

-
	ld	(hl), $30
	inc	hl
	djnz	-

+
	ld	a, $94		; Game Over music
	ld	(Sound_index), a
	ld	a, (Party_curr_num)
	or	a
	ld	hl, DialogueBattleAllDead_B12
	call	nz, ShowDialogue_B12
	ld	hl, DialogueBattleAlisGameOver_B12
	call	ShowDialogue_B12
	ld	hl, Game_mode
	ld	(hl), $02 ; GameMode_LoadTitleScreen
	jp	CloseTextBox

LABEL_163E:
	push	af
	call	Battle_RemoveEnemy
	call	UpdateCharStats
	ld	a, $D8
	ld	(Sound_index), a
	pop	af
	cp	$05
	ret	nz
	ld	a, (Scene_type)
	or	a
	ret	nz
	jp	Dungeon_RunAway

LABEL_1656:
	ld	a, (Battle_enemy_id)
	cp	EnemyID_Tarzimal
	jr	nz, LABEL_1663
	ld	a, $D8
	ld	(Sound_index), a
	ret

LABEL_1663:
	cp	EnemyID_GdDragn
	jr	nz, LABEL_1671
	ld	hl, Normal_palette+$10
	ld	b, $10
LABEL_166C:
	ld	(hl), $30
	inc	hl
	djnz	LABEL_166C
LABEL_1671:
	ld	a, $AF
	ld	(Sound_index), a
	call	Battle_RemoveEnemy

LABEL_1679:
	ld	a, (Battle_enemy_id)
	cp	EnemyID_Lassic
	jr	z, LABEL_1683
	cp	EnemyID_DarkFalz
	jr	nz,LABEL_1688

LABEL_1683:
	ld	b, $B4
	call	VIntDelay2

LABEL_1688:
	ld	a, $D8
	ld	(Sound_index), a
	ld	hl, DialogueBattleEnemyKilled_B12
	call	ShowDialogue_B12
	call	AwardEXP
	call	UpdateCharStats
	ld	hl, (Enemy_money)
	ld	a, (Dungeon_item_index)
	or	l
	or	h
	ret	z
	ld	hl, DialogueBattleEnemyHadChest
	call	ShowDialogue_B12
	call	Battle_ShowTreasureChest
	call	WaitForButton1Or2
	jp	RunTreasureChest

Battle_ShowTreasureChest:
	ld	hl, $FFFF
	ld	(hl), :Bank20
	ld	hl, Palette_TreasureChest_B20
	ld	de, Target_palette+$18
	ld	bc, $0008
	ldir
	ld	hl, Target_palette
	ld	de, Normal_palette
	ld	bc, $0020
	ldir
	ld	hl, Tiles_TreasureChest_B20
	ld	de, $6000
	call	LoadTiles4BitRLE
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $00FF
	ld	(hl), $00
	ldir
	ld	a, $0D
	ld	(Character_sprite_attributes), a
	call	BuildSprites
	ld	a, $16
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

AwardEXP:
	ld	hl, (CurrentBattle_EXPReward)
	ld	(NumberToShowInText), hl
	ld	a, l
	or	h
	ret	z
	ld	hl, DialogueGainedEXP_B12
	call	ShowDialogue_B12
	ld	iy, Alis_stats
	ld	de, B03_AlisLevelTable
	xor	a
	ld	(CurrentCharacter), a
	call	CalculateExp
	ld	iy, Myau_stats
	ld	de, B03_MyauLevelTable
	ld	a, $01
	ld	(CurrentCharacter), a
	call	CalculateExp
	ld	iy, Odin_stats
	ld	de, B03_OdinLevelTable
	ld	a, $02
	ld	(CurrentCharacter), a
	call	CalculateExp
	ld	iy, Noah_stats
	ld	de, B03_NoahLevelTable
	ld	a, $03
	ld	(CurrentCharacter), a

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
	cp	Maximum_Level
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
	ld	(Sound_index), a
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
	ld	hl, DialogueLearnedSpell_B12
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
	ld	de, ItemEquipBoosts
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



; =================================================================
ItemEquipBoosts:
.db	$00	; 0
.db	$03	; 1
.db	$04	; 2
.db	$0C	; 3
.db	$0A	; 4
.db	$0A	; 5
.db	$0A	; 6
.db $15	; 7
.db	$1F	; 8
.db	$12	; 9
.db	$1E	; $A
.db	$1E	; $B
.db	$2E	; $C
.db	$32	; $D
.db	$3C	; $E
.db	$50	; $F
.db	$05	; $10
.db	$05	; $11
.db	$0F	; $12
.db	$14	; $13
.db	$1E	; $14
.db	$1E	; $15
.db	$3C	; $16
.db $50	; $17
.db	$28	; $18
.db	$03	; $19
.db	$08	; $1A
.db	$0F	; $1B
.db	$17	; $1C
.db	$28	; $1D
.db	$1E	; $1E
.db	$28	; $1F
.db	$32	; $20
.db	$00	; $21
.db	$00	; $22
.db	$00	; $23
.db	$00	; $24
.db	$00	; $25
.db	$00	; $26
.db $00	; $27
.db	$00	; $28
.db	$00	; $29
.db	$00	; $2A
.db	$00	; $2B
.db	$00	; $2C
.db	$00	; $2D
.db	$00	; $2E
.db	$00	; $2F
.db	$00	; $30
.db	$00	; $31
.db	$00	; $32
.db	$00	; $33
.db	$00	; $34
.db	$00	; $35
.db	$00	; $36
.db $00	; $37
.db	$00	; $38
.db	$00	; $39
.db	$00	; $3A
.db	$00	; $3B
.db	$00	; $3C
.db	$00	; $3D
.db	$00	; $3E
.db	$00	; $3F
; =================================================================

IsCharacterAlive_FromC267:
	ld	a, (Battle_current_player)

IsCharacterAlive:
	push	af
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, Char_stats
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	pop	af
	bit  0, (hl)
	ret

ShowMessageIfDead:
	push	hl
	call	IsCharacterAlive
	pop	hl
	ret  nz

	push	af
	push	bc
	push	de
	push	hl
	ld	(CurrentCharacter), a
	ld	hl, DialogueCharacterAlreadyDead_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret


ShowAttackSprites:
	push	iy
	ld	(Character_sprite_attributes+$A), a
	ld	a, $0B
	ld	(Character_sprite_attributes), a
	call	LABEL_18B9
	pop	iy
	ret

LABEL_18B9:
	ld	a, $08
	call	WaitForVInt
	call	BuildSprites
	ld	a, (Character_sprite_attributes)
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
	ld	(Sound_index), a

LABEL_18DB:
	ld	a, $08
	call	WaitForVInt
	call	BuildSprites
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
	call	UpdateRNGSeed
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


; =================================================================
BattleMenu_OptionTbl:
.dw	BattleMenu_Attack
.dw	BattleMenu_Magic
.dw	BattleMenu_Item
.dw	BattleMenu_Talk
.dw BattleMenu_Run
; =================================================================

BattleMenu_Attack:
	ld	bc, $01
	xor	a
	call	LABEL_1BB9
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a
	ret

BattleMenu_Talk:
	call	LABEL_2ECD
	call	HidePartyStats
	call	CloseMenu
	ld	a, (Battle_current_player)
	ld	(CurrentCharacter), a
	ld	hl, DialogueBattleCharacterSpeaks_B12
	call	ShowDialogue_B12
	ld	a, (Battle_enemy_action)
	and	$80
	jr	z, Battle_EnemyDoesNotUnderstand
	ld	a, ($C448)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	jr	nc, LABEL_1964
Battle_EnemyDoesNotUnderstand
	ld	a, $04
	ld	(Battle_current_player), a
	ld	a, $FF
	ld	($C2D4), a
	ld	hl, DialogueBattleNotUnderstand_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_1964:
	ld	hl, DialogueBattleEnemyAnswers_B12
	call	ShowDialogue_B12

-
	call	UpdateRNGSeed
	and	$0F
	cp	$09
	jr	nc, -
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld	de, BattleEnemyDialoguePointers
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	call	ShowDialogue_B12
	ld	a, $06
	ld	(Battle_current_player), a
	jp	CloseTextBox


; =================================================================
BattleEnemyDialoguePointers:
.dw	DialogueBattleWantToBeFriends_B12
.dw	DialogueBattleWantToEatLaerma_B12
.dw	DialogueBattleDontOffendLassic_B12
.dw	DialogueBattleUnderstandOurLanguage_B12
.dw	DialogueBattleEnemyHello_B12
.dw	DialogueBattleCarefulOfPitsin_B12
.dw	DialogueBattleChestsTrapped_B12
.dw	DialogueBattleYouThief_B12
.dw	DialogueBattleWeAreOutcasts_B12
; =================================================================


BattleMenu_Run:
	call	LABEL_2ECD
	call	HidePartyStats
	call	CloseMenu
	ld	a, (Battle_escape_rate)
	ld	b, a
	call	UpdateRNGSeed
	cp	b
	jr	nc, LABEL_19C5
	ld	a, (Scene_type)
	or	a
	jr	nz, +
	call	LABEL_687A
	jr	nz, LABEL_19C5
+
	ld	a, $BC
	ld	(Sound_index), a
	ld	a, $05
	ld	(Battle_current_player), a
	ret

LABEL_19C5:
	ld	a, (Battle_current_player)
	ld	(CurrentCharacter), a
	ld	hl, DialogueBattleEnemyBlocksRetreat_B12
	call	ShowDialogue_B12
	ld	a, $04
	ld	(Battle_current_player), a
	ld	a, $FF
	ld	($C2D4), a
	jp	CloseTextBox

BattleMenu_Magic:
	ld	a, (Battle_current_player)
	ld	(CurrentCharacter), a
	cp	$02
	jp	nz, LABEL_19F2
	ld	hl, DialogueBattleOdinCannotUseMagic_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

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
	call	ShowMagicMenu
	ld	hl, $7A8C
	ld	(CursorTileMapAddress), hl
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
	ld	de, BattleMagicList
	add	hl, de
	ld	a, (hl)
	and	$1F
	ld	b, a
	call	CheckEnoughMP
	jr	c, LABEL_1A4B
	ld	a, b
	ld	hl, BattleMagicSelectPointers
	call	GetPtrAndJump

LABEL_1A3F:
	jp	HideMagicMenu

LABEL_1A42:
	ld	hl, DialogueBattleNotLearnedMagic_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_1A4B:
	ld	hl, DialogueBattleNotEnoughPoints_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	jp	HideMagicMenu


; =================================================================
BattleMagicList:

; Alis
.db	MagicID_Heal
.db	MagicID_Bye
.db MagicID_Chat
.db	MagicID_Fire
.db	MagicID_Rope

; Myau
.db	MagicID_Cure
.db	MagicID_Terr
.db	MagicID_Wall
.db	MagicID_Help
.db	MagicID_Nothing

; Noah
.db	MagicID_Fire
.db	MagicID_Tele
.db	MagicID_Wind
.db	MagicID_Prot
.db	MagicID_Thun
; =================================================================


; =================================================================
BattleMagicSelectPointers:
.dw	BattleMagicSelect_Nothing	; 0
.dw	BattleMagicSelect_Heal	; 1
.dw	BattleMagicSelect_Heal	; 2
.dw	BattleMagicSelect_Advance	; 3
.dw	BattleMagicSelect_Advance	; 4
.dw	BattleMagicSelect_SelectEnemy	; 5
.dw	BattleMagicSelect_SelectEnemy	; 6
.dw	BattleMagicSelect_SelectEnemy	; 7
.dw	BattleMagicSelect_SelectEnemy	; 8
.dw	BattleMagicSelect_Advance	; 9
.dw	BattleMagicSelect_Help	; $A
.dw	BattleMagicSelect_Advance	; $B
.dw	BattleMagicSelect_Advance	; $C
.dw	BattleMagicSelect_Advance	; $D
.dw	BattleMagicSelect_Advance	; $E
.dw	BattleMagicSelect_Advance	; $F
.dw	BattleMagicSelect_Chat	; $10
.dw	BattleMagicSelect_Tele	; $11
; =================================================================


; =================================================================
BattleMagicActionPointers:
.dw	MagicAction_Nothing		; 0
.dw	BattleMagicAction_Heal	; 1
.dw	BattleMagicAction_Cure	; 2
.dw	BattleMagicAction_Wall	; 3
.dw	BattleMagicAction_Prot	; 4
.dw	BattleMagicAction_Fire	; 5
.dw	BattleMagicAction_Thun	; 6
.dw	BattleMagicAction_Wind	; 7
.dw	BattleMagicAction_Rope	; 8
.dw	BattleMagicAction_Bye	; 9
.dw	BattleMagicAction_Help	; $A
.dw	BattleMagicAction_Terr	; $B
.dw	BattleMagicAction_Trap	; $C
.dw	BattleMagicAction_Exit	; $D
.dw	BattleMagicAction_Open	; $E
.dw	BattleMagicAction_Rise	; $F
.dw	BattleMagicSelect_Chat	; $10
.dw	BattleMagicSelect_Tele	; $11
; =================================================================


BattleMagicSelect_Nothing:
	jp	BattleMagicSelect_Nothing

BattleMagicSelect_Heal:
	push	bc
	call	PlayerSelect2
	pop	de
	bit	4, c
	jr	nz, LABEL_1ACC
	call	ShowMessageIfDead
	jr	z, LABEL_1ACC
	ld	c, $03
	ld	b, d
	call	LABEL_1BB9
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a

LABEL_1ACC:
	call	HidePlayerSelect2Window
	ret

BattleMagicSelect_SelectEnemy:
	ld	c, $03
	xor	a
	call	LABEL_1BB9
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a
	ret

BattleMagicSelect_Help:
	push	bc
	call	PlayerSelect2
	pop	de
	bit	4, c
	jr	nz, LABEL_1AF9
	call	ShowMessageIfDead
	jr	z, LABEL_1AF9
	ld	c, $03
	ld	b, d
	call	LABEL_1BB9
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a

LABEL_1AF9:
	call	HidePlayerSelect2Window
	ret

BattleMagicSelect_Advance:
	ld	c, $03
	ld	a, (CurrentCharacter)
	call	LABEL_1BB9
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a
	ret

BattleMagicSelect_Chat:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a

BattleMagicSelect_ChatCont:
	ld	a, (Battle_enemy_action)
	and	$C0
	jp	z, Battle_EnemyDoesNotUnderstand
	and	$40
	jp	z, LABEL_1964
	ld	a, ($C448)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	jr	nc, LABEL_1B42
	jp	Battle_EnemyDoesNotUnderstand

BattleMagicSelect_Tele:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a

BattleMagicSelect_TeleCont:
	ld	a, (Battle_enemy_action)
	and	$C0
	jp	z, Battle_EnemyDoesNotUnderstand
	and	$40
	jp	z, LABEL_1964

LABEL_1B42:
	ld	a, $AC
	ld	(Sound_index), a
	ld	hl, DialogueBattleEnemyAnswers_B12
	call	ShowDialogue_B12

-
	call	UpdateRNGSeed
	and	$0F
	cp	$0A
	jr	nc, -
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld	de, BattleEnemyDialoguesPointers2
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	call	ShowDialogue_B12
	ld	a, $06
	ld	(Battle_current_player), a
	ld	a, $D5
	ld	(Sound_index), a
	jp	CloseTextBox


; =================================================================
BattleEnemyDialoguesPointers2:
.dw	DialogueBattleSoundOfFlute_B12
.dw	DialogueBattleIceDigger_B12
.dw	DialogueBattleLassicLivesAbove_B12
.dw	DialogueBattleAbionDoctor_B12
.dw	DialogueBattlePlacesInSky_B12
.dw	DialogueBattleLaermaNeedsLight_B12
.dw	DialogueBattleSecretDoorsInDungeon_B12
.dw	DialogueBattleMiracleKeyOpenDoors_B12
.dw	DialogueBattleSomeDezoriansLie_B12
.dw	DialogueBattleBraveToApproachMe_B12
; =================================================================


CheckEnoughMP:
	ld	hl, MPCostData
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (Battle_current_player)
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
	call	SelectItemFromInventory
	call	HideInventoryWindow
	bit	4, c
	ret	nz
	ld	a, (CurrentItem)
	ld	b, a
	ld	c, $04
	xor	a
	call	LABEL_1BB9
	ld	a, (Battle_current_player)
	inc	a
	ld	(Battle_current_player), a
	ret

LABEL_1BB9:
	push	af
	ld	a, (Battle_current_player)
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
	ld	a, (Battle_current_player)
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
	xor	a
	ld	(Battle_flag), a
	ld	($C2D8), a
	call	LABEL_36DD
	call	UpdatePartyStats

LABEL_1BEE:
	ld	a, ($C2D8)
	or	a
	jr	nz, LABEL_1C15
	ld	hl, $7882
	ld	(CursorTileMapAddress), hl
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
	ld	(Character_sprite_attributes), a
	ld	a, $D0
	ld	(Sprite_table), a
+
	call	HidePartyStats
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
	call	WaitForButton1Or2
	jp	OdinIntro
+
	cp	$07
	jr	nc, +
	ld	a, $85		; Final dungeon music
	call	Map_CheckMusic
	call	LABEL_7CBB
	ld	a, $FF
	ld	($C2DC), a
	jp	LABEL_1BE1
+
	cp	$08
	jp	c, MyauTransformation
	ld	a, $BF
	ld	(Sound_index), a
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	xor	a
	ld	(Vehicle_movement_flags), a
	ld	a, (Last_church_visited)
	ld	l, a
	add	a, a
	add	a, l
	ld	h, $00
	ld	l, a
	ld	de, ChurchLocationData
	add	hl, de
	jp	LABEL_787B


; =================================================================
ChurchLocationData:
.db $04, $16, $69
.db $04, $27, $6B ; Camineet
.db $07, $29, $2A ; Gothic
.db $09, $19, $66
.db $0E, $29, $19 ; Camineet
.db $0F, $15, $43 ; Uzo
.db $11, $53, $52
.db $16, $15, $2C
.db $15, $28, $61
; =================================================================


; =================================================================
PlayerMenu_OptionTbl:
.dw	PlayerMenu_Stats
.dw	PlayerMenu_Magic
.dw	PlayerMenu_Item
.dw	PlayerMenu_Search
.dw	PlayerMenu_Save
; =================================================================


PlayerMenu_Stats:
	call	PlayerSelect
	bit  Button_1, c
	jr	nz, LABEL_1CDC
	call	ShowMessageIfDead
	jr	z, LABEL_1CDC
	push	af
	call	ShowEquippedItems
	call	ShowCharacterStats
	call	WaitForButton1Or2
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
	call	ShowMagicMenu
	call	WaitForButton1Or2
	call	HideMagicMenu

LABEL_1CD6:
	call	HideCharacterStats
	call	HideEquippedItems

LABEL_1CDC:
	jp	ClosePlayerSelect


PlayerMenu_Save:
	ld	hl, DialogueSaveSelectSlot_B12
	call	ShowDialogue_B12
	call	GetSaveGameSelection
	ld	hl, DialogueSaveDeleteConfirmSlot_B12
	call	ShowDialogue_B12
	call	ShowYesNoPrompt
	jr	nz, LABEL_1D3B
	ld	a, (Game_mode)
	ld	($C316), a
	ld	hl, DialogueSavingToSlot_B12
	call	ShowDialogue_B12
	push	bc
	ld	a, (NumberToShowInText)
	ld	h, a
	ld	l, $00
	add	hl, hl
	add	hl, hl
	set	7, h
	ex	de, hl
	call	CheckSlotUsed
	push	af
	push	hl
	ld	a, $08
	ld	($FFFC), a
	ld	(hl), $00
	ld	hl, H_scroll
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
	ld	hl, DialogueTextSavingComplete_B12
	call	ShowDialogue_B12

LABEL_1D3B:
	call	LABEL_39DD
	jp	CloseTextBox

LABEL_1D41:
	xor	a
	ld	(Name_entry_mode), a
	ld	hl, Game_mode
	ld	(hl), $10 ; GameMode_LoadNameInput
	pop	hl
	pop	hl
	ret

PlayerMenu_Magic:
	call	PlayerSelect
	bit	Button_1, c
	jp	nz, LABEL_1DBA
	call	ShowMessageIfDead
	jp	z, LABEL_1DBA
	cp	$02	; is it Odin?
	jp	z, LABEL_1DC5	; jump and display different message for Odin
	ld	c, a
	ld	(CurrentCharacter), a
	ld	(Battle_current_player), a
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
	call	ShowMagicMenu
	ld	hl, $7A8C
	ld	(CursorTileMapAddress), hl
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
	ld	de, MapMagicList
	add	hl, de
	ld	a, (hl)
	and	$1F
	ld	b, a
	call	CheckEnoughMP
	jp	c, LABEL_1DD1
	ld	a, b
	ld	hl, MapMagicActionPointers
	call	GetPtrAndJump

LABEL_1DB7:
	call	HideMagicMenu

LABEL_1DBA:
	call	ClosePlayerSelect
	jp	LABEL_2F3C

LABEL_1DC0:
	ld	hl, DialogueBattleNotLearnedMagic_B12
	jr	LABEL_1DC8

LABEL_1DC5:
	ld	hl, DialogueBattleOdinCannotUseMagic_B12

LABEL_1DC8:
	call	ShowDialogue_B12
	call	CloseTextBox
	jp	ClosePlayerSelect

LABEL_1DD1:
	ld	hl, DialogueBattleNotEnoughPoints_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	jr	LABEL_1DB7


; =================================================================
MPCostData:
.db	$00	; 0
.db	$02	; 1
.db	$06	; 2
.db	$06	; 3
.db	$0A	; 4
.db	$04	; 5
.db	$10	; 6
.db	$0C	; 7
.db	$04	; 8
.db	$02	; 9
.db	$0A	; $A
.db	$02	; $B
.db	$02	; $C
.db	$04	; $D
.db	$04	; $E
.db $0C	; $F
.db	$02	; $10
.db	$04	; $11
.db	$08	; $12
; =================================================================


; =================================================================
MapMagicList:

; Alis
.db	MagicID_Heal
.db	MagicID_Fly
.db	MagicID_Nothing
.db	MagicID_Nothing
.db	MagicID_Nothing

; Myau
.db	MagicID_Cure
.db	MagicID_Trap
.db	MagicID_Exit
.db	MagicID_Nothing
.db	MagicID_Nothing

; Noah
.db	MagicID_Cure
.db	MagicID_Exit
.db MagicID_Tele
.db	MagicID_Open
.db	MagicID_Rise
; =================================================================


; =================================================================
MapMagicActionPointers:
.dw	MagicAction_Nothing	; 0
.dw	MapMagicAction_Heal	; 1
.dw	MapMagicAction_Cure	; 2
.dw	BattleMagicAction_Wall	; 3
.dw	BattleMagicAction_Prot	; 4
.dw	BattleMagicAction_Fire	; 5
.dw	BattleMagicAction_Thun	; 6
.dw	BattleMagicAction_Wind	; 7
.dw	BattleMagicAction_Rope	; 8
.dw	BattleMagicAction_Bye	; 9
.dw	BattleMagicAction_Help	; $A
.dw	BattleMagicAction_Terr	; $B
.dw	BattleMagicAction_Trap	; $C
.dw	BattleMagicAction_Exit	; $D
.dw	BattleMagicAction_Open	; $E
.dw	BattleMagicAction_Rise	; $F
.dw	MapMagicAction_Chat	; $10
.dw	MapMagicAction_Chat	; $11
.dw	MapMagicAction_Fly	; $12
; =================================================================


MagicAction_Nothing:
	jp	MagicAction_Nothing

MapMagicAction_Heal:
	ld	d, 20
	jr	LABEL_1E2D

MapMagicAction_Cure:
	ld	d, 80

LABEL_1E2D:
	push	bc
	push	de
	call	PlayerSelect2
	pop	de
	bit	4, c
	pop	bc
	jr	nz, +
	ld	(CurrentCharacter), a
	call	ShowMessageIfDead
	jr	z, +
	call	LABEL_1E53
+
	jp	HidePlayerSelect2Window

BattleMagicAction_Heal:
	ld	d, 20
	jr	LABEL_1E4C

BattleMagicAction_Cure:
	ld	d, 80

LABEL_1E4C:
	ld	a, (CurrentCharacter)
	call	ShowMessageIfDead
	ret	z

LABEL_1E53:
	push	de
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	pop	de

BattleMagicAction_HealHP:
	push	de
	ld	hl, LABEL_B12_B1D0
	call	ShowDialogue_B12
	pop	de
	ld	a, $C1
	ld	(Sound_index), a
	ld	a, (CurrentCharacter)
	call	IsCharacterAlive
	push	hl
	pop	ix
	ld	b, (ix+max_hp)
	ld	a, (ix+curr_hp)
	add	a, d
	jr	nc, +
	ld	a, $FF
+
	cp	b
	jr	c, +
	ld	a, b
+
	ld	(ix+curr_hp), a
	jp	CloseTextBox

BattleMagicAction_Wall:
	ld	c, $06
	jr	LABEL_1E90

BattleMagicAction_Prot:
	ld	c, $86

LABEL_1E90:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, c
	ld	(Magic_wall_active), a
	ld	hl, DialogueMagicWallActive_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

BattleMagicAction_Fire:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	de, $F610
	call	BattleMagicAction_AttackRandomEnemy

BattleMagicAction_AttackRandomEnemy:
	ld	b, $08

-
	ld	a, b
	sub	$0C
	neg
	call	IsCharacterAlive
	jr	nz, +
	djnz	-
	ret
+
	push	de
	ld	a, e
	call	ShowAttackSprites

LABEL_1EC6:
	call	UpdateRNGSeed
	and	$07
	add	a, $04
	call	IsCharacterAlive
	jp	z, LABEL_1EC6
	push	hl
	pop	ix
	pop	de
	push	de
	call	UpdateRNGSeed
	and	$03
	add	a, d
	call	Battle_FlashAndReduceEnemyHp
	call	UpdateEnemyHP
	pop	de
	ret

BattleMagicAction_Thun:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	de, $D811

DoGunOrThunderAttack:
	; d = attach strength (negative number)
    ; e = weapon number for sprites
	ld	b, $08

LABEL_1EF0:
	push	bc
	ld	a, b
	sub	$0C
	neg
	call	IsCharacterAlive
	jp	z, LABEL_1F1F
	push	hl
	pop	ix
	push	de
	ld	a, e
	call	ShowAttackSprites
	pop	de
	push	de
	ld	a, d
	cp	$D8
	jr	nz, +
	call	UpdateRNGSeed
	and	$0F
	add	a, d
+
	call	Battle_FlashAndReduceEnemyHp
	call	UpdateEnemyHP
	pop	de
	ld	a, (Battle_enemy_id)
	cp	EnemyID_DarkFalz
	jr	z, LABEL_1F23

LABEL_1F1F:
	pop	bc
	djnz	LABEL_1EF0
	ret

LABEL_1F23:
	pop	bc
	ret

BattleMagicAction_Wind:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	de, $F412
	call	BattleMagicAction_AttackRandomEnemy
	call	BattleMagicAction_AttackRandomEnemy
	jp	BattleMagicAction_AttackRandomEnemy

BattleMagicAction_Rope:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, (Battle_enemy_action)
	and	$20
	jr	z, LABEL_1F71
	ld	a, (Enemy_stats+attack)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	ld	c, $03
	jr	nc, +
	call	UpdateRNGSeed
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
	call	IsCharacterAlive
	jr	z, +
	add	hl, de
	ld	a, (hl)
	or	a
	jr	z, LABEL_1F76
+
	djnz	-

LABEL_1F71:
	ld	hl, DialoguePlayerSpellNoEffect_B12
	jr	LABEL_1F7A

LABEL_1F76:
	ld	(hl), c
	ld	hl, DialogueEnemyTiedUp_B12

LABEL_1F7A:
	call	ShowDialogue_B12
	jp	CloseTextBox

BattleMagicAction_Bye:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	xor	a
	ld	(CurrentItem), a

BattleMagicAction_ByeCont:
	ld	a, (Battle_escape_rate)
	or	a
	jr	z, +
	ld	a, (Scene_type)
	or	a
	jr	nz, LABEL_1FAC
	call	LABEL_687A
	jr	z, LABEL_1FAC
+
	ld	a, (CurrentItem)
	or	a
	ld	hl, DialoguePlayerSpellNoEffect_B12
	jr	z, +
	ld	hl, DialogueNoEffect_B12
+
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_1FAC:
	ld	a, $BC
	ld	(Sound_index), a
	ld	hl, DialogueCharactersEscape_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	ld	a, $05
	ld	(Battle_current_player), a
	ret

BattleMagicAction_Help:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, (CurrentCharacter)
	call	ShowMessageIfDead
	ret	z
	call	IsCharacterAlive
	set	7, (hl)
	ld	hl, DialogueCharacterStrengthUp_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

BattleMagicAction_Terr:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, (Enemy_stats+attack)
	ld	b, a
	ld	a, (Alis_stats+attack)
	cp	b
	jr	c, LABEL_200C
	call	UpdateRNGSeed
	cp	$B2
	jr	nc, LABEL_200C
	ld	b, $08

-
	ld	a, b
	sub	$0C
	neg
	call	IsCharacterAlive
	jr	z, +
	bit	6, (hl)
	jr	z, LABEL_2011
+
	djnz	-

LABEL_200C:
	ld	hl, DialoguePlayerSpellNoEffect_B12
	jr	LABEL_2016

LABEL_2011:
	set	6, (hl)
	ld	hl, DialogueEnemyFear_B12

LABEL_2016:
	call	ShowDialogue_B12
	jp	CloseTextBox

BattleMagicAction_Trap:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, (Character_sprite_attributes)
	cp	$0E
	jr	z, ++
	ld	a, (Scene_type)
	or	a
	ld	hl, DialogueNothingUnusualHere_B12
	jr	nz, +
	call	CheckObjectInFront
	ld	hl, DialogueNothingUnusualHere_B12
	jr	z, +
	ld	l, c
	ld	h, $CB
	ld	(hl), $00
	ld	hl, DialogueTrapDisarmed_B12
+:
	call	ShowDialogue_B12
	jp	CloseTextBox

++:
	ld	a, ($C80F)
	cp	$3D
	ld	hl, LABEL_B12_B27F
	jr	z, +
	ld	hl, DialogueTrapDisarmed_B12
+:
	call	ShowDialogue_B12
	ld	a, $3D
	ld	(Character_sprite_attributes+$F), a
	jp	LABEL_28EE

BattleMagicAction_Exit:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, (Scene_type)
	or	a
	jr	z, LABEL_2078
	ld	hl, DialoguePlayerSpellNoEffect_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_2078:
	ld	a, $BF
	ld	(Sound_index), a
	ld	hl, DialogueCharacterBecomesLight_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	ld	a, $FF
	ld	($C2D8), a
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

BattleMagicAction_Open:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, (Scene_type)
	or	a
	jr	z, +
-:
	ld	hl, DialoguePlayerSpellNoEffect_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

+:
	ld	b, $01
	call	Dungeon_GetRelativeSquare
	and	$07
	cp	$06 ; Magically locked door
	jr	nz, -
	bit	7, (hl) ; Mark as unlocked
	jr	nz, -
	ld	a, $04
	ld	($C2D8), a
	ret

BattleMagicAction_Rise:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	call	PlayerSelect2
	bit	4, c
	jr	nz, +++
	push	af
	ld	a, $AB
	ld	(Sound_index), a
	pop	af
	ld	(CurrentCharacter), a
	call	IsCharacterAlive
	jr	z, +
	ld	hl, DialogueCharacterStillAlive_B12
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
	ld	hl, DialogueCharacterIsRevived_B12
++:
	call	ShowDialogue_B12
	call	CloseTextBox
+++:
	jp	HidePlayerSelect2Window

MapMagicAction_Chat:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AC
	ld	(Sound_index), a
MapMagicAction_ChatCont:
	ld	a, (Character_sprite_attributes)
	cp	$0E
	jr	z, ++
	ld	a, (Scene_type)
	or	a
	ld	hl, DialogueCharacterFeelsNothing_B12
	jr	nz, +
	call	CheckObjectInFront
	ld	hl, DialogueCharacterFeelsNothing_B12
	jr	z, +
	ld	hl, DialogueCharacterFeelsSomething_B12
+:
	call	ShowDialogue_B12
	ld	a, $D5
	ld	(Sound_index), a
	jp	CloseTextBox

++:
	ld	a, ($C80F)
	cp	$3D
	ld	hl, DialogueCharacterFeelsNothing_B12
	jr	z, +
	ld	hl, DialogueCharacterFeelsSomething_B12
+:
	call	ShowDialogue_B12
	ld	a, $D5
	ld	(Sound_index), a
	jp	RunTreasureChest

MapMagicAction_Fly:
	ld	a, b
	call	CheckEnoughMP
	ld	(de), a
	ld	a, $AB
	ld	(Sound_index), a
	ld	a, (Scene_type)
	or	a
	jr	nz, LABEL_2159
	ld	hl, DialoguePlayerSpellNoEffect_B12
	call	ShowDialogue_B12
	jp	CloseTextBox

LABEL_2159:
	ld	hl, DialogueCharacterBecomesLight_B12
	call	ShowDialogue_B12
	call	CloseTextBox
	ld	a, $08
	ld	($C2D8), a
	ret

PlayerMenu_Item:
	ld a, (Inventory_curr_num)
	or a
	jp nz, +
	call SelectItemFromInventory
	jp HideInventoryWindow

+:
	call SelectItemFromInventory
	bit 4, c
	jp nz, LABEL_21F5
	ld a, (CurrentItem)
	cp ItemID_Landrover
	jr c, +++
	cp ItemID_Cola
	jr nc, +++
	sub $21
	add a, a
	add a, a
	add a, $04
	ld b, a
	ld a, (Vehicle_movement_flags)
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
	ld hl, DialogueCannotDisembark_B12
	jr nz, +
	xor a
	ld (Vehicle_movement_flags), a
	dec a
	ld ($C2D8), a
	ld hl, DialogueDisembarked_B12
+:
	call ShowDialogue_B12
	call CloseTextBox
	jp LABEL_21F5

+++:
	ld b, $04
-:
	ld a, b
	sub $04
	neg
	call IsCharacterAlive
	jp nz, +
	djnz -
	jp LABEL_21F5

+:
	ld (CurrentCharacter), a
	call LABEL_3759
	ld hl, $7A72
	ld (CursorTileMapAddress), hl
	ld a, $02
	ld (Option_total_num), a
	call CheckOptionSelect
	bit Button_1, c
	jp nz, +
	ld hl, ItemActionJmpTbl
	call GetPtrAndJump
+:
	call LABEL_376B
LABEL_21F5:
	call HideInventoryWindow
	jp LABEL_2F3C


; =================================================================
ItemActionJmpTbl:
.dw	ItemAction_Use
.dw	ItemAction_Equip
.dw	ItemAction_Drop
; =================================================================

ItemAction_Use:
	ld a, (CurrentItem)
	ld hl, ItemUseJmpTbl
	jp GetPtrAndJump

; =================================================================
ItemUseJmpTbl:
.dw	ItemUse_NoEffect		; 0
.dw	ItemUse_NoEffect		; 1
.dw	ItemUse_NoEffect		; 2
.dw	ItemUse_NoEffect		; 3
.dw	ItemUse_Wand			; 4
.dw	ItemUse_NoEffect		; 5
.dw	ItemUse_NoEffect		; 6
.dw	ItemUse_NoEffect		; 7
.dw	ItemUse_NoEffect		; 8
.dw	ItemUse_NoEffect		; 9
.dw	ItemUse_NoEffect		; $A
.dw	ItemUse_NoEffect		; $B
.dw	ItemUse_NoEffect		; $C
.dw	ItemUse_NoEffect		; $D
.dw	ItemUse_NoEffect		; $E
.dw	ItemUse_NoEffect		; $F
.dw	ItemUse_NoEffect		; $10
.dw	ItemUse_NoEffect		; $11
.dw	ItemUse_NoEffect		; $12
.dw	ItemUse_NoEffect		; $13
.dw	ItemUse_NoEffect		; $14
.dw	ItemUse_NoEffect		; $15
.dw	ItemUse_NoEffect		; $16
.dw	ItemUse_NoEffect		; $17
.dw	ItemUse_NoEffect		; $18
.dw	ItemUse_NoEffect		; $19
.dw	ItemUse_NoEffect		; $1A
.dw	ItemUse_NoEffect		; $1B
.dw	ItemUse_NoEffect		; $1C
.dw	ItemUse_NoEffect		; $1D
.dw	ItemUse_NoEffect		; $1E
.dw	ItemUse_NoEffect		; $1F
.dw	ItemUse_NoEffect		; $20
.dw	ItemUse_LandRover		; $21
.dw	ItemUse_Hovercraft		; $22
.dw	ItemUse_IceDigger		; $23
.dw	ItemUse_Cola			; $24
.dw	ItemUse_Burger			; $25
.dw	ItemUse_Flute			; $26
.dw	ItemUse_Flash			; $27
.dw	ItemUse_Escaper			; $28
.dw	ItemUse_Transfer		; $29
.dw	ItemUse_MagicHat		; $2A
.dw	ItemUse_Alsulin			; $2B
.dw	ItemUse_Polymaterial	; $2C
.dw	ItemUse_DungeonKey		; $2D
.dw	ItemUse_Sphere			; $2E
.dw	ItemUse_EclipseTorch	; $2F
.dw	ItemUse_AeroPrism		; $30
.dw	ItemUse_Nuts			; $31
.dw	ItemUse_Hapsby			; $32
.dw	ItemUse_NoUse			; $33
.dw	ItemUse_NoUse			; $34
.dw	ItemUse_Compass			; $35
.dw	ItemUse_NoUse			; $36
.dw	ItemUse_NoUse			; $37
.dw	ItemUse_NoUse			; $38
.dw	ItemUse_NoUse			; $39
.dw	ItemUse_NoUse			; $3A
.dw	ItemUse_NoUse			; $3B
.dw	ItemUse_NoUse			; $3C
.dw	ItemUse_NoUse			; $3D
.dw	ItemUse_MiracleKey		; $3E
.dw	ItemUse_NoUse			; $3F
; =================================================================


ItemUse_NoEffect:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld hl, DialogueNoEffect_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_Wand:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jp nz, BattleMagicAction_ByeCont
	ld hl, DialogueNothingHappens_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_LandRover:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld e, $04

LABEL_22B7:
	ld a, ($C308)
	cp $04
	ld hl, DialogueUseNoGood_B12
	jr nc, +
	ld a, (Scene_type)
	or a
	jr z, +
	push bc
	push de
	call LABEL_7656
	pop de
	pop bc
	ld hl, DialogueUseNoGood_B12
	jr nz, +
	ld a, e
	ld (Vehicle_movement_flags), a
	ld a, $FF
	ld ($C2D8), a
	ld hl, DialogueEmbarked_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_Hovercraft:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, ($C308)
	cp $04
	ld hl, DialogueUseNoGood_B12
	jr nc, +
	ld a, (Scene_type)
	or a
	jr z, +
	push bc
	push de
	call LABEL_76C1
	pop de
	pop bc
	ld hl, DialogueUseNoGood_B12
	jr nz, +
	ld a, $08
	ld (Vehicle_movement_flags), a
	ld a, $FF
	ld ($C2D8), a
	ld hl, DialogueEmbarked_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_IceDigger:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, ($C308)
	cp $02
	ld e, $0C
	jp z, LABEL_22B7
	ld hl, DialogueUseNoGood_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_Cola:
	ld d, 10	; heal 10
	jr +

ItemUse_Burger:
	ld d, 40	; heal 40
+:
	ld a, (Battle_flag)
	or a
	ld a, (Battle_current_player)
	jr nz, +
	push de
	call PlayerSelect
	pop de
	bit Button_1, c
	jr nz, ++
+:
	ld (CurrentCharacter), a
	call ShowMessageIfDead
	jr z, ++
	push de
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	pop de
	call BattleMagicAction_HealHP
	call Inventory_RemoveItem
++:
	ld a, (Battle_flag)
	or a
	ret nz
	jp ClosePlayerSelect

ItemUse_Flute:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, $C2
	ld (Sound_index), a
	ld a, (Battle_flag)
	or a
	jr nz, +
	ld hl, DialogueSoundIsHeartwarming_B12
	call ShowDialogue_B12
	ld a, $D5
	ld (Sound_index), a
	ld a, (Scene_type)
	or a
	jp z, LABEL_2078
	jp CloseTextBox

+:
	ld hl, LABEL_B12_B322
	call ShowDialogue_B12
	ld a, $D5
	ld (Sound_index), a
	jp CloseTextBox


ItemUse_Flash:
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld hl, DialogueCannotDoThatHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Scene_type)
	or a
	jr z, +
-:
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld hl, DialogueDoesNotSeemBroken_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Dungeon_palette_index)
	or a
	jr nz, -
	; In a dungeon with palette 0
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	call CloseTextBox
	call Inventory_RemoveItem
	ld a, $FF ; Palette $FF is the lit one
	ld (Dungeon_palette_index), a
	ld ($C2D8), a
	ret

ItemUse_Escaper:
	ld a, (Battle_flag)
	or a
	call nz, Inventory_RemoveItem
	jp ItemUse_Wand

ItemUse_Transfer:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueNoEffect_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Scene_type)
	or a
	push af
	call nz, Inventory_RemoveItem
	pop af
	jp nz, LABEL_2159
	ld hl, DialogueNothingHappens_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_MagicHat:
	call Inventory_RemoveItem
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jp nz, BattleMagicSelect_ChatCont
	ld hl, DialogueNoEffect_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_Alsulin:
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueCannotDoThatHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Room_index)
	cp $A3	; Odin turned to stone
	jr z, ++
	call CheckCharAliveNotMyau
	ld hl, DialogueNothingUnusualHere_B12
	jr nz, +
-:
	ld hl, DialogueMyauCannotOpenBottle_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

++:
	call CheckCharAliveNotMyau
	jr z, -
	ld hl, DialogueBottleOpens_B12
	call ShowDialogue_B12
	call CloseTextBox
	call Inventory_RemoveItem
	ld iy, Odin_stats
	ld (iy+weapon), ItemID_IronAxe
	ld (iy+armor), ItemID_IronArmor
	call UnlockCharacter
	ld a, $02
	ld (Party_curr_num), a
	ld hl, Event_flags
	ld (hl), $00
	ld hl, Dialogue_flags+DialogueFlag_StoneOdin
	ld (hl), $FF
	ld a, $05
	ld ($C2D8), a
	ret

ItemUse_Polymaterial:
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueCannotDoThatHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Room_index)
	cp $A1
	jr z, ++
	call CheckCharAliveNotMyau
	ld hl, DialogueMyauCannotOpenBottle_B12
	jr z, +
	ld hl, DialogueItStinks_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

CheckCharAliveNotMyau:
	ld a, (Alis_stats)	; get status
	ld d, a
	ld a, (Odin_stats)	; get status
	ld e, a
	ld a, (Noah_stats)	; get status
	or d
	or e
	ret

++:
	call CheckCharAliveNotMyau
	jr nz, +
	ld hl, DialogueMyauCannotOpenBottle_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld hl, DialogueBottleOpens_B12
	call ShowDialogue_B12
	call Inventory_RemoveItem
	call GetHapsby
	jp CloseTextBox

ItemUse_DungeonKey:
	ld a, (Scene_type)
	or a
	jr z, +

ItemUse_DungeonKeyCont:
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld hl, DialogueNothingUnusualHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld b, $01
	call Dungeon_GetRelativeSquare
	and $07
	cp $05
	jr nz, +
	bit 7, (hl)
	jr nz, +
	ld a, $03
	ld ($C2D8), a
	jp CloseTextBox

+:
	ld hl, DialogueNoEffect_B12
	call ShowDialogue_B12
	jp CloseTextBox


ItemUse_Sphere:
	call Inventory_RemoveItem
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jp nz, BattleMagicSelect_TeleCont
	jp MapMagicAction_ChatCont

ItemUse_EclipseTorch:
	ld hl, DialogueRaisesItemTowardsSky_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueSeesFlameBecomesAfraid_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Room_index)
	cp $AF	; Laerma tree
	jr z, +
	ld hl, DialogueNothingHappens_B12
	call ShowDialogue_B12
	jp	CloseTextBox

+:
	push bc
	call Palette_Animate
	pop bc
	ld a, ItemID_LaconiaPot
	call Inventory_FindItem
	jr z, +
	ld hl, DialogueTakesNutButShrivelsUp_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	call Inventory_RemoveItem
	ld hl, DialogueTakesNutAndPutsItIn_B12
	call ShowDialogue_B12
	call CloseTextBox
	ld a, ItemID_Nuts
	ld (CurrentItem), a
	call Inventory_FindItem
	ret z
	jp Inventory_AddItem

ItemUse_AeroPrism:
	ld hl, DialogueRaisesItemTowardsSky_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueCannotDoThatHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (Room_index)
	cp $B0	; top of Baya Malay
	jr z, +
-:
	ld hl, DialogueNothingHappens_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, ($C2DC)
	cp $FF
	jr z, -
	ld hl, DialogueCastleAppearsInTheSky_B12
	call ShowDialogue_B12
	ld a, $06
	ld ($C2D8), a
	jp CloseTextBox

ItemUse_Nuts:
	ld a, (Myau_stats)
	or a
	jr z, LABEL_25D7
	ld a, (Location_index)
	cp $17
	jr z, +++
	ld a, (Room_index)
	cp $B0	; top of Baya Malay
	jr z, ++

LABEL_25D7:
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	ld hl, DialogueMyauNotHungry_B12
	jr z, +
	ld hl, DialogueCannotDoThatHere_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

++:
	ld a, ($C2DC)
	cp $FF
	jr nz, LABEL_25D7
-:
	ld hl, DialogueMyauAteNut_B12
	call ShowDialogue_B12
	call CloseTextBox
	ld a, $07
	ld ($C2D8), a
	ret

+++:
	ld a, (Scene_type)
	or a
	jr z, LABEL_25D7
	ld a, (Battle_flag)
	or a
	jr nz, LABEL_25D7
	jr -

ItemUse_Hapsby:
	ld a, (Battle_flag)
	or a
	jr z, +
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld hl, DialogueHapsbyShakesHead_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld hl, DialogueHapsbyIsHardheaded_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_Compass:
	ld a, (Scene_type)
	or a
	jr z, ++
-:
	ld hl, DialogueTakesOutItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	ld hl, DialogueDoesNotSeemBroken_B12
	jr z, +
	ld hl, DialogueCannotDoThatHere_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

++:
	ld a, (Battle_flag)
	or a
	jr nz, -
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, (Dungeon_direction)
	and $03
	ld hl, DialogueCompassNorth_B12
	jr z, +
	cp $01
	ld hl, DialogueCompassEast_B12
	jr z, +
	cp $02
	ld hl, DialogueCompassSouth_B12
	jr z, +
	ld hl, DialogueCompassWest_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_MiracleKey:
	ld a, (Scene_type)
	or a
	jp nz, ItemUse_DungeonKeyCont
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld b, $01
	call Dungeon_GetRelativeSquare
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
	jp CloseTextBox

++:
	ld hl, DialogueNoEffect_B12
	call ShowDialogue_B12
	jp CloseTextBox

ItemUse_NoUse:
	ld hl, DialogueCharacterUsesItem_B12
	call ShowDialogue_B12
	ld a, (Battle_flag)
	or a
	ld hl, DialogueNothingHappens_B12
	jr nz, +
	ld hl, DialogueNoNeedToUse_B12
+:
	call ShowDialogue_B12
	jp CloseTextBox

ItemAction_Equip:
	ld hl, $FFFF
	ld (hl), :Bank02
	ld a, (CurrentItem)
	ld hl, ItemData
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
	ld hl, DialogueNoNeedToEquipItem_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld d, a
	push de
	push hl
	call PlayerSelect
	pop hl
	pop de
	bit Button_1, c
	jp nz, LABEL_2741
	call ShowMessageIfDead
	jp z, LABEL_2741
	ld (CurrentCharacter), a
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
	ld hl, (Selected_inventory_item)
	ld (hl), a
	push af
	ld a, (CurrentItem)
	ld (de), a
	ld hl, DialogueCharacterEquipsItem_B12
	call ShowDialogue_B12
	ld a, (CurrentCharacter)
	call ShowEquippedItems
	call WaitForButton1Or2
	call HideEquippedItems
	call CloseTextBox
	pop af
	or a
	call z, Inventory_RemoveItem

LABEL_2741:
	call UpdateCharStats
	jp ClosePlayerSelect

+:
	ld hl, DialogueCharacterCannotEquip_B12
	call ShowDialogue_B12
	call CloseTextBox
	jr LABEL_2741

ItemAction_Drop:
	ld hl, $FFFF
	ld (hl), :Bank02
	ld a, (CurrentItem)
	ld hl, ItemData
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	and $04
	jr z, +
	ld hl, DialogueCharacterCannotDropItem_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld hl, DialogueCharacterDropsItem_B12
	call ShowDialogue_B12
	call Inventory_RemoveItem
	jp CloseTextBox

Inventory_RemoveItem:
	ld hl, (Selected_inventory_item)

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
	cp InventoryMaxNum
	jr nc, Inventory_IsFull
	ld hl, Inventory
	add a, l
	ld l, a
	ld a, (CurrentItem)
	ld (hl), a
	ld a, (Inventory_curr_num)
	inc a
	ld (Inventory_curr_num), a
	ld a, $B3
	ld (Sound_index), a
	ret

Inventory_IsFull:
	ld hl, DialogueCannotCarryAnyMoreItems_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr z, Inventory_SelectItemToDrop
	ld hl, DialogueCurrentItemNotNeeded_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr nz, Inventory_SelectItemToDrop
	ld hl, DialogueCurrentItemDropped_B12
	jp ShowDialogue_B12

Inventory_SelectItemToDrop:
	ld a, (CurrentItem)
	push af
	ld hl, DialogueWhatToDrop_B12
	call ShowDialogue_B12
	call SelectItemFromInventory
	call HideInventoryWindow
	bit 4, c
	jr nz, ++
	ld hl, $FFFF
	ld (hl), :Bank02
	ld a, (CurrentItem)
	ld hl, ItemData
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	and $04
	jr z, +
	ld hl, DialogueCharacterCannotDropItem_B12
	call ShowDialogue_B12
	pop af
	ld (CurrentItem), a
	jp Inventory_SelectItemToDrop

+:
	ld hl, DialogueCurrentItemIsDropped_B12
	call ShowDialogue_B12
	pop af
	ld (CurrentItem), a
	ld hl, (Selected_inventory_item)
	ld (hl), a
	ld a, $B3
	ld (Sound_index), a
	ld hl, DialogueCurrentItemIsPickedUp_B12
	jp ShowDialogue_B12

++:
	pop af
	ld (CurrentItem), a
	jp Inventory_IsFull

Inventory_FindItem:
	ld hl, Inventory
	ld b, InventoryMaxNum
-:
	cp (hl)
	ret z
	inc hl
	djnz -
	ret

PlayerMenu_Search:
	ld a, (Character_sprite_attributes)
	cp $0E
	jr nz, +
	call HidePartyStats
	ld hl, DialogueNothingUnusualHere_B12
	call ShowDialogue_B12
	call RunTreasureChest
	jp UpdatePartyStats

+:
	ld hl, (V_location)
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
	ld hl, (H_location)
	ld bc, $0080
	add hl, bc
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld l, a
	ld a, (Location_index)
	cp $07
	jr nz, +
	ld a, l
	cp $28
	jr nz, LABEL_28C5
	ld a, h
	cp $1E
	jr nz, LABEL_28C5
	ld a, (Dialogue_flags+DialogueFlag_FluteUnhidden)	; Soothe Flute unhidden
	or a
	jr z, LABEL_28C5
	cp $FF
	jr z, LABEL_28C5
	ld a, $FF
	ld (Dialogue_flags+DialogueFlag_FluteUnhidden), a
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
	ld a, (Dialogue_flags+DialogueFlag_MirrorShieldUnhidden)	; Mirror Shield unhidden
	or a
	jr z, LABEL_28C5
	ld a, (Odin_stats+shield)
	ld b, a
	ld a, $1F
	cp b
	jr z, LABEL_28C5
++:
	ld (CurrentItem), a
	call Inventory_FindItem
	jr z, LABEL_28C5
	ld hl, DialogueYouFoundItem_B12
	call ShowDialogue_B12
	call Inventory_AddItem
	jp CloseTextBox

LABEL_28C5:
	ld a, (Room_index)
	cp $A2
	jp z, CheckHovercraft
	cp $A3
	jp z, FindOdin
	ld hl, DialogueNothingUnusualHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

RunTreasureChest:
	ld	hl, DialogueWantToOpenIt_B12
	call	ShowDialogue_B12
	call	ShowMenuYesNo
	push	af
	call	HideMenuYesNo
	call	CloseTextBox
	pop	af
	or 	a
	ret	nz

LABEL_28EE:
	ld a, $B0
	ld (Sound_index), a
	ld hl, (Dungeon_obj_flag_addr)
	ld (hl), $FF
	ld a, $01
	ld (Character_sprite_attributes+$A), a
	push bc
	call LABEL_18B9
	pop bc
	ld a, (Character_sprite_attributes+$F)
	cp $3D
	call nz, LABEL_2950
	ld hl, (Enemy_money)
	ld a, h
	or l
	jr nz, +
	ld a, (Dungeon_item_index)
	or a
	jr nz, +
	ld hl, DialogueItsEmpty_B12
	call ShowDialogue_B12
	ld a, $D0
	ld (Sprite_table), a
	jp CloseTextBox

+:
	ld hl, (Enemy_money)
	ld (NumberToShowInText), hl
	call Shop_AddMeseta
	ld a, h
	or l
	ld hl, DialogueThereAreMesetaInside_B12
	call nz, ShowDialogue_B12
	ld a, (Dungeon_item_index)
	ld (CurrentItem), a
	or a
	jr z, +
	ld hl, DialogueYouFoundItem_B12
	call ShowDialogue_B12
	call Inventory_AddItem
+:
	ld a, $D0
	ld (Sprite_table), a
	jp CloseTextBox

LABEL_2950:
	ld a, (Character_sprite_attributes+$F)
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
	call UpdateRNGSeed
	and $03
++:
	call IsCharacterAlive
	ret z
	inc hl
	push hl
	ld h, (hl)
	ld l, $00
	ld e, $03
	call Divide16Bit
	pop de
	ex de, hl
	ld a, (hl)
	sub d
	ld (hl), a
	ret

Shop_AddMeseta:
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
	call	WaitForButton1Or2
	ret

Scene_Hospital:
	ld hl, DialogueThisIsAHospital_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jp nz, LABEL_2A55
LABEL_2999:
	ld a, (Party_curr_num)
	or a
	ld hl, DialogueWhoNeedsToBeHealed_B12
	call nz, ShowDialogue_B12
	call PlayerSelect
	bit Button_1, c
	jp nz, HospitalClosePlayerSelect
	ld (CurrentCharacter), a
	call IsCharacterAlive
	jr nz, +
	ld hl, DialogueCharacterAlreadyDead_B12
	call ShowDialogue_B12
	jp LABEL_2A48

+:
	push hl
	pop iy
	; Check if at full HP/MP
	ld a, (iy+curr_hp)
	cp (iy+max_hp)
	jr nz, +
	ld a, (iy+curr_mp)
	cp (iy+max_mp)
	jr nz, +
	ld hl, DialogueNoNeedToHeal_B12
	call ShowDialogue_B12
	ld a, (Party_curr_num)
	or a
	jr nz, LABEL_2A48
	ld hl, DialoguePleaseBeCareful_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld a, (iy+max_hp)
	sub (iy+curr_hp)
	ld b, a
	ld a, (iy+max_mp)
	sub (iy+curr_mp)
	add a, b
	ld l, a
	ld h, $00
	ld (NumberToShowInText), hl
	ld hl, DialogueHealingFee_B12
	call ShowDialogue_B12
	call ShopMesetaWindowDraw
	call ShowYesNoPrompt
	push af
	call nz, LABEL_3A12
	pop af
	jr nz, LABEL_2A48
	ld de, (NumberToShowInText)
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr c, LABEL_2A5E
	ld (Current_money), hl
	call LABEL_39F7
	ld a, $C1
	ld (Sound_index), a
	ld a, (iy+max_hp)
	ld (iy+curr_hp), a
	ld a, (iy+max_mp)
	ld (iy+curr_mp), a
	ld hl, DialogueThankYouForWaiting_B12
	call ShowDialogue_B12
	call LABEL_3A12
	ld a, (Party_curr_num)
	or a
	jr z, +
	ld hl, DialogueAnyoneElseBeHealed_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr nz, HospitalClosePlayerSelect

LABEL_2A48:
	call ClosePlayerSelect
	ld a, (Party_curr_num)
	or a
	jp nz, LABEL_2999
HospitalClosePlayerSelect:
	call ClosePlayerSelect
LABEL_2A55:
	ld hl, DialogueHospitalCouldNotHelp_B12
	call ShowDialogue_B12
	jp CloseTextBox

LABEL_2A5E:
	call LABEL_3A12
	call ClosePlayerSelect
	ld hl, DialogueHospitalNotEnoughMoney_B12
	call ShowDialogue_B12
+:
	jp CloseTextBox

LABEL_2A6D:
	ld bc, $04FF
-:
	ld a, b
	dec a
	call IsCharacterAlive
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

Scene_Church:
	ld a, (Room_index)
	ld (Last_church_visited), a
	ld hl, DialogueThisIsAChurch_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	or a
	jp nz, LABEL_2B46
LABEL_2A98:
	ld a, (Party_curr_num)
	or a
	jp z, LABEL_2B31
	ld hl, DialogueWhoNeedsToBeRevived_B12
	call ShowDialogue_B12
	call PlayerSelect
	bit Button_1, c
	jp nz, LABEL_2B43
	call IsCharacterAlive
	jr nz, LABEL_2B31
	ld (CurrentCharacter), a
	push hl
	pop iy
	; resurrection cost = LV * 20
	ld a, (iy+level)
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld e, l
	ld d, h
	add hl, hl
	add hl, hl
	add hl, de
	ld (NumberToShowInText), hl
	ld hl, DialogueChurchMesetaRequirement_B12
	call ShowDialogue_B12
	call ShopMesetaWindowDraw
	call ShowYesNoPrompt
	push af
	call nz, LABEL_3A12
	pop af
	jr nz, LABEL_2B15
	ld hl, DialogueChurchCastSpell_B12
	call ShowDialogue_B12
	ld de, (NumberToShowInText)
	ld hl, (Current_money)
	or a
	sbc hl, de
	jp c, +
	; Enough money
	ld (Current_money), hl
	call LABEL_39F7
	ld (iy+status), $01
	ld a, (iy+max_hp)
	ld (iy+curr_hp), a
	ld a, (iy+max_mp)
	ld (iy+curr_mp), a
	ld hl, DialogueChurchReviving_B12
	call ShowDialogue_B12
	ld a, $C5
	ld (Sound_index), a
	call VintDelayButtonPress
	call LABEL_3A12
LABEL_2B15:
	ld hl, DialogueChurchAnyoneElse_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr nz, LABEL_2B43
	call ClosePlayerSelect
	jp LABEL_2A98

+:
	ld hl, DialogueChurchFail_B12
	call ShowDialogue_B12
	call LABEL_3A12
	jr LABEL_2B15

LABEL_2B31:
	ld (CurrentCharacter), a
	ld hl, DialogueChurchCharacterAlive_B12
	call ShowDialogue_B12
	ld a, (Party_curr_num)
	or a
	jr nz, LABEL_2B15
	call WaitForButton1Or2
LABEL_2B43:
	call ClosePlayerSelect
LABEL_2B46:
	ld hl, DialogueChurchEnd_B12
	call ShowDialogue_B12
	ld hl, DialogueChurchNextLevel_B12
	call ShowDialogue_B12
	call +
	jp CloseTextBox

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
	ld (CurrentCharacter), a
	bit 0, (iy+status)
	ret z
	ld a, (iy+level)
	cp Maximum_Level
	jr c, +
	ld hl, DialogueChurchCharacterStrong_B12
	jp ShowDialogue_B12

+:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	push hl
	pop ix
	ld e, (iy+exp)
	ld d, (iy+exp+1)
	ld l, (ix+exp+1)
	ld h, (ix+level)
	or a
	sbc hl, de
	ld (NumberToShowInText), hl
	ld hl, DialogueChurchNeedEXP_B12
	jp ShowDialogue_B12

Scene_Armory:
	ld hl, DialogueThisIsArmory_B12
	call ShowDialogue_B12
ShopMenus:
	call ShowYesNoPrompt
	jr z, LABEL_2BD4
	ld hl, DialogueArmoryComeAgain_B12
	call ShowDialogue_B12
	jp CloseTextBox

LABEL_2BD4:
	push bc
	call ShopMesetaWindowCopy
	call ShopMesetaWindowDraw
	pop bc
LABEL_2BDC:
	ld hl, DialogueArmoryWhatToBuy
	call ShowDialogue_B12
	push bc
	call RunShop
	bit 4, c
	pop bc
	jr nz, LABEL_2C2D
	ld a, (Inventory_curr_num)
	cp InventoryMaxNum
	jr nc, LABEL_2C3C
	ld a, (hl)
	ld (CurrentItem), a
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr c, LABEL_2C41
	ld a, (CurrentItem)
	cp ItemID_Secrets
	jr nc, LABEL_2C46
	ld (Current_money), hl
	call LABEL_39F7
	ld a, (CurrentItem)
	cp ItemID_Landrover
	jr c, +
	cp ItemID_Cola
	jr nc, +
	call Inventory_FindItem
	jr z, ++
+:
	call Inventory_AddItem
++:
	ld hl, DialogueArmoryAnythingElse_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr z, LABEL_2BDC

LABEL_2C2D:
	ld hl, DialogueArmoryComeAgain_B12
-:
	call ShowDialogue_B12
	call LABEL_3A12
	call LABEL_3999
	jp CloseTextBox

LABEL_2C3C:
	ld hl, DialogueArmoryCannotCarryAnyMore_B12
	jr -

LABEL_2C41:
	ld hl, DialogueHospitalNotEnoughMoney_B12
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
	jp CloseTextBox

++:
	xor a
	ld ($C2EC), a
	push hl
	ld a, ItemID_RoadPass
	ld (CurrentItem), a
	call Inventory_FindItem
	pop hl
	jr z, LABEL_2C46
	ld (Current_money), hl
	call LABEL_39F7
	call Inventory_AddItem
	ld hl, $0146
	call ShowDialogue_B2
	call LABEL_3A12
	call LABEL_3999
	jp CloseTextBox

Scene_Pharmacy:
	ld hl, DialoguePharmacy_B12
	call ShowDialogue_B12
	jp ShopMenus

Scene_ToolShop:
	ld hl, DialogueToolShop_B12
	call ShowDialogue_B12
	call BuySellMenu
	push af
	push bc
	call BuySellMenuClose
	pop bc
	pop af
	bit 4, c
	jp nz, LABEL_2CEA
	or a
	jp z, LABEL_2BD4
LABEL_2CB1:
	ld hl, DialogueToolShopWhatToSell_B12
	call ShowDialogue_B12
	call SelectItemFromInventory
	bit 4, c
	push af
	call HideInventoryWindow
	pop af
	jp nz, LABEL_2CEA
	ld hl, $FFFF
	ld (hl), :Bank03
	ld a, (CurrentItem)
	and $3F
	add a, a
	ld hl, ItemSellingPriceData_B03
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (NumberToShowInText), hl
	or h
	jr nz, +
	ld hl, DialogueToolShopComeInHandy_B12
	call ShowDialogue_B12
	jp LABEL_2CB1

LABEL_2CEA:
	ld hl, DialogueArmoryComeAgain_B12
	call ShowDialogue_B12
	jp CloseTextBox

+:
	ld hl, DialogueToolShopMeseta_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jr z, +
	jp LABEL_2CB1

+:
	call Inventory_RemoveItem
	ld hl, (NumberToShowInText)
	call Shop_AddMeseta
	ld hl, DialogueToolShopAnythingElse_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	jp z, LABEL_2CB1
	jp LABEL_2CEA

ShowYesNoPrompt:
	push	bc
	call	ShowMenuYesNo
	push	af
	call	HideMenuYesNo
	pop	af
	pop	bc
	or	a
	ret

WaitForButton1Or2:
	ld	a, $08
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jp	z, WaitForButton1Or2
	ret

VintDelayButtonPress:
	ld	b, $1E
	jr	VintDelayButtonPressLoop

VintDelayButtonPress2:
	ld	b, $B4

VintDelayButtonPressLoop:
	ld	a, $08
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	ret  nz

	djnz	VintDelayButtonPressLoop
	ret

VIntDelay:
	ld	b, $D0
VIntDelay2:
	ld	a, $08
	call	WaitForVInt
	djnz	VIntDelay2
	ret

CheckOptionSelect:
	ld	a, $FF
	ld	(Cursor_enabled), a  ; Enable cursor
	ld	hl, $0000
	ld	(Cursor_pos), hl	; CursorPos, OldCursorPos = 0
	xor	a
	ld	(Cursor_counter), a
OptionSelect_Loop:
	ld	a, $08
	call	WaitForVInt
	ld	a, (Ctrl_1_pressed)
	and	ButtonUp_Mask|ButtonDown_Mask
	jp	z, OptionSelect_Check1And2Buttons
	ld	c, a
	ld	hl, Option_total_num
	ld	a, (Cursor_pos)
	bit  ButtonUp, c
	jr	z, +
	sub	$01	; if we pressed UP, subtract 1
	jr	nc, +
	ld	a, (hl)
+
	bit  ButtonDown, c
	jr	z, +
	inc	a	; if we pressed DOWN, increment by 1
	cp	(hl)
	jr	c, +
	jr	z, +
	xor	a
+
	ld	(Cursor_pos), a
OptionSelect_Check1And2Buttons:
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	jp	z, OptionSelect_Loop
	ld	c, a
	xor	a
	ld	(Cursor_counter), a
	ld	a, $08
	call	WaitForVInt
	xor	a
	ld	(Cursor_enabled), a
	ld	a, (Cursor_pos)
	ret


LABEL_2DA5:
	ld a, $FF
	ld (Cursor_enabled), a

LABEL_2DAA:
	ld a, $08
	call WaitForVInt
	ld a, (Ctrl_1_pressed)
	ld c, a
	and ButtonUp_Mask|ButtonDown_Mask
	jp z, ++
	ld c, a
	ld hl, Option_total_num
	ld a, (Cursor_pos)
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
	ld (Cursor_pos), a
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
	ld (Cursor_counter), a
	ld a, $08
	call WaitForVInt
	xor a
	ld (Cursor_enabled), a
	bit 4, c
	ret nz
	ld a, (Inventory_curr_num)
	cp $09
	ld a, (Cursor_pos)
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
	ld (Cursor_enabled), a
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
	ld hl, (Cursor_pos)
	cp l
	jr nc, +
	ld l, a
+:
	ld h, l
	ld (Cursor_pos), hl
	jp LABEL_2DA5

CursorBlink:
	ld a, (Cursor_enabled)
	or a
	ret z
	ld a, (Game_mode)
	cp $03 ; GameMode_TitleScreen
	ld bc, $F0F3
	jr nz, +
	ld bc, $FF00
+:
	ld hl, (CursorTileMapAddress)
	ld a, (Cursor_old_pos)
	srl a
	ld e, $00
	rr e
	ld d, a
	add hl, de
	ex de, hl
	rst $08
	ld a, c
	out (Port_VDPData), a
	ld hl, (CursorTileMapAddress)
	ld a, (Cursor_pos)
	ld ($C26C), a
	srl a
	ld e, $00
	rr e
	ld d, a
	add hl, de
	ex de, hl
	rst $08
	ld a, (Cursor_counter)
	dec a
	and $0F
	ld (Cursor_counter), a
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
	call InputTilemapRect
	ld a, (Battle_current_player)
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
	jp OutputTilemapBoxB27

LABEL_2ECD:
	ld hl, $D700
	ld de, $7B02
	ld bc, $030C
	jp OutputTilemapBoxB27

UpdatePartyStats:
	ld hl, $D724
	ld de, $7C80
	ld bc, $0640
	call InputTilemapRect
	ld hl, MenuBox8Top_B27
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
	call OutputTilemapBoxB27
	ld hl, Tiles_HP
	ld a, (ix+curr_hp)
	call Output4CharsPlusStat
	ld hl, Tiles_MP
	ld a, (ix+curr_mp)
	call Output4CharsPlusStat
	ld hl, MenuBox8Bottom_B27
	ld bc, $0110
	jp OutputTilemapBoxB27

LABEL_2F3C:
	ld hl, MenuBox8Top_B27
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
	call OutputTilemapRect
	ld hl, Tiles_HP
	ld a, (ix+curr_hp)
	call Output4CharsPlusStat
	ld hl, Tiles_MP
	ld a, (ix+curr_mp)
	call Output4CharsPlusStat
	ld hl, MenuBox8Bottom_B27
	ld bc, $0110
	jp OutputTilemapRect

ShowCharacterStatsBox:
	push af
	ld hl, $D724
	ld de, $7C80
	ld bc, $0640
	call InputTilemapRect
	pop af
LABEL_2FA1:
	ld hl, MenuBox8Top_B27
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

Output4CharsPlusStatWide:
	di
	push	de
	push	af
	rst  $08
	ld	b, $10
	jp	LABEL_2FE7

Output4CharsPlusStat:
	di
	push	de
	push	af
	rst  $08
	ld	b, $08
LABEL_2FE7:
	ld	a, (hl)
	out	(Port_VDPData), a
	inc	hl
	djnz	LABEL_2FE7
	pop	af
	ld	bc, $C010
	ld	d, $FF
LABEL_2FF3:
	sub	100
	inc	d
	jr	nc, LABEL_2FF3
	add	a, 100
	ld	l, a
	ld	a, d
	call	OutputDigit
	ld	d, $FF
	ld	a, l
LABEL_3002:
	sub	10
	inc	d
	jr	nc, LABEL_3002
	add	a, 10
	ld	l, a
	ld	a, d
	call	OutputDigit
	ld	d, $FF
	ld	a, l
LABEL_3011:
	sub	$01
	inc	d
	jr	nc, LABEL_3011
	ld	a, d
	ld	bc, $C110
	call	OutputDigit
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $13
	out	(Port_VDPData), a
	pop	de
	ld	hl, $0040
	add	hl, de
	ex   de, hl
	ei
	ld	a, $0A
	call	WaitForVInt
	ret

ConvertToDec5Digits:
	di
	push	de
	push	bc
	rst  $08
	ld	b, $0C
LABEL_303C:
	ld	a, (hl)
	out	(Port_VDPData), a
	inc	hl
	djnz	LABEL_303C
	pop	hl
	ld	bc, $C010
	ld	de, 10000
	xor	a
	dec  a
LABEL_304B:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_304B
	add	hl, de
	call	OutputDigit
	ld	de, 1000
	ld	a, $FF
LABEL_3059:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_3059
	add	hl, de
	call	OutputDigit
	ld	de, 100
	ld	a, $FF
LABEL_3067:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_3067
	add	hl, de
	call	OutputDigit
	ld	d, $FF
	ld	a, l
LABEL_3073:
	sub	$0A
	inc	d
	jr	nc, LABEL_3073
	add	a, 10
	ld	l, a
	ld	a, d
	call	OutputDigit
	ld	d, $FF
	ld	a, l
LABEL_3082:
	sub	$01
	inc	d
	jr	nc, LABEL_3082
	ld	a, d
	ld	bc, $C110
	call	OutputDigit
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $13
	out	(Port_VDPData), a
	pop	de
	ld	hl, $0040
	add	hl, de
	ex   de, hl
	ei
	ld	a, $0A
	call	WaitForVInt
	ret


Tiles_HP:
.db $F3, $11, $F4, $11, $F5, $11, $C0, $10

Tiles_MP:
.db	$F3, $11, $F6, $11, $F5, $11, $C0, $10

HidePartyStats:
	ld hl, $D724
	ld de, $7C80
	ld bc, $0640
	jp OutputTilemapBoxB27

ShowCombatMenu:
	ld	hl, $D8A4
	ld	de, $7842
	ld	bc, $0B0C
	call	InputTilemapRect
	ld	hl, Tiles_MenuCombat_B27
	jp	OutputTilemapBoxB27


RefreshCombatMenu:
	ld hl, Tiles_MenuCombat_B27
	ld de, $7842
	ld bc, $0B0C
	jp OutputTilemapRect

CloseMenu:
	ld hl, $D8A4
	ld de, $7842
	ld bc, $0B0C
	jp OutputTilemapBoxB27

ShowEnemyData:
	ld	hl, $D928
	ld	de, $781C
	ld	bc, $0414
	call	InputTilemapRect
	ld	hl, $D978
	ld	de, $7830
	ld	bc, $0A10
	call	InputTilemapRect

UpdateEnemyHP:
	ld	hl, LABEL_B27_BACF
	ld	de, $781C
	ld	bc, $0114
	call	OutputTilemapRect
	ld	hl, CurrentBattle_EnemyName
	ld	c, $00
	call	Output8CharMenuLine
	ld	c, $01
	call	Output8CharMenuLine
	ld	hl, LABEL_B27_BAE3
	ld	bc, $0114
	call	OutputTilemapRect
	ld	a, (Battle_enemy_id)
	cp	$49
	ret  z

	ld	hl, MenuBox8Top_B27
	ld	de, $7830
	ld	bc, $0110
	call	OutputTilemapBoxB27
	ld	ix, $C440
	ld	a, (Enemy_num)
	ld	b, a
LABEL_3141:
	push	bc
	ld	hl, Tiles_HP
	ld	a, (ix+1)
	call	Output4CharsPlusStat
	ld	bc, $0010
	add	ix, bc
	pop	bc
	djnz	LABEL_3141
	ld	hl, MenuBox8Bottom_B27
	ld	bc, $0110
	jp	OutputTilemapBoxB27

Output8CharMenuLine:
	di
	push	bc
	push	hl
	push	de
	rst  $08
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $11
	out	(Port_VDPData), a
	ld	b, $08
LABEL_316F:
	ld	a, (hl)
	sub	$20
	add	a, a
	add	a, c
	ld	de, TileCharacterTable
	add	a, e
	ld	e, a
	adc	a, d
	sub	e
	ld	d, a
	ld	a, (de)
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $10
	out	(Port_VDPData), a
	inc	hl
	djnz	LABEL_316F
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $13
	out	(Port_VDPData), a
	pop	de
	ld	hl, $0040
	add	hl, de
	ex   de, hl
	pop	hl
	pop	bc
	ei
	ret

HideEnemyData:
	ld	hl, $D978
	ld	de, $7830
	ld	bc, $0A10
	ld	a, (Battle_enemy_id)
	cp	$49
	call	nz, OutputTilemapBoxB27
	ld	hl, $D928
	ld	de, $781C
	ld	bc, $0414
	jp	OutputTilemapBoxB27


CharacterNames:
.db "ALIS"
.db	"MYAU"
.db	"ODIN"
.db	"NOAH"

LABEL_31CB:
	dec  hl
	jp	Dialogue_NextLine

ShowDialogue_B12:
	ld	a, :Bank12
	ld	($FFFF), a

LABEL_31D4:
	ld	a, (Text_box_open_flag)
	or	a
	jp	nz, LABEL_31CB
	ld	a, $FF
	ld	(Text_box_open_flag), a
	push	hl
	ld	hl, $DA18
	ld	de, $7C8C
	ld	bc, $0628
	call	InputTilemapRect
	ld	hl, LABEL_B27_B5EF
	call	OutputTilemapBoxB27
	pop	hl
Dialogue_ResetCursor:
	ld	de, $7CCE
	ld	bc, $1200
Dialogue_ReadData:
	ld	a, (hl)	; get data
	or	a
	jp	m, LABEL_3332
	cp	$65
	jp	nc, WaitForButton1Or2
	cp	$62
	ret  z

	cp	$63
	jp	z, VintDelayButtonPress
	cp	$64
	jp	z, VIntDelay
	cp	$61
	jr	nz, LABEL_321B
	call	WaitForButton1Or2
	jp	Dialogue_NextLine

LABEL_321B:
	cp	$5F
	jr	nz, LABEL_3231
	push	hl
	ld	hl, LABEL_B27_B5EF
	ld	de, $7C8C
	ld	bc, $0628
	call	OutputTilemapRect
	pop	hl
	inc	hl
	jp	Dialogue_ResetCursor

LABEL_3231:
	cp	$60
	jr	nz, LABEL_3244
Dialogue_NextLine:
	ld	a, c
	or	a
	call	nz, Dialogue_ScrollUp2Lines
	ld	de, $7D4E
	ld	bc, $1201
	inc	hl
	jp	Dialogue_ReadData

LABEL_3244:
	cp	Dialogue_CurrentCharacter
	jr	nz, LABEL_3262
	push	hl
	ld	a, (CurrentCharacter)
	and	$03
	add	a, a
	add	a, a
	ld	hl, CharacterNames
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, $04
	call	Display65TerminatedString
	pop	hl
	inc	hl
	jp	Dialogue_ReadData

LABEL_3262:
	cp	Dialogue_EnemyName
	jr	nz, LABEL_3274
	push	hl
	ld	hl, CurrentBattle_EnemyName
	ld	a, $08
	call	Display65TerminatedString
	pop	hl
	inc	hl
	jp	Dialogue_ReadData

LABEL_3274:
	cp	Dialogue_CurrentItem
	jr	nz, LABEL_3292
	push	hl
	ld	a, (CurrentItem)
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	bc
	ld	bc, ItemNames
	add	hl, bc
	pop	bc
	ld	a, $08
	call	Display65TerminatedString
	pop	hl
	inc	hl
	jp	Dialogue_ReadData

LABEL_3292:
	cp	Dialogue_NumberFromC2C5
	jr	nz, LABEL_32F5
	push	hl
	push	bc
	push	de
	ld	hl, (NumberToShowInText)
	ld	de, 10000
	xor	a
	ld	c, a
	dec  a
LABEL_32A2:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_32A2
	add	hl, de
	pop	de
	call	Dialogue_OutputDigitA
	push	de
	ld	de, 1000
	ld	a, $FF
LABEL_32B2:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_32B2
	add	hl, de
	pop	de
	call	Dialogue_OutputDigitA
	push	de
	ld	de, 100
	ld	a, $FF
LABEL_32C2:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_32C2
	add	hl, de
	pop	de
	call	Dialogue_OutputDigitA
	push	de
	ld	d, $FF
	ld	a, l
LABEL_32D0:
	sub	10
	inc	d
	jr	nc, LABEL_32D0
	add	a, 10
	ld	l, a
	ld	a, d
	pop	de
	call	Dialogue_OutputDigitA
	push	de
	ld	d, $FF
	ld	a, l
LABEL_32E1:
	sub	$01
	inc	d
	jr	nc, LABEL_32E1
	ld	a, d
	ld	c, $01
	pop	de
	call	Dialogue_OutputDigitA
	ld	a, b
	pop	bc
	ld	b, a
	pop	hl
	inc	hl
	jp	Dialogue_ReadData

LABEL_32F5:
	call	Dialogue_DrawLetter
	jp	Dialogue_ReadData

Dialogue_OutputDigitA:
	or	a
	jp	nz, LABEL_3302
	bit  0, c
	ret  z

LABEL_3302:
	ld	c, $01
	di
	push	de
	push	af
	rst  $08
	push	af
	pop	af
	ld	a, $C0
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $10
	out	(Port_VDPData), a
	ld	a, $40
	add	a, e
	ld	e, a
	adc	a, d
	sub	e
	ld	d, a
	rst  $08
	pop	af
	add	a, $C1
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $10
	out	(Port_VDPData), a
	pop	de
	inc	de
	inc	de
	ei
	ld	a, $0A
	call	WaitForVInt
	dec  b
	ret

LABEL_3332:
	call	LABEL_333E
	jp	Dialogue_ReadData

LABEL_3338:
	call LABEL_333E
	jp LABEL_3389

LABEL_333E:
	push	hl
	and	$7F
	add	a, a
	ld	hl, DialogueWordBlock
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, ($FFFF)
	push	af
	ld	a, :Bank02
	ld	($FFFF), a
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
LABEL_3357:
	call	Dialogue_DrawLetter
	ld	a, (hl)
	cp	Dialogue_Terminator65
	jr	nz, LABEL_3357
	pop	af
	ld	($FFFF), a
	pop	hl
	inc	hl
	ld	a, b
	or	a
	ret  nz

	ld	a, (hl)
	jp	LABEL_3419

Display65TerminatedString:
	push	af
	call	Dialogue_DrawLetter
	ld	a, (hl)
	cp	Dialogue_Terminator65
	jr	z, LABEL_337B
	pop	af
	dec  a
	jp	nz, Display65TerminatedString
	ret

LABEL_337B:
	pop	af
	ret


ShowNarrativeText:
	ld a, :Bank02
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
	jr z, Dialogue_ExitAfterPause
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
	call Dialogue_DrawLetter
	jr LABEL_3389

++:
	pop de
	push hl
	cp $5F
	call nz, WaitForButton1Or2
	ld de, $7C00
	ld bc, $0100
	ld hl, $0800
	di
	call FillVRAMWithHL
	ei
	pop hl
	inc hl
	jp ShowNarrativeText

+++:
	call WaitForButton1Or2
	pop de
	ret

Dialogue_ExitAfterPause:
	call VIntDelay
	pop de
	ret

Dialogue_DrawLetter:
	di
	push	bc
	push	de
	rst  $08
	ld	a, (hl)
	sub	$20
	add	a, a
	ld	bc, TileCharacterTable
	add	a, c
	ld	c, a
	adc	a, b
	sub	c
	ld	b, a
	ld	a, (bc)
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $10
	out	(Port_VDPData), a
	ex   de, hl
	ld	bc, $0040
	add	hl, bc
	ex   de, hl
	rst  $08
	ld	a, (hl)
	sub	$20
	add	a, a
	ld	bc, TileCharacterTable+1
	add	a, c
	ld	c, a
	adc	a, b
	sub	c
	ld	b, a
	ld	a, (bc)
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $10
	out	(Port_VDPData), a
	inc	hl
	pop	de
	inc	de
	inc	de
	pop	bc
	ei
	ld	a, $0A
	call	WaitForVInt
	dec  b
	ret  nz

	ld	a, (hl)
LABEL_3419:
	or	a
	jp	m, LABEL_3420
	cp	$5F
	ret  nc

LABEL_3420:
	ld	a, c
	or	a
	call	nz, Dialogue_ScrollUp2Lines
	ld	de, $7D4E
	ld	bc, $1201
	ret

Dialogue_ScrollUp2Lines:
	push	bc
	push	de
	push	hl
	call	Dialogue_ScrollUp1Line
	call	Dialogue_ScrollUp1Line
	pop	hl
	pop	de
	pop	bc
	ret

Dialogue_ScrollUp1Line:
	ld	hl, $DB08
	ld	de, $7D0E
	ld	bc, $0324
	call	InputTilemapRect
	ld	hl, $DB08
	ld	de, $7CCE
	ld	bc, $0324
	call	OutputTilemapRect
	ld	hl, LABEL_B27_B619
	ld	bc, $0124
	call	OutputTilemapRect
	ld	b, $04
LABEL_345C:
	ld	a, $0A
	call	WaitForVInt
	djnz	LABEL_345C
	ret

CloseTextBox:
	ld	hl, Text_box_open_flag
	ld	a, (hl)
	or	a
	ret  z

	ld	(hl), $00
	ld	hl, $DA18
	ld	de, $7C8C
	ld	bc, $0628
	jp	OutputTilemapBoxB27


ShowMagicMenu:
	push af
	push bc
	ld hl, $DB74
	ld de, $7A0C
	ld bc, $0C0C
	call InputTilemapRect
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
	call OutputTilemapBoxB27
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
	jp OutputTilemapBoxB27

+:
	ld hl, LABEL_B27_BA3F
	ld bc, $0C0C
	jp OutputTilemapBoxB27

HideMagicMenu:
	ld hl, $DB74
	ld de, $7A0C
	ld bc, $0C0C
	jp OutputTilemapBoxB27

SelectItemFromInventory:
	ld a, (Inventory_curr_num)
	dec a
	and $18
	ld h, a
	ld l, $00
	ld ($C299), hl
	call LABEL_3521
	ld a, (Inventory_curr_num)
	or a
	jp z, WaitForButton1Or2
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
	ld (CursorTileMapAddress), hl
	ld hl, $0000
	ld (Cursor_pos), hl
	xor a
	ld (Cursor_counter), a
	call LABEL_2DA5
	ld l, a
	ld a, ($C299)
	add a, l
	ld hl, Inventory
	add a, l
	ld l, a
	ld (Selected_inventory_item), hl
	ld a, (hl)
	ld (CurrentItem), a
	ret

LABEL_3521:
	ld hl, $DC04
	ld de, $78AC
	ld bc, $1514
	call InputTilemapRect

LABEL_352D:
	ld hl, LABEL_B27_BACF
	ld de, $78AC
	ld bc, $0114
	call OutputTilemapBoxB27
	call LABEL_35C4
	ld a, (Inventory_curr_num)
	cp $09
	ld hl, LABEL_B27_BAF7
	ld bc, $0214
	call nc, OutputTilemapBoxB27
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
	call OutputTilemapBoxB27
	ret

LABEL_356B:
	di
	push	bc
	push	hl
	push	de
	rst  $08
	ld	l, (hl)
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, ItemNames
	add	hl, de
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $11
	out	(Port_VDPData), a
	ld	b, $08
LABEL_3588:
	ld	a, (hl)
	sub	$20
	add	a, a
	add	a, c
	ld	de, TileCharacterTable
	add	a, e
	ld	e, a
	adc	a, d
	sub	e
	ld	d, a
	ld	a, (de)
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $10
	out	(Port_VDPData), a
	inc	hl
	djnz	LABEL_3588
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $13
	out	(Port_VDPData), a
	pop	de
	ld	hl, $0040
	add	hl, de
	ex   de, hl
	pop	hl
	pop	bc
	ei
	ld	a, $0A
	call	WaitForVInt
	ret

LABEL_35BC:
	di
	push	de
	rst  $08
	ld	b, $0C
	jp	LABEL_35C9


LABEL_35C4:
	di
	push de
	rst $08
	ld b, $08

LABEL_35C9:
	ld	hl, LABEL_3639
LABEL_35CC:
	ld	a, (hl)
	out	(Port_VDPData), a
	inc	hl
	djnz	LABEL_35CC
	ld	hl, (Current_money)

Draw5DigitNumAndRightBorder:
	ld	bc, $C010
	ld	de, 10000
	xor	a
	cpl
LABEL_35DD:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_35DD
	add	hl, de
	call	OutputDigit
	ld	de, 1000
	xor	a
	cpl
LABEL_35EB:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_35EB
	add	hl, de
	call	OutputDigit
	ld	de, 100
	xor	a
	cpl
LABEL_35F9:
	sbc  hl, de
	inc	a
	jr	nc, LABEL_35F9
	add	hl, de
	call	OutputDigit
	ld	d, $FF
	ld	a, l
LABEL_3605:
	sub	10
	inc	d
	jr	nc, LABEL_3605
	add	a, 10
	ld	l, a
	ld	a, d
	call	OutputDigit
	ld	d, $FF
	ld	a, l
LABEL_3614:
	sub	$01
	inc	d
	jr	nc, LABEL_3614
	ld	a, d
	ld	bc, $C110
	call	OutputDigit

DrawRightBorder:
	push	af
	pop	af
	ld	a, $F3
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, $13
	out	(Port_VDPData), a
	pop	de
	ld	hl, $0040
	add	hl, de
	ex   de, hl
	ei
	ld	a, $0A
	call	WaitForVInt
	ret


LABEL_3639:
.db $F3, $11, $D7, $10, $DD, $10, $DE, $10, $C0, $10, $C0, $10

OutputDigit:
	and	$0F
	jp	z, LABEL_364D
	ld	bc, $C110
LABEL_364D:
	add	a, b
	out	(Port_VDPData), a
	push	af
	pop	af
	ld	a, c
	out	(Port_VDPData), a
	ret


HideInventoryWindow:
	push bc
	ld hl, $DC04
	ld de, $78AC
	ld bc, $1514
	call OutputTilemapBoxB27
	pop bc
	ret


PlayerSelect:
	ld	a, (Party_curr_num)
	or	a
	ret  z	; return if there's only 1 party member

	ld	hl, $DDA8
	ld	de, $7A44
	ld	bc, $090C
	call	InputTilemapRect
	call	LABEL_369F
	ld	hl, $7A84
	ld	(CursorTileMapAddress), hl
	jp	CheckOptionSelect


PlayerSelect2:
	ld a, (Party_curr_num)
	or a
	ret z
	ld hl, $DE14
	ld de, $7A54
	ld bc, $090C
	call InputTilemapRect
	call LABEL_369F
	ld hl, $7A94
	ld (CursorTileMapAddress), hl
	jp CheckOptionSelect

LABEL_369F:
	ld	a, (Party_curr_num)
	or	a
	ret  z

	ld	(Option_total_num), a
	inc	a
	add	a, a
	ld	b, a
	ld	c, $0C
	ld	hl, LABEL_B27_BB1F
	call	OutputTilemapBoxB27
	ld	hl, LABEL_B27_BB7F
	ld	bc, $010C
	jp	OutputTilemapBoxB27

ClosePlayerSelect:
	ld	a, (Party_curr_num)
	or	a
	ret  z

	ld	hl, $DDA8
	ld	de, $7A44
	ld	bc, $090C
	jp	OutputTilemapBoxB27


HidePlayerSelect2Window:
	ld a, (Party_curr_num)
	or a
	ret z
	ld hl, $DE14
	ld de, $7A54
	ld bc, $090C
	jp OutputTilemapBoxB27

LABEL_36DD:
	ld	hl, $D8A4
	ld	de, $7842
	ld	bc, $0B0C
	call	InputTilemapRect
	ld	hl, LABEL_B27_BB8B
	jp	OutputTilemapBoxB27


LABEL_36EF:
	ld hl, LABEL_B27_BB8B
	ld de, $7842
	ld bc, $0B0C
	jp OutputTilemapRect

LABEL_36FB:
	ld hl, $D8A4
	ld de, $7842
	ld bc, $0B0C
	jp OutputTilemapBoxB27

ShowEquippedItems:
	push	af
	ld	hl, $D928
	ld	de, $7A8C
	ld	bc, $0814
	call	InputTilemapRect
	ld	hl, LABEL_B27_BACF
	ld	de, $7A8C
	ld	bc, $0114
	call	OutputTilemapBoxB27
	pop	af
	push	af
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, $FFFF
	ld	(hl), :Bank02
	ld	hl, Char_stats+weapon
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	b, $03
LABEL_3735:
	ld	c, $00
	call	LABEL_356B
	ld	c, $01
	call	LABEL_356B
	inc	hl
	djnz	LABEL_3735
	ld	hl, LABEL_B27_BAE3
	ld	bc, $0114
	call	OutputTilemapBoxB27
	pop	af
	ret


HideEquippedItems:
	ld hl, $D928
	ld de, $7A8C
	ld bc, $0814
	jp OutputTilemapBoxB27

LABEL_3759:
	ld hl, $DE14
	ld de, $7A32
	ld bc, $070A
	call InputTilemapRect
	ld hl, LABEL_B27_BC0F
	jp OutputTilemapBoxB27

LABEL_376B:
	ld hl, $DE14
	ld de, $7A32
	ld bc, $070A
	jp OutputTilemapBoxB27

BuySellMenu:
	ld hl, $DE14
	ld de, $7B48
	ld bc, $050C
	call InputTilemapRect
	ld hl, LABEL_B27_BC55
	call OutputTilemapBoxB27
	ld hl, $7B88
	ld (CursorTileMapAddress), hl
	ld a, $01
	ld (Option_total_num), a
	jp CheckOptionSelect

BuySellMenuClose:
	ld hl, $DE14
	ld de, $7B48
	ld bc, $050C
	jp OutputTilemapBoxB27

ShowMenuYesNo:
	ld	hl, $DE64
	ld	de, $7B6A
	ld	bc, $050A
	call	InputTilemapRect
	ld	hl, LABEL_B27_BC91
	call	OutputTilemapBoxB27
	ld	hl, $7BAA
	ld	(CursorTileMapAddress), hl
	ld	a, $01
	ld	(Option_total_num), a
	jp	CheckOptionSelect

HideMenuYesNo:
	ld	hl, $DE64
	ld	de, $7B6A
	ld	bc, $050A
	jp	OutputTilemapBoxB27

ShowCharacterStats:
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	hl, Char_stats
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	push	hl
	pop	ix
	ld	hl, $DC04
	ld	de, $7920
	ld	bc, $0E18
	call	InputTilemapRect
	ld	hl, LABEL_B27_BCC3
	ld	bc, $0118
	call	OutputTilemapBoxB27
	ld	hl, LABEL_3865
	ld	a, (ix+5)
	call	Output4CharsPlusStatWide
	ld	hl, LABEL_3875
	ld	c, (ix+3)
	ld	b, (ix+4)
	call	ConvertToDec5Digits
	ld	hl, LABEL_B27_BCDB
	ld	bc, $0118
	call	OutputTilemapBoxB27
	ld	hl, LABEL_3881
	ld	a, (ix+8)
	call	Output4CharsPlusStatWide
	ld	hl, LABEL_B27_BCDB
	ld	bc, $0118
	call	OutputTilemapBoxB27
	ld	hl, LABEL_3891
	ld	a, (ix+9)
	call	Output4CharsPlusStatWide
	ld	hl, LABEL_B27_BCDB
	ld	bc, $0118
	call	OutputTilemapBoxB27
	ld	hl, LABEL_38A1
	ld	a, (ix+6)
	call	Output4CharsPlusStatWide
	ld	hl, LABEL_B27_BCDB
	ld	bc, $0118
	call	OutputTilemapBoxB27
	ld	hl, LABEL_38B1
	ld	a, (ix+7)
	call	Output4CharsPlusStatWide
	ld	hl, LABEL_B27_BCF3
	ld	bc, $0118
	call	OutputTilemapBoxB27
	call	LABEL_35BC
	ld	hl, LABEL_B27_BD0B
	ld	bc, $0118
	jp	OutputTilemapBoxB27


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

HideCharacterStats:
	ld hl, $DC04
	ld de, $7920
	ld bc, $0E18
	jp OutputTilemapBoxB27

ShopMesetaWindowCopy:
	ld hl, $D8A4
	ld de, $780C
	ld bc, $0820
	jp InputTilemapRect

RunShop:
	ld hl, LABEL_B27_BD23
	ld de, $780C
	ld bc, $0120
	call OutputTilemapBoxB27
	ld hl, $FFFF
	ld (hl), :Bank03
	ld a, (Room_index)
	and $1F
	ld l, a
	ld h, $00
	add hl, hl
	ld c, l
	ld b, h
	add hl, hl
	add hl, hl
	add hl, bc
	ld bc, B03_ShopData
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
	call OutputTilemapBoxB27
	ld hl, $788C
	ld (CursorTileMapAddress), hl
	call CheckOptionSelect
	ld hl, $FFFF
	ld (hl), :Bank03
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
	ld de, ItemNames
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
	ld de, TileCharacterTable
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
	jp nz, Draw5DigitNumAndRightBorder
	jp DrawRightBorder

LABEL_3999:
	ld hl, $D8A4
	ld de, $780C
	ld bc, $0820
	jp OutputTilemapBoxB27

GetSaveGameSelection:
	ld hl, $D928
	ld de, $786E
	ld bc, $0C12
	call InputTilemapRect

GetSaveGameSelectionCont:
	ld a, $08
	ld ($FFFC), a
	ld hl, $8100
	ld de, $786E
	ld bc, $0C12
	call OutputTilemapBoxWipe
	ld a, $80
	ld ($FFFC), a
	ld hl, $78EE
	ld (CursorTileMapAddress), hl
	ld a, $04
	ld (Option_total_num), a
	call CheckOptionSelect
	ld l, a
	inc l
	ld h, $00
	ld (NumberToShowInText), hl
	ret

LABEL_39DD:
	ld hl, $D928
	ld de, $786E
	ld bc, $0C12
	jp OutputTilemapBoxB27

ShopMesetaWindowDraw:
	push bc
	ld hl, $D700
	ld de, $782C
	ld bc, $0314
	call InputTilemapRect
	pop bc

LABEL_39F7:
	push bc
	ld hl, LABEL_B27_BACF
	ld de, $782C
	ld bc, $0114
	call OutputTilemapBoxB27
	call LABEL_35C4
	ld hl, LABEL_B27_BAE3
	ld bc, $0114
	call OutputTilemapBoxB27
	pop bc
	ret

LABEL_3A12:
	push bc
	ld hl, $D700
	ld de, $782C
	ld bc, $0314
	call OutputTilemapBoxB27
	pop bc
	ret

LABEL_3A21:
	ld hl, $DE14
	ld de, $7AE4
	ld bc, $0710
	call InputTilemapRect
	ld a, :Bank18
	ld ($FFFF), a
	ld hl, LABEL_B18_BE84
	call OutputTilemapBoxWipe
	ld hl, $7B24
	ld (CursorTileMapAddress), hl
	ld a, $02
	ld (Option_total_num), a
	call CheckOptionSelect
	push af
	push bc
	ld hl, $DE14
	ld de, $7AE4
	ld bc, $0710
	call OutputTilemapBoxB27
	pop bc
	pop af
	ret

OutputTilemapBoxB27:
	ld	a, ($FFFF)
	push	af
	ld	a, :Bank27
	ld	($FFFF), a
	call	OutputTilemapBoxWipe
	pop	af
	ld	($FFFF), a
	ret

OutputTilemapBoxWipe:
	push	bc
	di
	rst  $08
	ld	b, c
	ld	c, $BE
LABEL_3A6E:
	outi
	jp	nz, LABEL_3A6E
	ex   de, hl
	ld	bc, $0040
	add	hl, bc
	ex   de, hl
	ei
	ld	a, $0A
	call	WaitForVInt
	pop	bc
	djnz	OutputTilemapBoxWipe
	ret

OutputTilemapRect:
	ld	a, ($FFFF)
	push	af
	ld	a, :Bank27
	ld	($FFFF), a
	di
LABEL_3A8D:
	push	bc
	rst  $08
	ld	b, c
	ld	c, $BE
LABEL_3A92:
	outi
	jp	nz, LABEL_3A92
	ex   de, hl
	ld	bc, $0040
	add	hl, bc
	ex   de, hl
	pop	bc
	djnz	LABEL_3A8D
	ei
	pop	af
	ld	($FFFF), a
	ret

InputTilemapRect:
	di
	push	bc
	push	de
	res  6, d
LABEL_3AAB:
	push	bc
	rst  $08
	ld	b, c
	ld	c, $BE
LABEL_3AB0:
	ini
	push	af
	pop	af
	jp	nz, LABEL_3AB0
	ex   de, hl
	ld	bc, $0040
	add	hl, bc
	ex   de, hl
	pop	bc
	djnz	LABEL_3AAB
	pop	de
	pop	bc
	ei
	ret


; =================================================================
DefaultSRAMData:
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
; =================================================================


GameMode_Scene:
	ld a, (Game_is_paused)
	or a
	call nz, PauseLoop
	ld a, $08
	call WaitForVInt
	ld a, (Battle_flag)
	or a
	jp nz, LABEL_3C1A
	ld a, ($C2DC)
	call LoadDialogueSprite
	ld a, (Scene_type)
	sub $10
	jr nc, +
	xor a
+:
	and $0F
	ld hl, GameModeScenePointers
	call GetPtrAndJump
LABEL_3BC5:
	ld a, (Scene_type)
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
	ld (Sound_index), a
+:
	xor a
	ld (Battle_flag), a
	ld (Scene_type), a
	ld ($C2D5), a
	ld hl, $0000
	ld ($C2DB), hl
	ld hl, Character_sprite_attributes
	ld de, Character_sprite_attributes+1
	ld bc, $00FF
	ld (hl), $00
	ldir
	ld a, (Game_mode)
	cp $0D ; GameMode_Scene
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
	call Dungeon_LoadEnemy
	call Dungeon_EnterBattle
	ld a, ($C800)
	or a
	call nz, LABEL_1BE1
	jp LABEL_3BC5


; =================================================================
GameModeScenePointers:
.dw	Scene_DoRoomScript
.dw	Scene_DoRoomScript
.dw	Scene_Hospital
.dw	Scene_Hospital
.dw	Scene_Church
.dw	Scene_Church
.dw	Scene_Armory
.dw	Scene_Armory
.dw Scene_Pharmacy
.dw	Scene_Pharmacy
.dw	Scene_ToolShop
.dw	Scene_ToolShop
.dw	Scene_DoRoomScript
.dw	Scene_DoRoomScript
.dw	Scene_DoRoomScript
.dw	Scene_DoRoomScript
.dw Scene_DoRoomScript
.dw	Scene_DoRoomScript
.dw	Scene_DoRoomScript
.dw	Scene_DoRoomScript
; =================================================================


GameMode_LoadScene:
	ld a, $D6
	ld (Sound_index), a
	call FadeOut2
	ld a, ($C308)
	or a
	jr nz, +
	ld a, (Scene_type)
	cp $05
	jr nz, LABEL_3CAD
	ld a, $04
	ld (Scene_type), a
	jr LABEL_3CAD

+:
	cp $01
	jr nz, +
	ld a, (Scene_type)
	cp $01
	jr nz, LABEL_3CAD
	ld a, $05
	ld (Scene_type), a
	jr LABEL_3CAD

+:
	cp $07
	jr nz, +
	ld a, (Scene_type)
	cp $01
	jr nz, LABEL_3CAD
	ld a, $05
	ld (Scene_type), a
	jr LABEL_3CAD

+:
	cp $08
	jr nz, +
	ld a, $06
	ld (Scene_type), a
	jr LABEL_3CAD

+:
	cp $0A
	jr nz, LABEL_3CAD
	ld a, (Scene_type)
	cp $09
	jr nz, LABEL_3CAD
	ld a, $08
	ld (Scene_type), a
LABEL_3CAD:
	ld a, (Scene_type)
	or a
	jr nz, +
	inc a
	ld (Scene_type), a
+:
	call Scene_LoadData
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, TilesFont_B16
	ld de, $5800
	call LoadTiles4BitRLE
	ld hl, TilesExtraFont_B16
	ld de, $7E00
	call LoadTiles4BitRLE
	xor a
	ld (V_scroll), a
	ld (H_scroll), a
	ld (Character_sprite_attributes), a
	ld ($C2E9), a
	dec a
	ld (Scene_anim_flag), a
	ld hl, $0000
	ld (Palette_move_delay), hl
	ld hl, $FF00
	ld (Anim_delay_counter), hl
	di
	call AnimateEnemyTile
	ei
	ld a, (Scene_type)
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
	ld (Sound_index), a
+:
	ld hl, Game_mode
	inc (hl) ; GameMode_Scene
	di
	ld de, $8006
	rst $08
	ei
	ld a, $0C
	call WaitForVInt
	jp ClearSpriteTableFadeIn


SpritePaletteStart:
.db	$00, $00, $3F, $30, $38, $03, $0B, $0F

LABEL_3D25:
.db	$00, $00, $00, $00, $00, $8D, $8D, $8E, $8E, $8E, $8E, $8E, $8E, $00, $00
.db $00, $00

LABEL_3D36:
	cp	$20
	jr	nc, LABEL_3D4E
	add	a, a
	add	a, a
	add	a, a
	ld	l, a
	ld	h, $00
	ld	de, SceneData-3
	add	hl, de
	jp	LABEL_3D96

Scene_LoadData:
	ld	a, (Scene_type)
	cp	$20
	jr	c, LABEL_3D64
LABEL_3D4E:
	ld	hl, $D000
	ld	de, $D002
	ld	bc, $05FE
	ld	(hl), $00
	inc	hl
	ld	(hl), $08
	dec  hl
	ldir
	xor	a
	ld	(Text_box_open_flag), a
	ret

LABEL_3D64:
	add	a, a
	add	a, a
	add	a, a
	ld	l, a
	ld	h, $00
	ld	de, SceneData-8
	add	hl, de
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	ld	de, Target_palette
	ld	bc, $0010
	ldir
	ld	hl, SpritePaletteStart
	ld	c, $08
	ldir
	pop	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	ld	de, $4000
	call	LoadTiles4BitRLE
	pop	hl
	inc	hl
LABEL_3D96:
	xor	a
	ld	(Text_box_open_flag), a
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	jp	DecompressTilemapData


; =================================================================
; Byte 1 = Bank number
; Bytes 2-3 = Palette
; Bytes 4-5 = Tiles
; Byte 6 = Bank number
; Bytes 7-8 = Tilemap
; =================================================================
SceneData:

; 01 Palma enemy (open)
.db :Bank16
.dw	Palette_PalmaOpen_B16, Tiles_PalmaAndDezorisOpen_B16
.db	:Bank15
.dw	Tilemap_PalmaOpen_B15

; 02 Palma enemy (forest)
.db	:Bank16
.dw	Palette_PalmaForest_B16, Tiles_PalmaForest_B16
.db	:Bank15
.dw	Tilemap_PalmaForest_B15

; 03 Palma enemy (sea)
.db :Bank16
.dw	Palette_PalmaSea_B16, Tiles_PalmaSea_B16
.db	:Bank15
.dw	Tilemap_PalmaSea_B15

; 04 Palma enemy (coast)
.db	:Bank16
.dw	Palette_PalmaSea_B16, Tiles_PalmaSea_B16
.db	:Bank15
.dw	Tilemap_PalmaCoast_B15

; 05 Motavia enemy
.db :Bank16
.dw	Palette_MotaviaOpen_B16, Tiles_MotaviaOpen_B16
.db	:Bank15
.dw	Tilemap_MotaviaOpen_B15

; 06 Dezoris enemy
.db	:Bank16
.dw	Palette_DezorisOpen_B16, Tiles_PalmaAndDezorisOpen_B16
.db	:Bank15
.dw	Tilemap_DezorisOpen_B15

; 07 Palma enemy (lava pit)
.db :Bank16
.dw	Palette_PalmaOpen_B16, Tiles_PalmaAndDezorisOpen_B16
.db	:Bank15
.dw	Tilemap_PalmaLavaPit_B15

; 08 Palma town
.db	:Bank17
.dw	Palette_PalmaTown_B17, Tiles_PalmaTown_B17
.db	:Bank15
.dw	Tilemap_PalmaTown_B15

; 09 Palma village
.db :Bank17
.dw	Palette_PalmaVillage_B17, Tiles_PalmaVillage_B17
.db	:Bank15
.dw	Tilemap_PalmaVillage_B15

; 10 Spaceport
.db	:Bank17
.dw	Palette_Spaceport_B17, Tiles_Spaceport_B17
.db	:Bank15
.dw	Tilemap_Spaceport_B15

; 11 Dead trees (?)
.db :Bank17
.dw	Palette_DeadTrees_B17, Tiles_DeadTrees_B17
.db	:Bank15
.dw	Tilemap_DeadTrees_B15

; 12 Dezoris forest
.db	:Bank16
.dw	Palette_DezorisForest_B16, Tiles_PalmaForest_B16
.db	:Bank15
.dw	Tilemap_PalmaForest_B15

; 13 Air Castle
.db	:Bank22
.dw	Palette_AirCastle_B22, Tiles_AirCastle_B22
.db	:Bank22
.dw	Tilemap_AirCastle_B22

; 14 Gold Dragon
.db	:Bank11
.dw	Palette_GoldDragon_B11, Tiles_GoldDragon_B11
.db	:Bank22
.dw	Tilemap_GoldDragon_B22

; 15 Air Castle
.db :Bank22
.dw	Palette_AirCastleFull, Tiles_AirCastle_B22
.db	:Bank22
.dw	Tilemap_AirCastle_B22

; 16 Building Empty
.db	:Bank23
.dw	Palette_BuildingEmpty_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingEmpty_B23

; 17 Building Windows
.db :Bank23
.dw	Palette_BuildingWindows_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingWindows_B23

; 18 Hospital 1
.db	:Bank23
.dw	Palette_BuildingHospital1_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingHospital1_B23

; 19 Hospital 2
.db :Bank23
.dw	Palette_BuildingHospital2_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingHospital2_B23

; 20 Church 1
.db	:Bank23
.dw	Palette_BuildingChurch1_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingChurch1_B23

; 21 Church 2
.db :Bank23
.dw	Palette_BuildingChurch2_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingChurch2_B23

; 22 Armory 1
.db	:Bank23
.dw	Palette_BuildingArmory1_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingArmory1_B23

; 23 Armory 2
.db :Bank23
.dw	Palette_BuildingArmory2_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingArmory2_B23

; 24 Shop 1
.db	:Bank23
.dw	Palette_BuildingShop1_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingShop1_B23

; 25 Shop 2
.db :Bank23
.dw	Palette_BuildingShop2_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingShop2_B23

; 26 Shop 3
.db	:Bank23
.dw	Palette_BuildingShop3_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingShop3_B23

; 27 Shop 4
.db :Bank23
.dw	Palette_BuildingShop4_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingShop4_B23

; 28 Building Destroyed
.db	:Bank23
.dw	Palette_BuildingDestroyed_B23, Tiles_Building_B23
.db	:Bank23
.dw	Tilemap_BuildingDestroyed_B23

; 29 Mansion
.db :Bank09
.dw	Palette_Mansion_B09, Tiles_Mansion_B09
.db	:Bank09
.dw	Tilemap_Mansion_B09

; 30 Lassic's Room
.db	:Bank20
.dw	Palette_LassicRoom_B20, Tiles_LassicRoom_B20
.db	:Bank27
.dw	Tilemap_LassicRoom_B27

; 31 Dark Force
.db :Bank19
.dw	Palette_DarkForce_B19, Tiles_DarkForce_B19
.db	:Bank13
.dw	Tilemap_DarkForce_B13
; =================================================================


; =================================================================
Palette_AirCastleFull:
.db	$30, $00, $3F, $0B, $06, $1A, $2F, $2A
.db $08, $15, $15, $0B, $06, $1A, $2F, $28
; =================================================================


; =================================================================
.db	$A6, $8B, $17, $EF, $AA, $6F, $AB, $17, $8E, $8F, $17
; =================================================================


GameMode_NameInput:
	ld a, (Game_is_paused)
	or a
	call nz, PauseLoop
	ld ix, Name_entry_cursor_x
	ld a, $08
	call WaitForVInt
	call NameInput_DrawCursorSprites
	ld a, (Ctrl_1_pressed)
	and Button_1_Mask|Button_2_Mask
	jp z, NameInput_NoButtonPressed
	and Button_1_Mask
	jp nz, +++
	ld a, (Name_entry_currently_pointed)
	cp $5C
	jr z, +
	jr nc, ++
	ld de, (Name_entry_char_index)
	ld d, $C7
	ld (de), a
	call NameInput_GetCharTilemapDataAddress
	ld a, (de)
	di
	call NameInput_WriteCharToTilemapData2
	ei
+:
	ld hl, Name_entry_char_index
	ld a, (hl)
	cp $25
	ret z
	inc (hl)
	ret

++:
	cp $5E
	jr z, ++++
-:
	ld a, (Name_entry_mode)
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
	ld de, (Name_entry_char_index)
	ld d, $C7
	ld a, $20
	ld (de), a
	call NameInput_GetCharTilemapDataAddress
	ld a, (de)
	di
	call NameInput_WriteCharToTilemapData2
	ei
	jp -

++++:
	ld hl, $C721
	ld de, $C778
	ld bc, $0005
	ldir
	ld hl, (NumberToShowInText)
	add hl, hl
	ld de, NameInputSaveSlotNameTileAddr-2
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
	ld a, $0C ; GameMode_LoadScene
+:
	ld (Game_mode), a
	ret


; =================================================================
NameInputSaveSlotNameTileAddr:
.dw $8118
.dw $813C
.dw $8160
.dw $8184
.dw $81A8
; =================================================================


NameInput_NoButtonPressed:
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
	call NameInput_DecrementKeyRepeatCounter
	ret nz
-:
	ld bc, $C808
	ld de, $0002
	ld iy, Name_entry_cursor_x
	jr LABEL_3FF2

+:
	ld a, $18
	ld (Name_entry_key_repeat_counter), a
	jr -

++:
	call NameInput_DecrementKeyRepeatCounter
	ret nz
-:
	ld bc, $60F0
	ld de, $FF80
	ld iy, Name_entry_cursor_y
	jr LABEL_3FF2

LABEL_3FB7:
	ld a, $18
	ld (Name_entry_key_repeat_counter), a
	jr -

+++:
	call NameInput_DecrementKeyRepeatCounter
	ret nz
-:
	ld bc, $9010
	ld de, $0080
	ld iy, Name_entry_cursor_y
	jr LABEL_3FF2

LABEL_3FCE:
	ld a, $18
	ld (Name_entry_key_repeat_counter), a
	jr -

LABEL_3FD5:
	call NameInput_DecrementKeyRepeatCounter
	ret nz
-:
	ld bc, $28F8
	ld a, (Name_entry_currently_pointed)
	cp $5C
	ret z
	ld de, $FFFE
	ld iy, Name_entry_cursor_x
	jr LABEL_3FF2

LABEL_3FEB:
	ld a, $18
	ld (Name_entry_key_repeat_counter), a
	jr -

LABEL_3FF2:
	ld	a, (iy+0)
	cp	b
	ret	z
	add	a, c
	ld	(iy+0), a
	ld	hl, (Name_entry_cursor_tilemap_addr)
	add	hl, de

; The next 3 bytes are translated as ld	(Name_entry_cursor_tilemap_addr), hl, but since the instruction is split
;  across 2 banks, I can't use it. This will have to do until I find a workaround
.db $22


.BANK 1 SLOT 1
.ORG $0000


.dw Name_entry_cursor_tilemap_addr

	ld a, (hl)
	or a
	jr z, LABEL_3FF2
	cp (ix+4)
	jr z, LABEL_3FF2
	ld (Name_entry_currently_pointed), a
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
	ld (Name_entry_cursor_tilemap_addr), hl
	ld a, c
	ld (Name_entry_cursor_x), a
	ret

NameInput_DecrementKeyRepeatCounter:
	ld hl, Name_entry_key_repeat_counter
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
	call FillVRAMWithHL
	ei
	ld hl, Game_mode
	inc (hl) ; GameMode_NameInput
	ld hl, Name_entry_char_index
	ld (hl), $00
	ld de, Name_entry_char_index+1
	ld bc, $007E
	ldir
	ld hl, $D000
	ld de, $D001
	ld bc, $0600
	ld (hl), $00
	ldir
	call NameInput_DecompressTilemapData
	ld hl, $C700
	ld de, $C701
	ld bc, $0037
	ld (hl), $00
	ldir
	ld a, $21
	ld (Name_entry_char_index), a
	ld de, $78C0
	ld hl, $D0C0
	ld bc, $0540
	di
	call DataToVRAM
	ei
	call NameInput_LoadTilemapDataWithCharValues
	ld hl, Palette_NameInput
	ld de, Target_palette
	ld bc, $0020
	ldir
	ld de, $6000
	ld hl, NameInputCursorSprite
	ld bc, $0020
	di
	call DataToVRAM
	ei
	ld de, Name_entry_cursor_x
	ld hl, NameInputCursorInitialValues
	ld bc, $0005
	ldir
	xor a
	ld (V_scroll), a
	ld (H_scroll), a
	ld (Text_box_open_flag), a
	ld de, $8006
	di
	rst $08
	ei
	jp ClearSpriteTableFadeIn


; =================================================================
NameInputCursorInitialValues:
.db $28	; selected char cursor sprite X
.db $60 ; selected char cursor sprite Y
.dw $D30A ; selected char TileMapData address
.db $41 ; currently pointed char
; =================================================================


NameInput_DrawCursorSprites:
	call NameInput_GetCharTilemapDataAddress
	ld de, $3040
	add hl, de
	add hl, hl
	add hl, hl
	ld de, Sprite_table
	ld a, h
	add a, a
	add a, a
	add a, a
	ld (de), a
	ld a, (Name_entry_currently_pointed)
	cp $5C
	ld a, (Name_entry_cursor_y)
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


nameInput_DrawPassword:
	ld	hl, Name_entry_char_index
	ld	(hl), $38
	ld	d, $C7

-:
	dec	(hl)
	ret	m
	ld	e, (hl)
	push	hl
	call	NameInput_GetCharTilemapDataAddress
	ld	a, (de)
	push	de
	call	NameInput_WriteCharToTilemapData
	pop	de
	pop	hl
	jr	-

NameInput_GetCharTilemapDataAddress:
	ld a, (Name_entry_char_index)
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

NameInput_WriteCharToTilemapData:
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

NameInput_WriteCharToTilemapData2:
	call NameInput_WriteCharToTilemapData
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

NameInput_DecompressTilemapData:
	ld hl, NameEntryTilemapData
	ld de, Tilemap_data+$100
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

NameInput_LoadTilemapDataWithCharValues:
	ld hl, NameEntryCharValues
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

Palette_NameInput:
.db	$00, $00, $3F, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $3C, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00

NameInputCursorSprite:
.db	$FF, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00

.db $00, $00, $00, $00

NameEntryTilemapData:
.db	$03, $C0, $01, $F1
.db $17, $F2, $01, $F1, $0C, $C0, $D0, $D3
.db $D8, $DA, $DF, $DE, $C0, $E3, $D9, $DF
.db $DC, $C0, $D8, $CB, $D7, $CF, $E7, $58
.db $C0, $55, $C0, $8B, $CB, $2A, $C0, $8B
.db $D6, $1E, $C0, $01, $EB, $0B, $C0, $8A
.db $E1, $36, $C0, $CB, $CB, $CE, $E0, $C0
.db $DC, $DF, $CC, $C0, $CF, $D8, $CE, $09
.db $C0, $01, $F1, $17, $F2, $01, $F1, $00

NameEntryCharValues:
.db $41, $42, $43, $44, $45, $46, $47, $48
.db $49, $4A, $4B, $4C, $4D, $4E, $4F, $50
.db $51, $52, $53, $54, $55, $56, $57, $58
.db $59, $5A, $2C, $3B, $2E, $21, $3F, $2D
.db $22, $5C, $5C, $5C, $5C, $5C, $5C, $5C
.db $5D, $5D, $5E, $5E

GoToIntroSequence:
	ld a, $D7
	ld (Sound_index), a
	call FadeOut2
	ld hl, $FFFF
	ld (hl), :Bank23
	ld hl, Palette_Space_B23
	ld de, Target_palette
	ld bc, $0011
	ldir
	ld hl, Ship_SpaceTiles_B23
	ld de, $4000
	call LoadTiles4BitRLE
	ld hl, $FFFF
	ld (hl), :Bank28
	ld hl, Ship_TilemapSpace_B28
	call DecompressTilemapData
	ld hl, Tilemap_data
	ld de, Tilemap_data+$300
	ld bc, $0300
	ldir
	ld hl, Tilemap_data
	ld bc, $0100
	ldir
	xor a
	ld (H_scroll), a
	ld a, $80
	ld (V_scroll), a
	ld hl, Tilemap_data
	ld de, $7800
	ld bc, $0700
	di
	call DataToVRAM
	ei
	ld a, $8C
	ld (Sound_index), a
	call FadeIn2
	ld a, $02
	ld (Scroll_direction), a
	ld a, $02
	ld (Scroll_screens), a
-:
	ld a, $0E
	call WaitForVInt
	ld a, (Ctrl_1_pressed)
	and Button_1_Mask|Button_2_Mask
	jr nz, +
	call Intro_ScrollDown
	ld a, (Scroll_screens)
	cp $01
	jr nz, -
	ld a, (V_scroll)
	cp $80
	jr nz, -
	call VintDelayButtonPress2
+:
	xor a
	ld (Scroll_direction), a
	ld (Scroll_screens), a
	call FadeOut2
	ld a, $08
	ld (Scene_type), a
	call Scene_LoadData
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, TilesFont_B16
	ld de, $5800
	call LoadTiles4BitRLE
	ld hl, TilesExtraFont_B16
	ld de, $7E00
	call LoadTiles4BitRLE
	xor a
	ld (V_scroll), a
	ld (H_scroll), a
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld hl, $FFFF
	ld (hl), :Bank18
	ld hl, IntroBox1_B18
	ld de, $7886
	ld bc, $0528
	call OutputTilemapBoxWipe
	call VintDelayButtonPress2
	call GameMode_FadeToPicture
	ld a, $00
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueIntro1
	call ShowNarrativeText
	ld a, $01
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueIntro2
	call ShowNarrativeText
	ld a, $02
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueIntro3
	call ShowNarrativeText
	ld a, $D7
	ld (Sound_index), a
	ret

Intro_ScrollDown:
	ld de, $0001
	ld a, (V_scroll)
	add a, e
	cp $E0
	jr c, +
	ld d, $01
	add a, $20
+:
	ld (V_scroll), a
	ld a, (Scroll_screens)
	sub d
	ld (Scroll_screens), a
	cp $01
	ret nz
	ld a, d
	or a
	ret z
	ld hl, Ship_TilemapBottomPlanet_B28
	jp DecompressTilemapData

MyauIntro:
	call GameMode_FadeToPicture
	ld a, $8A
	ld (Sound_index), a
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauIntro1
	call ShowNarrativeText
	ld a, $04
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauIntro2
	call ShowNarrativeText
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauIntro3
	call ShowNarrativeText
	ld a, $04
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauIntro4
	call ShowNarrativeText
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauIntro5
	call ShowNarrativeText
	ld a, $D8
	ld (Sound_index), a
	ret

OdinIntro:
	call GameMode_FadeToPicture
	ld a, $8A
	ld (Sound_index), a
	ld a, $05
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueOdinIntro1
	call ShowNarrativeText
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueOdinIntro2
	call ShowNarrativeText
	ld a, $05
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueOdinIntro3
	call ShowNarrativeText
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueOdinIntro4
	call ShowNarrativeText
	ld a, $05
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueOdinIntro5
	call ShowNarrativeText
	call FadeOut2
	call LABEL_FF3
	ld a, $D8
	ld (Sound_index), a
	jp FadeIn2

NoahIntro:
	call GameMode_FadeToPicture
	ld a, $8A
	ld (Sound_index), a
	; Pick an alive character to show
	ld a, $03
	ld hl, Alis_stats
	bit 0, (hl)
	jr nz, +
	ld a, $05
	ld hl, Odin_stats
	bit 0, (hl)
	jr nz, +
	ld a, $04
+:
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueNoahIntro1
	call ShowNarrativeText
	ld a, $06
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueNoahIntro2
	call ShowNarrativeText
	ld a, $D8
	ld (Sound_index), a
	ret

MyauTransformation:
	ld a, (Location_index)
	cp $17
	jr nz, +
	call MyauFlight
	ld hl, LABEL_4514
	jp LABEL_4509

+:
	call GameMode_FadeToPicture
	ld a, $8A
	ld (Sound_index), a
	ld a, $07
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauTransformation1
	call ShowNarrativeText
	ld a, $08
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueMyauTransformation2
	call ShowNarrativeText
	call MyauFlight
	ld a, $0E
	ld (Scene_type), a
	call Scene_LoadData
	ld a, $0C
	call WaitForVInt
	ld hl, $C250
	ld b, $10
-:
	ld (hl), $30
	inc hl
	djnz -
	call FadeIn2
	call VintDelayButtonPress
	ld hl, $FFFF
	ld (hl), :Bank11
	ld hl, Palette_GoldDragon_B11
	ld de, Target_palette+$10
	ld bc, $0008
	ldir
	ld a, EnemyID_GdDragn
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	call Dungeon_EnterBattle
	ld a, (Game_mode)
	cp $02 ; GameMode_LoadTitleScreen
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

MyauFlight:
	call FadeOut2
	ld a, $0F
	ld (Scene_type), a
	call Scene_LoadData
	ld hl, $FFFF
	ld (hl), :Bank22
	ld hl, Palette_MyauFlight_B22
	ld de, $C251
	ld bc, $000F
	ldir
	ld hl, Tiles_MyauFlight_B22
	ld de, $6000
	call LoadTiles4BitRLE
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $15
	ld ($C800), a
	call LABEL_18B9
	jp FadeOut2

EndingScreen:
	call FadeOut2
	ld a, $D0
	ld (Sprite_table), a
	ld a, $8B
	ld (Sound_index), a
	ld a, $0D
	ld (Scene_type), a
	call Scene_LoadData
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld b, $80
	call VIntDelay2
	call Ending_FadeSky
	ld hl, DialogueEnding1_B12
	call ShowDialogue_B12
	ld hl, DialogueEnding2_B12
	call ShowDialogue_B12
	ld hl, DialogueEnding3_B12
	call ShowDialogue_B12
	ld hl, DialogueEnding4_B12
	call ShowDialogue_B12
	ld hl, DialogueEnding5_B12
	call ShowDialogue_B12
	ld hl, DialogueEnding6_B12
	call ShowDialogue_B12
	call CloseTextBox
	call GameMode_FadeToPicture
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueEndingAlis
	call ShowNarrativeText
	ld a, $05
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueEndingOdin
	call ShowNarrativeText
	ld a, $06
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueEndingNoah
	call ShowNarrativeText
	ld a, $04
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueEndingMyau
	call ShowNarrativeText
	ld a, $03
	call GameMode_FadeToNarrativePicture
	ld hl, DialogueEndingEnd1
	call ShowNarrativeText
	ld hl, DialogueEndingEnd2
	call ShowNarrativeText
	call FadeOut2
	ld hl, $FFFF
	ld (hl), :Bank31
	ld hl, Palette_Ending_B31
	ld de, $C240
	ld bc, $0011
	ldir
	ld hl, Tiles_Ending_B31
	ld de, $4000
	call LoadTiles4BitRLE
	ld hl, $FFFF
	ld (hl), :Bank24
	ld hl, $D000
	ld de, $D001
	ld bc, $0600
	ld (hl), $00
	ldir
	ld hl, Tilemap_Ending_B24
	ld de, $D0D4
	ld bc, $1316
	call LoadTilemapRawRect
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	call VIntDelay
	
	; Dungeon credits
	ld hl, $3DF7
	ld (Dungeon_position), hl
	xor a
	ld (Dungeon_direction), a
	call Dungeon_Pitfall
	ld hl, $FFFF
	ld (hl), :Bank15
	ld hl, Tiles_CreditsFont_B15
	ld de, $5820
	call LoadTiles4BitRLE
	ld a, $01
	ld ($C2F5), a
	ld a, $91
	ld (Sound_index), a
	ld hl, EndingMovementData_B15
-:
	ld a, :Bank15
	ld ($FFFF), a
	ld a, (hl)
	cp $FF ; FF = End
	jr z, ++
	cp $0F ; F = pause
	jr nz, +
	ld b, $B4
	call VIntDelay2
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
	ld (Sound_index), a
	xor a
	ld ($C2F5), a
	ld b, $B4
	call VIntDelay2
	ld a, $02 ; GameMode_LoadTitleScreen
	ld (Game_mode), a
	ret

GameMode_FadeToPicture:
	call FadeOut2
	ld hl, $FFFF
	ld (hl), :Bank16
	ld hl, TilesFont_B16
	ld de, $5800
	call LoadTiles4BitRLE
	ld hl, TilesExtraFont_B16
	ld de, $7E00
	call LoadTiles4BitRLE
	ld hl, $FFFF
	ld (hl), :Bank24
	ld hl, Target_palette
	ld de, Target_palette+1
	ld (hl), $00
	ld bc, $000F
	ldir
	ld hl, Palette_Frame_B24
	ld bc, $0010
	ldir
	ld hl, Tiles_Frame_B24
	ld de, $4000
	call LoadTiles4BitRLE
	ld hl, Tilemap_Frame_B24
	call DecompressTilemapData
	xor a
	ld (V_scroll), a
	ld (H_scroll), a
	ld (Text_box_open_flag), a
	ld a, $0C
	call WaitForVInt
	jp ClearSpriteTableFadeIn

GameMode_FadeToNarrativePicture:
	push	af
	call	FadeOut
	pop	af
	ld	l, a
	add	a, a
	add	a, a
	add	a, l
	ld	l, a
	ld	h, $00
	ld	de, NarrativeGraphicsTable
	add	hl, de
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	push	hl
	ex   de, hl
	ld	de, $C240
	ld	bc, $0010
	ldir
	ld	de, $6000
	call	LoadTiles4BitRLE
	ld	hl, $FFFF
	ld	(hl), :Bank24
	pop	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	de, $78CC
	ld	bc, $0C28
	di
	call	OutputTilemapRawDataBox
	ld	de, $7C00
	ld	bc, $0100
	ld	hl, $0800
	call	FillVRAMWithHL
	ei
	jp	FadeIn


; =================================================================
NarrativeGraphicsTable:
.db	:Bank31
.dw	Graphics_IntroNero1_B31, Tilemap_IntroNero1_B31

.db	:Bank30
.dw	Graphics_IntroNero2_B30, Tilemap_IntroNero2_B30

.db	:Bank30
.dw	Graphics_IntroAlis_B30, Tilemap_IntroAlis_B30

.db	:Bank30
.dw	Graphics_NarrativeAlis_B30, Tilemap_NarrativeAlis_B30

.db	:Bank31
.dw	Graphics_NarrativeMyau_B31, Tilemap_NarrativeMyau_B31

.db	:Bank29
.dw	Graphics_NarrativeOdin_B29, Tilemap_NarrativeOdin_B29

.db	:Bank18
.dw	Graphics_NarrativeNoah_B18, Tilemap_NarrativeNoah_B18

.db	:Bank30
.dw	Graphics_MyauWings1_B30, Tilemap_MyauWings1_B30

.db	:Bank30
.dw	Graphics_MyauWings2_B30, Tilemap_MyauWings2_B30
; =================================================================


Scene_DoRoomScript:
	; Exit if room is 0
	ld	a, (Room_index)
	or	a
	jp	z, LABEL_1BE1
	ld	de, SceneRoomScriptTable-2
	call	Scene_GetPtrAndJump
	ld	a, (Scene_type)
	or	a
	jp	nz, CloseTextBox
	call	CloseTextBox
	jp	LABEL_15DC


Scene_RoomScriptEnd:
	pop	hl
	jp	WaitForButton1Or2

Scene_GetPtrAndJump:
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	jp	(hl)


; =================================================================
SceneRoomScriptTable:
.dw	SceneRoom_Suelo	; 1
.dw	SceneRoom_Nekise	; 2
.dw	SceneRoom_CamineetMan1	; 3
.dw	SceneRoom_CamineetMan2	; 4
.dw	SceneRoom_CamineetMan3	; 5
.dw	SceneRoom_CamineetMan4	; 6
.dw	SceneRoom_CamineetMan5	; 7
.dw	SceneRoom_CamineetAlgolMan	; 8
.dw	SceneRoom_CamineetGuard1	; 9
.dw	SceneRoom_CamineetGuard2	; $A
.dw	SceneRoom_CamineetGuard3	; $B
.dw	SceneRoom_CamineetGuard4	; $C
.dw	SceneRoom_ParolitWoman1	; $D
.dw	SceneRoom_ParolitMan1	; $E
.dw	SceneRoom_ParolitMan2	; $F
.dw	SceneRoom_ParolitMan3	; $10
.dw	SceneRoom_ParolitMan4	; $11
.dw	SceneRoom_ParolitMan5	; $12
.dw	SceneRoom_AirStripGuard	; $13
.dw	SceneRoom_AirStripGuard	; $14
.dw	SceneRoom_ShionMan1	; $15
.dw	SceneRoom_MadDoctor	; $16
.dw	SceneRoom_PalmaLuggageHandler1	; $17
.dw	SceneRoom_PalmaLuggageHandler2	; $18
.dw	SceneRoom_PalmaLuggageHandler3	; $19
.dw	SceneRoom_AirStripGuard2	; $1A
.dw	SceneRoom_RoadGuard1	; $1B
.dw	SceneRoom_RoadGuard2	; $1C
.dw	SceneRoom_PassportOffice	; $1D
.dw	SceneRoom_ShionMan2	; $1E
.dw	SceneRoom_ShionMan3	; $1F
.dw	SceneRoom_ShionMan4	; $20
.dw	SceneRoom_ShionMan5	; $21
.dw	SceneRoom_ShionMan6	; $22
.dw	SceneRoom_ShionMan7	; $23
.dw	SceneRoom_ShionMan8	; $24
.dw	SceneRoom_ShionMan9	; $25
.dw	SceneRoom_EppiMan1	; $26
.dw	SceneRoom_EppiMan2	; $27
.dw	SceneRoom_EppiMan3	; $28
.dw	SceneRoom_EppiMan4	; $29
.dw	SceneRoom_EppiMan5	; $2A
.dw	SceneRoom_EppiMan6	; $2B
.dw	SceneRoom_PaseoLuggageHandler1	; $2C
.dw	SceneRoom_PaseoLuggageHandler2	; $2D
.dw	SceneRoom_PaseoSpaceport3	; $2E
.dw	SceneRoom_Paseo1	; $2F
.dw	SceneRoom_Paseo2	; $30
.dw	SceneRoom_Paseo3	; $31
.dw	SceneRoom_Paseo4	; $32
.dw	SceneRoom_Paseo5	; $33
.dw	SceneRoom_Paseo6	; $34
.dw	SceneRoom_Paseo7	; $35
.dw	SceneRoom_MyauSeller	; $36
.dw	SceneRoom_GovernorGeneral	; $37
.dw	SceneRoom_MansionGuard1	; $38
.dw	SceneRoom_GuestHouseLady	; $39
.dw	SceneRoom_BartevoVillager1	; $3A
.dw	SceneRoom_BartevoVillager2	; $3B
.dw	SceneRoom_GothicWoods1	; $3C
.dw	SceneRoom_GothicWoods2	; $3D
.dw	SceneRoom_DrLuveno	; $3E
.dw	SceneRoom_Room3F	; $3F
.dw	SceneRoom_LoreVillager1	; $40
.dw	SceneRoom_LoreVillager2	; $41
.dw	SceneRoom_LoreVillager3	; $42
.dw	SceneRoom_LoreVillager4	; $43
.dw	SceneRoom_LoreVillager5	; $44
.dw	SceneRoom_AbionVillager1	; $45
.dw	SceneRoom_AbionVillager2	; $46
.dw	SceneRoom_AbionVillager3	; $47
.dw	SceneRoom_AbionVillager4	; $48
.dw	SceneRoom_AbionVillager5	; $49
.dw	SceneRoom_UzoVillager1	; $4A
.dw	SceneRoom_UzoVillager2	; $4B
.dw	SceneRoom_UzoVillager3	; $4C
.dw	SceneRoom_UzoVillager4	; $4D
.dw	SceneRoom_UzoVillager5	; $4E
.dw	SceneRoom_UzoVillager6	; $4F
.dw	SceneRoom_CasbaVillager1	; $50
.dw	SceneRoom_CasbaVillager2	; $51
.dw	SceneRoom_AeroCastle1	; $52
.dw	SceneRoom_CasbaVillager3	; $53
.dw	SceneRoom_CasbaVillager4	; $54
.dw	SceneRoom_CasbaVillager5	; $55
.dw	SceneRoom_Drasgo1	; $56
.dw	SceneRoom_Drasgo2	; $57
.dw	SceneRoom_Drasgo3	; $58
.dw	SceneRoom_Drasgo4	; $59
.dw	SceneRoom_Drasgo5	; $5A
.dw	SceneRoom_DrasgoCave1	; $5B
.dw	SceneRoom_DrasgoCave2	; $5C
.dw	SceneRoom_GasShieldSeller	; $5D
.dw	SceneRoom_Skure1	; $5E
.dw	SceneRoom_Skure2	; $5F
.dw	SceneRoom_Skure3	; $60
.dw	SceneRoom_Skure4	; $61
.dw	SceneRoom_Skure5	; $62
.dw	SceneRoom_Skure6	; $63
.dw	SceneRoom_Skure7	; $64
.dw	SceneRoom_Skure8	; $65
.dw	SceneRoom_Skure9	; $66
.dw	SceneRoom_Skure10	; $67
.dw	SceneRoom_HonestDezorian1	; $68
.dw	SceneRoom_HonestDezorian2	; $69
.dw	SceneRoom_HonestDezorian3	; $6A
.dw	SceneRoom_HonestDezorian4	; $6B
.dw	SceneRoom_HonestDezorian5	; $6C
.dw	SceneRoom_HonestDezorian6	; $6D
.dw	SceneRoom_DishonestDezorian1	; $6E
.dw	SceneRoom_DishonestDezorian2	; $6F
.dw	SceneRoom_DishonestDezorian3	; $70
.dw	SceneRoom_DishonestDezorian4	; $71
.dw	SceneRoom_DishonestDezorian5	; $72
.dw	SceneRoom_DishonestDezorian6	; $73
.dw	SceneRoom_SopiaVillageChief	; $74
.dw	SceneRoom_Miki	; $75
.dw	SceneRoom_Sopia1	; $76
.dw	SceneRoom_Sopia2	; $77
.dw	SceneRoom_Sopia3	; $78
.dw	SceneRoom_Sopia4	; $79
.dw	SceneRoom_AeroCastle2	; $7A
.dw	SceneRoom_AeroCastle3	; $7B
.dw	SceneRoom_ShortCakeShop	; $7C
.dw	SceneRoom_MahalCaveMotavianPeasant	; $7D
.dw	SceneRoom_Noah	; $7E
.dw	SceneRoom_LuvenoAssistant	; $7F
.dw	SceneRoom_Room80	; $80
.dw	SceneRoom_LuvenoPrison	; $81
.dw	SceneRoom_TriadaPrisonGuard1	; $82
.dw	SceneRoom_TriadaPrisoner1	; $83
.dw	SceneRoom_TriadaPrisoner2	; $84
.dw	SceneRoom_TriadaPrisoner3	; $85
.dw	SceneRoom_TriadaPrisoner4	; $86
.dw	SceneRoom_TriadaPrisoner5	; $87
.dw	SceneRoom_TriadaPrisoner6	; $88
.dw	SceneRoom_MedusaTower1	; $89
.dw	SceneRoom_MedusaTower2	; $8A
.dw	SceneRoom_MedusaTower3	; $8B
.dw	SceneRoom_BartevoCave	; $8C
.dw	SceneRoom_AbionTower	; $8D
.dw	SceneRoom_Room8E	; $8E
.dw	SceneRoom_Room8F	; $8F
.dw	SceneRoom_DrasgoCave1	; $90
.dw	SceneRoom_DrasgoCave2	; $91
.dw	SceneRoom_GasShieldSeller	; $92
.dw	SceneRoom_TriadaGuard	; $93
.dw	SceneRoom_Room94	; $94
.dw	SceneRoom_Room95	; $95
.dw	SceneRoom_Room96	; $96
.dw	SceneRoom_Room97	; $97
.dw	SceneRoom_Room98	; $98
.dw	SceneRoom_Room99	; $99
.dw	SceneRoom_Room9A	; $9A
.dw	SceneRoom_GiftCheck	; $9B
.dw	SceneRoom_TorchBearer	; $9C
.dw	SceneRoom_Tarzimal	; $9D
.dw	SceneRoom_ShadowWarrior	; $9E
.dw	SceneRoom_Lassic	; $9F
.dw	SceneRoom_EppiWoodsNoCompass	; $A0
.dw	SceneRoom_HapsbyScrapHeap	; $A1
.dw	SceneRoom_HapsbyScrapHeap	; $A2
.dw	SceneRoom_OdinStone	; $A3
.dw	SceneRoom_CoronaTowerDezorian1	; $A4
.dw	SceneRoom_GuaronMorgue	; $A5
.dw	SceneRoom_CoronaTowerDishonestDezorian	; $A6
.dw	SceneRoom_RoomA7	; $A7
.dw	SceneRoom_BayaMalayPrisoner	; $A8
.dw	SceneRoom_RoomA9	; $A9
.dw	SceneRoom_LuvenoGuard	; $AA
.dw	SceneRoom_DarkForce	; $AB
.dw	SceneRoom_RoomAC	; $AC
.dw	SceneRoom_RoomAD	; $AD
.dw	SceneRoom_RoomAE	; $AE
.dw	SceneRoom_HapsbyScrapHeap	; $AF
.dw	SceneRoom_HapsbyScrapHeap	; $B0
.dw	SceneRoom_RoomB1	; $B1
.dw	SceneRoom_RoomB2	; $B2
.dw	SceneRoom_FlightToMotavia	; $B3
.dw	SceneRoom_FlightToPalma	; $B4
.dw	SceneRoom_HapsbyTravel	; $B5
.dw	SceneRoom_HapsbyScrapHeap	; $B6
; =================================================================



SceneRoom_Suelo:
	ld hl, Dialogue_flags+DialogueFlag_VisitedSuelo	; Visisted Suelo flag
	ld a, (hl)
	or a
	jr nz, +
	; first time
	ld (hl), $01
	ld hl, $0002
	call ShowDialogue_B2
+:
	ld hl, $0006
	call ShowDialogue_B2
	ld a, $C1
	ld (Sound_index), a
	jp LABEL_2A6D

SceneRoom_Nekise:
	ld a, (Dialogue_flags+DialogueFlag_PotFromNekise)	; Visisted Nekise flag
	or a
	jr nz, +
	; first time
	ld hl, $0008
	call ShowDialogue_B2
	ld a, ItemID_LaconiaPot
	ld (CurrentItem), a
	call Inventory_AddItem
	ld a, $38
	call Inventory_FindItem
	jr nz, +
	ld a, $01
	ld (Dialogue_flags+DialogueFlag_PotFromNekise), a
+:
	ld hl, $0010
	jp ShowDialogue_B2

SceneRoom_CamineetMan1:
	ld	hl, $12
	jp	ShowDialogue_B2

SceneRoom_CamineetMan2:
	ld	hl, $14
	jp	ShowDialogue_B2

SceneRoom_CamineetMan3:
	ld	hl, $16
	jp	ShowDialogue_B2

SceneRoom_CamineetMan4:
	ld	hl, $18
	jp	ShowDialogue_B2

SceneRoom_CamineetMan5:
	ld	hl, $1A
	jp	ShowDialogue_B2

SceneRoom_CamineetAlgolMan:
	ld hl, $0062
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0060
	jr z, +
	ld hl, $0003
	ld (NumberToShowInText), hl
	ld hl, $0064
+:
	jp ShowDialogue_B2

SceneRoom_CamineetGuard1:
	ld	hl, $1C
	jp	ShowDialogue_B2

SceneRoom_CamineetGuard2:
	ld	hl, $1E
	jp	ShowDialogue_B2

SceneRoom_CamineetGuard3:
	ld a, ItemID_RoadPass
	call Inventory_FindItem
	jr z, +
	ld hl, $0020
	jp ShowDialogue_B2

SceneRoom_CamineetGuard4:
	ld a, ItemID_RoadPass
	call Inventory_FindItem
	jr z, +
	ld hl, $0022
	jp ShowDialogue_B2

+:
	ld hl, $0024
	call ShowDialogue_B2
	ld a, (Location_index)
	rrca
	dec a
	and $03
	ld ($C2E9), a
	ret

SceneRoom_ParolitWoman1:
	ld	hl, $26
	jp	ShowDialogue_B2

SceneRoom_ParolitMan1:
	ld	hl, $28
	jp	ShowDialogue_B2

SceneRoom_ParolitMan2:
	ld	hl, $2A
	jp	ShowDialogue_B2

SceneRoom_ParolitMan3:
	ld	hl, $2E
	jp	ShowDialogue_B2

SceneRoom_ParolitMan4:
	ld	hl, $30
	jp	ShowDialogue_B2

SceneRoom_ParolitMan5:
	ld	hl, $32
	jp	ShowDialogue_B2

SceneRoom_AirStripGuard:
	ld a, (Dialogue_flags+DialogueFlag_LuvenoState)	; Luveno state
	cp $07
	jp nc, SpaceportsClosed	; if we have Hapsby, jump
	ld hl, $0070
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0020
	jr nz, +
	ld a, $34
	call Inventory_FindItem
	ld hl, $00CE
	jr nz, +
	ld a, $06
	ld ($C2E9), a
	ld hl, $0024
+:
	jp ShowDialogue_B2

SceneRoom_ShionMan1:
	ld	hl, $286
	jp	ShowDialogue_B2

SceneRoom_MadDoctor:
	ld a, EnemyID_DrMad
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld a, (Myau_stats)
	or a
	jr z, +
	ld hl, $0296
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	; Kill Myau
	ld a, $AE
	ld (Sound_index), a
	ld a, $01
	ld (CurrentCharacter), a
	ld hl, DialogueBattlePlayerDied_B12
	call ShowDialogue_B12
	ld hl, $0000
	ld (Myau_stats), hl
	ld hl, $0298
	jr ++

+:
	ld hl, $029A
++:
	call ShowDialogue_B2
	call CloseTextBox
	ld a, (Party_curr_num)
	or a
	jr z, +	; We don't have Myau yet
	ld a, ItemID_LaconiaPot
	call Inventory_FindItem
	jr z, +
	ld hl, $C518
	ld (Dungeon_obj_flag_addr), hl
	ld a, ItemID_LaconiaPot
	ld (Dungeon_item_index), a
+:
	jp LABEL_5389

SceneRoom_PalmaLuggageHandler1:
	ld	hl, $6A
	jp	ShowDialogue_B2

SceneRoom_PalmaLuggageHandler2:
	ld	hl, $6C
	jp	ShowDialogue_B2

SceneRoom_PalmaLuggageHandler3:
	ld	hl, $6E
	jp	ShowDialogue_B2

SceneRoom_AirStripGuard2:
	ld a, (Dialogue_flags+DialogueFlag_LuvenoState)	; Luveno state
	cp $07
	jr nc, SpaceportsClosed		; jump if we have Hapsby
	ld hl, $0070
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $0020
	jp ShowDialogue_B2

+:
	ld a, ItemID_Passport
	call Inventory_FindItem
	jr z, +
	ld hl, $00CE
	jp ShowDialogue_B2

+:
	ld hl, $0024
	call ShowDialogue_B2
	ld a, (V_location)
	cp $60
	ld hl, LABEL_4AA3
	jr nz, +
	ld hl, LABEL_4AA6
+:
	call LABEL_787B
	ret

SpaceportsClosed:
	ld hl, $019E
	call ShowDialogue_B2
	ld a, ItemID_Passport
	call Inventory_FindItem
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

SceneRoom_RoadGuard1:
	ld a, ItemID_RoadPass
	call Inventory_FindItem
	ld hl, $0020
	jr nz, +
	ld a, $04
	ld ($C2E9), a
	ld hl, $0024
+:
	jp ShowDialogue_B2

SceneRoom_RoadGuard2:
	ld a, ItemID_RoadPass
	call Inventory_FindItem
	ld hl, $0022
	jr nz, +
	ld a, $05
	ld ($C2E9), a
	ld hl, $0024
+:
	jp ShowDialogue_B2

SceneRoom_PassportOffice:
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
	ld (NumberToShowInText), hl
	ld hl, $0078
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $007C
	jp ShowDialogue_B2

+:
	ld de, 100
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, DialogueHospitalNotEnoughMoney_B12
	jp ShowDialogue_B12

+:
	ld (Current_money), hl
	ld hl, $007A
	call ShowDialogue_B2
	ld a, ItemID_Passport
	ld (CurrentItem), a
	call Inventory_FindItem
	ret z
	jp Inventory_AddItem

SceneRoom_ShionMan2:
	ld a, (Party_curr_num)
	or a
	; we don't have Myau yet
	ld hl, $0034
	jr z, +
	ld hl, $003A
+:
	jp ShowDialogue_B2

SceneRoom_ShionMan3:
	ld a, (Party_curr_num)
	or a
	ld hl, $003C
	jr z, +
	ld hl, $0040
+:
	jp ShowDialogue_B2

SceneRoom_ShionMan4:
	ld	hl, $42
	jp	ShowDialogue_B2

SceneRoom_ShionMan5:
	ld	hl, $44
	jp	ShowDialogue_B2

SceneRoom_ShionMan6:
	ld	hl, $46
	jp	ShowDialogue_B2

SceneRoom_ShionMan7:
	ld	hl, $48
	jp	ShowDialogue_B2

SceneRoom_ShionMan8:
	ld	hl, $4A
	jp	ShowDialogue_B2

SceneRoom_ShionMan9:
	ld	hl, $4C
	jp	ShowDialogue_B2

SceneRoom_EppiMan1:
	ld	hl, $4E
	jp	ShowDialogue_B2

SceneRoom_EppiMan2:
	ld	hl, $50
	jp	ShowDialogue_B2

SceneRoom_EppiMan3:
	ld	hl, $52
	jp	ShowDialogue_B2

SceneRoom_EppiMan4:
	ld	hl, $54
	jp	ShowDialogue_B2

SceneRoom_EppiMan5:
	ld hl, $0056
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0060
	jr nz, ++
	ld a, ItemID_DungeonKey
	call Inventory_FindItem
	jr z, +
	ld hl, Event_flags+4
	ld (hl), $00		; unlock Dungeon Key
+:
	ld hl, $0058
++:
	jp ShowDialogue_B2

SceneRoom_EppiMan6:
	ld hl, $005C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0060
	jr z, +
	ld hl, $005E
+:
	jp ShowDialogue_B2

SceneRoom_PaseoLuggageHandler1:
	ld	hl, $80
	jp	ShowDialogue_B2

SceneRoom_PaseoLuggageHandler2:
	ld	hl, $82
	jp	ShowDialogue_B2

SceneRoom_PaseoSpaceport3:
	ld	hl, $84
	jp	ShowDialogue_B2

SceneRoom_Paseo1:
	ld	hl, $86
	jp	ShowDialogue_B2

SceneRoom_Paseo2:
	ld	hl, $88
	jp	ShowDialogue_B2

SceneRoom_Paseo3:
	ld	hl, $8A
	jp	ShowDialogue_B2

SceneRoom_Paseo4:
	ld	hl, $8C
	jp	ShowDialogue_B2

SceneRoom_Paseo5:
	ld	hl, $8E
	jp	ShowDialogue_B2

SceneRoom_Paseo6:
	ld	hl, $90
	jp	ShowDialogue_B2

SceneRoom_Paseo7:
	ld	hl, $288
	jp	ShowDialogue_B2

SceneRoom_MyauSeller:
	ld a, (Party_curr_num)
	or a
	jr z, +
	ld hl, $028A
	jp ShowDialogue_B2

+:
	ld hl, $000A
	ld (NumberToShowInText), hl
	ld hl, $0092
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld hl, $0094
	jp ShowDialogue_B2

+:
	ld a, ItemID_LaconiaPot
	call Inventory_FindItem
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
	call CloseTextBox
	pop hl
	ld iy, Myau_stats
	call UnlockCharacter
	ld a, $01
	ld (Party_curr_num), a
	ld a, ItemID_Alsulin
	ld (CurrentItem), a
	call Inventory_AddItem
	jp MyauIntro

+:
	ld hl, $007C
	jp ShowDialogue_B2

SceneRoom_GovernorGeneral:
	ld a, (Dialogue_flags+DialogueFlag_BeatLassic)
	or a
	jr z, +
	ld hl, $02A6
	call ShowDialogue_B2
	call CloseTextBox
	pop hl
	ld hl, $22E6
	ld (Dungeon_position), hl
	xor a
	ld (Dungeon_direction), a
	ld hl, Game_mode
	ld (hl), $0B ; GameMode_Dungeon
	call Dungeon_Pitfall
	ld a, $85
	jp Map_CheckMusic

+:
	ld a, $35
	call LoadDialogueSprite
	call BuildSprites
	ld a, (Party_curr_num)
	cp $03
	jr nc, +
	ld a, ItemID_Letter
	call Inventory_FindItem
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
	ld (CurrentItem), a
	call Inventory_AddItem
	pop bc
	ld a, ItemID_Letter
	call Inventory_FindItem
	ret nz
	ld hl, $029C
	call ShowDialogue_B2
	call FadeOut2
	call CloseTextBox
	ld a, $20
	ld (Scene_type), a
	call Scene_LoadData
	ld a, $D0
	ld (Sprite_table), a
	ld a, $0C
	call WaitForVInt
	ld hl, Palette_GovernorGeneral
	ld de, Target_palette
	ld bc, $0008
	ldir
	call FadeIn2
	ld hl, $02A0
	call ShowDialogue_B2
	call CloseTextBox
	ld a, $A0
	ld (Sound_index), a
	call VIntDelay
	ld a, EnemyID_Saccubus
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld a, (Alis_stats)	; get status
	push af
	ld a, (Myau_stats)
	push af
	ld a, (Odin_stats)
	push af
	call Dungeon_EnterBattle
	pop af
	ld (Odin_stats), a
	pop af
	ld (Myau_stats), a
	pop af
	ld (Char_stats), a
	call FadeOut2
	call Scene_LoadData
	ld a, $D0
	ld (Sprite_table), a
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld hl, $02A2
	call ShowDialogue_B2
	call FadeOut2
	ld a, $1D
	ld (Scene_type), a
	call Scene_LoadData
	call LABEL_2A6D
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $35
	call LoadDialogueSprite
	call BuildSprites
	ld hl, $00AA
	jp ShowDialogue_B2

Palette_GovernorGeneral:
.db	$00, $00, $3F, $00, $00, $00, $00
.db $00

SceneRoom_MansionGuard1:
	ld	hl, $B4
	jp	ShowDialogue_B2

SceneRoom_GuestHouseLady:
	ld hl, $00B6
	call ShowDialogue_B2
	call FadeOut2
	call CloseTextBox
	ld a, $A0
	ld (Sound_index), a
	call VIntDelay
	call LABEL_2A6D
	ld a, $C1
	ld (Sound_index), a
	call FadeIn2
	ld hl, $00B8
	jp ShowDialogue_B2

SceneRoom_BartevoVillager1:
	ld	hl, $102
	jp	ShowDialogue_B2

SceneRoom_BartevoVillager2:
	ld	hl, $106
	jp	ShowDialogue_B2

SceneRoom_GothicWoods1:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00C2
	jp ShowDialogue_B2

+:
	ld a, ItemID_Cola
	call Inventory_FindItem
	jr nz, +
	push bc
	call Inventory_RemoveItem2
	pop bc
	ld hl, $00BC
	jp ShowDialogue_B2

+:
	ld hl, $020E
	jp ShowDialogue_B2

SceneRoom_GothicWoods2:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00C2
	jp ShowDialogue_B2

+:
	ld a, ItemID_Cola
	call Inventory_FindItem
	jr nz, +
	call Inventory_RemoveItem2
	ld hl, $00C4
	jp ShowDialogue_B2

+:
	ld hl, $020E
	jp ShowDialogue_B2

SceneRoom_DrLuveno:
	ld a, (Dialogue_flags+DialogueFlag_LuvenoState)
	or a
	jp z, Scene_RoomScriptEnd
	ld a, $34
	call LoadDialogueSprite
	call BuildSprites
	ld a, (Dialogue_flags+DialogueFlag_LuvenoState)
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
	ld (NumberToShowInText), hl
	ld hl, $028C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00DA
	jp ShowDialogue_B2

+:
	ld de, 1200
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, $00D0
	jp ShowDialogue_B2

+:
	ld (Current_money), hl
	ld a, $03
	ld (Dialogue_flags+DialogueFlag_LuvenoState), a
	ld hl, $0290
	jp ShowDialogue_B2

++:
	cp $05
	jr nc, +
	inc a
	ld (Dialogue_flags+DialogueFlag_LuvenoState), a
	ld hl, $0292
	jp ShowDialogue_B2

+:
	cp $06
	jr nc, +
	inc a
	ld (Dialogue_flags+DialogueFlag_LuvenoState), a
	ld hl, $00D2
	call ShowDialogue_B2
	ld a, $32
	call Inventory_FindItem
	jr z, ++
	ld hl, $00D6
	call ShowDialogue_B2
+:
	ld a, ItemID_Hapsby
	call Inventory_FindItem
	jr z, ++
	ld hl, $0104
	jp ShowDialogue_B2

++:
	ld a, $07
	ld (Dialogue_flags+DialogueFlag_LuvenoState), a
	ld hl, $0294
	jp ShowDialogue_B2

SceneRoom_Room3F:
	ld hl, Dialogue_flags+DialogueFlag_LuvenoState
	ld a, (hl)
	cp $02
	jp c, Scene_RoomScriptEnd
	ld a, $10
	call LoadDialogueSprite
	call BuildSprites
	ld hl, $00DC
	jp ShowDialogue_B2

SceneRoom_LoreVillager1:
	ld	hl, $118
	jp	ShowDialogue_B2

SceneRoom_LoreVillager2:
	ld	hl, $10E
	jp	ShowDialogue_B2

SceneRoom_LoreVillager3:
	ld	hl, $112
	jp	ShowDialogue_B2

SceneRoom_LoreVillager4:
	ld hl, $0114
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0116
	jr nz, +
	ld hl, $013C
+:
	jp ShowDialogue_B2

SceneRoom_LoreVillager5:
	ld	hl, $10C
	jp	ShowDialogue_B2

SceneRoom_AbionVillager1:
	ld	hl, $11C
	jp	ShowDialogue_B2

SceneRoom_AbionVillager2:
	ld	hl, $11E
	jp	ShowDialogue_B2

SceneRoom_AbionVillager3:
	ld	hl, $120
	jp	ShowDialogue_B2

SceneRoom_AbionVillager4:
	ld	hl, $126
	jp	ShowDialogue_B2

SceneRoom_AbionVillager5:
	ld	hl, $128
	jp	ShowDialogue_B2

SceneRoom_UzoVillager1:
	ld	hl, $12E
	jp	ShowDialogue_B2

SceneRoom_UzoVillager2:
	ld	hl, $130
	jp	ShowDialogue_B2

SceneRoom_UzoVillager3:
	ld	hl, $132
	jp	ShowDialogue_B2

SceneRoom_UzoVillager4:
	ld	hl, $134
	jp	ShowDialogue_B2

SceneRoom_UzoVillager5:
	ld hl, $013A
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $013C
	jr z, ++
	ld a, (Dialogue_flags+DialogueFlag_FluteUnhidden)
	or a
	jr nz, +
	ld a, $01
	ld (Dialogue_flags+DialogueFlag_FluteUnhidden), a
+:
	ld hl, $013E
++:
	jp ShowDialogue_B2

SceneRoom_UzoVillager6:
	ld	hl, $136
	jp	ShowDialogue_B2

SceneRoom_CasbaVillager1:
	ld	hl, $166
	jp	ShowDialogue_B2

SceneRoom_CasbaVillager2:
	ld	hl, $168
	jp	ShowDialogue_B2

SceneRoom_AeroCastle1:
	ld	hl, $16A
	jp	ShowDialogue_B2

SceneRoom_CasbaVillager3:
	ld	hl, $16C
	jp	ShowDialogue_B2

SceneRoom_CasbaVillager4:
	ld	hl, $170
	jp	ShowDialogue_B2

SceneRoom_CasbaVillager5:
	ld hl, $0172
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $017C
	jr nz, +
	ld a, $01
	ld (Dialogue_flags+DialogueFlag_HovercraftUnhidden), a
	ld hl, $0174
+:
	jp ShowDialogue_B2

SceneRoom_Drasgo1:
	ld	hl, $17E
	jp	ShowDialogue_B2

SceneRoom_Drasgo2:
	ld	hl, $180
	jp	ShowDialogue_B2

SceneRoom_Drasgo3:
	ld	hl, $184
	jp	ShowDialogue_B2

SceneRoom_Drasgo4:
	ld	hl, $186
	jp	ShowDialogue_B2

SceneRoom_Drasgo5:
	ld	hl, $188
	jp	ShowDialogue_B2

SceneRoom_DrasgoCave1:
	ld	hl, $18C
	jp	ShowDialogue_B2

SceneRoom_DrasgoCave2:
	ld	hl, $190
	jp	ShowDialogue_B2

SceneRoom_GasShieldSeller:
	ld hl, 1000
	ld (NumberToShowInText), hl
	ld hl, $0194
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $019C
	jp ShowDialogue_B2

+:
	ld de, 1000
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
	ld (CurrentItem), a
	call Inventory_FindItem
	ret z
	jp Inventory_AddItem

SceneRoom_Skure1:
	ld	hl, $1A2
	jp	ShowDialogue_B2

SceneRoom_Skure2:
	ld	hl, $1A4
	jp	ShowDialogue_B2

SceneRoom_Skure3:
	ld	hl, $1A6
	jp	ShowDialogue_B2

SceneRoom_Skure4:
	ld	hl, $1AA
	jp	ShowDialogue_B2

SceneRoom_Skure5:
	ld	hl, $1B2
	jp	ShowDialogue_B2

SceneRoom_Skure6:
	ld	hl, $1B8
	jp	ShowDialogue_B2

SceneRoom_Skure7:
	ld	hl, $1BA
	jp	ShowDialogue_B2

SceneRoom_Skure8:
	ld	hl, $1BC
	jp	ShowDialogue_B2

SceneRoom_Skure9:
	ld	hl, $1BE
	jp	ShowDialogue_B2

SceneRoom_Skure10:
	ld	hl, $1C4
	jp	ShowDialogue_B2

SceneRoom_HonestDezorian1:
	ld	hl, $1C8
	jp	ShowDialogue_B2

SceneRoom_HonestDezorian2:
	ld	hl, $1CA
	jp	ShowDialogue_B2

SceneRoom_HonestDezorian3:
	ld	hl, $1CC
	jp	ShowDialogue_B2

SceneRoom_HonestDezorian4:
	ld	hl, $1D0
	jp	ShowDialogue_B2

SceneRoom_HonestDezorian5:
	ld hl, $01D6
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $01DA
	jr z, +
	ld hl, $01D8
+:
	jp ShowDialogue_B2

SceneRoom_HonestDezorian6:
	ld	hl, $1DC
	jp	ShowDialogue_B2

SceneRoom_DishonestDezorian1:
	ld	hl, $1DE
	jp	ShowDialogue_B2

SceneRoom_DishonestDezorian2:
	ld hl, $000A
	ld (NumberToShowInText), hl
	ld hl, $01E0
	jp ShowDialogue_B2

SceneRoom_DishonestDezorian3:
	ld	hl, $1E2
	jp	ShowDialogue_B2

SceneRoom_DishonestDezorian4:
	ld	hl, $1E4
	jp	ShowDialogue_B2

SceneRoom_DishonestDezorian5:
	ld	hl, $1E6
	jp	ShowDialogue_B2

SceneRoom_DishonestDezorian6:
	ld	hl, $1E8
	jp	ShowDialogue_B2

SceneRoom_SopiaVillageChief:
	ld hl, 400
	ld (NumberToShowInText), hl
	ld hl, $01EA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $01F0
	jp ShowDialogue_B2

+:
	ld de, 400
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, $01F2
	jp ShowDialogue_B2

+:
	ld (Current_money), hl
	ld a, $01
	ld (Dialogue_flags+DialogueFlag_MirrorShieldUnhidden), a
	ld hl, $01F4
	jp ShowDialogue_B2

SceneRoom_Miki:
	ld hl, $01FA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $01FC
	jr z, +
	ld hl, $01FE
+:
	jp ShowDialogue_B2

SceneRoom_Sopia1:
	ld	hl, $200
	jp	ShowDialogue_B2

SceneRoom_Sopia2:
	ld	hl, $202
	jp	ShowDialogue_B2

SceneRoom_Sopia3:
	ld hl, $0204
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0206
	jr z, +
	ld hl, $0208
+:
	jp ShowDialogue_B2

SceneRoom_Sopia4:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $020C
	jp ShowDialogue_B2

+:
	ld a, ItemID_Cola
	call Inventory_FindItem
	jr nz, +
	call Inventory_RemoveItem2
	ld hl, $020A
	jp ShowDialogue_B2

+:
	ld hl, $020E
	jp ShowDialogue_B2


SceneRoom_AeroCastle2:
	ld	hl, $210
	jp	ShowDialogue_B2

SceneRoom_AeroCastle3:
	ld	hl, $26A
	jp	ShowDialogue_B2

SceneRoom_ShortCakeShop:
	ld hl, 280
	ld (NumberToShowInText), hl
	ld hl, $024A
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, DialogueArmoryComeAgain_B12
	jp ShowDialogue_B12

+:
	ld de, 280
	ld hl, (Current_money)
	or a
	sbc hl, de
	jr nc, +
	ld hl, DialogueHospitalNotEnoughMoney_B12
	jp ShowDialogue_B12

+:
	ld a, (Inventory_curr_num)
	cp InventoryMaxNum
	jr c, +
	ld hl, DialogueArmoryCannotCarryAnyMore_B12
	jp ShowDialogue_B12

+:
	ld (Current_money), hl
	ld hl, $020A
	call ShowDialogue_B2
	ld a, ItemID_Cake
	ld (CurrentItem), a
	call Inventory_FindItem
	ret z
	jp Inventory_AddItem

SceneRoom_MahalCaveMotavianPeasant:
	ld a, EnemyID_NFarmer
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld a, (Party_curr_num)
	cp $03
	ld hl, $00AC
	jr nz, +
	ld hl, $00B2
+:
	jp ShowDialogue_B2

SceneRoom_Noah:
	ld a, (Party_curr_num)
	cp $03
	jp nc, Scene_RoomScriptEnd
	ld a, $3B
	call LoadDialogueSprite
	call BuildSprites
	ld hl, $00AE
	call ShowDialogue_B2
	ld a, ItemID_Letter
	call Inventory_FindItem
	ret nz
	call Inventory_RemoveItem2
	pop hl
	call CloseTextBox
	call WaitForButton1Or2
	ld a, $01
	ld (Dialogue_flags+DialogueFlag_NoahJoined), a
	ld iy, Noah_stats
	ld (iy+weapon), ItemID_WoodCane
	ld (iy+armor), ItemID_WhiteMantle
	call UnlockCharacter
	ld a, $03
	ld (Party_curr_num), a
	jp NoahIntro

SceneRoom_LuvenoAssistant:
	ld hl, Dialogue_flags+DialogueFlag_LuvenoState
	ld a, (hl)
	cp $02
	jp nc, Scene_RoomScriptEnd
	ld a, $10
	call LoadDialogueSprite
	call BuildSprites
	ld hl, Dialogue_flags+DialogueFlag_LuvenoState
	ld a, (hl)
	cp $01
	ld de, $00DC
	jr nz, +
	ld (hl), $02
	ld de, $00F6
+:
	ex de, hl
	jp ShowDialogue_B2

SceneRoom_Room80:
	ld	hl, $F8
	jp	ShowDialogue_B2

SceneRoom_LuvenoPrison:
	ld a, (Dialogue_flags+DialogueFlag_LuvenoState)
	or a
	jp nz, Scene_RoomScriptEnd
	ld a, $34
	call LoadDialogueSprite
	call BuildSprites
	ld hl, Dialogue_flags+DialogueFlag_LuvenoPrisonVisitCounter
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
	ld hl, Dialogue_flags+DialogueFlag_LuvenoState
	ld (hl), $01
	ld hl, $00E4
+:
	jp ShowDialogue_B2

SceneRoom_TriadaPrisonGuard1:
	ld a, EnemyID_RobotCop
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $00E6
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld a, ItemID_RoadPass
	call Inventory_FindItem
	jr nz, +
	ld hl, $0024
	jp ShowDialogue_B2

+:
	ld hl, $00E8
	call ShowDialogue_B2
	call CloseTextBox
	jp LABEL_5389

SceneRoom_TriadaPrisoner1:
	ld hl, $00BA
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00C2
	jp ShowDialogue_B2

+:
	ld a, ItemID_Cola
	call Inventory_FindItem
	jr nz, +
	call Inventory_RemoveItem2
	ld hl, $00EA
	jp ShowDialogue_B2

+:
	ld hl, $00CE
	jp ShowDialogue_B2

SceneRoom_TriadaPrisoner2:
	ld hl, $00EC
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $013C
	jr z, +
	ld hl, $0124
+:
	jp ShowDialogue_B2

SceneRoom_TriadaPrisoner3:
	ld	hl, $EE
	jp	ShowDialogue_B2

SceneRoom_TriadaPrisoner4:
	ld	hl, $F0
	jp	ShowDialogue_B2

SceneRoom_TriadaPrisoner5:
	ld hl, $00F2
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $014C
	jr z, +
	ld hl, $013C
+:
	jp ShowDialogue_B2

SceneRoom_TriadaPrisoner6:
	ld a, EnemyID_Tarantul
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $00F4
	jp ShowDialogue_B2

SceneRoom_MedusaTower1:
	ld	hl, $FC
	jp	ShowDialogue_B2

SceneRoom_MedusaTower2:
	ld	hl, $FE
	jp	ShowDialogue_B2

SceneRoom_MedusaTower3:
	ld	hl, $100
	jp	ShowDialogue_B2

SceneRoom_BartevoCave:
	ld	hl, $10A
	jp	ShowDialogue_B2

SceneRoom_AbionTower:
	ld	hl, $21A
	jp	ShowDialogue_B2

SceneRoom_Room8E:
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
	ld (CurrentItem), a
	call Inventory_FindItem
	ret z
	jp Inventory_AddItem

SceneRoom_Room8F:
	ld hl, $0160
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0162
	jr z, +
	ld hl, $0164
+:
	jp ShowDialogue_B2

SceneRoom_TriadaGuard:
	ld a, EnemyID_RobotCop
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $021C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr nz, +
	ld a, ItemID_RoadPass
	call Inventory_FindItem
	jr nz, +
	ld hl, $021E
	call ShowDialogue_B2
	call CloseTextBox
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
	call CloseTextBox
LABEL_5389:
	call Dungeon_EnterBattle
	ld a, ($C800)
	or a
	call nz, LABEL_1BE1
	pop hl
	ret

SceneRoom_Room94:
	ld	hl, $222
	jp	ShowDialogue_B2

SceneRoom_Room95:
	ld	hl, $224
	jp	ShowDialogue_B2

SceneRoom_Room96:
	ld	hl, $226
	jp	ShowDialogue_B2

SceneRoom_Room97:
	ld	hl, $22E
	jp	ShowDialogue_B2

SceneRoom_Room98:
	ld	hl, $232
	jp	ShowDialogue_B2

SceneRoom_Room99:
	ld	hl, $218
	jp	ShowDialogue_B2

SceneRoom_Room9A:
	ld	hl, $214
	jp	ShowDialogue_B2

SceneRoom_GiftCheck:
	ld a, EnemyID_RobotCop
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $009C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $00A2
	call ShowDialogue_B2
	jr ++

+:
	ld a, ItemID_Cake
	call Inventory_FindItem
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
	call CloseTextBox
	call LABEL_15DC
	jp Dungeon_RunAway

SceneRoom_TorchBearer:
	ld hl, $023E
	call ShowDialogue_B2
	call ShowYesNoPrompt
	jr z, +
	ld hl, $0246
	jp ShowDialogue_B2

+:
	ld a, ItemID_AmberEye
	call Inventory_FindItem
	jr nz, +
	call Inventory_RemoveItem2
	ld a, ItemID_EclipseTorch
	ld (CurrentItem), a
	call Inventory_AddItem
	ld hl, $0244
	jp ShowDialogue_B2

+:
	ld hl, $0248
	jp ShowDialogue_B2

SceneRoom_Tarzimal:
	ld a, EnemyID_Tarzimal
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld a, (Noah_stats+armor)
	ld b, a
	ld a, ItemID_FradeMantle
	cp b
	jr z, +
	call Inventory_FindItem
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
	call CloseTextBox
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
	call Dungeon_EnterBattle
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
	ld (CurrentItem), a
	jp Inventory_AddItem

SceneRoom_ShadowWarrior:
	ld a, EnemyID_Shadow
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $0262
	call ShowDialogue_B2
	call CloseTextBox
	call LABEL_54EF
	ld a, $FF
	ld (Dialogue_flags+DialogueFlag_ShadowWarrior), a
	ld hl, $0266
	jp ShowDialogue_B2

LABEL_54EF:
	call Dungeon_EnterBattle
	ld a, (Game_mode)
	cp $02 ; GameMode_LoadTitleScreen
	ret nz
	pop hl
	pop hl
	ret

SceneRoom_Lassic:
	ld a, (Dialogue_flags+DialogueFlag_BeatLassic)
	or a
	jp nz, Scene_RoomScriptEnd
	ld a, EnemyID_Lassic
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $026C
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $026E
	jr z, +
	ld hl, $0270
+:
	call ShowDialogue_B2
	call CloseTextBox
	call LABEL_54EF
	ld a, $01
	ld (Dialogue_flags+DialogueFlag_BeatLassic), a
	ld hl, $02AA
	jp ShowDialogue_B2

SceneRoom_EppiWoodsNoCompass:
	ld	hl, DialogueWoodsPathUnclear_B12
	jp	ShowDialogue_B12

SceneRoom_HapsbyScrapHeap:
	call	WaitForButton1Or2

SceneRoom_OdinStone:
	call LABEL_1BE1
	pop hl
	ret

ShowNothingInterestingHere:
	ld hl, DialogueNothingUnusualHere_B12
	call ShowDialogue_B12
	jp CloseTextBox

GetHapsby:
	ld a, ItemID_Hapsby
	ld (CurrentItem), a
	call Inventory_FindItem
	jr z, ShowNothingInterestingHere
	call CloseTextBox
	ld hl, $C801
	inc (hl)
	call BuildSprites
	call WaitForButton1Or2
	ld hl, $012C
	call ShowDialogue_B2
	jp Inventory_AddItem

CheckHovercraft:
	ld a, (Dialogue_flags+DialogueFlag_HovercraftUnhidden)
	or a
	jr z, ShowNothingInterestingHere
	ld a, ItemID_Hapsby
	ld (CurrentItem), a
	call Inventory_FindItem
	jr nz, ShowNothingInterestingHere
	ld a, ItemID_Hovercraft
	ld (CurrentItem), a
	call Inventory_FindItem
	jr z, ShowNothingInterestingHere
	ld hl, $0178
	call ShowDialogue_B2
	call CloseTextBox
	jp Inventory_AddItem

FindOdin:
	ld hl, $00FA
	call ShowDialogue_B2
	jp CloseTextBox

SceneRoom_CoronaTowerDezorian1:
	ld a, EnemyID_EvilHead
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $0234
	jp ShowDialogue_B2

SceneRoom_GuaronMorgue:
	ld	hl, $234
	jp	ShowDialogue_B2

SceneRoom_CoronaTowerDishonestDezorian:
	ld a, EnemyID_Dezorian
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	xor a
	ld ($CBC3), a
	ld hl, $0238
	jp ShowDialogue_B2

SceneRoom_RoomA7:
	ld a, EnemyID_Serpent
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	pop hl
	ld hl, 0
	ld (Enemy_money), hl
	jp Dungeon_EnterBattle

SceneRoom_BayaMalayPrisoner:
	ld hl, $0228
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $022C
	jr z, +
	ld hl, $022A
+:
	jp ShowDialogue_B2

SceneRoom_RoomA9:
	ld a, EnemyID_NFarmer
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	ld hl, $0212
	jp ShowDialogue_B2

SceneRoom_LuvenoGuard:
	ld a, ($C504)
	cp $07
	jr nc, +
	ld hl, $0282
	jp ShowDialogue_B2

+:
	ld hl, $0284
	call ShowDialogue_B2
	ld a, (H_location)
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

SceneRoom_DarkForce:
	ld a, $93
	ld (Sound_index), a
	call VIntDelay
	ld a, $1F
	ld (Scene_type), a
	call Scene_LoadData
	ld hl, $FFFF
	ld (hl), :Bank19
	ld hl, Palette_DarkForce_B19
	ld de, Target_palette+$10
	ld bc, $0010
	ldir
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, EnemyID_DarkFalz
	ld (Battle_enemy_id), a
	call Dungeon_LoadEnemy
	call VintDelayButtonPress
	ld a, $20
	ld (Scene_type), a
	call LABEL_54EF
	call CloseTextBox
	ld a, (Char_stats)
	or a
	jr nz, SceneRoom_RoomAC
	ld hl, LABEL_B12_BF64
	call ShowDialogue_B12
	call CloseTextBox

SceneRoom_RoomAC:
	call FadeOut2
	ld a, $1D
	ld (Scene_type), a
	call Scene_LoadData
	ld a, $0C
	call WaitForVInt
	call FadeIn2
	ld a, $35
	call LoadDialogueSprite
	call BuildSprites
	ld hl, $0272
	call ShowDialogue_B2
	call ShowYesNoPrompt
	ld hl, $0212
	jr z, +
	ld hl, $0230
+:
	call ShowDialogue_B2
	call CloseTextBox
	pop hl
	jp EndingScreen

SceneRoom_RoomAD:
	ld	hl, $2A4
	jp	ShowDialogue_B2

SceneRoom_RoomAE:
	ld a, ($C2F0)
	ld d, a
	ld e, $00
-:
	ld a, e
	ld (CurrentCharacter), a
	rr d
	push de
	ld hl, DialogueBattlePlayerDied_B12
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
	call IsCharacterAlive
	jr nz, +
	djnz -
	jp LABEL_1602

+:
	jp CloseTextBox

SceneRoom_RoomB1:
	ld	hl, $23A
	jp	ShowDialogue_B2

SceneRoom_RoomB2:
	ld	hl, $27A
	jp	ShowDialogue_B2

SceneRoom_FlightToMotavia:
	ld hl, DialogueBoundForMotavia_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	ret nz
	ld a, $81
	ld ($C2E9), a
	ret

SceneRoom_FlightToPalma:
	ld hl, DialogueBoundForPalma_B12
	call ShowDialogue_B12
	call ShowYesNoPrompt
	ret nz
	ld a, $82
	ld ($C2E9), a
	ret

SceneRoom_HapsbyTravel:
	ld hl, DialogueChooseDestination_B12
	call ShowDialogue_B12
	push bc
	call LABEL_3A21
	bit 4, c
	pop bc
	ret nz
	ld d, a
	ld a, (Location_index)
	rrca
	rrca
	rrca
	and $03
	ld e, a
	cp d
	jr nz, ++
	or a
	ld hl, DialogueWeAreAtGothic_B12
	jr z, +
	dec a
	ld hl, DialogueWeAreAtUzo_B12
	jr z, +
	ld hl, DialogueWeAreAtSkure_B12
+:
	call ShowDialogue_B12
	jr SceneRoom_HapsbyTravel

++:
	ld a, d
	or a
	ld hl, DialogueHeadingForGothic_B12
	jr z, +
	dec a
	ld hl, DialogueHeadingForUzo_B12
	jr z, +
	ld hl, DialogueHeadingForSkure_B12
+:
	push de
	call ShowDialogue_B12
	call ShowYesNoPrompt
	pop de
	jr nz, SceneRoom_HapsbyTravel
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

BuildSprites:
	ld	hl, $C289
	ld	($C287), hl
	ld	de, $C28B
	ld	bc, $000E
	ld	(hl), $00
	inc	hl
	ld	(hl), $FF
	dec  hl
	ldir
	ld	hl, Sprite_table
	ld	(Next_sprite_y), hl
	ld	hl, $C980
	ld	(Next_sprite_x), hl
	ld	iy, Character_sprite_attributes
	ld	bc, $0800
BuildSprites_Loop:
	ld	a, (iy+0)
	and	$7F
	jr	z, BuildSprites_Next
	push	bc
	ld	hl, LABEL_5827-2
	call	GetPtrAndJump
	pop	bc
	or	a
	jp	z, BuildSprites_Next
	ld	hl, ($C287)
	ld	a, (iy+2)
	ld	(hl), a
	inc	hl
	ld	(hl), c
	inc	hl
	ld	($C287), hl
BuildSprites_Next:
	ld	de, $0020
	add	iy, de
	inc	c
	djnz	BuildSprites_Loop
	ld	de, $C289
	ld	b, $03
LABEL_57BE:
	push	bc
	ld	l, e
	ld	h, d
	inc	hl
	inc	hl
LABEL_57C3:
	ld	a, (de)
	cp	(hl)
	jr	nc, LABEL_57D4
	ld	c, a
	ld	a, (hl)
	ld	(hl), c
	ld	(de), a
	inc	hl
	inc	de
	ld	a, (de)
	ld	c, a
	ld	a, (hl)
	ld	(hl), c
	ld	(de), a
	dec  hl
	dec  de
LABEL_57D4:
	inc	hl
	inc	hl
	djnz	LABEL_57C3
	inc	de
	inc	de
	pop	bc
	djnz	LABEL_57BE
	ld	hl, $C28A
	ld	b, $08
LABEL_57E2:
	ld	a, (hl)
	cp	$FF
	jr	z, LABEL_580E
	push	bc
	push	hl
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, Character_sprite_attributes
	add	hl, de
	push	hl
	pop	iy
	cp	$04
	ld	a, :Bank03
	ld	bc, CharacterSpriteData_B03
	jr	c, LABEL_5806
	ld	a, :Bank21
	ld	bc, EnemySpriteData_B21
LABEL_5806:
	ld	($FFFF), a
	call	UpdateSprites
	pop	hl
	pop	bc
LABEL_580E:
	inc	hl
	inc	hl
	djnz	LABEL_57E2
	ld	hl, (Next_sprite_y)
	ld	(hl), $D0
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


; =================================================================
LABEL_5827:
.dw	LABEL_599F	; 1
.dw	LABEL_59D4	; 2
.dw	LABEL_59E0	; 3
.dw	LABEL_59E5	; 4
.dw	LABEL_59F1	; 5
.dw	LABEL_59F6	; 6
.dw	LABEL_5A02	; 7
.dw	LABEL_5A07	; 8
.dw	LABEL_5A4F	; 9
.dw	LABEL_5A70	; $A
.dw	LABEL_5B87	; $B
.dw	LABEL_5BCE	; $C
.dw	LABEL_5C63	; $D
.dw	LABEL_5C99	; $E
.dw	LABEL_5DA0	; $F
.dw	LABEL_5E2B	; $10
.dw	LABEL_5E2E	; $11
.dw	LABEL_5E72	; $12
.dw	LABEL_5EAE	; $13
.dw	LABEL_5EEA	; $14
.dw	LABEL_5D30	; $15
.dw	LABEL_5D5B	; $16
; =================================================================


UpdateSprites:
	ld	l, (iy+1)
	ld	h, $00
	add	hl, hl
	add	hl, bc
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	b, (hl)
	push	bc
	inc	hl
	ld	de, (Next_sprite_y)
	ld	c, (iy+2)
LABEL_5868:
	ld	a, (hl)
	add	a, c
	ld	(de), a
	inc	de
	inc	hl
	djnz	LABEL_5868
	ld	(Next_sprite_y), de
	pop	bc
	ld	de, (Next_sprite_x)
	ld	c, (iy+4)
LABEL_587B:
	ld	a, (hl)
	add	a, c
	ld	(de), a
	inc	de
	inc	hl
	ld	a, (hl)
	ld	(de), a
	inc	hl
	inc	de
	djnz	LABEL_587B
	ld	(Next_sprite_x), de
	ret


; Data from 588B to 5FFD (1907 bytes)
UpdateSpriteTable:
	ld	hl, Sprite_table
	ld	de, $7F00
	rst	$08
	ld	c, $BE
	call	GoToOuti64
	ld	hl, $C980
	ld	de, $7F80
	rst	$08

GoToOuti128:
.REPEAT 64
	outi
.ENDR

GoToOuti64:
.REPEAT 32
	outi
.ENDR

GoToOuti32:
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
	ld a, (Vehicle_movement_flags)
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
	ld a, (Scroll_direction)
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
	ld a, (Vehicle_movement_flags)
	add a, (hl)
	ld (iy+16), a
	ret

LABEL_5A94:
.db	$FC, $FE, $FF, $FD


LABEL_5A98:
	ld a, c
	or a
	call z, LABEL_7143
	ld a, (Rotate_palette_flag)
	or a
	jp z, LABEL_5AFC
	cp $0F
	jp nz, LABEL_5B30
	ld a, c
	or a
	jp nz, +
	ld a, (iy+18)
	ld (iy+19), a
	ld a, (Scroll_direction)
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
	ld a, (Scroll_direction)
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
	ld (Sound_index), a
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
	call LoadTiles4BitRLE
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
	call UpdateRNGSeed
	ld b, a
	ld c, $3D
	ld a, (Dungeon_obj_item_trapped)
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
	ld (Sound_index), a
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
	ld a, (Location_index)
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
	ld (Sound_index), a
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
	ld a, (Location_index)
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
	ld (Battle_player_hurt_flag), a
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
	ld a, (Battle_enemy_id)
	cp EnemyID_Lassic
	jr z, LABEL_5E1D
	ld a, $11
	ld (Character_sprite_attributes), a
	ret

+:
	ld a, (Battle_player_hurt_flag)
	or a
	jr nz, LABEL_5E1D
	ld a, $BB
	ld (Sound_index), a
	ret

LABEL_5E1D:
	ld a, $AE
	ld (Sound_index), a
	call LABEL_7BC4
	ld a, (Battle_player_target)
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
	ld (Sound_index), a
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
	call LoadTiles4BitRLE
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
	ld a, (Magic_wall_active)
	and $80
	jp z, LABEL_5E1D
	ld a, $BB
	ld (Sound_index), a
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
	ld a, (Battle_player_target)
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
	call OutputTilemapRawDataBox
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

Map_RunRandomBattles:
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
	ld de, (V_location)
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
	ld de, (H_location)
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
	ld a, (Vehicle_movement_flags)
	or a
	jr z, +
	srl b
	srl b
+:
	call UpdateRNGSeed
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
	ld de, B03_MapEncounterIDList
	add hl, de
	add hl, bc
	ld a, (hl)

Dungeon_GetEncounter:
	or a
	ret z
	ld hl, $FFFF
	ld (hl), :Bank03
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, B03_EncounterPoolData-8
	add hl, de
	call UpdateRNGSeed
	and $07
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld (Battle_enemy_id), a
	ld a, $FF
	ret

LABEL_5FF9:
	xor a
	ld (Battle_flag), a
	ret

Dungeon_LoadEnemy:
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $00FF
	ld	(hl), $00
	ldir
	ld	hl, Enemy_stats
	ld	de, Enemy_stats+1
	ld	bc, $007F
	ld	(hl), $00
	ldir
	ld	a, (Battle_enemy_id)
	ld	a, a
	and	$7F
	ret  z

	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, B03_EnemyData
	add	hl, de
	ld	de, CurrentBattle_EnemyName
	ld	bc, $0008
	ldir
	ld	de, $C258
	ld	bc, $0008
	ldir
	ld	b, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	ld	a, b
	ld	($FFFF), a
	ld	de, $6000
	call	LoadTiles4BitRLE
	pop	hl
	inc	hl
	ld	a, :Bank03
	ld	($FFFF), a
	ld	a, (hl)
	push	hl
	call	LABEL_60FD
	pop	hl
	inc	hl
	ld	a, :Bank03
	ld	($FFFF), a
	ld	a, (hl)
	bit  7, a
	jr	nz, LABEL_607F
	and	$0F
	ld	b, a
	ld	a, (Party_curr_num)
	inc	a
	add	a, a
	cp	b
	jr	nc, LABEL_6075
	ld	b, a
LABEL_6075:
	call	UpdateRNGSeed
	and	$07
	cp	b
	jp	nc, LABEL_6075
	inc	a
LABEL_607F:
	and	$0F
	ld	b, a
	ld	(Enemy_num), a
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	push	hl
	ex   de, hl
	ld	ix, $C440
	ld	de, $0010
LABEL_6095:
	ld	(ix+status), $01
	ld	(ix+curr_hp), a
	ld	(ix+max_hp), a
	ld	(ix+attack), h
	ld	(ix+defense), l
	add	ix, de
	djnz	LABEL_6095
	pop	hl
	ld	a, (hl)
	ld	(Dungeon_item_index), a
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	hl
	ld	a, (Enemy_num)
	ld	c, a
	ld	b, $00
	call	Multiply16Bit
	ld	(Enemy_money), hl
	pop	hl
	inc	hl
	ld	a, (hl)
	ld	(Dungeon_obj_item_trapped), a
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	hl
	ld	a, (Enemy_num)
	ld	c, a
	ld	b, $00
	call	Multiply16Bit
	ld	(CurrentBattle_EXPReward), hl
	pop	hl
	inc	hl
	ld	a, (hl)
	ld	(Battle_enemy_action), a
	inc	hl
	ld	a, (hl)
	ld	(Battle_escape_rate), a
	ld	hl, Dialogue_flags
	ld	(Dungeon_obj_flag_addr), hl
	call	BuildSprites
	call	BuildSprites
	ld	hl, Target_palette
	ld	de, Normal_palette
	ld	bc, $0020
	ldir
	ld	a, $10
	jp	WaitForVInt

LABEL_60FD:
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, l
	ld	d, h
	add	hl, hl
	add	hl, de
	ld	de, LABEL_B03_8FC7-$18
	add	hl, de
	ld	de, $C880
	ld	bc, $0003
	ldir
	inc	de
	ldi
	ld	de, $C894
	ld	bc, $0009
	ldir
	ld	a, ($C898)
	ld	($C88E), a
	ld	a, $01
	ld	($C88D), a
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, c
	ld	c, a
	ld	a, h
	ld	h, b
	ld	b, a
	or	c
	ld	a, :Bank24
	ld	($FFFF), a
	call	nz, LABEL_615A
	pop	hl
	inc	hl
	ld	a, :Bank03
	ld	($FFFF), a
	ld	de, $C8A0
	ld	bc, $0003
	ldir
	inc	de
	ldi
	ld	a, (hl)
	ld	($C2F1), a
	ret

LABEL_615A:
	push	bc
	push	de
	ld	c, $FF
LABEL_615E:
	ld	a, (hl)
	or	a
	jp	z, LABEL_6176
	ldi
	ldi
LABEL_6167:
	djnz	LABEL_615E
	pop	de
	ex   de, hl
	ld	bc, $0040
	add	hl, bc
	ex   de, hl
	pop	bc
	dec  c
	jp	nz, LABEL_615A
	ret

LABEL_6176:
	inc	hl
	inc	de
	inc	hl
	inc	de
	jp	LABEL_6167

LoadDialogueSprite:
	or	a
	ret  z

	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	hl, Character_sprite_attributes
	ld	de, Character_sprite_attributes+1
	ld	bc, $00FF
	ld	(hl), $00
	ldir
	ld	hl, Enemy_stats
	ld	de, Enemy_stats+1
	ld	bc, $007F
	ld	(hl), $00
	ldir
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld	de, DialogueSpritesPaletteIndices_B03
	add	hl, de
	ld	a, (hl)
	push	hl
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, DialogueSpritesPalettes_B03
	add	hl, de
	push	hl
	ld	de, Target_palette+$18
	ld	bc, $0008
	ldir
	pop	hl
	ld	de, Normal_palette+$18
	ld	bc, $0008
	ldir
	pop	hl
	inc	hl
	ld	a, (hl)
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, DialogueSprites_B03
	add	hl, de
	ld	de, $C800
	ld	bc, $0003
	ldir
	inc	de
	ldi
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	a, b
	ld	($FFFF), a
	ld	de, $6000
	call	LoadTiles4BitRLE
	call	BuildSprites
	ld	a, $16
	jp	WaitForVInt


AnimateCharacterSprites:
	ld hl, $FFFF
	ld (hl), :Bank28
	ld ix, Character_sprite_attributes
	ld b, $04
-:
	ld a, (ix+16)
	cp (ix+17)
	jp z, +
	ld (ix+17), a
	ld d, a
	ld a, (ix+1)
	or a
	ld hl, CharacterSpritesTable-2
	jp nz, GetPtrAndJump
+:
	ld de, $0020
	add ix, de
	djnz -
	ret


; =================================================================
CharacterSpritesTable:
.dw	CharacterSprites_Alis
.dw	CharacterSprites_Noah
.dw	CharacterSprites_Odin
.dw	CharacterSprites_Myau
.dw	CharacterSprites_Vehicle
; =================================================================


CharacterSprites_Alis:
	ld e, $00
	srl d
	rr e
	ld l, e
	ld h, d
	srl d
	rr e
	add hl, de
	ld de, AlisSprites_B28
	add hl, de
	ld de, $7540
	rst $08
	ld c, $BE
	call GoToOuti128
	jp GoToOuti64

CharacterSprites_Noah:
	ld e, $00
	srl d
	rr e
	ld l, e
	ld h, d
	srl d
	rr e
	add hl, de
	ld de, NoahSprites_B28
	add hl, de
	ld de, $7600
	rst $08
	ld c, $BE
	call GoToOuti128
	jp GoToOuti64

CharacterSprites_Odin:
	ld e, $00
	srl d
	rr e
	ld l, e
	ld h, d
	srl d
	rr e
	add hl, de
	ld de, OdinSprites_B28
	add hl, de
	ld de, $76C0
	rst $08
	ld c, $BE
	call GoToOuti128
	jp GoToOuti64

CharacterSprites_Myau:
	ld e, $00
	srl d
	rr e
	ld hl, MyauSprites_B28
	add hl, de
	ld de, $7780
	rst $08
	ld c, $BE
	jp GoToOuti128

CharacterSprites_Vehicle:
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
	ld de, VehicleSprites_B18
	add hl, de
	ld de, $7540
	rst $08
	ld c, $BE
	call GoToOuti128
	call GoToOuti128
	call GoToOuti128
	jp GoToOuti128

AnimateMapTiles:
	ld hl, $FFFF
	ld (hl), :Bank14
	ld hl, $C26F
	ld de, MapAnimSeaShoreFrames
	ld bc, $0C10
	call MapAnim_CountAndAnimate
	ld hl, $C273
	ld de, MapAnimSeaFrames
	ld bc, $0340
	call MapAnim_CountAndAnimate
	ld hl, $C277
	ld de, MapAnimSmokeFrames
	ld bc, $044C
	call MapAnim_CountAndAnimate
	ld hl, $C27B
	ld de, MapAnimRoadwayFrames
	ld bc, $065C
	call MapAnim_CountAndAnimate
	ld hl, $C27F
	ld de, MapAnimLavaPitFrames
	ld bc, $0874
	call MapAnim_CountAndAnimate
	ld hl, $C283
	ld de, MapAnimAntlionHillFrames
	ld bc, $1094
	call MapAnim_CountAndAnimate
	ret

MapAnim_CountAndAnimate:
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


MapAnimSeaShoreFrames:
.dw	LABEL_B14_A3E8
.dw	LABEL_B14_A3E8
.dw	LABEL_B14_A568
.dw	LABEL_B14_A6E8
.dw	LABEL_B14_A6E8
.dw	LABEL_B14_A568
.dw	LABEL_B14_A868
.dw	LABEL_B14_A9E8


MapAnimSeaFrames:
.dw	LABEL_B14_AB68
.dw	LABEL_B14_AB68
.dw	LABEL_B14_ABC8
.dw	LABEL_B14_ABC8
.dw	LABEL_B14_AC28
.dw	LABEL_B14_AC28
.dw	LABEL_B14_AC88
.dw	LABEL_B14_AC88


MapAnimSmokeFrames:
.dw	LABEL_B14_BAE8
.dw	LABEL_B14_BAE8
.dw	LABEL_B14_BB68
.dw	LABEL_B14_BB68
.dw	LABEL_B14_BBE8
.dw	LABEL_B14_BBE8
.dw	LABEL_B14_BB68
.dw	LABEL_B14_BB68


MapAnimRoadwayFrames:
.dw	LABEL_B14_ACE8
.dw	LABEL_B14_ACE8
.dw	LABEL_B14_ADA8
.dw	LABEL_B14_ADA8
.dw	LABEL_B14_AE68
.dw	LABEL_B14_AE68
.dw	LABEL_B14_AF28
.dw	LABEL_B14_AF28


MapAnimLavaPitFrames:
.dw	LABEL_B14_AFE8
.dw	LABEL_B14_AFE8
.dw	LABEL_B14_B0E8
.dw	LABEL_B14_B0E8
.dw	LABEL_B14_B1E8
.dw	LABEL_B14_B1E8
.dw	LABEL_B14_B0E8
.dw	LABEL_B14_B0E8


MapAnimAntlionHillFrames:
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B4E8
.dw	LABEL_B14_B6E8
.dw	LABEL_B14_B8E8
.dw	LABEL_B14_B2E8


AnimateEnemyTile:
	ld a, (Scene_anim_flag)
	or a
	ret z
	ld a, (Scene_type)
	or a
	ret z
	cp $0C
	ret nc
	ld hl, EnemyTileAnimTable-2
	jp GetPtrAndJump


EnemyTileAnimTable:
.dw	EnemyTileAnim_Nothing
.dw	EnemyTileAnim_Nothing
.dw	EnemyTileAnim_SeaWaveIn
.dw	EnemyTileAnim_SeaInOut
.dw	EnemyTileAnim_Nothing
.dw	EnemyTileAnim_Nothing
.dw	EnemyTileAnim_LavaPit
.dw	EnemyTileAnim_Nothing
.dw	EnemyTileAnim_Nothing
.dw	EnemyTileAnim_Nothing
.dw	LABEL_64CF

EnemyTileAnim_Nothing:
	ret

EnemyTileAnim_SeaWaveIn:
	call AnimateWaterPalette
	ld hl, Anim_delay_counter
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
	ld hl, AnimSeaWaveInFrames
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld b, $04
	jp EnemyTileAnim_DoAnimation

EnemyTileAnim_SeaInOut:
	call AnimateWaterPalette
	ld hl, Anim_delay_counter
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
	ld hl, AnimSeaInOutFrames
	add a, a
	ld e, a
	add a, a
	add a, e
	ld e, a
	ld d, $00
	add hl, de
	ld b, $03

EnemyTileAnim_DoAnimation:
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
	ld hl, Tiles_AnimSea_B16
	add hl, de
	ld bc, $8000|Port_VDPData
-:
	outi
	jp nz, -
	pop hl
	pop bc
	djnz EnemyTileAnim_DoAnimation
	ret

EnemyTileAnim_LavaPit:
	ld hl, Anim_delay_counter
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
	ld hl, AnimLavaPitFrames
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

AnimateWaterPalette:
	ld a, (Fade_timer)
	or a
	ret nz
	ld a, (Game_mode)
	cp $0D ; GameMode_Scene
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
	ld hl, Palette_Water
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
	cp $0D ; GameMode_Scene
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


AnimSeaWaveInFrames:
.db	$01, $15, $25, $09, $29, $0A, $29, $0A, $01, $00, $05, $0B, $01, $00, $05, $0B
.db	$05, $01, $09, $0D, $05, $01, $09, $0D, $09, $02, $0D, $0D, $09, $02, $0D, $0D
.db $0D, $03, $11, $0E, $0D, $03, $11, $0E, $11, $04, $15, $0E, $11, $04, $15, $0E
.db $15, $05, $19, $0F, $15, $05, $19, $0F, $19, $06, $21, $0F, $19, $06, $21, $0F
.db	$21, $08, $01, $10, $25, $0C, $29, $11


AnimSeaInOutFrames:
.db	$25, $09, $29, $0A, $29, $0A, $25, $09, $29, $0A, $29, $0A, $25, $09, $29, $0C
.db	$29, $0C, $21, $08, $25, $0F, $29, $14, $21, $0F, $25, $13, $29, $14, $19, $06
.db	$1D, $0F, $21, $12, $15, $05, $19, $0E, $1D, $12, $15, $0E, $19, $12, $19, $12
.db	$15, $0E, $19, $12, $19, $12, $15, $05, $19, $0E, $1D, $12, $19, $06, $1D, $0F
.db	$21, $12, $1D, $07, $21, $0F, $25, $13, $21, $08, $25, $0C, $29, $11, $25, $09
.db	$29, $0C, $29, $0C

AnimLavaPitFrames:
.db	$00, $02, $05, $08, $15, $18, $00, $03, $06, $09, $16, $14, $01, $04, $07, $05
.db	$17, $14, $02, $00, $08, $05, $18, $15, $03, $00, $09, $06, $14, $16, $04, $01
.db	$05, $07, $14, $17


Palette_Water:
.db	$3F, $3C, $38, $38, $3F, $3C, $38, $38


LABEL_65CE:
.db	$06, $06, $06, $06, $06, $06, $06, $06


LABEL_65D6:
.db	$06, $06, $06, $06, $25, $2A, $3E, $3F, $06, $06, $06, $06, $06, $06, $06, $06
.db	$06, $06, $06, $06, $06, $06, $06, $06


LABEL_65EE:
	ld	a, (Dungeon_position)
	ld	l, a
	ld	h, $CB
	ld	a, (hl)
	cp	$08 ; Object or pitfall
	jp	nz, LABEL_66E1
	; Check if it's an object
	ld	c, l
	ld	a, (Dungeon_index)
	ld	b, a
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	hl, B03_ObjectData
	ld	de, $0006
LABEL_660A:
	ld	a, (hl)
	cp	$FF
	jr	z, Dungeon_Pitfall	; jump if we reached the end of the list (it's a pitfall)
	inc	hl
	cp	b
	jr	nz, LABEL_6618
	ld	a, (hl)
	cp	c
	jp	z, LABEL_66E1
LABEL_6618:
	add	hl, de
	jp	LABEL_660A

Dungeon_Pitfall:
	ld	de, $7E00
	ld	hl, $00C0
	ld	bc, $0080
	di
	call	FillVRAMWithHL
	ei
	ld	a, $C0
	ld	(Sound_index), a
	xor	a
	ld	(V_scroll), a
	ld	b, $0C
LABEL_6635:
	push	bc
	ld	a, (V_scroll)
	add	a, $10
	ld	(V_scroll), a
	ld	a, $08
	call	WaitForVInt
	ld	a, b
	sub	$0C
	neg
	ld	c, $00
	ld	b, a
	srl  b
	rr   c
	ld	hl, $7800
	add	hl, bc
	ex   de, hl
	ld	hl, $00C0
	ld	bc, $0040
	di
	call	FillVRAMWithHL
	ei
	pop	bc
	djnz	LABEL_6635
	; Move down a floor
	ld	a, (Dungeon_index)
	sub	$01
	jr	nc, LABEL_666A
	xor	a
LABEL_666A:
	ld	(Dungeon_index), a
	call	LoadDungeonMap
	xor	a
	call	Dungeon_LoadScreen
	ld	hl, $C240
	ld	de, Normal_palette
	ld	bc, $0020
	ldir
	ld	a, $16
	call	WaitForVInt
	ld	a, $10
	ld	(V_scroll), a
	ld	b, $0C
LABEL_668B:
	push	bc
	ld	a, (V_scroll)
	add	a, $10
	ld	(V_scroll), a
	ld	a, $08
	call	WaitForVInt
	ld	a, b
	sub	$0C
	neg
	ld	c, $00
	ld	b, a
	srl  b
	rr   c
	ld	hl, $7800
	add	hl, bc
	ex   de, hl
	ld	hl, $D000
	add	hl, bc
	ld	bc, $0080
	di
	call	DataToVRAM
	ei
	pop	bc
	djnz	LABEL_668B
	ld	b, $05
LABEL_66BB:
	ld	a, (V_scroll)
	or	a
	ld	a, $D8
	jr	z, LABEL_66C4
	xor	a
LABEL_66C4:
	ld	(V_scroll), a
	ld	a, $08
	call	WaitForVInt
	djnz	LABEL_66BB
	ld	hl, $FFFF
	ld	(hl), :Bank16
	ld	hl, TilesExtraFont_B16
	ld	de, $7E00
	call	LoadTiles4BitRLE
	ld	b, $01
	jp	Dungeon_CheckObjects

LABEL_66E1:
	ld	a, (Ctrl_1_held)
	and	ButtonUp_Mask|ButtonDown_Mask|ButtonLeft_Mask|ButtonRight_Mask
	jp	z, Dungeon_NotMoving
	ld	c, a
	bit  0, c
	jp	z, Dungeon_NotForward
	; Check what's in front
	ld	b, $01
	call	Dungeon_GetRelativeSquare
	ld	b, a
	and	$07
	jp	z, Dungeon_MoveForward	; 0 means we can move
	sub	$02
	jp	c, Dungeon_NotForward	; it's a wall
	cp	$05
	jp	z, Dungeon_MoveForwardIntoFakeWall	; 7 means fake wall
	cp	$02
	jp	nc, LABEL_6729
	; Stairs up or down
	ld	c, a
	ld	a, $C3
	ld	(Sound_index), a
	ld	a, c
	bit  3, b
	jp	nz, Dungeon_Exit
	or	a
	ld	b, $01
	jr	z, LABEL_671C
	ld	b, $FF
LABEL_671C:
	ld	a, (Dungeon_index)
	add	a, b
	ld	(Dungeon_index), a
	call	LoadDungeonMap
	jp	LABEL_6731

LABEL_6729:
	bit  7, (hl)
	ret  z

	bit  3, b
	jp	nz, Dungeon_Exit
LABEL_6731:
	call	FadeOut2
	ld	a, (Dungeon_direction)
	and	$03
	ld	hl, DungeonMovementTable
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (Dungeon_position)
	add	a, (hl)
	add	a, (hl)
	ld	(Dungeon_position), a
	xor	a
	call	Dungeon_NextScreen
	call	FadeIn2
	ld	b, $01
	jp	Dungeon_CheckObjects

Dungeon_MoveForwardIntoFakeWall:
	call	Dungeon_MoveForward
Dungeon_MoveForward:
	ld	a, $00
	call	Dungeon_Animate
	ld	a, (Dungeon_direction)
	and	$03
	ld	hl, DungeonMovementTable
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (Dungeon_position)
	add	a, (hl)
	ld	(Dungeon_position), a
	xor	a
	call	Dungeon_NextScreen
	ld	b, $01
	jp	Dungeon_CheckObjects

Dungeon_NotForward:
	bit  1, c
	jr	z, LABEL_67AB
	ld	b, $0B
	call	Dungeon_GetRelativeSquareType
	jr	nz, LABEL_67AB
	call	Dungeon_MoveBackwards
	ld	b, $01
	call	Dungeon_CheckObjects
	ld	b, $0B
	jp	Dungeon_CheckObjects

Dungeon_MoveBackwards:
	ld	a, (Dungeon_direction)
	and	$03
	ld	hl, DungeonMovementTable+2
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (Dungeon_position)
	add	a, (hl)
	ld	(Dungeon_position), a
	ld	a, $01
	jp	Dungeon_Animate

LABEL_67AB:
	bit  2, c
	jr	z, LABEL_67D7
	call	Dungeon_TurnLeft
	ld	b, $01
	jp	Dungeon_CheckObjects

Dungeon_TurnLeft:
	ld	a, (Dungeon_direction)
	dec  a
	and	$03
	ld	(Dungeon_direction), a
	ld	h, $02
	ld	b, $0D
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_67CB
	inc	h
	inc	h
LABEL_67CB:
	ld	b, $01
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_67D3
	inc	h
LABEL_67D3:
	ld	a, h
	jp	Dungeon_Animate

LABEL_67D7:
	bit  3, c
	ret  z
	call	Dungeon_TurnRight
	ld	b, $01
	jp	Dungeon_CheckObjects

Dungeon_TurnRight:
	ld	a, (Dungeon_direction)
	inc	a
	and	$03
	ld	(Dungeon_direction), a
	ld	h, $06
	ld	b, $0C
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_67F6
	inc	h
	inc	h
LABEL_67F6:
	ld	b, $01
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_67FE
	inc	h
LABEL_67FE:
	ld	a, h
	jp	Dungeon_Animate

Dungeon_NotMoving:
	ld	a, (Ctrl_1_pressed)
	and	Button_1_Mask|Button_2_Mask
	ret  z

	ld	b, $01
	call	Dungeon_GetRelativeSquareType
	cp	$04
	jr	nz, LABEL_6817
	ld	c, $02
	call	LABEL_681B
	ret  z

LABEL_6817:
	call	LABEL_1BE1
	ret

LABEL_681B:
	ld	b, $01
	call	Dungeon_GetRelativeSquare
	bit  7, (hl)
	ret  nz

	set  7, (hl)
	ld	a, $BD
	ld	(Sound_index), a
	ld	h, c
	ld	l, $00
	ld	b, $03
LABEL_682F:
	push	bc
LABEL_6830:
	push	hl
	ld	a, h
	call	LABEL_6E4C
	ld	a, $0C
	call	WaitForVInt
	pop	hl
	ld	a, h
	ld	bc, $0040
	add	hl, bc
	cp	h
	jr	z, LABEL_6830
	inc	h
	inc	h
	pop	bc
	djnz	LABEL_682F
	xor	a
	ret


CheckObjectInFront:
	ld b, $01
	call Dungeon_GetRelativeSquare
	cp $08
	jr nz, ++
	ld c, l
	ld a, (Dungeon_index)
	ld b, a
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, B03_ObjectData
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
	xor a ; item found -> return 0
	ret

+++:
	ld a, $FF; Item not found
	or a
	ret

LABEL_687A:
	ld b, $0B
	call Dungeon_GetRelativeSquareType
	ret z
	ld b, $0C
	call Dungeon_GetRelativeSquareType
	ret z
	ld b, $0D
	call Dungeon_GetRelativeSquareType
	ret

Dungeon_RunAway:
; Move backwards if possible, else turn left or right to face a wall, else randomly turn left or right
	ld b, $0B
	call Dungeon_GetRelativeSquareType
	jr z, +++
	ld b, $0C
	call Dungeon_GetRelativeSquareType
	jr nz, ++
	ld b, $0D
	call Dungeon_GetRelativeSquareType
	jr nz, +
	call UpdateRNGSeed
	rrca
	jr nc, ++
+:
	call Dungeon_TurnRight
	jr +++

++:
	call Dungeon_TurnLeft
+++:
	call Dungeon_MoveBackwards
	ld b, $01
	call Dungeon_CheckObjects
	ld b, $0B
	jp Dungeon_CheckObjects

Dungeon_Exit:
	ld	b, $01
	call	Dungeon_GetRelativeSquare
	and	$08
	ret  z

	ld	c, l
	ld	a, (Dungeon_index)
	ld	b, a
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	hl, B03_DungeonTransitionData
	ld	de, $0004
LABEL_68D4:
	ld	a, (hl)
	cp	$FF
	jr	z, LABEL_68E6
	inc	hl
	cp	b
	jr	nz, LABEL_68E1
	ld	a, (hl)
	cp	c
	jr	z, LABEL_68EC
LABEL_68E1:
	add	hl, de
	jp	LABEL_68D4
	ret


LABEL_68E6:
	ld	hl, Game_mode
	ld	(hl), $08 ; GameMode_LoadMap
	ret

LABEL_68EC:
	inc	hl
	ld	a, (hl)
	ld	d, a
	dec  hl
	cp	$80
	ld	a, $08
	jp	c, LABEL_7877
	ld	a, d
	cp	$FF
	jr	nz, LABEL_6947
	push	hl
	call	FadeOut2
	ld	hl, $FFFF
	ld	(hl), :Bank09
	ld	hl, Tiles_DungeonRooms_B09
	ld	de, $4000
	call	LoadTiles4BitRLE
	ld	hl, LABEL_B09_B130
	call	DecompressTilemapData
	ld	a, $0F
	ld	(Scene_type), a
	xor	a
	ld	(Target_palette+$10), a
LABEL_691D:
	ld	a, $0C
	call	WaitForVInt
	call	FadeIn2
LABEL_6925:
	ld	hl, $FFFF
	ld	(hl), :Bank03
	pop	hl
	inc	hl
	inc	hl
	call	LABEL_6A2F
	ld	a, (Game_mode)
	cp	$0B ; GameMode_Dungeon
	ret  nz

	call	FadeOut2
	xor	a
	call	Dungeon_NextScreen
	call	Dungeon_LoadData
	call	Dungeon_ChangeMusic
	call	FadeIn2
	ret

LABEL_6947:
	push	hl
	push	af
	call	FadeOut2
	pop	af
	ld	c, $0D
	cp	$FE
	jr	z, LABEL_6959
	ld	c, $1E
	cp	$FD
	jr	nz, LABEL_6925
LABEL_6959:
	ld	a, c
	ld	(Scene_type), a
	call	Scene_LoadData
	jp	LABEL_691D

Dungeon_CheckObjects:
; b = index of offset to player
	call	Dungeon_GetRelativeSquare
	cp	$08 ; Object
	ret  nz	; return if not an object

	ld	c, l
	push	bc
	ld	a, (Dungeon_index)
	ld	b, a
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	hl, B03_ObjectData
	ld	de, $0006
LABEL_697A:
	ld	a, (hl)
	cp	$FF
	jp	z, LABEL_698C
	inc	hl
	cp	b
	jr	nz, LABEL_6988
	ld	a, (hl)
	cp	c
	jr	z, LABEL_698E
LABEL_6988:
	add	hl, de
	jp	LABEL_697A

LABEL_698C:
	pop	bc
	ret

LABEL_698E:
	pop	bc
	; Object found, hl points to its second byte
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, (de)
	cp	$FF
	ret  z

	ld	(Dungeon_obj_flag_addr), de
	ld	a, $FF
	ld	(Dungeon_moving_flag), a
	inc	hl
	ld	a, (hl) ; Read object type
	inc	hl
	or	a
	jr	nz, LABEL_69B8
	
	; Type 0: item
	ld	a, (hl) ; Read item type
	ld	(Dungeon_item_index), a
	inc	hl
	ld	a, (hl) ; trapped byte
	ld	(Dungeon_obj_item_trapped), a
	ld	hl, 0
	ld	(Enemy_money), hl
	jp	LABEL_69C7

LABEL_69B8:
	cp	$01
	jr	nz, LABEL_69E1
	; Type 1: money
	xor	a
	ld	(Dungeon_item_index), a
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	(Enemy_money), hl
LABEL_69C7:
	; Treasure chest for item or money
	ld	a, b
	cp	$01
	ret  nz

	ld	hl, DialogueTreasureChestFound_B12
	call	ShowDialogue_B12
	push	bc
	call	Battle_ShowTreasureChest
	pop	bc
	call	RunTreasureChest
	ld	a, ($C800)
	or	a
	ret	z
	jp	LABEL_1BE1

LABEL_69E1:
	cp	$02
	jr	nz, LABEL_6A1A
	; Type 2: battle
	ld	a, b
	cp	$01
	jr	z, LABEL_69F7
	push	hl
	call	Dungeon_TurnLeft
	call	Dungeon_TurnLeft
	ld	hl, $FFFF
	ld	(hl), :Bank03
	pop	hl
LABEL_69F7:
	ld	a, (hl)
	ld	(Battle_enemy_id), a
	or	a
	ret  z

	inc	hl
	ld	a, (hl) ; Enemy item drop
	push	af
	ld	hl, (Dungeon_obj_flag_addr)
	push	hl
	call	Dungeon_LoadEnemy
	pop	hl
	ld	(Dungeon_obj_flag_addr), hl
	pop	af
	ld	(Dungeon_item_index), a
	call	Dungeon_EnterBattle
	ld	a, (Character_sprite_attributes)
	or	a
	ret  z

	jp	LABEL_1BE1

LABEL_6A1A:
	cp	$03
	ret  nz
	; Type 3: dialogue
	ld	a, b
	cp	$01
	jr	z, LABEL_6A2F
	push	hl
	call	Dungeon_TurnRight
	call	Dungeon_TurnRight
	ld	hl, $FFFF
	ld	(hl), :Bank03
	pop	hl
LABEL_6A2F:
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	(Room_index), hl
	ld	a, ($C2DC)
	call	LoadDialogueSprite
	call	Scene_DoRoomScript
	ld	a, $D0	; Turn off sprites
	ld	(Sprite_table), a
	xor	a
	ld	(Character_sprite_attributes), a
	ld	(Battle_flag), a
	ld	(Scene_type), a
	ld	($C2D5), a
	ld	hl, $0000
	ld	(Room_index), hl
	ret

Dungeon_Animate:
	ld	l, a
	ld	h, $00
	add	hl, hl
	ld	de, DungeonAnimTable
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	a, $FF
	ld	(Dungeon_moving_flag), a

-:
	ld	a, (hl)
	cp	$FF
	ret  z
	push	hl
	call	Dungeon_NextScreen
	pop	hl
	inc	hl
	jp	-

; =================================================================
DungeonAnimTable:
.dw	DungeonAnimValues0
.dw	DungeonAnimValues1
.dw	DungeonAnimValues2
.dw	DungeonAnimValues3
.dw	DungeonAnimValues4
.dw	DungeonAnimValues5
.dw	DungeonAnimValues6
.dw	DungeonAnimValues7
.dw	DungeonAnimValues8
.dw	DungeonAnimValues9

DungeonAnimValues0:	.db	$01, $02, $03, $04, $05, $FF				; 0 = Forward
DungeonAnimValues1:	.db	$05, $04, $03, $02, $01, $00, $FF			; 1 = Backward
DungeonAnimValues2:	.db	$07, $08, $09, $0A, $0B, $0C, $0D, $00, $FF	; 2 = turn corridor to corridor (left)
DungeonAnimValues3:	.db	$17, $18, $19, $1A, $1B, $1C, $1D, $00, $FF	; 3 = turn corridor to wall (left)
DungeonAnimValues4:	.db	$1F, $20, $21, $22, $23, $24, $25, $00, $FF ; 4 = turn wall to corridor (left)
DungeonAnimValues5:	.db	$0F, $10, $11, $12, $13, $14, $15, $00, $FF ; 5 = turn wall to wall (left)
DungeonAnimValues6:	.db	$0D, $0C, $0B, $0A, $09, $08, $07, $00, $FF ; 6 = turn corridor to corridor (right)
DungeonAnimValues7:	.db	$25, $24, $23, $22, $21, $20, $1F, $00, $FF ; 7 = turn corridor to wall (right)
DungeonAnimValues8:	.db	$1D, $1C, $1B, $1A, $19, $18, $17, $00, $FF ; 8 = turn wall to corridor (right)
DungeonAnimValues9:	.db	$15, $14, $13, $12, $11, $10, $0F, $00, $FF ; 9 = turn wall to wall (right)
; =================================================================

; =================================================================
; Values to add to Dungeon_position to move in certain directions:
; - up, right, down, left, up, right
; Indexed +2 for opposite movement
DungeonMovementTable:
.db	$F0, $01, $10, $FF, $F0, $01
; =================================================================


Dungeon_NextScreen:
	call	Dungeon_LoadScreen
	ld	a, $0C
	jp	WaitForVInt

Dungeon_LoadScreen:
	and	$3F
	jr	nz, LABEL_6AFC
	ld	b, $01
	call	Dungeon_GetRelativeSquareType
	ld	a, $00
	jr	z, LABEL_6AFC
	ld	a, $06
LABEL_6AFC:
	ld	c, a
	add	a, a
	ld	b, a
	add	a, a
	add	a, b
	ld	hl, DungeonTilesTable
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	push	bc
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	rr   c
	ld	d, $40
	jr	nc, LABEL_6B1C
	ld	d, $60
LABEL_6B1C:
	di
	xor	a
	out	(Port_VDPAddress), a
	ld	a, d
	out	(Port_VDPAddress), a
	ei
	call	DecodeDungeonTiles
	pop	hl
	inc	hl
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	call	DecompressTilemapData
	pop	bc
	call	LABEL_6C46
	ret

LABEL_6B3A:
	ld	b, $01
	call	Dungeon_GetRelativeSquareType
	ld	a, $00
	jr	z, LABEL_6B45
	ld	a, $06
LABEL_6B45:
	ld	c, a
	add	a, a
	ld	e, a
	add	a, a
	add	a, e
	ld	e, a
	ld	d, $00
	ld	hl, DungeonTilesTable+3
	add	hl, de
	push	bc
	ld	a, (hl)
	ld	($FFFF), a
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	call	DecompressTilemapData
	pop	bc
	jp	LABEL_6C46


; Copies data from (hl) to TileMapData
; with RLE decompression and 2-interleaving
; data format:
; Header: $fccccccc
;   f = flag: 1 = not RLE, 0 = RLE
;   ccccccc = count
; Then [count] bytes are copied to even bytes starting at TileMapData
; Then the process is repeated for the odd bytes
DecompressTilemapData:
	ld	b, $00
	ld	de, Tilemap_data
	call	LABEL_6B6E
	inc	hl
	ld	de, Tilemap_data+1
LABEL_6B6E:
	ld	a, (hl)
	or	a
	ret  z

	jp	m, LABEL_6B81
	ld	c, a
	inc	hl
LABEL_6B76:
	ldi
	dec  hl
	inc	de
	jp	pe, LABEL_6B76
	inc	hl
	jp	LABEL_6B6E

LABEL_6B81:
	and	$7F
	ld	c, a
	inc	hl
LABEL_6B85:
	ldi
	inc	de
	jp	pe, LABEL_6B85
	jp	LABEL_6B6E

DecodeDungeonTiles:
	ld	c, $BE
LABEL_6B90:
	ld	a, (hl)
	or	a
	ret  z

	jp	m, LABEL_6BB1
	ld	b, a
	inc	hl
LABEL_6B98:
	ld	a, (hl)
	outi
	inc	b
	or	(hl)
	outi
	inc	b
	or	(hl)
	outi
	dec  hl
	dec  hl
	dec  hl
	out	(Port_VDPData), a
	jp	nz, LABEL_6B98
	inc	hl
	inc	hl
	inc	hl
	jp	LABEL_6B90

LABEL_6BB1:
	and	$7F
	ld	b, a
	inc	hl
LABEL_6BB5:
	ld	a, (hl)
	outi
	inc	b
	or	(hl)
	outi
	inc	b
	or	(hl)
	outi
	push	af
	pop	af
	out	(Port_VDPData), a
	jp	nz, LABEL_6BB5
	jp	LABEL_6B90

Dungeon_GetRelativeSquareType:
	push	hl
	ld	a, (Dungeon_direction)
	and	$03
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	e, a
	ld	d, $00
	ld	hl, DungeonRelativeSquareOffsets
	add	hl, de
	ld	e, b
	add	hl, de
	ld	a, (Dungeon_position)
	add	a, (hl)
	ld	h, $CB
	ld	l, a
	ld	a, (hl)
	and	$07
	pop	hl
	ret

Dungeon_GetRelativeSquare:
	ld	a, (Dungeon_direction)
	and	$03
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	ld	e, a
	ld	d, $00
	ld	hl, DungeonRelativeSquareOffsets
	add	hl, de
	ld	e, b
	add	hl, de
	ld	a, (Dungeon_position)
	add	a, (hl)
	ld	h, $CB
	ld	l, a
	ld	a, (hl)
	and	$7F
	ret


; =================================================================
; Offsets of tile a certain distance away in the map. For a player at X facing right:
;
;      $0c $02 $05 $07
;  $0b [X] $01 $04 $08 $0a
;      $0d $03 $06 $09
DungeonRelativeSquareOffsets:
.db $00, $F0, $EF, $F1, $E0, $DF, $E1, $D0, $CF, $D1, $C0, $10, $FF, $01, $00, $00	; Up
.db $00, $01, $F1, $11, $02, $F2, $12, $03, $F3, $13, $04, $FF, $F0, $10, $00, $00	; Right
.db $00, $10, $11, $0F, $20, $21, $1F, $30, $31, $2F, $40, $F0, $01, $FF, $00, $00	; Down
.db $00, $FF, $0F, $EF, $FE, $0E, $EE, $FD, $0D, $ED, $FC, $01, $10, $F0, $00, $00	; Left
; =================================================================


LABEL_6C46:
	ld	a, c
	cp	$06
	jp	z, LABEL_6E38
	ret  nc

	ld	hl, $FFFF
	ld	(hl), :Bank06
	add	a, a
	ld	l, a
	add	a, a
	add	a, a
	ld	h, a
	add	a, a
	add	a, h
	add	a, l
	ld	l, a
	ld	h, $00
	ld	e, l
	ld	d, h
	add	hl, hl
	add	hl, de
	ld	de, LABEL_6E8B
	add	hl, de
	ld	b, $04
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_6C85
	call	LABEL_6D13
	ld	b, $02
	call	Dungeon_GetRelativeSquareType
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	push	bc
	call	LABEL_6D34
	ld	b, $03
	call	Dungeon_GetRelativeSquareType
	pop	bc
	jp	LABEL_6D34

LABEL_6C85:
	ld	de, $000C
	add	hl, de
	ld	b, $02
	call	Dungeon_GetRelativeSquareType
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	push	bc
	call	LABEL_6D45
	ld	b, $03
	call	Dungeon_GetRelativeSquareType
	pop	bc
	call	LABEL_6D45
	ld	b, $07
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_6CBF
	call	LABEL_6D13
	ld	b, $05
	call	Dungeon_GetRelativeSquareType
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	push	bc
	call	LABEL_6D34
	ld	b, $06
	call	Dungeon_GetRelativeSquareType
	pop	bc
	jp	LABEL_6D34

LABEL_6CBF:
	ld	de, $000C
	add	hl, de
	ld	b, $05
	call	Dungeon_GetRelativeSquareType
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	push	bc
	call	LABEL_6D45
	ld	b, $06
	call	Dungeon_GetRelativeSquareType
	pop	bc
	call	LABEL_6D45
	ld	b, $0A
	call	Dungeon_GetRelativeSquareType
	jr	z, LABEL_6CF9
	call	LABEL_6D13
	ld	b, $08
	call	Dungeon_GetRelativeSquareType
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	push	bc
	call	LABEL_6D34
	ld	b, $09
	call	Dungeon_GetRelativeSquareType
	pop	bc
	jp	LABEL_6D34

LABEL_6CF9:
	ld	de, $000C
	add	hl, de
	ld	b, $08
	call	Dungeon_GetRelativeSquareType
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	push	bc
	call	LABEL_6D45
	ld	b, $09
	call	Dungeon_GetRelativeSquareType
	pop	bc
	jp	LABEL_6D45

LABEL_6D13:
	push	af
	call	LABEL_6D21
	pop	af
	cp	$07
	jr	z, LABEL_6D21
	cp	$01
	jr	nc, LABEL_6D21
	xor	a
LABEL_6D21:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	call	nz, LoadTilemapRawRect
	pop	hl
	inc	hl
	ret

LABEL_6D34:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	call	z, LoadTilemapRawRect
	pop	hl
	inc	hl
	ret

LABEL_6D45:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	push	hl
	ld	h, (hl)
	ld	l, a
	call	z, LoadTilemapRawRect
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ret

LoadDungeonMap:
	ld	hl, $FFFF
	ld	(hl), :Bank15
	ld	a, (Dungeon_index)
	ld	h, a
	ld	l, $00
	srl  h
	rr   l
	ld	de, B15_DungeonLayouts
	add	hl, de
	ld	de, Dungeon_layout
	ld	b, $80
LABEL_6D6E:
	ld	a, (hl)
	rrca
	rrca
	rrca
	rrca
	and	$0F
	ld	(de), a
	inc	de
	ld	a, (hl)
	and	$0F
	ld	(de), a
	inc	de
	inc	hl
	djnz	LABEL_6D6E

Dungeon_LoadData:
	ld	hl, $FFFF
	ld	(hl), :Bank03
	ld	hl, Palette_DungeonSprites
	ld	de, Target_palette+$11
	ld	bc, $0007
	ldir
	ld	a, (Dungeon_index)
	add	a, a
	add	a, a
	ld	l, a
	ld	h, $00
	ld	de, DungeonData_B03
	add	hl, de
	ld	e, (hl) ; First byte = battle probability
	inc	hl
	ld	d, (hl) ; Second byte = Battle_enemy_pool_index
	ld	(Battle_rate), de
	inc	hl
	ld	a, (Dungeon_palette_index)
	or	a
	ld	a, (hl)
	jr	nz, LABEL_6DBB
	ld	e, a
	ld	a, (Dungeon_index)
	ld	hl, LABEL_6DFE
	ld	bc, $0006
	cpir
	ld	a, e
	jr	z, LABEL_6DBB
	ld	a, $FF
LABEL_6DBB:
	inc	a
	ld	(Dungeon_palette_index), a
	add	a, a
	add	a, a
	add	a, a
	ld	l, a
	ld	h, $00
	ld	de, Palette_Dungeons_B03
	add	hl, de
	ld	a, (hl)
	ld	(Target_palette), a
	ld	de, Target_palette+8
	ld	bc, $0008
	ldir
	ld	a, (Target_palette+9)
	ld	(Target_palette+8), a
	ld	a, (Target_palette+$D)
	ld	(Target_palette+$10), a
	ret


Dungeon_ChangeMusic:
	ld hl, $FFFF
	ld (hl), :Bank03
	ld a, (Dungeon_index)
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld de, DungeonSoundData_B03
	add hl, de
	ld a, (hl)
	jp Map_CheckMusic

Palette_DungeonSprites:
.db	$00, $3F, $30, $38, $03, $0B, $0F

LABEL_6DFE:
.db	$01, $02, $14, $15, $16, $21

LABEL_6E04:
	ld	a, ($C2F5)
	or	a
	ret  z

	inc	a
	ld	($C2F5), a
	ld	hl, $FFFF
	ld	(hl), :Bank20
	ld	h, $00
	ld	l, a
	add	hl, hl
	ld	de, LABEL_B20_BDB8
	add	hl, de
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	b, (hl)
	inc	hl
LABEL_6E20:
	push	bc
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
LABEL_6E27:
	ld	a, (hl)
	add	a, $80
	cp	$C0
	jr	c, LABEL_6E2F
	ld	(de), a
LABEL_6E2F:
	inc	de
	inc	de
	inc	hl
	djnz	LABEL_6E27
	pop	bc
	djnz	LABEL_6E20
	ret

LABEL_6E38:
	ld	b, $01
	call	Dungeon_GetRelativeSquare
	and	$07
	cp	$07
	jr	z, LABEL_6E04
	sub	$02
	ret  c

	bit  7, (hl)
	jr	z, LABEL_6E4C
	add	a, $06
LABEL_6E4C:
	ld	hl, $FFFF
	ld	(hl), :Bank06
	add	a, a
	ld	hl, LABEL_6E75
	add	a, l
	ld	l, a
	adc	a, h
	sub	l
	ld	h, a
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	ld	de, $D114
	ld	bc, $1218
LoadTilemapRawRect:
	push	bc
	push	de
	ld	b, $00
	ldir
	ex   de, hl
	pop	hl
	ld	bc, $0040
	add	hl, bc
	ex   de, hl
	pop	bc
	djnz	LoadTilemapRawRect
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
.db $68, $A6

DungeonTilesTable:
.db	:Bank07
.dw	LABEL_B07_8000

.db	:Bank04
.dw	LABEL_B04_8B0F

.db :Bank07
.dw	LABEL_B07_8A4B

.db :Bank04
.dw	LABEL_B04_8ED4

.db :Bank07
.dw	LABEL_B07_951E

.db :Bank04
.dw	LABEL_B04_92A4

.db :Bank07
.dw	LABEL_B07_9F6B

.db :Bank04
.dw	LABEL_B04_9673

.db :Bank07
.dw	LABEL_B07_AA13

.db :Bank04
.dw	LABEL_B04_9A34

.db :Bank08
.dw	LABEL_B08_8000

.db :Bank04
.dw	LABEL_B04_9E02

.db :Bank08
.dw	LABEL_B08_89ED

.db :Bank04
.dw	LABEL_B04_8906

.db :Bank08
.dw	LABEL_B08_A423

.db :Bank04
.dw	LABEL_B04_A1D3

.db :Bank09
.dw	LABEL_B09_83D1

.db :Bank04
.dw	LABEL_B04_A535

.db :Bank07
.dw	LABEL_B07_B422

.db :Bank04
.dw	LABEL_B04_A880

.db :Bank05
.dw	LABEL_B05_B1AF

.db :Bank04
.dw	LABEL_B04_ABA6

.db :Bank07
.dw	LABEL_B07_B422

.db :Bank04
.dw	LABEL_B04_AF5B

.db :Bank09
.dw	LABEL_B09_83D1

.db :Bank04
.dw	LABEL_B04_B33D

.db :Bank08
.dw	LABEL_B08_A423

.db :Bank04
.dw	LABEL_B04_B76C

.db :Bank08
.dw	LABEL_B08_89ED

.db :Bank04
.dw	LABEL_B04_8906

.db :Bank08
.dw	LABEL_B08_963F

.db :Bank28
.dw	LABEL_B28_A6C0

.db :Bank08
.dw	LABEL_B08_9D06

.db :Bank28
.dw	LABEL_B28_A935

.db :Bank05
.dw	LABEL_B05_AA27

.db :Bank28
.dw	LABEL_B28_ABD0

.db :Bank09
.dw	LABEL_B09_8000

.db :Bank28
.dw	LABEL_B28_AEC9

.db :Bank05
.dw	LABEL_B05_AA27

.db :Bank28
.dw	LABEL_B28_B20C

.db :Bank08
.dw	LABEL_B08_9D06

.db :Bank28
.dw	LABEL_B28_B5C2

.db :Bank08
.dw	LABEL_B08_963F

.db :Bank28
.dw	LABEL_B28_B95A

.db :Bank08
.dw	LABEL_B08_89ED

.db :Bank04
.dw	LABEL_B04_8906

.db :Bank09
.dw	LABEL_B09_8F4A

.db :Bank05
.dw	LABEL_B05_8000

.db :Bank09
.dw	LABEL_B09_9ABD

.db :Bank05
.dw	LABEL_B05_8367

.db :Bank09
.dw	LABEL_B09_A60D

.db :Bank05
.dw	LABEL_B05_8695

.db :Bank08
.dw	LABEL_B08_AF75

.db :Bank05
.dw	LABEL_B05_897A

.db :Bank04
.dw	LABEL_B04_8000

.db :Bank05
.dw	LABEL_B05_8C62

.db :Bank05
.dw	LABEL_B05_B830

.db :Bank05
.dw	LABEL_B05_8F18

.db :Bank08
.dw	LABEL_B08_B926

.db :Bank05
.dw	LABEL_B05_918F

.db :Bank08
.dw	LABEL_B08_89ED

.db :Bank04
.dw	LABEL_B04_8906

.db :Bank08
.dw	LABEL_B08_B926

.db :Bank05
.dw	LABEL_B05_93C6

.db :Bank05
.dw	LABEL_B05_B830

.db :Bank05
.dw	LABEL_B05_972E

.db :Bank04
.dw	LABEL_B04_8000

.db :Bank05
.dw	LABEL_B05_9AAD

.db :Bank08
.dw	LABEL_B08_AF75

.db :Bank05
.dw	LABEL_B05_9E7E

.db :Bank09
.dw	LABEL_B09_A60D

.db :Bank05
.dw	LABEL_B05_A248

.db :Bank09
.dw	LABEL_B09_9ABD

.db :Bank05
.dw	LABEL_B05_A612

.db :Bank09
.dw	LABEL_B09_8F4A

.db :Bank04
.dw	LABEL_B04_BBBE


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
	ld hl, Rotate_palette_flag
	ld a, (hl)
	dec (hl)
	jp m, +
	ld a, (Scroll_direction)
	ld c, a
	jp ++

+:
	ld (hl), $00
	ld a, (Ctrl_1_held)
	and ButtonUp_Mask|ButtonDown_Mask|ButtonLeft_Mask|ButtonRight_Mask
	or $80
	ld c, a
	ld a, (Vehicle_movement_flags)
	or a
	ld a, $0F
	jr z, +
	ld a, $07
+:
	ld ($C265), a
++:
	ld de, $0001
	ld a, (Vehicle_movement_flags)
	or a
	jr z, +
	inc e
+:
	ld a, (V_scroll)
	ld d, a
	ld hl, (V_location)
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
	ld (Scroll_direction), a
	ld a, $FF
	ld ($C2D2), a
	ld a, d
	ld (V_scroll), a
	ld a, h
	and $07
	ld h, a
	ld (V_location), hl
	cp b
	call nz, DecompressScrollTilemap
	jp LABEL_733A

++++:
	ld d, $00
	ld hl, (H_location)
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
	ld (Scroll_direction), a
	ld a, $FF
	ld ($C2D2), a
	ld a, l
	neg
	ld (H_scroll), a
	ld a, h
	and $07
	ld h, a
	ld (H_location), hl
	cp b
	jp nz, DecompressScrollTilemap
	jp LABEL_72A6

+++:
	ld a, $D6
	ld (Sound_index), a
	xor a
	ld ($C2D2), a
	ld (Scroll_direction), a
	ld ($C265), a
	ret

DecompressScrollTilemap:
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
	ld a, (H_location+1)
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
	ld a, (Scroll_direction)
	and $0C
	ret z
	ld b, a
	ld a, ($C263)
	ld ($FFFF), a
	ld c, $00
	ld a, (H_location)
	and $07
	jr z, +
	ld a, b
	and $08
	jr nz, +
	ld c, $08
+:
	ld a, (V_scroll)
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, (H_location)
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
	ld a, (V_location)
	and $F0
	ld l, a
	ld a, (H_location)
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
	ld a, (Scroll_direction)
	and $03
	ret z
	ld b, a
	and $01
	ld a, ($C263)
	ld ($FFFF), a
	ld a, (V_scroll)
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
	ld a, (H_location)
	rrca
	rrca
	and $3C
	add a, l
	ld e, a
	ld a, h
	add a, $D0
	ld d, a
	ld a, (V_location)
	and $F0
	add a, b
	ld l, a
	adc a, $00
	sub l
	ld h, a
	ld a, (H_location)
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

UpdateScrollingTilemap:
	ld a, (Scroll_direction)
	and $0F
	ret z
	ld b, a
	and $03
	ld a, ($C263)
	ld ($FFFF), a
	jp nz, ++
	ld c, $00
	ld a, (H_location)
	and $07
	jr z, +
	ld a, b
	and $08
	jr nz, +
	ld c, $08
+:
	ld a, (H_location)
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
	ld a, (V_scroll)
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

FillTilemap:
	call LABEL_7602
	ld a, ($C263)
	ld ($FFFF), a
	ld a, (V_scroll)
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, (H_location)
	rrca
	rrca
	and $3C
	add a, l
	ld e, a
	ld a, h
	add a, $D0
	ld d, a
	ld a, (V_location)
	and $F0
	ld l, a
	ld a, (H_location)
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
	ld a, (Vehicle_movement_flags)
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
	ld (Sound_index), a
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
	ld a, (V_location)
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
	ld a, (H_location)
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
	ld a, (V_scroll)
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
	ld a, (H_location)
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
	ld a, (Vehicle_movement_flags)
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
	ld a, (V_location)
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
	ld a, (H_location)
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
	ld hl, (V_location)
	ld a, l
	add a, $10
	cp $C0
	jr c, +
	add a, $40
	inc h
+:
	ld l, a
	ld (V_location), hl
	ld ($C311), hl
++:
	ld hl, (H_location)
	add hl, de
	ld (H_location), hl
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
	ld de, (V_location)
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
	ld (V_location), de
	ld ($C311), de
	inc hl
	ld a, (hl)
	ld e, a
	rlca
	sbc a, a
	ld d, a
	ld hl, (H_location)
	add hl, de
	ld (H_location), hl
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
	ld a, (V_location)
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
	ld a, (H_location)
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
	ld (Scene_type), a
	ld a, b
	and $08
	jr nz, ++
	ld a, b
	and $04
	jp nz, LABEL_792A
	ld a, (Vehicle_movement_flags)
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
	ld hl, (V_location)
	ld ($C311), hl
	ld hl, (H_location)
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
	ld de, (V_location)
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
	ld hl, (H_location)
	add hl, bc
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, h
	ld hl, $FFFF
	ld (hl), :Bank03
	ld hl, (Dungeon_entrance_points_addr)
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
	ld	(Game_mode), a
	inc	hl
LABEL_787B:
	ld	a, (hl)
	ld	($C308), a
	ld	(Location_index), a
	inc	hl
	ld	e, (hl)
	ld	d, $00
	ex   de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, l
	sub	$60
	jr	c, LABEL_7894
	cp	$C0
	jr	c, LABEL_7897
LABEL_7894:
	sub	$40
	dec  h
LABEL_7897:
	ld	l, a
	ld	a, h
	and	$07
	ld	h, a
	ld	(V_location), hl
	ld	($C311), hl
	ex   de, hl
	inc	hl
	ld	a, (hl)
	sub	$08
	and	$7F
	ld	l, a
	ld	h, $00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	(H_location), hl
	ld	($C313), hl
	xor	a
	ld	(Vehicle_movement_flags), a
	jp	LABEL_7908


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
	ld (V_location), hl
	ld hl, ($C313)
	ld (H_location), hl
	xor a
	ld (Vehicle_movement_flags), a
	jp LABEL_7908

+:
	cp $0C
	ret nz
	ld (Game_mode), a
	inc hl
	ld a, (hl)
	ld (Scene_type), a
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld ($C2DB), hl
	xor a
	ld (Battle_flag), a
	ld hl, ($C311)
	ld (V_location), hl
	ld hl, ($C313)
	ld (H_location), hl

LABEL_7908:
	ld	a, ($C810)
	ld	($C2D7), a
	ld	hl, $C26F
	ld	de, $C270
	ld	bc, $0017
	ld	(hl), $00
	ldir
	ld	hl, $C800
	ld	de, $C801
	ld	bc, $00FF
	ld	(hl), $00
	ldir
	pop	hl
	ret


LABEL_792A:
	ld a, ($C2E5)
	cp $4C
	jp nz, +
	ld a, (Location_index)
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
	ld (V_location), hl
	ld hl, ($C313)
	ld (H_location), hl
	jp LABEL_7908

+:
	cp $5E
	jp nz, +
	ld a, (Vehicle_movement_flags)
	or a
	ret nz
	ld a, $35
	call Inventory_FindItem
	ret z
	ld hl, $00A0
	ld ($C2DB), hl
LABEL_7972:
	ld a, $0C ; GameMode_LoadScene
	ld (Game_mode), a
	ld hl, ($C311)
	ld (V_location), hl
	ld hl, ($C313)
	ld (H_location), hl
	jp LABEL_7908

+:
	cp $5F
	ret c
	cp $64
	jp nc, +
	ld a, (Vehicle_movement_flags)
	cp $08
	ret z
	call LABEL_7BC4
	ld c, $02
	jp LABEL_79E2

+:
	cp $AD
	jp nz, +
	ld a, (Location_index)
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
	ld a, (Vehicle_movement_flags)
	or a
	ret nz
	ld a, $FF
	ld (Battle_flag), a
	ld a, $19
	ld (Battle_enemy_id), a
	jp LABEL_7972

+:
	cp $C7
	ret c
	cp $D2
	ret nc
	ld a, $3B
	call Inventory_FindItem
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
	ld a, $0C ; GameMode_LoadScene
	ld (Game_mode), a
	jp LABEL_7908

+:
	call IsCharacterAlive
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
	ld	hl, $2009
	ld	(Fade_timer), hl
LABEL_7B0B:
	ld	a, $16
	call	WaitForVInt
	ld	a, (Fade_timer)
	or	a
	jp	nz, LABEL_7B0B
	ret

FadeIn:
	ld	hl, $1089
	ld	(Fade_timer), hl
	jr	LABEL_7B33

FadeIn2:
	ld	hl, $2089
	ld	(Fade_timer), hl
	ld	hl, Normal_palette
	ld	de, $C221
	ld	bc, $001F
	ld	(hl), $00
	ldir
LABEL_7B33:
	ld	a, $16
	call	WaitForVInt
	ld	a, (Fade_timer)
	or	a
	jp	nz, LABEL_7B33
	ret


FadePaletteInRAM:
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
	ld hl, Normal_palette
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
	ld de, Normal_palette
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

ScreenFlash:
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
	ld a, (Battle_enemy_id)
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

FlashPaletteInRAM:
	ld a, ($C2BE)
	or a
	ret z
	dec a
	ld ($C2BE), a
	rrca
	jp c, +
	ld hl, $C240
	ld de, Normal_palette
	ld bc, $0020
	ldir
	ret

+:
	ld hl, ($C2C0)
	ld b, h
	ld a, l
	ld hl, Normal_palette
	add a, l
	ld l, a
	ld a, $3F
-:
	ld (hl), a
	inc hl
	djnz -
	ret

Palette_Rotate:
	ld a, (Vehicle_movement_flags)
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
	ld (Sound_index), a
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
	ld hl, Normal_palette
	ld de, $C000
	rst $08
	ld c, $BE
	jp GoToOuti32


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

Palette_Animate:
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

Ending_FadeSky:
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
	ld (Normal_palette), a
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


; =================================================================
TileCharacterTable:
.db	$C0, $C0	; 0
.db	$C0, $E8	; 1
.db	$EB, $C0	; 2
.db	$C0, $C0	; 3
.db	$C0, $C0	; 4
.db	$C0, $C0	; 5
.db	$C0, $C0	; 6
.db	$E5, $C0	; 7
.db	$C0, $C0	; 8
.db	$C0, $C0	; 9
.db	$C0, $C0	; $A
.db	$C0, $C0	; $B
.db	$C0, $E5	; $C
.db	$C0, $EA	; $D
.db	$C0, $E7	; $E
.db	$C0, $C0	; $F
.db	$C0, $C1	; $10
.db	$C0, $C2	; $11
.db	$C0, $C3	; $12
.db	$C0, $C4	; $13
.db	$C0, $C5	; $14
.db	$C0, $C6	; $15
.db	$C0, $C7	; $16
.db	$C0, $C8	; $17
.db	$C0, $C9	; $18
.db	$C0, $CA	; $19
.db	$C0, $C0	; $1A
.db	$C0, $E6	; $1B
.db	$C0, $C0	; $1C
.db	$C0, $C0	; $1D
.db	$C0, $C0	; $1E
.db	$C0, $E9	; $1F
.db	$E5, $C0	; $20
.db	$C0, $CB	; $21
.db	$C0, $CC	; $22
.db	$C0, $CD	; $23
.db	$C0, $CE	; $24
.db	$C0, $CF	; $25
.db	$C0, $D0	; $26
.db	$C0, $D1	; $27
.db	$C0, $D2	; $28
.db	$C0, $D3	; $29
.db	$C0, $D4	; $2A
.db	$C0, $D5	; $2B
.db	$C0, $D6	; $2C
.db	$C0, $D7	; $2D
.db	$C0, $D8	; $2E
.db	$C0, $D9	; $2F
.db	$C0, $DA	; $30
.db	$C0, $DB	; $31
.db	$C0, $DC	; $32
.db	$C0, $DD	; $33
.db	$C0, $DE	; $34
.db	$C0, $DF	; $35
.db	$C0, $E0	; $36
.db	$C0, $E1	; $37
.db	$C0, $E2	; $38
.db	$C0, $E3	; $39
.db	$C0, $E4	; $3A
.db	$C0, $C0	; $3B
.db	$C0, $C0	; $3D
.db	$C0, $C0	; $3E
.db	$C0, $C0	; $3F
.db	$C0, $C0	; $40
.db	$C0, $C0	; $41
.db	$C0, $C0	; $42
.db	$C0, $C0	; $43
.db	$C0, $C0	; $44
.db	$C0, $C0	; $45
.db	$C0, $C0	; $46
; =================================================================


; =================================================================
ItemNames:
.db	"        "
.db	"WOODCANE"
.db	"SHT. SWD"
.db	"IRN. SWD"
.db	"WAND", Dialogue_Terminator65, "   "
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
.db	"GLOVE", Dialogue_Terminator65, "  "
.db	"LASR.SLD"
.db	"MIRR.SLD"
.db	"LAC. SLD"
.db	"LANDROVR"
.db	"HOVRCRFT"
.db	"ICE DIGR"
.db	"COLA", Dialogue_Terminator65, "   "
.db	"BURGER", Dialogue_Terminator65, " "
.db	"FLUTE", Dialogue_Terminator65, "  "
.db	"FLASH", Dialogue_Terminator65, "  "
.db	"ESCAPER", Dialogue_Terminator65
.db	"TRANSER", Dialogue_Terminator65
.db	"MAGC HAT"
.db	"ALSULIN", Dialogue_Terminator65
.db	"POLYMTRL"
.db	"DUGN KEY"
.db	"SPHERE", Dialogue_Terminator65, " "
.db	"TORCH", Dialogue_Terminator65, "  "
.db	"PRISM", Dialogue_Terminator65, "  "
.db	"NUTS", Dialogue_Terminator65, "   "
.db	"HAPSBY", Dialogue_Terminator65, " "
.db	"ROADPASS"
.db	"PASSPORT"
.db	"COMPASS", Dialogue_Terminator65
.db	"CAKE", Dialogue_Terminator65, "   "
.db	"LETTER", Dialogue_Terminator65, " "
.db	"LAC. POT"
.db	"MAG.LAMP"
.db	"AMBR EYE"
.db	"GAS. SLD"
.db	"CRYSTAL", Dialogue_Terminator65
.db	"M SYSTEM"
.db	"MRCL KEY"
.db	"ZILLION", Dialogue_Terminator65
.db	"SECRETS", Dialogue_Terminator65
; =================================================================


; =================================================================
; bits 0-1 = 0 = Weapon; 1 = Armor; 2 = Shield
; bit 2 = If set, item cannot be thrown away
; bit 4 = If set, Alis can equip item
; bit 5 = If set, Myau can equip item
; bit 6 = If set, Odin can equip item
; bit 7 = If set, Noah can equip item
; =================================================================
ItemData:
.db	$00	; 0
.db	$D0	; 1
.db	$D0	; 2
.db	$50	; 3
.db	$D0	; 4
.db $20	; 5
.db	$40	; 6
.db	$50	; 7
.db	$50	; 8
.db	$40	; 9
.db	$20	; $A
.db	$40	; $B
.db	$50	; $C
.db $40	; $D
.db	$50	; $E
.db	$40	; $F
.db	$51	; $10
.db	$81	; $11
.db	$51	; $12
.db	$41	; $13
.db	$21	; $14
.db $51	; $15
.db	$51	; $16
.db	$41	; $17
.db	$81	; $18
.db	$52	; $19
.db	$42	; $1A
.db	$52	; $1B
.db	$52	; $1C
.db $22	; $1D
.db	$D2	; $1E
.db	$46	; $1F
.db	$52	; $20
.db	$04	; $21
.db	$04	; $22
.db	$04	; $23
.db	$00	; $24
.db $00	; $25
.db	$00	; $26
.db	$00	; $27
.db	$00	; $28
.db	$00	; $29
.db	$00	; $2A
.db	$04	; $2B
.db	$00	; $2C
.db $04	; $2D
.db	$00	; $2E
.db	$04	; $2F
.db	$04	; $30
.db	$04	; $31
.db	$04	; $32
.db	$04	; $33
.db	$00	; $34
.db $04	; $35
.db	$00	; $36
.db	$04	; $37
.db	$04	; $38
.db	$00	; $39
.db	$04	; $3A
.db	$00	; $3B
.db	$00	; $3C
.db $00	; $3D
.db	$04	; $3E
.db	$00	; $3F
; =================================================================


; =================================================================
; Filler
.db	$FF
.db	$FF
.db	$FF
.db	$FF
.db	$FF
; =================================================================


; =================================================================
RomHeader:
.db	"TMR SEGA"
.db	$FF, $FF	; Reserved
.dw	$EAD8		; Checksum
.dw	$9500		; Product Code
.db	$03			; Version
.db	$40			; Region Code (SMS Export)
; =================================================================

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
.db "I", Dialogue_Apostrophe, "M SUELO. I ", Word_Know, Dialogue_NewLine
.db "HOW ", Word_You_Must, " FEEL,", Dialogue_NewPage
.db "DEAR,NO ", Word_One, " CAN", Dialogue_NewLine
.db "STOP ", Word_You, Word_From, Dialogue_NewPage
.db "DOING WHAT ", Word_You, Dialogue_NewLine
.db Word_Know, " ", Word_You_Must, " DO.", Dialogue_NewPage

Dialogue_Index_0004:
.db "BUT IF ", Word_You, "SHOULD", Dialogue_NewLine
.db "EVER BE WOUNDED", Dialogue_NewPage
.db "IN BATTLE,COME", Dialogue_NewLine
.db Word_Here, " TO ", Word_Rest, ".", Dialogue_Terminator65

Dialogue_Index_0006:
.db Word_Please, Word_Rest, Dialogue_NewLine
.db Word_Yourself, ".", Dialogue_NewPage
.db Word_You, Word_Are, Word_Welcome, Dialogue_NewLine
.db Word_Here, " AT ", Word_Any, Word_Time, ".", Dialogue_Terminator65

Dialogue_Index_0008:
.db "I", Dialogue_Apostrophe, "M NEKISE. ", Word_One, Dialogue_NewLine
.db "HEARS LOTS OF", Dialogue_NewPage

Dialogue_Index_000A:
.db "STORIES, ", Word_You, Word_Know, ",BUT ", Word_Some, " SAY ", Word_That, Dialogue_NewPage
.db "A FIGHTER ", Word_Named, Dialogue_NewLine
.db "ODIN LIVES IN A", Dialogue_NewPage
.db Word_Town, " CALLED ", Word_Scion, ".", Dialogue_NewLine

Dialogue_Index_000C:
.db "ALSO, I ", Word_Have, "A", Dialogue_NewPage
.db Word_Laconian_Pot, " GIVEN", Dialogue_NewLine

Dialogue_Index_000E:
.db "BY ", Word_Nero, ". ", Word_That, Dialogue_NewPage
.db "WOULD BE HELPFUL", Dialogue_NewLine
.db "TO ", Word_You, "IN ", Word_Your, Dialogue_NewPage
.db "TASK.", Dialogue_Terminator65

Dialogue_Index_0010:
.db "I ", Word_Wish, " I COULD", Dialogue_NewLine
.db Word_Help, " ", Word_You, "MORE.", Dialogue_NewPage
.db "I PRAY FOR ", Word_Your, Dialogue_NewLine
.db "SAFETY.", Dialogue_Terminator65

Dialogue_Index_0012:
.db Word_The, "CAMINEET", Dialogue_NewLine
.db Word_Residential_Area, Dialogue_NewPage
.db "IS UNDER", Dialogue_NewLine
.db "MARTIAL LAW.", Dialogue_Terminator65

Dialogue_Index_0014:
.db Word_You, "NEED A", Dialogue_NewLine
.db Word_Dungeon, " KEY TO", Dialogue_NewPage
.db "OPEN LOCKED DOORS.", Dialogue_Terminator65

Dialogue_Index_0016:
.db "IN ", Word_Some, " ", Word_Dungeon, "S", Dialogue_NewLine
.db Word_You_Will, " ", Word_Not, "GET", Dialogue_NewPage
.db "FAR WITHOUT ", Word_Some, Dialogue_NewLine
.db "SORT OF LIGHT.", Dialogue_Terminator65

Dialogue_Index_0018:
.db Word_There_Is, " A", Dialogue_NewLine
.db Word_Spaceport, " TO ", Word_The, Dialogue_NewPage
.db "WEST OF CAMINEET.", Dialogue_Terminator65

Dialogue_Index_001A:
.db "IF ", Word_You, Word_Want, "TO", Dialogue_NewLine
.db "MAKE A DEAL, ", Word_You, Dialogue_NewPage
.db "SHOULD HEAD FOR", Dialogue_NewLine
.db Word_The, "PORT ", Word_Town, ".", Dialogue_Terminator65

Dialogue_Index_001C:
.db Word_You, "HAD BETTER", Dialogue_NewLine
.db Word_Not, "LEAVE ", Word_The, Dialogue_NewPage
.db Word_Residential_Area, ".", Dialogue_Terminator65

Dialogue_Index_001E:
.db "UNLESS ", Word_You, "HOPE TODIE, ", Word_You, "HAD BEST", Dialogue_NewPage
.db "STAY ", Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_0020:
.db Word_You, "MAY ", Word_Not, Word_Pass, ".", Dialogue_Terminator65

Dialogue_Index_0022:
.db Word_You, Word_Cannot, " ", Word_Pass, Dialogue_NewLine
.db "WITHOUT ", Word_Roadpass, ".", Dialogue_Terminator65

Dialogue_Index_0024:
.db Word_You, "MAY PROCEED.", Dialogue_Terminator65

Dialogue_Index_0026:
.db Word_This, "IS PAROLIT", Dialogue_NewLine
.db Word_Residential_Area, ".", Dialogue_Terminator65

Dialogue_Index_0028:
.db Word_The, Word_Forest, " IS A", Dialogue_NewLine
.db "DANGEROUS PLACE.", Dialogue_Terminator65

Dialogue_Index_002A:
.db Word_Medusa, " HAS BEEN", Dialogue_NewLine
.db "REBORN AND LIVES", Dialogue_NewPage
.db "IN A CAVE TO ", Word_The, Dialogue_NewLine
.db "SOUTH. IF ", Word_You, "SEE", Dialogue_NewPage

Dialogue_Index_002C:
.db "HER, ", Word_You_Will, " BE", Dialogue_NewLine
.db Word_Turned_To_Stone, ".", Dialogue_Terminator65

Dialogue_Index_002E:
.db "TO ", Word_The, "EAST LIES", Dialogue_NewLine
.db "A PORT ", Word_Town, Dialogue_NewPage
.db "CALLED ", Word_Scion, ".", Dialogue_Terminator65

Dialogue_Index_0030:
.db Word_From, Word_The, Word_Spaceport, Dialogue_NewLine
.db Word_You, "CAN GO TO", Dialogue_NewPage
.db "PASEO ON ", Word_Motavia, ".", Dialogue_Terminator65

Dialogue_Index_0032:
.db Word_There_Is, " AN", Dialogue_NewLine
.db "UNDERGROUND", Dialogue_NewPage
.db Word_Passage, " TO ", Word_The, Dialogue_NewLine
.db Word_Gothic, " ", Word_Forest, Dialogue_NewPage
.db Word_Some, Word_Where, " TO ", Word_The, Dialogue_NewLine
.db "WEST OF PAROLIT.", Dialogue_Terminator65

Dialogue_Index_0034:
.db "ODIN SET OFF TO", Dialogue_NewLine
.db "KILL ", Word_Medusa, ". HE", Dialogue_NewPage

Dialogue_Index_0036:
.db "WENT WITH AN", Dialogue_NewLine
.db "ANIMAL ", Word_That, " CAN", Dialogue_NewPage
.db "SPEAK! ", Word_The, "ANIMAL", Dialogue_NewLine
.db "HAD A BOTTLE OF", Dialogue_NewPage

Dialogue_Index_0038:
.db "MEDICINE HANGING", Dialogue_NewLine
.db Word_From, "ITS NECK, BUT", Dialogue_NewPage
.db "I DON", Dialogue_Apostrophe, "T ", Word_Know, " WHAT", Dialogue_NewLine
.db Word_That, " IS FOR.", Dialogue_Terminator65

Dialogue_Index_003A:
.db "I HEAR ", Word_You, Word_Are, Dialogue_NewLine
.db "GOING TO TRY", Dialogue_NewPage
.db "TO KILL ", Word_Lassic, ".", Dialogue_NewLine
.db "BEST OF LUCK!", Dialogue_Terminator65

Dialogue_Index_003C:
.db "I RECENTLY FOUND ATALKING BEAST IN", Dialogue_NewPage
.db Word_The, "CAVE ", Word_Where, Dialogue_NewLine
.db Word_Medusa, " LIVES.", Dialogue_NewPage

Dialogue_Index_003E:
.db "I SOLD HIM FOR A", Dialogue_NewLine
.db "GOOD PRICE TO A", Dialogue_NewPage
.db "MERCHANT ", Word_From, Dialogue_NewLine
.db "PASEO!", Dialogue_Terminator65

Dialogue_Index_0040:
.db "TIMES ", Word_Are, "HARD.", Dialogue_NewLine
.db Word_There, " DOESN", Dialogue_Apostrophe, "T SEEM", Dialogue_NewPage
.db "TO BE ", Word_Any, "WAY TO", Dialogue_NewLine
.db "MAKE M", Word_One, "Y.", Dialogue_Terminator65

Dialogue_Index_0042:
.db "A CAVE CALLED IALACAN BE FOUND ON", Dialogue_NewPage
.db Word_The, "PENINSULA TO", Dialogue_NewLine
.db Word_The, "SOUTH OF ", Word_Scion, Dialogue_Terminator65

Dialogue_Index_0044:
.db Word_This, "IS ", Word_The, "PORT", Dialogue_NewLine
.db Word_Town, " ", Word_Scion, ".", Dialogue_NewPage
.db "LONG AGO, WE", Dialogue_NewLine
.db "THRIVED ON TRADE.", Dialogue_Terminator65

Dialogue_Index_0046:
.db Word_You, "NEED A COMPASSTO ", Word_Pass, " ", Word_Through, Dialogue_NewPage
.db Word_The, "EPPI ", Word_Forest, ".", Dialogue_Terminator65

Dialogue_Index_0048:
.db "A DOOR LOCKED WITH", Word_Magic_84, "CAN ONLY BE", Dialogue_NewPage
.db "OPENED WITH ", Word_Magic_EF, ".", Dialogue_Terminator65

Dialogue_Index_004A:
.db Word_There_Is, " A ", Word_Hill, Dialogue_NewLine
.db Word_Named, Word_Baya_Malay, Dialogue_NewPage
.db "TO ", Word_The, "NORTH OF", Dialogue_NewLine
.db Word_This, Word_Town, ".", Dialogue_NewPage
.db "BUT N", Word_One, " OF US", Dialogue_NewLine
.db "D", Word_Are, "APPROACH IT.", Dialogue_Terminator65

Dialogue_Index_004C:
.db "A CAVE CALLED", Dialogue_NewLine
.db "NAULA LIES ON ", Word_The, Dialogue_NewPage
.db "NORTH COAST OF", Dialogue_NewLine
.db Word_Baya_Malay, ".", Dialogue_Terminator65

Dialogue_Index_004E:
.db Word_The, Word_Governor, " OF", Dialogue_NewLine
.db Word_Motavia, " MIGHT", Dialogue_NewPage
.db "POSSIBLY ", Word_Help, " ", Word_You, "WELL.", Dialogue_Terminator65

Dialogue_Index_0050:
.db "NOAH LIVES ON", Dialogue_NewLine
.db Word_Motavia, ".", Dialogue_Terminator65

Dialogue_Index_0052:
.db "DR.", Word_Luveno, " HAD A", Dialogue_NewLine
.db Word_Laboratory, " IN ", Word_The, Dialogue_NewPage
.db Word_Gothic, " ", Word_Forest, " LONGAGO, IT IS SAID.", Dialogue_Terminator65

Dialogue_Index_0054:
.db Word_Welcome, "TO EPPI.", Dialogue_Terminator65

Dialogue_Index_0056:
.db Word_Are, Word_You, "LOOKING", Dialogue_NewLine
.db "FOR A ", Word_Dungeon, " KEY?", Dialogue_Terminator62

Dialogue_Index_0058:
.db "I", Dialogue_Apostrophe, "VE HIDDEN A", Dialogue_NewLine
.db Word_Dungeon, " KEY IN THE", Dialogue_NewPage

Dialogue_Index_005A:
.db "WAREHOUSE IN ", Word_The, Dialogue_NewLine
.db "OUTSKIRTS OF ", Word_The, Dialogue_NewPage
.db "CAMINEET.", Dialogue_Terminator65

Dialogue_Index_005C:
.db Word_Do_You_Know, " WHAT", Dialogue_NewLine
.db Word_The, "HARDEST,", Dialogue_NewPage
.db "STRONGEST MATERIALIN OUR ", Word_World, " IS?", Dialogue_Terminator62

Dialogue_Index_005E:
.db "IT", Dialogue_Apostrophe, "S ", Word_Laconia, "!", Dialogue_NewLine
.db "ARMS MADE WITH", Dialogue_NewPage
.db Word_Laconia, " ", Word_Are, Word_The, Dialogue_NewLine
.db "BEST TO HAVE.", Dialogue_Terminator65

Dialogue_Index_0060:
.db "O.K. GOOD DAY.", Dialogue_Terminator65

Dialogue_Index_0062:
.db Word_Do_You_Know, " ABOUT", Dialogue_NewLine
.db Word_The, Word_Planets, " OF", Dialogue_NewPage
.db Word_The, Word_Algol, " STAR", Dialogue_NewLine
.db Word_System, "?", Dialogue_Terminator62

Dialogue_Index_0064:
.db Word_There_Are, " THREE", Dialogue_NewLine
.db Word_Planets, "; ", Word_Palma, Dialogue_NewPage
.db Word_Motavia, " AND", Dialogue_NewLine
.db Word_Dezoris, ".", Dialogue_NewPage

Dialogue_Index_0066:
.db Word_Palma, " IS A ", Word_World, Dialogue_NewLine
.db "OF GREEN.", Dialogue_NewPage
.db Word_Motavia, " IS A ", Word_World, Dialogue_NewLine
.db "OF SAND.", Dialogue_NewPage
.db Word_Dezoris, " IS A ", Word_World, Dialogue_NewLine
.db "OF ICE.", Dialogue_NewPage

Dialogue_Index_0068:
.db Word_The, Word_Algol, " STAR", Dialogue_NewLine
.db Word_System, " IS", Dialogue_NewPage
.db Word_Currently, " ", Word_Facing, Dialogue_NewLine
.db "A ", Word_Great, "CRISIS.", Dialogue_Terminator65

Dialogue_Index_006A:
.db Word_This, "IS PALMA", Dialogue_Apostrophe, "S", Dialogue_NewLine
.db Word_Spaceport, ".", Dialogue_NewPage
.db Word_From, Word_The, Word_Spaceport, Dialogue_NewLine
.db Word_You, "CAN GO TO", Dialogue_NewPage
.db "PASEO ON ", Word_Motavia, ".", Dialogue_Terminator65

Dialogue_Index_006C:
.db Word_The, Word_Governor, " IS INPASEO. HE RULES", Dialogue_NewPage
.db "ALL OF ", Word_Motavia, ".", Dialogue_Terminator65

Dialogue_Index_006E:
.db "LONG AGO, A", Dialogue_NewLine
.db Word_Spaceship, " WAS", Dialogue_NewPage
.db "BUILT IN ", Word_The, Dialogue_NewLine
.db Word_Gothic, " ", Word_Laboratory, ".", Dialogue_Terminator65

Dialogue_Index_0070:
.db Word_Do_You_Have, " ", Word_Your, Dialogue_NewLine
.db Word_Passport, "?", Dialogue_Terminator62

Dialogue_Index_0072:
.db Word_You, "CAN FILE FOR A", Dialogue_NewLine
.db Word_Passport, " ", Word_Here, ".", Dialogue_NewPage
.db Word_Do_You, " ", Word_Want, "A", Dialogue_NewLine
.db Word_Passport, "?", Dialogue_Terminator62

Dialogue_Index_0074:
.db Word_Have, Word_You, "EVER D", Word_One, Dialogue_NewLine
.db Word_Any, Word_Thing, " ILLEGAL? ", Dialogue_Terminator62

Dialogue_Index_0076:
.db Word_Do_You, " CURRENTLY", Dialogue_NewLine
.db Word_Have, "AN ILLNESS?", Dialogue_Terminator62

Dialogue_Index_0078:
.db Word_The, Word_Passport, " FEE", Dialogue_NewLine
.db "IS 100 ", Word_Mesetas, ".", Dialogue_NewPage
.db "WOULD ", Word_You, "PAY IT?", Dialogue_Terminator62

Dialogue_Index_007A:
.db Word_Your, Word_Passport, " IS", Dialogue_NewLine
.db "READY, ", Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_007C:
.db Word_I_See, ". ", Word_Have, "A GOODDAY.", Dialogue_Terminator65

Dialogue_Index_007E:
.db Word_That, Dialogue_Apostrophe, "S ", Word_Not, "GOOD.", Dialogue_NewLine
.db "YOU", Dialogue_Apostrophe, "LL ", Word_Have, "TO", Dialogue_NewPage
.db "COME BACK LATER.", Dialogue_Terminator65

Dialogue_Index_0080:
.db Word_Welcome, "TO ", Word_The, Dialogue_NewLine
.db "PASEO ", Word_Spaceport, Dialogue_NewPage
.db "ON ", Word_Motavia, ".", Dialogue_Terminator65

Dialogue_Index_0082:
.db "IT IS SAID ", Word_That, Dialogue_NewLine
.db Word_Ant_Lion, "S ROAM", Dialogue_NewPage
.db "IN ", Word_The, "DESERT.", Dialogue_Terminator65

Dialogue_Index_0084:
.db Word_There_Is, " A CAKE", Dialogue_NewLine
.db "SHOP IN ", Word_The, "CAVE", Dialogue_NewPage
.db "CALLED NAULA ON", Dialogue_NewLine
.db Word_Palma, "!", Dialogue_Terminator65

Dialogue_Index_0086:
.db Word_Motavia, Dialogue_Apostrophe, "S ", Word_Governor, "AND ", Word_Lassic, " ", Word_Are, "NOT", Dialogue_NewPage
.db "ON GOOD TERMS, IT", Dialogue_NewLine
.db "IS SAID.", Dialogue_Terminator65

Dialogue_Index_0088:
.db "A GIFT IS NEEDED", Dialogue_NewLine
.db "IF ", Word_You, Word_Wish, " TO SEE", Dialogue_NewPage
.db Word_The, Word_Governor, ".", Dialogue_Terminator65

Dialogue_Index_008A:
.db Word_The, Word_Governor, " LOVESSWEETS, I HEAR.", Dialogue_Terminator65

Dialogue_Index_008C:
.db Word_There_Is, " A CAVE", Dialogue_NewLine
.db "CALLED ", Word_Maharu, " IN", Dialogue_NewPage
.db "A ", Word_Mountain, " TO ", Word_The, Dialogue_NewLine
.db "NORTH OF PASEO.", Dialogue_Terminator65

Dialogue_Index_008E:
.db Word_This, "IS PASEO", Dialogue_NewLine
.db Word_Motavia, Dialogue_Apostrophe, "S CAPITAL.", Dialogue_Terminator65

Dialogue_Index_0090:
.db "IT", Dialogue_Apostrophe, "S ", Word_Not, "POSSIBLE", Dialogue_NewLine
.db "TO ", Word_Pass, " ", Word_Through, Dialogue_NewPage
.db Word_Ant_Lion, " ON FOOT.", Dialogue_Terminator65

Dialogue_Index_0092:
.db "I ", Word_Have, "AN RARE", Dialogue_NewLine
.db "ANIMAL ", Word_Here, ". WOULD", Dialogue_NewPage
.db Word_You, "PAY 1 BILLION", Dialogue_NewLine
.db Word_Mesetas, " FOR IT?", Dialogue_Terminator62

Dialogue_Index_0094:
.db Word_You, Word_Are, "A LIAR!", Dialogue_Terminator65

Dialogue_Index_0096:
.db Word_I_See, " ", Word_You, Word_Have, "A", Dialogue_NewLine
.db Word_Strange, " POT.", Dialogue_NewPage

Dialogue_Index_0098:
.db "SHALL I TRADE ", Word_The, Dialogue_NewLine
.db "ANIMAL FOR IT?", Dialogue_Terminator62

Dialogue_Index_009A:
.db "ALL RIGHT, ", Word_There, Dialogue_NewLine
.db Word_You, "GO WITH HIM.", Dialogue_Terminator65

Dialogue_Index_009C:
.db Word_Do_You_Have, " A", Dialogue_NewLine
.db Word_Present, " TO GIVE TO", Dialogue_NewPage
.db Word_The, Word_Governor, "?", Dialogue_Terminator62

Dialogue_Index_009E:
.db "I", Dialogue_Apostrophe, "LL TAKE ", Word_The, Dialogue_NewLine
.db "SHORTCAKE NOW.", Dialogue_Terminator65

Dialogue_Index_00A0:
.db "I DON", Dialogue_Apostrophe, "T THINK ", Word_You, Dialogue_NewLine
.db Word_Have, "A SUITABLE", Dialogue_NewPage
.db Word_Present, ".", Dialogue_Terminator65

Dialogue_Index_00A2:
.db "GO BACK TO ", Word_Your, Dialogue_NewLine
.db "HOME NOW.", Dialogue_Terminator65

Dialogue_Index_00A4:
.db "I", Dialogue_Apostrophe, "M ", Word_The, Word_Governor, ".", Dialogue_NewLine
.db "I", Dialogue_Apostrophe, "M TOLD ", Word_That, " ", Word_You, Dialogue_NewPage
.db "INTEND TO TRY TO", Dialogue_NewLine
.db "KILL ", Word_Lassic, ".", Dialogue_NewPage

Dialogue_Index_00A6:
.db "I ADMIRE ", Word_Your, Dialogue_NewLine
.db "COURAGE. IN ", Word_The, Dialogue_NewPage
.db Word_Maharu, " CAVE LIVES", Dialogue_NewLine
.db "AN ESPAR ", Word_Named, Dialogue_NewPage

Dialogue_Index_00A8:
.db "NOAH. ", Word_I_Will, " GIVE", Dialogue_NewLine
.db Word_You, "A LETTER OF", Dialogue_NewPage
.db "INTRODUCTION TO", Dialogue_NewLine
.db Word_Present, " TO HER.", Dialogue_NewPage

Dialogue_Index_00AA:
.db "I ", Word_Have, "FAITH ", Word_That, Dialogue_NewLine
.db Word_You_Will, " KILL", Dialogue_NewPage
.db Word_Lassic, " AND RETURN", Dialogue_NewLine
.db Word_Here, " EVENTUALLY.", Dialogue_Terminator65

Dialogue_Index_00AC:
.db "IF ", Word_The, Word_Governor, Dialogue_NewLine
.db "ORDERS NOAH TO DO", Dialogue_NewPage
.db Word_Some, Word_Thing, ",HE WILL", Dialogue_NewLine
.db "LIKELY OBEY.", Dialogue_Terminator65

Dialogue_Index_00AE:
.db "WHO ", Word_Are, "YOU? I", Dialogue_Apostrophe, "M", Dialogue_NewLine
.db "BUSY WITH MY", Dialogue_NewPage

Dialogue_Index_00B0:
.db "TRAINING NOW! DO", Dialogue_NewLine
.db Word_Not, "BE A NUISANCE!", Dialogue_Terminator65

Dialogue_Index_00B2:
.db "HELLO!", Dialogue_Terminator65

Dialogue_Index_00B4:
.db "ZZZ...ZZZ...", Dialogue_Terminator65

Dialogue_Index_00B6:
.db Word_Please, Word_Rest, " ", Word_Your, Dialogue_NewLine
.db "WEARY B", Word_One, "S.", Dialogue_Terminator65

Dialogue_Index_00B8:
.db "I AM PRAYING FOR", Dialogue_NewLine
.db Word_Your, "SAFETY.", Dialogue_Terminator65

Dialogue_Index_00BA:
.db "COULD YA SP", Word_Are, "ME", Dialogue_NewLine
.db "A CUP OF COLA?", Dialogue_Terminator62

Dialogue_Index_00BC:
.db Word_Thanks, "! ", Word_This, "WAS", Dialogue_NewLine
.db "ONCE ", Word_The, "LAB. OF", Dialogue_NewPage

Dialogue_Index_00BE:
.db "DR.", Word_Luveno, ". HE WENTBONKERS, THOUGH", Dialogue_NewPage

Dialogue_Index_00C0:
.db "AND BE INPRIS", Word_One, "D", Dialogue_NewLine
.db "IN TRIADA TO ", Word_The, Dialogue_NewPage
.db "SOUTH OF ", Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_00C2:
.db "I GOT NOTHIN", Dialogue_Apostrophe, " TO", Dialogue_NewLine
.db "SAY T", Dialogue_Apostrophe, "YA!GET LOST!", Dialogue_Terminator65

Dialogue_Index_00C4:
.db "DON", Dialogue_Apostrophe, "T GO NEAR ", Word_The, Dialogue_NewLine
.db Word_Tower, " AT ", Word_The, "FAR", Dialogue_NewPage

Dialogue_Index_00C6:
.db "END OF ", Word_The, "NARROW", Dialogue_NewLine
.db "ROAD WHICH GOES", Dialogue_NewPage
.db Word_From, Word_The, Word_Gothic, Dialogue_NewLine
.db Word_Forest, " ", Word_Through, " THE", Dialogue_NewPage

Dialogue_Index_00C8:
.db Word_Mountain, "S. A ", Word_Magic_EF, "BEAST LIVES ", Word_There, ".", Dialogue_NewPage
.db "LOOK AT IT AND YA", Dialogue_NewLine
.db "TURN TO ST", Word_One, ".", Dialogue_Terminator65

Dialogue_Index_00CA:
.db "AH, IT", Dialogue_Apostrophe, "S GETTING", Dialogue_NewLine
.db "LATE! FETCH MY", Dialogue_NewPage

Dialogue_Index_00CC:
.db "ASSISTANT. HE", Dialogue_Apostrophe, "S", Dialogue_NewLine
.db "LIKELY HIDING", Dialogue_NewPage
.db "IN ", Word_The, "UNDERGROUND", Word_Passage, ".", Dialogue_Terminator65

Dialogue_Index_00CE:
.db Word_Dont_Be_A_Fool, Dialogue_Terminator65

Dialogue_Index_00D0:
.db Word_You, "DON", Dialogue_Apostrophe, "T ", Word_Have, Dialogue_NewLine
.db "ENOUGH. COME BACK", Dialogue_NewPage
.db "AGAIN WHEN ", Word_You, Dialogue_NewLine
.db Word_Have, "ENOUGH FUNDS.", Dialogue_Terminator65

Dialogue_Index_00D2:
.db "SUCCESS! I ", Word_Present, "A SUPERB ", Word_Spaceship, Dialogue_NewPage
.db Word_The, Word_Luveno, ".", Dialogue_Terminator65

Dialogue_Index_00D4:
.db "IF ", Word_You, "DON", Dialogue_Apostrophe, "T OBEY", Dialogue_NewLine
.db "ME, I ", Word_Cannot, " ", Word_Help, ".", Dialogue_Terminator65

Dialogue_Index_00D6:
.db "BUT ", Word_You, Word_Cannot, " FLY", Dialogue_NewLine
.db "A ", Word_Spaceship, ".", Dialogue_Terminator65

Dialogue_Index_00D8:
.db "HOW IS ", Word_The, Word_Luveno, "?USE IT WELL.", Dialogue_Terminator65

Dialogue_Index_00DA:
.db Word_That, Dialogue_Apostrophe, "S TOO BAD.", Dialogue_NewLine
.db "AND ", Word_You, Word_Have, "COME", Dialogue_NewPage
.db "SO FAR, TOO.", Dialogue_Terminator65

Dialogue_Index_00DC:
.db "I", Dialogue_Apostrophe, "M BUSY.DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db "BOTHER ME.", Dialogue_Terminator65

Dialogue_Index_00DE:
.db "I", Dialogue_Apostrophe, "M ", Word_Luveno, ". IF", Dialogue_NewLine
.db "YOU", Dialogue_Apostrophe, "VE COME FOR", Dialogue_NewPage
.db Word_Help, ", ", Word_You, "HAD BESTFORGET IT. LEAVE!", Dialogue_Terminator65

Dialogue_Index_00E0:
.db Word_You, Word_Want, "ME TO", Dialogue_NewLine
.db "BUILD A ", Word_Spaceship, Dialogue_NewPage
.db "FOR ", Word_You, "? ", Word_Not, "A", Dialogue_NewLine
.db "CHANCE! I CAN", Dialogue_Apostrophe, "T", Dialogue_NewPage
.db "ACCEPT SUCH", Dialogue_NewLine
.db "RESPONSIBILITY.", Dialogue_Terminator65

Dialogue_Index_00E2:
.db Word_You, Word_Are, "CERTAINLY", Dialogue_NewLine
.db "PERSISITENT. WELL,", Dialogue_NewPage
.db "IF ", Word_You_Will, " DO AS", Dialogue_NewLine
.db "I SAY, ", Word_I_Will, " ", Word_Help, Dialogue_NewPage
.db "YOU. IS IT A DEAL?", Dialogue_Terminator62

Dialogue_Index_00E4:
.db "O.K. ", Word_I_Will, " GO TO", Dialogue_NewLine
.db Word_Gothic, " ", Word_Village, Dialogue_NewPage
.db "NEARBY TO MAKE", Dialogue_NewLine
.db "PREPARATIONS. COME", Dialogue_NewPage
.db "THEN. DO ", Word_Not, "WASTEWORRY ON ME.", Dialogue_Terminator65

Dialogue_Index_00E6:
.db Word_Do_You_Have, " ", Word_Your, Dialogue_NewLine
.db Word_Roadpass, "?", Dialogue_Terminator62

Dialogue_Index_00E8:
.db Word_You, Word_Are, "A FOOL!", Dialogue_NewLine
.db Word_You_Will, " DIE!", Dialogue_Terminator65

Dialogue_Index_00EA:
.db "SPIDER MONSTERS", Dialogue_NewLine
.db Word_Are, "ACTUALLY", Dialogue_NewPage
.db "VERY INTELLIGENT.", Dialogue_Terminator65

Dialogue_Index_00EC:
.db Word_Do_You_Know, " ", Word_The, Dialogue_NewLine
.db "ROBOT ", Word_Hapsby, "?", Dialogue_Terminator62

Dialogue_Index_00EE:
.db "ON ", Word_The, "FAR SIDE OF", Word_The, Word_Mountain, "S LIES", Dialogue_NewPage
.db "A POOL OF MOLTEN", Dialogue_NewLine
.db "LAVA CREATED BY A", Dialogue_NewPage
.db "VOLCANIC ERUPTION.", Dialogue_Terminator65

Dialogue_Index_00F0:
.db Word_The, Word_Tower, " DEEP IN", Dialogue_NewLine
.db Word_The, Word_Gothic, Dialogue_NewPage
.db Word_Mountain, "S IS KNOWNAS ", Word_Medusa, Dialogue_Apostrophe, "S ", Word_Tower, ".", Dialogue_Terminator65

Dialogue_Index_00F2:
.db "I HAVEN", Dialogue_Apostrophe, "T SEEN", Dialogue_NewLine
.db Word_Any, Word_One, " FOR A LONG", Dialogue_NewPage
.db Word_Time, ". ", Word_Will_You, Dialogue_NewLine
.db "TALK WITH ME?", Dialogue_Terminator62

Dialogue_Index_00F4:
.db "POLYMETERAL ", Word_Will, Dialogue_NewLine
.db "DISSOLVE ALL", Dialogue_NewPage
.db "MATERIALS EXCEPT", Dialogue_NewLine
.db "FOR ", Word_Laconia, ".", Dialogue_Terminator65

Dialogue_Index_00F6:
.db "WHAT? DR.", Word_Luveno, Dialogue_NewLine
.db "HAS RETURNED?", Dialogue_NewPage
.db "HE ", Word_Will, " BUILD", Dialogue_NewLine
.db "ANOTHER ", Word_Spaceship, "?", Dialogue_NewPage
.db "I ", Word_Will, " BE ", Word_There, Dialogue_NewLine
.db "RIGHT AWAY.", Dialogue_Terminator65

Dialogue_Index_00F8:
.db "NO MAN ", Word_That, " GOES", Dialogue_NewLine
.db "INTO ", Word_The, "ROOM IN", Dialogue_NewPage
.db Word_The, "FAR CORNER HASEVER COME OUT", Dialogue_NewPage
.db "ALIVE! AHA-HA-HA!", Dialogue_Terminator65

Dialogue_Index_00FA:
.db "IT SEEMS TO BE A", Dialogue_NewLine
.db "MAN WHO HAS BEEN", Dialogue_NewPage
.db Word_Turned_To_Stone, "!", Dialogue_NewLine
.db "I WONDER IF HE CAN", Dialogue_NewPage
.db "BE RETURNED TO HISORIGINAL FORM?", Dialogue_Terminator65

Dialogue_Index_00FC:
.db Word_You_Will, " SOON FIND", Dialogue_NewLine
.db "OUT ", Word_The, "TRUTH!", Dialogue_Terminator65

Dialogue_Index_00FE:
.db "HALT! GO BACK!", Dialogue_NewLine
.db Word_Your, "LAST CHANCE!", Dialogue_Terminator65

Dialogue_Index_0100:
.db "HOW BRAVE! BUT BE", Dialogue_NewLine
.db Word_Careful, " OF TRAPS!", Dialogue_Terminator65

Dialogue_Index_0102:
.db Word_Bortevo, " IS MY", Dialogue_NewLine
.db "TURF. DON", Dialogue_Apostrophe, "T YA", Dialogue_NewPage
.db "MESS ", Dialogue_Apostrophe, "ROUND ", Word_Here, ",", Dialogue_NewLine
.db "NOW GIT!", Dialogue_Terminator65

Dialogue_Index_0104:
.db Word_You_Must, " FIND A", Dialogue_NewLine
.db "ROBOT ", Word_Named, Dialogue_NewPage
.db Word_Hapsby, ". HE CAN FLYA ", Word_Spaceship, ".", Dialogue_Terminator65

Dialogue_Index_0106:
.db "IN ", Word_This, "PILE OF", Dialogue_NewLine
.db "JUNK, ", Word_Some, Word_Where, ",", Dialogue_NewPage

Dialogue_Index_0108:
.db Word_There_Is, " S", Dialogue_Apostrophe, "PPOSED", Dialogue_NewLine
.db "T", Dialogue_Apostrophe, "BE A USABLE", Dialogue_NewPage
.db "ROBOT,BUT ", Word_You, Word_Know, Dialogue_NewLine
.db "HOW RUMORS BE.", Dialogue_Terminator65

Dialogue_Index_010A:
.db "POLYMETERAL IS FOR", Dialogue_NewLine
.db "SALE IN ABION.", Dialogue_Terminator65

Dialogue_Index_010C:
.db Word_This, Word_Town, " IS", Dialogue_NewLine
.db "CALLED LOAR.", Dialogue_NewPage
.db "WE ", Word_Have, "BEEN IN", Dialogue_NewLine
.db "DECLINE ", Word_Thanks, " TO", Dialogue_NewPage
.db Word_The, "WORK OF", Dialogue_NewLine
.db Word_Lassic, ".", Dialogue_Terminator65

Dialogue_Index_010E:
.db Word_Have, Word_You, "HEARD OF", Dialogue_NewLine
.db "A GEM CALLED \"", Word_The, Dialogue_NewPage
.db "AMBER EYE\"?", Dialogue_NewLine

Dialogue_Index_0110:
.db Word_Some, " SAY ", Word_The, "CASBA", Dialogue_NewPage
.db "DRAGON HAS ", Word_One, ".", Dialogue_Terminator65

Dialogue_Index_0112:
.db Word_There_Is, " A ", Word_Village, "CALLED ABION ON", Dialogue_NewPage
.db Word_The, "WESTERN EDGE", Dialogue_NewLine
.db "ON ", Word_This, "ISLAND.", Dialogue_Terminator65

Dialogue_Index_0114:
.db Word_Do_You_Know, " ABOUT", Dialogue_NewLine
.db Word_Laerma, " TREES?", Dialogue_Terminator62

Dialogue_Index_0116:
.db "THEY GROW ON ", Word_The, Dialogue_NewLine
.db "ALTIPLANO PLATEAU", Dialogue_NewPage
.db "ON ", Word_The, Word_Planet, Dialogue_NewLine
.db Word_Dezoris, ".", Dialogue_Terminator65

Dialogue_Index_0118:
.db Word_You, Word_Are, "GOING TO", Dialogue_NewLine
.db "TRY TO KILL ", Word_Lassic, Dialogue_NewPage
.db "I HEAR. ", Word_That, Dialogue_Apostrophe, "S", Dialogue_NewLine
.db "GREAT!", Dialogue_NewPage

Dialogue_Index_011A:
.db "I ", Word_Have, "HEARD ", Word_That, Dialogue_NewLine
.db "A CERTAIN", Dialogue_NewPage
.db "CRYSTAL ", Word_Will, " BLOCK", Dialogue_NewLine
.db "EVIL ", Word_Magic_EF, ".", Dialogue_Terminator65

Dialogue_Index_011C:
.db Word_Welcome, "TO ABION.", Dialogue_Terminator65

Dialogue_Index_011E:
.db Word_Help, "! ", Word_Lassic, " HAS", Dialogue_NewLine
.db "COME TO ", Word_This, Word_Town, "!", Dialogue_Terminator65

Dialogue_Index_0120:
.db "A ", Word_Strange, " MAN CAMETO ", Word_This, Word_Town, ". HE", Dialogue_NewPage
.db "SEEMS TO BE", Dialogue_NewLine
.db "PERFORMING ANIMAL", Dialogue_NewPage

Dialogue_Index_0122:
.db "EXPERIMENTS. HE", Dialogue_NewLine
.db "BROUGHT A LARGE", Dialogue_NewPage
.db "POT OR ", Word_Some, Word_Thing, ".", Dialogue_Terminator65

Dialogue_Index_0124:
.db "IT", Dialogue_Apostrophe, "S A ROBOT MADE", Dialogue_NewLine
.db "OF ", Word_Laconia, ". BUT", Dialogue_NewPage
.db "IT HAS BEEN", Dialogue_NewLine
.db "ABAND", Word_One, "D", Dialogue_NewPage
.db Word_Some, Word_Where, " AS", Dialogue_NewLine
.db "BEING USELESS.", Dialogue_Terminator65

Dialogue_Index_0126:
.db "I", Dialogue_Apostrophe, "D LIKE TO TRAVELIN OUTER SPACE.", Dialogue_Terminator65

Dialogue_Index_0128:
.db Word_Some, " CATS, IF THEYEAT A CERTAIN TYPE", Dialogue_NewPage
.db "OF NUT,THEY BECOMEHUGE AND CAN FLY.", Dialogue_NewPage

Dialogue_Index_012A:
.db "IT", Dialogue_Apostrophe, "S REALLY VERY", Dialogue_NewLine
.db "WIERD.", Dialogue_Terminator65

Dialogue_Index_012C:
.db "I", Dialogue_Apostrophe, "M ", Word_Hapsby, ".", Dialogue_NewLine
.db Word_Thanks, " FOR FINDING", Dialogue_NewPage
.db "ME. I CAN FLY ", Word_The, Dialogue_NewLine
.db Word_Luveno, " FOR YOU.", Dialogue_Terminator65

Dialogue_Index_012E:
.db Word_This, Word_Town, " IS", Dialogue_NewLine
.db "CALLED UZO.", Dialogue_Terminator65

Dialogue_Index_0130:
.db "IF ", Word_You, "USE A", Dialogue_NewLine
.db "VEHICLE CALLED THE", Dialogue_NewPage
.db "LAND ROVER, ", Word_The, Dialogue_NewLine
.db Word_Ant_Lion, " ", Word_Will, " NOT", Dialogue_NewPage
.db "BE ABLE TO HARM", Dialogue_NewLine
.db "YOU.", Dialogue_Terminator65

Dialogue_Index_0132:
.db Word_There_Is, " A ", Word_Town, Dialogue_NewLine
.db "CALLED CASBA TO", Dialogue_NewPage
.db Word_The, "SOUTH OF ", Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_0134:
.db Word_There_Are, " DRAGONS", Dialogue_NewLine
.db "LIVING IN ", Word_The, Dialogue_NewPage
.db "CASBA CAVE. THESE", Dialogue_NewLine
.db "DRAGONS ", Word_Have, "GEMS", Dialogue_NewPage
.db "IN THEIR HEADS!", Dialogue_Terminator65

Dialogue_Index_0136:
.db Word_Have, Word_You, "HEARD", Dialogue_NewLine
.db "ABOUT MANTLES MADE", Dialogue_NewPage
.db "OF FRAD FIBERS?", Dialogue_NewLine

Dialogue_Index_0138:
.db "THEY ", Word_Are, "LIGHT,", Dialogue_NewPage
.db "BUT PROVIDE ", Word_Great, Dialogue_NewLine
.db "PROTECTION.", Dialogue_Terminator65

Dialogue_Index_013A:
.db Word_Have, Word_You, "HEARD", Dialogue_NewLine
.db "ABOUT ", Word_The, Dialogue_NewPage
.db Word_Soothing_Flute, "?", Dialogue_Terminator62

Dialogue_Index_013C:
.db "OH, NEVER MIND.", Dialogue_Terminator65

Dialogue_Index_013E:
.db "IT", Dialogue_Apostrophe, "S A ", Word_Secret, ", BUTI BURIED ", Word_One, " AT", Dialogue_NewPage
.db Word_The, "OUTSKIRTS OF", Dialogue_NewLine
.db Word_The, Word_Town, " OF ", Word_Gothic, Dialogue_NewPage

Dialogue_Index_0140:
.db "ON ", Word_Palma, ". DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db "TELL ", Word_Any, Word_One, ".", Dialogue_Terminator65

Dialogue_Index_0142:
.db "I DON", Dialogue_Apostrophe, "T ", Word_Know, " WHO", Dialogue_NewLine
.db "TOLD ", Word_You, Word_That, ".", Dialogue_NewPage
.db Word_You, "HAD BEST", Dialogue_NewLine
.db "FORGET IT.", Dialogue_Terminator65

Dialogue_Index_0144:
.db "I TELL ", Word_You, "NO ", Word_One, Dialogue_NewLine
.db "CAN DO.GO ON BACK", Dialogue_NewPage
.db "TO WHEREVER ", Word_You, Dialogue_NewLine
.db "CAME FROM.", Dialogue_Terminator65

Dialogue_Index_0146:
.db "ALL RIGHT, ALL", Dialogue_NewLine
.db "RIGHT. I GIVE UP.", Dialogue_NewPage
.db "BUT DON", Dialogue_Apostrophe, "T TELL", Dialogue_NewLine
.db Word_Any, Word_One, " ", Word_Where, " ", Word_You, Dialogue_NewPage
.db "GOT THIS, O.K.?", Dialogue_Terminator65

Dialogue_Index_0148:
.db "I", Dialogue_Apostrophe, "M ", Word_The, Word_Great, Dialogue_NewLine
.db "DAMOR, ", Word_Soothsayer, "!", Dialogue_NewPage

Dialogue_Index_014A:
.db Word_Do_You, " BELIEVE IN", Dialogue_NewLine
.db "MY PROPHECIES?", Dialogue_Terminator62

Dialogue_Index_014C:
.db "I", Dialogue_Apostrophe, "VE GOT A FRIEND", Dialogue_NewLine
.db "IN ", Word_Bortevo, ". HE", Dialogue_Apostrophe, "S", Dialogue_NewPage
.db "PROBABLY HAVING A", Dialogue_NewLine
.db "HARD ", Word_Time, " BECAUSE", Dialogue_NewPage
.db "OF ", Word_The, "LAVA. WHY", Dialogue_NewLine
.db Word_Not, "VISIT HIM?", Dialogue_Terminator65

Dialogue_Index_014E:
.db "GOOD!", Dialogue_Terminator65

Dialogue_Index_0150:
.db "YOU", Dialogue_Apostrophe, "RE SEARCHING", Dialogue_NewLine
.db "FOR ", Word_Some, Word_Thing, "?", Dialogue_Terminator62

Dialogue_Index_0152:
.db "LEAVE MY SIGHT,", Dialogue_NewLine
.db "UNBELIEVER!", Dialogue_Terminator65

Dialogue_Index_0154:
.db Word_You, Word_Are, "SEARCHING", Dialogue_NewLine
.db "FOR ALEX OSSALE?", Dialogue_Terminator62

Dialogue_Index_0156:
.db "EVERY", Word_Thing, " I", Dialogue_Apostrophe, "VE", Dialogue_NewLine
.db "SAID IS CORRECT?", Dialogue_Terminator62

Dialogue_Index_0158:
.db "THEN, COME AGAIN,", Dialogue_NewLine
.db Word_Any, Word_Time, ".", Dialogue_Terminator65

Dialogue_Index_015A:
.db Word_Do_You, " CONTRADICT", Dialogue_NewLine
.db Word_The, Word_Great, "DAMOR?!?", Dialogue_Terminator62

Dialogue_Index_015C:
.db "OF COURSE NOT!YOU", Dialogue_NewLine
.db Word_Are, "A PROMISING", Dialogue_NewPage
.db "YOUNG LASS! ", Word_I_Will

Dialogue_Index_015E:
.db "GIVE ", Word_You, "A ", Word_Magic_EF, Dialogue_NewPage
.db "CRYSTAL FOR A", Dialogue_NewLine
.db "REWARD.", Dialogue_Terminator65

Dialogue_Index_0160:
.db Word_Do_You, " COME IN", Dialogue_NewLine
.db "FULL KNOWLEDGE OF", Dialogue_NewPage
.db Word_The, Word_Tower, " OF ", Word_Baya, Dialogue_NewLine
.db Word_Malay, "?", Dialogue_Terminator62

Dialogue_Index_0162:
.db Word_You_Will, " SURELY", Dialogue_NewLine
.db "INCUR ", Word_The, "WRATH", Dialogue_NewPage
.db "OF ", Word_The, "HEAVENS!", Dialogue_Terminator65

Dialogue_Index_0164:
.db "GO BACK BEFORE IT", Dialogue_NewLine
.db "IS TOO LATE.", Dialogue_Terminator65

Dialogue_Index_0166:
.db Word_This, Word_Town, " IS", Dialogue_NewLine
.db "CALLED CASBA.", Dialogue_Terminator65

Dialogue_Index_0168:
.db "FIERCE DRAGONS", Dialogue_NewLine
.db "LIVE IN ", Word_The, "CAVE", Dialogue_NewPage
.db "NEAR ", Word_Here, ",AND I", Dialogue_Apostrophe, "M", Dialogue_NewLine
.db "SCARED OF THEM.", Dialogue_Terminator65

Dialogue_Index_016A:
.db "DON", Dialogue_Apostrophe, "T BELIEVE YOUR", Dialogue_NewLine
.db "OWN EYES IN ", Word_The, Dialogue_NewPage
.db "DEPTH OF ", Word_The, Dialogue_NewLine
.db Word_Dungeon, "S.", Dialogue_Terminator65

Dialogue_Index_016C:
.db Word_There_Are, " LEGENDS", Dialogue_NewLine
.db "OF A MYSTIC ", Word_Shield, Dialogue_NewPage
.db "IN A ", Word_Village, Dialogue_NewLine
.db "SURROUNDED IN MIST", Dialogue_NewPage

Dialogue_Index_016E:
.db "IT IS ", Word_The, Word_Shield, Dialogue_NewLine
.db "PERSEUS USED IN", Dialogue_NewPage
.db "DAYS TO CONQUER", Dialogue_NewLine
.db Word_Magic_84, "BEASTS.", Dialogue_Terminator65

Dialogue_Index_0170:
.db Word_There_Is, " POISON", Dialogue_NewLine
.db "GAS ABOVE ", Word_The, "SEA", Dialogue_NewPage
.db "TO ", Word_The, "WEST. NO", Dialogue_NewLine
.db Word_One, " CAN GO NEAR", Dialogue_NewPage
.db Word_There, " WITHOUT ", Word_Some, "PROTECTION.", Dialogue_Terminator65

Dialogue_Index_0172:
.db Word_Have, Word_You, "HEARD OF", Dialogue_NewLine
.db "VEHICLE CALLED", Dialogue_NewPage
.db Word_The, "HOVERCRAFT?", Dialogue_Terminator62

Dialogue_Index_0174:
.db "I BOUGHT IT IN", Dialogue_NewLine
.db Word_Scion, " ON ", Word_Palma, Dialogue_NewPage
.db "BUT IT SEEMED", Dialogue_NewLine
.db "BROKEN SO I", Dialogue_NewPage
.db "ABAND", Word_One, "D IT IN", Dialogue_NewLine

Dialogue_Index_0176:
.db Word_Bortevo, ". IT", Dialogue_NewPage
.db "PROBABLY CAN STILLBE USED, THOUGH.", Dialogue_Terminator65

Dialogue_Index_0178:
.db Word_You, "FOUND ", Word_The, Dialogue_NewLine
.db "HOVERCRAFT.", Word_Hapsby, Dialogue_NewPage
.db "HAS RESTORED IT TO", Dialogue_NewLine

Dialogue_Index_017A:
.db "WORKING ORDER.", Dialogue_Terminator65

Dialogue_Index_017C:
.db "IT", Dialogue_Apostrophe, "S A GOOD ", Word_Thing, Dialogue_NewLine
.db "TO HAVE. IT ", Word_Move, "S", Dialogue_NewPage
.db "ACROSS WATER.", Dialogue_Terminator65

Dialogue_Index_017E:
.db Word_Welcome, "TO DRASGOW-- A SMALL ", Word_Town, Dialogue_NewPage
.db "ON ", Word_The, "OCEAN.", Dialogue_Terminator65

Dialogue_Index_0180:
.db Word_You, Word_Are, "DARING TO", Dialogue_NewLine
.db Word_Have, "FOUND ", Word_Your, Dialogue_NewPage
.db "WAY ", Word_Here, " EVEN", Dialogue_NewLine

Dialogue_Index_0182:
.db "THOUGH ", Word_The, "SEA", Dialogue_NewPage
.db "LANES ", Word_Are, "CLOSED", Dialogue_NewLine
.db "TO SHIPS.", Dialogue_Terminator65

Dialogue_Index_0184:
.db Word_There_Is, " A ", Word_Magic_EF, Dialogue_NewLine
.db "SWORD IN A ", Word_Tower, Dialogue_NewPage
.db "ON A FORGOTTEN", Dialogue_NewLine
.db "ISLAND.", Dialogue_Terminator65

Dialogue_Index_0186:
.db "LONG AGO, I SAW A", Dialogue_NewLine
.db "GIANT ROCK FLOAT", Dialogue_NewPage
.db Word_Through, " ", Word_The, "SKY.", Dialogue_Terminator65

Dialogue_Index_0188:
.db Word_The, "TOP OF ", Word_The, Dialogue_NewLine
.db Word_Hill, " CALLED ", Word_Baya, Dialogue_NewPage
.db Word_Malay, " IS ALWAYS", Dialogue_NewLine
.db "HIDDEN BY CLOUDS.", Dialogue_NewPage

Dialogue_Index_018A:
.db Word_Some, Word_Thing, " ", Word_Must, " BE", Dialogue_NewLine
.db "UP ", Word_There, "!", Dialogue_Terminator65

Dialogue_Index_018C:
.db "I HEARD ", Word_That, " THEY", Dialogue_NewLine
.db "SELL GAS ", Word_Shield, Dialogue_NewPage
.db Word_Here, ", BUT I DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db Word_Know, " ", Word_Where, " ", Word_The, Dialogue_NewPage
.db "SHOP IS!", Dialogue_NewLine

Dialogue_Index_018E:
.db "WHAT A MESS!", Dialogue_Terminator65

Dialogue_Index_0190:
.db Word_Welcome, "TO OUR", Dialogue_NewLine
.db "STORE. WHAT CAN I", Dialogue_NewPage
.db Word_Help, " ", Word_You, "WITH?", Dialogue_NewPage

Dialogue_Index_0192:
.db "AHH, I WAS PULLING", Word_Your, "LEG! WHAT", Dialogue_Apostrophe, "S", Dialogue_NewPage
.db "A MATTER, CAN", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db Word_You, "TAKE A JOKE?", Dialogue_Terminator65

Dialogue_Index_0194:
.db "I BET ", Word_You, Word_Are, Dialogue_NewLine
.db "SURPRISED TO SEE A", Dialogue_NewPage
.db "SHOP IN A PLACE", Dialogue_NewLine
.db "LIKE THIS!", Dialogue_NewPage

Dialogue_Index_0196:
.db "A GAS ", Word_Shield, " IS", Dialogue_NewLine
.db "ONLY 1000 ", Word_Mesetas, "!", Dialogue_NewPage
.db "PRETTY CHEAP, HUH?", Word_Will_You, " BUY ", Word_One, "?", Dialogue_Terminator62

Dialogue_Index_0198:
.db Word_Thanks, "! SEE ", Word_You, Dialogue_NewLine
.db "AGAIN.", Dialogue_Terminator65

Dialogue_Index_019A:
.db Word_You, "DON", Dialogue_Apostrophe, "T ", Word_Have, Dialogue_NewLine
.db "ENOUGH M", Word_One, "Y!", Dialogue_Terminator65

Dialogue_Index_019C:
.db "SORRY, ", Word_That, " WAS", Dialogue_NewLine
.db Word_Your, "ONLY CHANCE.", Dialogue_Terminator65

Dialogue_Index_019E:
.db Word_The, Word_Spaceport, " IS", Dialogue_NewLine
.db "CLOSED.", Dialogue_Terminator65

Dialogue_Index_01A0:
.db Word_We_Are, "CONFISCAT-", Dialogue_NewLine
.db "ING ", Word_Your, Word_Passport, ".", Dialogue_Terminator65

Dialogue_Index_01A2:
.db Word_Welcome, "TO SKURE", Dialogue_NewLine
.db "ON ", Word_Dezoris, ".", Dialogue_NewPage
.db "IT", Dialogue_Apostrophe, "S FREEZING", Dialogue_NewLine
.db "OUTSIDE, ISN", Dialogue_Apostrophe, "T IT?", Dialogue_Terminator65

Dialogue_Index_01A4:
.db "MOST EMIGRANTS", Dialogue_NewLine
.db Word_From, Word_Palma, Dialogue_NewPage
.db "SETTLE ", Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_01A6:
.db "I DON", Dialogue_Apostrophe, "T ", Word_Know, " A LOTABOUT ", Word_This, Word_Planet, ",", Dialogue_NewPage

Dialogue_Index_01A8:
.db "BUT WORD HAS IT", Dialogue_NewLine
.db Word_That, " ", Word_There_Is, " A", Dialogue_NewPage
.db Word_Town, " OF NATIVE", Dialogue_NewLine
.db Word_Dezorian, "S IN ", Word_The, Dialogue_NewPage
.db "FAR REACHES OF THE", Word_Mountain, "S.", Dialogue_Terminator65

Dialogue_Index_01AA:
.db "IF ", Word_You, "REALLY HOPETO KILL ", Word_Lassic, ",", Dialogue_NewPage

Dialogue_Index_01AC:
.db Word_You, "HAD BEST FIND", Dialogue_NewLine
.db "A SWORD, AXE,", Dialogue_NewPage
.db Word_Shield, ", ARMOR", Dialogue_NewLine
.db "MADE OF ", Word_Laconia, ".", Dialogue_NewPage

Dialogue_Index_01AE:
.db "SUCH WEAPONS ", Word_Are, Dialogue_NewLine
.db "STRONGEST.", Dialogue_NewPage

Dialogue_Index_01B0:
.db "I PRAY FOR ", Word_Your, Dialogue_NewLine
.db "SAFETY.", Dialogue_Terminator65

Dialogue_Index_01B2:
.db "ARMS MADE OF", Dialogue_NewLine
.db Word_Laconia, " CONCEAL", Dialogue_NewPage
.db "HOLY POWER. ", Word_Lassic

Dialogue_Index_01B4:
.db "FEARS ", Word_This, "POWER", Dialogue_NewPage
.db "AND HAS BEEN", Dialogue_NewLine
.db "RUNNING AND HIDING", Dialogue_NewPage
.db "IN DIFFERENT", Dialogue_NewLine

Dialogue_Index_01B6:
.db "PLACES IN ", Word_The, Dialogue_NewPage
.db Word_Planets, " OF ", Word_The, Dialogue_NewLine
.db Word_Algol, " ", Word_System, ".", Dialogue_Terminator65

Dialogue_Index_01B8:
.db Word_Dezoris, " IS A", Dialogue_NewLine
.db Word_World, " OF ICE.", Dialogue_Terminator65

Dialogue_Index_01BA:
.db Word_There_Are, " PLACES", Dialogue_NewLine
.db "IN ", Word_The, Word_Mountain, "S", Dialogue_NewPage
.db "WHERE THE ICE IS", Dialogue_NewLine
.db "SOFT AND", Dialogue_NewPage
.db "IMPASSABLE TO", Dialogue_NewLine
.db "THOSE ON FOOT.", Dialogue_Terminator65

Dialogue_Index_01BC:
.db Word_The, "ALTIPLANO", Dialogue_NewLine
.db "PLATEAU IS AT ", Word_The, Dialogue_NewPage
.db "TOP OF ", Word_The, "ICE", Dialogue_NewLine
.db Word_Mountain, ".", Dialogue_Terminator65

Dialogue_Index_01BE:
.db "AN ECLIPSE OCCURS", Dialogue_NewLine
.db "ON ", Word_This, Word_Planet, Dialogue_NewPage
.db "ONCE EVERY HUNDREDYEARS. A TORCH", Dialogue_NewPage

Dialogue_Index_01C0:
.db "LIT DURING AN", Dialogue_NewLine
.db "ECLIPSE IS CALLED", Dialogue_NewPage
.db "AN \"ECLIPSE TORCH\""

Dialogue_Index_01C2:
.db "AND IS REGARDED", Dialogue_NewPage
.db "AS HOLY BY ", Word_The, Dialogue_NewLine
.db Word_Dezorian, "S.", Dialogue_Terminator65

Dialogue_Index_01C4:
.db Word_The, "DEAD GUARON", Dialogue_NewLine
.db "MORGUE ", Word_Have, "BEEN", Dialogue_NewPage
.db "CALLED BACK TO", Dialogue_NewLine

Dialogue_Index_01C6:
.db "LIFE! WHAT FEAR!", Dialogue_Terminator65

Dialogue_Index_01C8:
.db Word_The, "NEIBORING", Dialogue_NewLine
.db Word_Village, " ", Word_Are, "ALL", Dialogue_NewPage
.db "LIARS! DON", Dialogue_Apostrophe, "T", Dialogue_NewLine
.db "LISTEN TO THEM!", Dialogue_Terminator65

Dialogue_Index_01CA:
.db "ZE CORONA ", Word_Tower, Dialogue_NewLine
.db "STANDS ON ZE", Dialogue_NewPage
.db "FAR SIDE OF ZE", Dialogue_NewLine
.db Word_Mountain, " TO ZE", Dialogue_NewPage
.db "NORTH OF ZIS", Dialogue_NewLine
.db Word_Village, ".", Dialogue_Terminator65

Dialogue_Index_01CC:
.db "TO ZE WEST OF ZE", Dialogue_NewLine
.db "CORONA ", Word_Tower, " IS", Dialogue_NewPage
.db "ZE ", Word_Dezoris, " CAVE.", Dialogue_NewLine

Dialogue_Index_01CE:
.db "OUR FRIENDS ", Word_Are, "IN", Dialogue_NewPage
.db "ZERE. GIVE ZEM", Dialogue_NewLine
.db "OUR BEST, O.K.?", Dialogue_Terminator65

Dialogue_Index_01D0:
.db Word_Laerma, " TREES GROW", Dialogue_NewLine
.db "ZE ", Word_Laerma, " BERRIES.", Dialogue_NewPage

Dialogue_Index_01D2:
.db "ZOSE BERRIES ", Word_Are, Dialogue_NewLine
.db "OUR MOST IMPORTANT", Dialogue_NewPage
.db "FOOD, BUT IT", Dialogue_NewLine
.db "SHRIVELS UP AFTER", Dialogue_NewPage
.db "A FEW MOMENTS,", Dialogue_NewLine

Dialogue_Index_01D4:
.db "UNLESS IT IS PUT", Dialogue_NewPage
.db "IN ", Word_Laconian_Pot, ".", Dialogue_Terminator65

Dialogue_Index_01D6:
.db Word_Do_You_Know, " WHAT", Dialogue_NewLine
.db "AN AEROPRISM IS?", Dialogue_Terminator62

Dialogue_Index_01D8:
.db "IT LETS ", Word_You, "SEE", Dialogue_NewLine
.db "ANOTHER ", Word_World, ".", Dialogue_Terminator65

Dialogue_Index_01DA:
.db "I", Dialogue_Apostrophe, "D LIKE TO SEE", Dialogue_NewLine
.db Word_One, " ", Word_Some, Word_Time, ".", Dialogue_Terminator65

Dialogue_Index_01DC:
.db "WE OF ZIS ", Word_Town, Dialogue_NewLine
.db "HATE ", Word_Palmans, ".", Dialogue_Terminator65

Dialogue_Index_01DE:
.db Word_There_Is, " A SPRING", Dialogue_NewLine
.db "OF LIFE IN ", Word_The, Dialogue_NewPage
.db "CORONA ", Word_Tower, ",", Dialogue_NewLine
.db Word_There_Is, ", YES.", Dialogue_Terminator65

Dialogue_Index_01E0:
.db Word_You, "CAN WARP ", Word_From, Dialogue_NewLine
.db Word_The, "10TH LEVEL OF", Dialogue_NewPage
.db Word_The, Word_Dungeon, " UNDER", Dialogue_NewLine
.db Word_Dezoris, ",YES.", Dialogue_Terminator65

Dialogue_Index_01E2:
.db Word_Laerma, " BERRIES ARE", Dialogue_NewLine
.db "BLUE ", Word_Laerma, " NUTS", Dialogue_NewLine
.db "USED IN DYES,YES,", Dialogue_NewPage
.db "THEY ", Word_Are, ", ", Word_Indeed, ".", Dialogue_Terminator65

Dialogue_Index_01E4:
.db "IF ", Word_You, "USE A", Dialogue_NewLine
.db "CRYSTAL IN FRONT", Dialogue_NewPage
.db "OF A ", Word_Laerma, " TREE,", Dialogue_NewLine
.db "IT ", Word_Will, " BECOME,", Dialogue_NewPage
.db "YES, A ", Word_Laerma, " NUT,YES, ", Word_Indeed, ".", Dialogue_Terminator65

Dialogue_Index_01E6:
.db Word_This, Word_Town, " WELCOMESALL ", Word_Palmans, ",YES,", Dialogue_NewPage
.db Word_Indeed, ", WE DO.", Dialogue_Terminator65

Dialogue_Index_01E8:
.db Word_This, Word_Town, " IS", Dialogue_NewLine
.db "CALLED SOPIA.", Dialogue_NewPage
.db Word_You, Word_Are, "BRAVE TO", Dialogue_NewLine
.db "PENETRATE ", Word_The, "GAS.", Dialogue_Terminator65

Dialogue_Index_01EA:
.db "I", Dialogue_Apostrophe, "M ", Word_The, "HEAD OF", Dialogue_NewLine
.db Word_This, Word_Village, ".", Dialogue_NewPage

Dialogue_Index_01EC:
.db "BECAUSE OF ", Word_The, Dialogue_NewLine
.db "CLOUD OF GAS,", Dialogue_NewPage
.db Word_We_Are, "CUT OFF", Dialogue_NewLine
.db Word_From, "OTHER TOWNS,", Dialogue_NewPage
.db Word_We_Are, "THEREFORE", Dialogue_NewLine
.db "VERY POOR.", Dialogue_NewPage

Dialogue_Index_01EE:
.db Word_Will_You, " DONATE", Dialogue_NewLine
.db "400 ", Word_Mesetas, "?", Dialogue_Terminator62

Dialogue_Index_01F0:
.db Word_I_See, ". WE ", Word_Must, " GO", Dialogue_NewLine
.db "ON SUFFERING...", Dialogue_Terminator65

Dialogue_Index_01F2:
.db Word_You, Word_Have, "A LITTLE", Dialogue_NewLine
.db "M", Word_One, "Y,TOO, ", Word_I_See, ".", Dialogue_Terminator65

Dialogue_Index_01F4:
.db Word_Thanks, "! ACCORDING", Dialogue_NewLine
.db "TO OUR LEGENDS,", Dialogue_NewPage

Dialogue_Index_01F6:
.db Word_The, "VERY ", Word_Shield, ",", Dialogue_NewLine
.db "PERSEUS USED TO", Dialogue_NewPage
.db "OVERCOME ", Word_Medusa, ",ISBURIED ON ", Word_The, Dialogue_NewPage

Dialogue_Index_01F8:
.db "SMALL ISLAND IN", Dialogue_NewLine
.db Word_The, "MIDDLE OF A", Dialogue_NewPage
.db "LAKE.", Dialogue_Terminator65

Dialogue_Index_01FA:
.db "HI! I", Dialogue_Apostrophe, "M MIKI!", Dialogue_NewLine
.db Word_Do_You, " LIKE", Dialogue_NewPage
.db "SEGA ", Word_Game, "S?", Dialogue_Terminator62

Dialogue_Index_01FC:
.db "OF COURSE! SEGA", Dialogue_NewLine
.db Word_Game, "S ", Word_Are, "BEST.", Dialogue_Terminator65

Dialogue_Index_01FE:
.db "I CAN", Dialogue_Apostrophe, "T BELIEVE", Dialogue_NewLine
.db "IT. IF ", Word_You, "DON", Dialogue_Apostrophe, "T", Dialogue_NewPage
.db "LIKE ", Word_The, Word_Game, ",....", Dialogue_NewLine
.db "WHY ", Word_Have, Word_You, Dialogue_NewPage
.db "PLAYED SO FAR!?!", Dialogue_Terminator65

Dialogue_Index_0200:
.db "BEFORE ", Word_Lassic, " CAMETO POWER, EVEN OUR", Dialogue_NewPage
.db Word_Town, " HAD PLENTY.", Dialogue_Terminator65

Dialogue_Index_0202:
.db Word_There_Is, " A MONK", Dialogue_NewLine
.db Word_Named, "TAJIM IN THE", Dialogue_NewPage
.db Word_Mountain, "S TO ", Word_The, Dialogue_NewLine
.db "SOUTH OF ", Word_The, "LAKE.", Dialogue_Terminator65

Dialogue_Index_0204:
.db "I", Dialogue_Apostrophe, "VE HEARD ", Word_That, Dialogue_NewLine
.db Word_The, Word_Palma, " IS A", Dialogue_NewPage
.db "BEAUTIFUL ", Word_Planet, ".", Dialogue_NewLine
.db "IS ", Word_That, " TRUE?", Dialogue_Terminator62

Dialogue_Index_0206:
.db "I", Dialogue_Apostrophe, "D LIKE TO GO", Dialogue_NewLine
.db "VISITING ", Word_Some, "DAY.", Dialogue_Terminator65

Dialogue_Index_0208:
.db "NO? I", Dialogue_Apostrophe, "D LIKE TO GO", Word_Some, Word_Where, " ", Word_The, "AIR", Dialogue_NewPage
.db "IS MORE CLEAN", Dialogue_NewLine
.db "AND FRESH.", Dialogue_Terminator65

Dialogue_Index_020A:
.db Word_Thanks, "!", Dialogue_NewLine
.db "COME AGAIN!", Dialogue_Terminator65

Dialogue_Index_020C:
.db "TIGHTWAND!", Dialogue_Terminator65

Dialogue_Index_020E:
.db Word_Dont_Be_A_Fool, Dialogue_Terminator65

Dialogue_Index_0210:
.db "..........", Dialogue_Terminator65

Dialogue_Index_0212:
.db "THEN ", Word_You, Word_Are, Word_The, Dialogue_NewLine
.db "VERY ", Word_Queen, " OF ", Word_The, Dialogue_NewPage
.db "ENTIRE ", Word_System, ". I", Dialogue_NewLine
.db Word_Will, " ASSIST ", Word_You, "IN", Dialogue_NewPage
.db "ALL WAYS POSSIBLE.", Dialogue_Terminator65

Dialogue_Index_0214:
.db Word_You, Word_Have, "BEEN", Dialogue_NewLine
.db "LOCKED UP,TOO", Dialogue_NewPage

Dialogue_Index_0216:
.db Word_There_Is, " A WAY", Dialogue_NewLine
.db "OUT, BUT I LIKE", Dialogue_NewPage
.db "IT IN ", Word_Here, ",", Dialogue_NewLine
.db "MYSELF.", Dialogue_Terminator65

Dialogue_Index_0218:
.db Word_There_Are, " GUARDS", Dialogue_NewLine
.db "UP AHEAD!", Dialogue_Terminator65

Dialogue_Index_021A:
.db "IF ", Word_You, "PLAN TO GO", Dialogue_NewLine
.db "BACK, NOW IS ", Word_The, Dialogue_NewPage
.db Word_Time, " TO LEAVE.", Dialogue_Terminator65

Dialogue_Index_021C:
.db Word_Do_You_Have, " ", Word_Your, Dialogue_NewLine
.db Word_Roadpass, "?", Dialogue_Terminator62

Dialogue_Index_021E:
.db Word_This, "IS A FAKE!", Dialogue_NewLine

Dialogue_Index_0220:
.db Word_Do_You, " THINK ", Word_You, Dialogue_NewPage
.db "CAN FOOL A ROBOT?", Dialogue_NewLine
.db "OFF TO JAIL WE GO!", Dialogue_Terminator65

Dialogue_Index_0222:
.db "GET ME OUT ", Word_Here, "?", Dialogue_NewLine
.db "BUT IT", Dialogue_Apostrophe, "S IN VAIN.", Dialogue_Terminator65

Dialogue_Index_0224:
.db "IT", Dialogue_Apostrophe, "S FOOLISH TO", Dialogue_NewLine
.db "TRY TO GET ", Word_Lassic, "!", Dialogue_Terminator65

Dialogue_Index_0226:
.db Word_Lassic, " IS GONNA", Dialogue_NewLine
.db "SACRIFICE US! AGH!", Dialogue_Terminator65

Dialogue_Index_0228:
.db Word_Have, Word_You, "FOUND THE", Dialogue_NewLine
.db "ARMOR IN GUARON?", Dialogue_Terminator62

Dialogue_Index_022A:
.db "IT CAN BE FOUND AT", Word_The, "FAR SIDE OF", Dialogue_NewPage
.db "A PIT TRAP.", Dialogue_Terminator65

Dialogue_Index_022C:
.db "WELL,AREN", Dialogue_Apostrophe, "T ", Word_You, Dialogue_NewLine
.db Word_Some, Word_Thing, "?", Dialogue_Terminator65

Dialogue_Index_022E:
.db "ALL WHO FACE", Dialogue_NewLine
.db Word_Lassic, " LOSE THEIR", Dialogue_NewPage
.db "SOULS TO HIS", Dialogue_NewLine
.db Word_Magic_EF, "!", Dialogue_Terminator65

Dialogue_Index_0230:
.db "NO? ", Word_That, Dialogue_Apostrophe, "S FINE,", Dialogue_NewLine
.db "IF ", Word_You, "SO DESIRE.", Dialogue_NewPage
.db Word_You_Will, " ALWAYS BE", Word_Welcome, Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_0232:
.db Word_There_Is, " A ", Word_Tower, Dialogue_NewLine
.db "OF ", Word_The, "TOP OF", Dialogue_NewPage
.db Word_Baya_Malay, ".", Dialogue_NewLine
.db Word_Some, Word_Thing, " ", Word_Secret, Dialogue_NewPage
.db "IS HIDDEN AT ", Word_The, Dialogue_NewLine
.db "TOP OF ", Word_The, Word_Tower, "!", Dialogue_Terminator65

Dialogue_Index_0234:
.db "WHAT ", Word_Have, Word_You, "COMEFOR? ", Word_Do_You, " INTEND", Dialogue_NewPage
.db Word_Some, " MISCHIEF?", Dialogue_Terminator65

Dialogue_Index_0236:
.db "I ", Word_Have, "AN UNEASY", Dialogue_NewLine
.db "FEELING.", Dialogue_Terminator65

Dialogue_Index_0238:
.db "BE ", Word_Careful, " UP", Dialogue_NewLine
.db "AHEAD. AT ", Word_The, Dialogue_NewPage
.db "BREAK IN ", Word_The, "ROAD,GO TO ", Word_The, "LEFT!", Dialogue_Terminator65

Dialogue_Index_023A:
.db Word_Lassic, " LIVES IN", Dialogue_NewLine
.db "FEAR OF ", Word_The, Dialogue_NewPage
.db "CRYSTAL POSSESSED", Dialogue_NewLine
.db "BY ", Word_The, Word_Soothsayer, Dialogue_NewPage

Dialogue_Index_023C:
.db Word_Named, "DAMOR. ", Word_There, "IS ", Word_Some, Word_Thing, Dialogue_NewPage
.db "SPECIAL ABOUT IT,", Dialogue_NewLine
.db "WITHOUT A DOUBT.", Dialogue_Terminator65

Dialogue_Index_023E:
.db Word_This, "FIRE WAS LIT", Dialogue_NewLine
.db "DURING ", Word_The, "ECLIPSE", Dialogue_NewPage
.db "WHICH OCCURS ONCE", Dialogue_NewLine
.db "EVERY 100 YEARS.", Dialogue_NewPage

Dialogue_Index_0240:
.db "IF ", Word_You, "GIVE ME A", Dialogue_NewLine
.db "GEM ", Word_From, "A DRAGON,", Dialogue_NewPage
.db "I", Dialogue_Apostrophe, "LL GIVE ", Word_You, Word_Some, "OF ", Word_This, "FIRE.", Dialogue_NewPage

Dialogue_Index_0242:
.db "HOW ABOUT IT?", Dialogue_Terminator62

Dialogue_Index_0244:
.db Word_Here, ", TAKE ", Word_This, Dialogue_NewLine
.db "ECLIPSE TORCH.", Dialogue_Terminator65

Dialogue_Index_0246:
.db "NO? THEN WHAT DID", Dialogue_NewLine
.db Word_You, "COME FOR?", Dialogue_Terminator65

Dialogue_Index_0248:
.db Word_You, Word_Have, "NO GEM!", Dialogue_NewLine
.db "DO I LOOK LIKE A", Dialogue_NewPage
.db "FOOL OR ", Word_Some, Word_Thing, "?", Dialogue_Terminator65

Dialogue_Index_024A:
.db "I", Dialogue_Apostrophe, "M SORRY I ", Word_Have, "A", Dialogue_NewLine
.db "SHOP IN SUCH A", Dialogue_NewPage
.db "PLACE. SHORTCAKE", Dialogue_NewLine
.db "FOR 1000 ", Word_Mesetas, "!", Dialogue_NewPage
.db Word_Will_You, " BUY ", Word_One, "?", Dialogue_Terminator62

Dialogue_Index_024C:
.db "AH,MY YOUNG PUPIL,NOAH. ", Word_You, Word_Are, Dialogue_NewPage
.db "PREPARING TO FACE", Dialogue_NewLine
.db Word_Lassic, "?", Dialogue_Terminator65

Dialogue_Index_024E:
.db "COME,", Word_You_Must, " ", Word_Pass, Dialogue_NewLine
.db Word_Your, "FINAL TEST---", Dialogue_NewPage
.db "WE ", Word_Will, " DUEL!", Dialogue_Terminator65

Dialogue_Index_0250:
.db Word_You, Word_Have, "BECOME", Dialogue_NewLine
.db "MUCH STRONGER...", Dialogue_NewPage

Dialogue_Index_0252:
.db Word_You, Word_Are, "WELL", Dialogue_NewLine
.db "PREPARED.", Dialogue_NewPage

Dialogue_Index_0254:
.db "I", Dialogue_Apostrophe, "LL GIVE ", Word_You, "A", Dialogue_NewLine
.db "FRAD MANTLE AS A", Dialogue_NewPage
.db "GIFT. IT PROTECTS", Dialogue_NewLine
.db Word_You, Word_From, "DANGER!", Dialogue_Terminator65

Dialogue_Index_0256:
.db Word_You, Word_Are, Word_Not, "YET", Dialogue_NewLine
.db "READY! ", Word_You_Must, " GO", Dialogue_NewPage
.db "STILL UNDERGO MORETRAINING.", Dialogue_Terminator65

Dialogue_Index_0258:
.db "I ", Word_Have, "NO", Word_Thing, " TO", Dialogue_NewLine
.db "TEACH ", Word_You, "MORE.", Dialogue_Terminator65

Dialogue_Index_025A:
.db "AND WHO ", Word_Are, "YOU?", Dialogue_NewLine
.db "FIND MY PUPIL NOAH", Dialogue_NewPage
.db "IN ", Word_The, Word_Maharu, Dialogue_NewLine

Dialogue_Index_025C:
.db "CAVE.", Word_Do_You_Know, Dialogue_NewPage
.db "HIM?", Dialogue_Terminator62

Dialogue_Index_025E:
.db "I", Dialogue_Apostrophe, "VE ", Word_Some, Word_Thing, Dialogue_NewLine
.db "I ", Word_Must, " TELL HIM.", Dialogue_NewPage
.db "BRING HIM ", Word_Here, ".", Dialogue_Terminator65

Dialogue_Index_0260:
.db "IN ", Word_That, " CASE,", Dialogue_NewLine
.db Word_There_Is, " NO POINT", Dialogue_NewPage
.db "IN FURTHER", Dialogue_NewLine
.db "CONVERSATION.", Dialogue_Terminator65

Dialogue_Index_0262:
.db "I ", Word_Have, "WATCHED", Dialogue_NewLine
.db "ALL ", Word_Your, "ACTIONS.", Dialogue_NewPage

Dialogue_Index_0264:
.db Word_Attack, " ME NOW, IF", Dialogue_NewLine
.db Word_You, "DARE.", Dialogue_Terminator65

Dialogue_Index_0266:
.db "I", Dialogue_Apostrophe, "M BUT ONLY", Dialogue_NewLine
.db Word_Lassic, Dialogue_Apostrophe, "S SHADOW!", Dialogue_NewPage

Dialogue_Index_0268:
.db "EVEN IF ", Word_You, "DEFEATME, YOU", Dialogue_Apostrophe, "VE GAINED", Dialogue_NewPage
.db "NO", Word_Thing, " AT ALL!", Dialogue_Terminator65

Dialogue_Index_026A:
.db "DON", Dialogue_Apostrophe, "T GO AGAINST", Dialogue_NewLine
.db Word_Lassic, "!", Dialogue_Terminator65

Dialogue_Index_026C:
.db "AH, MY CHILDREN,", Dialogue_NewLine
.db Word_You, Word_Have, "D", Word_One, " VERY", Dialogue_NewPage
.db "WELL TO COME ", Word_This, Dialogue_NewLine
.db "FAR. ", Word_You, Word_Are, "VERY", Dialogue_NewPage
.db "LUCKY ", Word_Indeed, ". DO", Dialogue_NewLine
.db Word_You, "REALLY ", Word_Wish, " TO", Dialogue_NewPage
.db "KILL AN OLD MAN?", Dialogue_Terminator62

Dialogue_Index_026E:
.db "ALL RIGHT! THEN", Dialogue_NewLine
.db "WE ", Word_Will, " FORGET", Dialogue_NewPage
.db Word_This, "AS AN UNFOR-", Dialogue_NewLine
.db "TUNATE MISTAKE.", Dialogue_Terminator65

Dialogue_Index_0270:
.db "EVEN NOW ", Word_You, "TRY", Dialogue_NewLine
.db "TO FOOL WITH ME?", Dialogue_NewPage
.db Word_You, "SHALL REPENT!", Dialogue_Terminator65

Dialogue_Index_0272:
.db "I", Dialogue_Apostrophe, "M SORRY, I ", Word_Must, Dialogue_NewLine
.db Word_Have, "BEEN", Dialogue_NewPage

Dialogue_Index_0274:
.db "POSSESSED BODY ANDSOUL BY EVIL.", Dialogue_NewPage

Dialogue_Index_0276:
.db Word_You, "RESCUED OUR", Dialogue_NewLine
.db Word_World, " JUST IN ", Word_The, Dialogue_NewPage
.db "NICK OF ", Word_Time, "! IF", Dialogue_NewLine
.db Word_You, "HAD COME ", Word_Any, Dialogue_NewPage

Dialogue_Index_0278:
.db "LATER, IT MIGHT", Dialogue_NewLine
.db Word_Have, "BEEN TOO LATE", Dialogue_NewPage
.db "WE ALL ", Word_Thank_You, Dialogue_NewLine
.db Word_From, Word_The, "BOTTOM", Dialogue_NewPage
.db "OF OUR HEARTS.", Dialogue_NewLine
.db Word_Alis, ", ", Word_Your, Word_Father, Dialogue_NewPage
.db "WAS ONCE ", Word_King, " OF", Dialogue_NewLine
.db Word_Algol, ". ", Word_The, "DARK", Dialogue_NewPage
.db Word_Castle, " HAS BEEN", Dialogue_NewLine
.db "DESTROYED, ", Word_Lassic, Dialogue_NewPage
.db "KILLED... ", Word_Do_You, ",", Dialogue_NewLine
.db Word_Alis, ",", Word_Wish, " TO", Dialogue_NewPage
.db "ASCEND ", Word_Your, Dialogue_NewLine
.db Word_Father, Dialogue_Apostrophe, "S THR", Word_One, Dialogue_NewPage
.db "AND BECOME ", Word_The, Dialogue_NewLine
.db Word_Queen, " OF ", Word_Algol, "?", Dialogue_Terminator62

Dialogue_Index_027A:
.db "RAISE ", Word_The, Dialogue_NewLine
.db "AEROPRISM TOWARDS", Dialogue_NewPage
.db Word_The, "HEAVENS- ", Word_You, Dialogue_NewLine
.db "SHOULD THEN BE", Dialogue_NewPage
.db "ABLE TO SEE ", Word_The, Dialogue_NewLine
.db "DARK ", Word_Castle, ".", Dialogue_Terminator65

Dialogue_Index_027C:
.db "ALRIGHT! ", Word_You, "SAVEDALL OF ", Word_Algol, "!", Dialogue_Terminator65

Dialogue_Index_027E:
.db Word_We_Are, " ALL", Dialogue_NewLine
.db "THANKFUL FOR ", Word_Your, Dialogue_NewPage
.db "BRAVE DEEDS! WE", Dialogue_NewLine
.db "LOVE ", Word_You, "!", Dialogue_Terminator65

Dialogue_Index_0280:
.db "REPORT QUICKLY TO", Dialogue_NewLine
.db Word_The, Word_Governor, "!", Dialogue_Terminator65

Dialogue_Index_0282:
.db Word_You, Word_Cannot, " COME", Dialogue_NewLine
.db Word_Through, " ", Word_Here, ".", Dialogue_NewPage
.db Word_This, "IS MY AREA.", Dialogue_Terminator65

Dialogue_Index_0284:
.db "WELL,IF DR.", Word_Luveno, Dialogue_NewLine
.db "SENT ", Word_You, ",I GUESS", Dialogue_NewPage
.db "I ", Word_Have, "TO LET ", Word_You, Dialogue_NewLine
.db Word_Through, ".", Dialogue_Terminator65

Dialogue_Index_0286:
.db "THEY SAY ", Word_That, Dialogue_NewLine
.db Word_There_Are, " ", Word_Motavia, "N", Dialogue_NewPage
.db "LIVING ON ", Word_Motavia, Dialogue_NewLine
.db "AND ", Word_Dezorian, "N ON", Dialogue_NewPage
.db Word_Dezoris, ". I", Dialogue_Apostrophe, "D SURE", Dialogue_NewLine
.db "LIKE A CHANCE TO", Dialogue_NewPage
.db "TALK TO ", Word_Some, Word_One, ".", Dialogue_Terminator65

Dialogue_Index_0288:
.db Word_Some, " INTELLIGENT", Dialogue_NewLine
.db "MONSTERS ", Word_Have, Dialogue_NewPage
.db "THEIR OWN", Dialogue_NewLine
.db Word_Language, ".", Dialogue_Terminator65

Dialogue_Index_028A:
.db "I SOLD ", Word_That, Dialogue_NewLine
.db Word_Laconian_Pot, " FOR", Dialogue_NewPage
.db "A ", Word_Great, "DEAL OF", Dialogue_NewLine
.db "M", Word_One, "Y. ", Word_Thanks, ".", Dialogue_Terminator65

Dialogue_Index_028C:
.db "NOW ", Word_That, " MY STAFF", Dialogue_NewLine
.db "IS ASSEMBLED", Dialogue_NewPage
.db "I CAN BEGIN.", Word_There, Dialogue_NewLine
.db "IS HOWERVER, A", Dialogue_NewPage

Dialogue_Index_028E:
.db "SLIGHT FEE OF 1200", Word_Mesetas, " INVOLVED.", Dialogue_NewPage
.db Word_Will_You, " PAY?", Dialogue_Terminator62

Dialogue_Index_0290:
.db Word_Thank_You, ". I CAN", Dialogue_NewLine
.db "NOW GET TO WORK.", Dialogue_NewPage
.db Word_Please, "WAIT ", Word_One, Dialogue_NewLine
.db "MOMENT.", Dialogue_Terminator65

Dialogue_Index_0292:
.db "IT ", Word_Cannot, " BE", Dialogue_NewLine
.db "HURRIED! ", Word_Please, Dialogue_NewPage
.db "SHOW A BIT MORE", Dialogue_NewLine
.db "PATIENCE!", Dialogue_Terminator65

Dialogue_Index_0294:
.db "WE CAN BOARD ", Word_The, Dialogue_NewLine
.db Word_Luveno, " AND BE ON", Dialogue_NewPage
.db "OUR WAY!", Dialogue_Terminator65

Dialogue_Index_0296:
.db "HEY, BRING ", Word_That, Dialogue_NewLine
.db "CAT OVER ", Word_Here, "!", Dialogue_Terminator62

Dialogue_Index_0298:
.db "OOHH,HA,HA! ", Word_The, Dialogue_NewLine
.db "CAT ", Word_Will, " DIE!", Dialogue_Terminator65

Dialogue_Index_029A:
.db "I ", Word_Will, " KILL ", Word_Any, Dialogue_NewLine
.db "WHO INTERFERE!", Dialogue_Terminator65

Dialogue_Index_029C:
.db Word_You, "SHOULD ", Word_Rest, Dialogue_NewLine
.db Word_Here, " AWHILE AFTER", Dialogue_NewPage
.db Word_Your, "LONG JOURNEY.", Dialogue_Terminator65

Dialogue_Index_029E:
.db Word_That, " WAS QUICK-OH,", Dialogue_NewLine
.db Word_I_See, ",", Word_You, Word_Are, Word_Not, Dialogue_NewPage
.db Word_Through, " WITH", Dialogue_NewLine
.db Word_Lassic, ". ", Word_You, "HAD", Dialogue_NewPage
.db "BEST ", Word_Rest, " AT ", Word_The, Dialogue_NewLine
.db "INN.", Dialogue_Terminator65

Dialogue_Index_02A0:
.db Word_You, "FELL INTO A", Dialogue_NewLine
.db "DEEP SLEEP.", Dialogue_Terminator63

Dialogue_Index_02A2:
.db Word_You, "HAD A BAD", Dialogue_NewLine
.db "DREAM.", Dialogue_Terminator65

Dialogue_Index_02A4:
.db Word_Here, " IS ", Word_The, "HOME", Dialogue_NewLine
.db "OF ", Word_Alis, ".", Dialogue_Terminator65

Dialogue_Index_02A6:
.db "IT HAS ", Word_Some, Word_Thing, Dialogue_NewLine
.db Word_Strange, ".", Dialogue_NewPage
.db Word_Where, " IS ", Word_The, Dialogue_NewLine
.db Word_Governor, ",I WONDER?", Dialogue_Terminator65

Dialogue_Index_02A8:
.db Word_You, Word_Have, "GOTTEN", Dialogue_NewLine
.db Word_Yourself, " KILLED?", Dialogue_NewPage
.db "COME, LET", Dialogue_Apostrophe, "S TRY", Dialogue_NewLine
.db Word_One, " MORE ", Word_Time, ".", Dialogue_Terminator65

Dialogue_Index_02AA:
.db Word_Lassic, " HAS DIED.", Dialogue_NewLine
.db Word_Alis, " ACCOMPLISHED", Dialogue_NewPage
.db "HER ", Word_Wish, ". ", Word_Nero, " IS", Dialogue_NewLine
.db "SATISFIED NOW IN", Dialogue_NewPage
.db "HEAVEN. HURRY TO", Dialogue_NewLine
.db Word_The, Word_Governor, "!", Dialogue_Terminator65

DialogueIntro1:
.db "SCUM! DO NOT SNIFF", Dialogue_NewLine
.db "AROUND IN ", Word_Lassic, Dialogue_Apostrophe, "S", Dialogue_NewLine
.db "AFFAIRS! LEARN", Dialogue_NewLine
.db "THIS LESSON WELL!", Dialogue_NewPage
.db Word_Nero, "! WHAT HAPP-", Dialogue_NewLine
.db "ENED! DON", Dialogue_Apostrophe, "T DIE!", Dialogue_Terminator65

DialogueIntro2:
.db Word_Alis, ",LISTEN!", Dialogue_NewLine
.db Word_Lassic, " IS LEADING", Dialogue_NewLine
.db "OUR ", Word_World, " TO", Dialogue_NewLine
.db "DESTRUCTION. I", Dialogue_NewPage
.db "TRIED TO DISCOVER", Dialogue_NewLine
.db "HIS PLANS, BUT I", Dialogue_NewLine
.db "C", Word_Ould, " NOT DO MUCH", Dialogue_NewLine
.db "BY MYSELF.", Dialogue_NewPage
.db "I ", Word_Have, "HEARD OF A", Dialogue_NewLine
.db "MAN WITH ", Word_Great, Dialogue_NewLine
.db "STRENGTH ", Word_Named, Dialogue_NewLine
.db "\"ODIN.\" MAYBE THE", Dialogue_NewPage
.db "TWO OF ", Word_You, "CAN", Dialogue_NewLine
.db "STOP ", Word_Lassic, ".", Dialogue_NewLine
.db Word_Alis, ",IT", Dialogue_Apostrophe, "S TOO LATE", Dialogue_NewLine
.db "FOR ME. BE STRONG.", Dialogue_Terminator65

DialogueIntro3:
.db "I ", Word_Will, " MAKE SURE", Dialogue_NewLine
.db Word_That, " ", Word_My_Brother, Dialogue_NewLine
.db "DIED NOT IN VAIN!", Dialogue_NewLine
.db "WATCH OVER AND", Dialogue_NewPage
.db "PROTECT ME, ", Word_Nero, "!", Dialogue_Terminator65

DialogueMyauIntro1:
.db "WE ", Word_Will, " BE FELLOW", Dialogue_NewLine
.db "TRAVELERS.", Dialogue_NewLine
.db "I", Dialogue_Apostrophe, "M ", Word_Alis, "; WHAT", Dialogue_Apostrophe, "S", Dialogue_NewLine
.db Word_Your, "NAME?", Dialogue_Terminator65

DialogueMyauIntro2:
.db "I", Dialogue_Apostrophe, "M ", Word_Myau, ".", Dialogue_Terminator65

DialogueMyauIntro3:
.db Word_Myau, ", ", Word_Have, Word_You, Dialogue_NewLine
.db "EVER HEARD OF A", Dialogue_NewLine
.db "MAN ", Word_Named, "ODIN?", Dialogue_Terminator65

DialogueMyauIntro4:
.db "YES, BUT HE IS", Dialogue_NewLine
.db Word_Turned_To_Stone, "!", Dialogue_NewLine
.db "IF HE DRINKS THIS", Dialogue_NewLine
.db "MEDICINE, HE", Dialogue_Apostrophe, "LL BE", Dialogue_NewPage
.db "O.K., BUT I ", Word_Cannot, Dialogue_NewLine
.db "OPEN ", Word_The, "BOTTLE.", Dialogue_Terminator65

DialogueMyauIntro5:
.db "WELL, THEN, WE", Dialogue_Apostrophe, "D", Dialogue_NewLine
.db "BETTER GO ", Word_Save, Dialogue_NewLine
.db "ODIN TOGETHER,", Dialogue_NewLine
.db "O.K.?", Dialogue_Terminator65

DialogueOdinIntro1:
.db Word_Thanks, " FOR SAVING", Dialogue_NewLine
.db "ME. I GUESS IF", Dialogue_NewLine
.db Word_Medusa, " CAN STOP", Dialogue_NewLine
.db "ME, I DON", Dialogue_Apostrophe, "T ", Word_Have, Dialogue_NewPage
.db "MUCH HOPE OF", Dialogue_NewLine
.db "KILLING ", Word_Lassic, ",", Dialogue_NewLine
.db "DO I?", Dialogue_Terminator65

DialogueOdinIntro2:
.db Word_My_Brother, " DIED", Dialogue_NewLine
.db "TRYING TO KILL", Dialogue_NewLine
.db Word_Lassic, ". BEFORE HE", Dialogue_NewLine
.db "DIED, HE TOLD ME", Dialogue_NewPage
.db "TO SEEK ", Word_Your, Word_Help, ".", Dialogue_Terminator65

DialogueOdinIntro3:
.db "IS ", Word_That, " SO? WELL,", Dialogue_NewLine
.db "I ", Word_Must, " NOT LET", Dialogue_NewLine
.db Word_Your, "BROTHER DIE", Dialogue_NewLine
.db "UNAVENGED.", Dialogue_Terminator65

DialogueOdinIntro4:
.db "WHY DID ", Word_You, "TRY TO", Dialogue_NewLine
.db "KILL ", Word_Medusa, "?", Dialogue_Terminator65

DialogueOdinIntro5:
.db "BECAUSE ", Word_Medusa, " HAS", Dialogue_NewLine
.db "A MYSTIC AXE.", Dialogue_NewLine
.db "UNFORTUNATELY, SHE", Dialogue_NewLine
.db "GOT AWAY ", Word_From, "ME.", Dialogue_NewPage
.db "ANYHOW, I ", Word_Have, Dialogue_NewLine
.db "STASHED A COMPASS", Dialogue_NewLine
.db "IN ONE OF THE", Dialogue_NewLine
.db Word_Passage, "S OF ", Word_This, Dialogue_NewPage
.db "CAVE. LET", Dialogue_Apostrophe, "S GO AND", Dialogue_NewLine
.db "GET IT", Dialogue_Terminator65

DialogueNoahIntro1:
.db "I", Dialogue_Apostrophe, "VE RECEIVED A", Dialogue_NewLine
.db "LETTER ", Word_From, Word_The, Dialogue_NewLine
.db Word_Governor, ". ", Word_Please, Dialogue_NewLine
.db "READ IT.", Dialogue_Terminator65

DialogueNoahIntro2:
.db "LET ME SEE IT.....", Dialogue_NewLine
.db "OUR DUTY IS CLEAR;", Dialogue_NewLine
.db "WE ", Word_Must, " PROTECT", Dialogue_NewLine
.db Word_The, Word_Planets, " OF THE", Dialogue_NewPage
.db Word_Algol, " ", Word_System, " ", Word_From, Dialogue_NewLine
.db "EVIL.", Dialogue_NewLine
.db "WE ", Word_Must, " FIRST GO", Dialogue_NewLine
.db "TO ", Word_The, Word_Gothic, Dialogue_NewPage
.db "FORESTS AND FIND", Dialogue_NewLine
.db "DR.", Word_Luveno, ". WE CAN", Dialogue_NewLine
.db "USE AN UNDERGROUND", Dialogue_NewLine
.db Word_Passage, " ", Word_From, "A", Dialogue_NewPage
.db "MANHOLE IN THE", Dialogue_NewLine
.db Word_Spaceport, ".", Dialogue_Terminator65

DialogueMyauTransformation1:
.db "WHEN ", Word_Myau, " EATS THE", Dialogue_NewLine
.db "NUTS OF ", Word_Laerma, ", HE", Dialogue_NewLine
.db "BECOMES CLOTHED IN", Dialogue_NewLine
.db "FLAME AND EMITS A", Dialogue_NewPage
.db "BLINDING LIGHT.", Dialogue_Terminator65

DialogueMyauTransformation2:
.db "WHEN HE IS VISIBLE", Dialogue_NewLine
.db "AGAIN, HE HAS BEEN", Dialogue_NewLine
.db "TRANSFORMED INTO", Dialogue_NewPage
.db "A BEAUTIFUL", Dialogue_NewLine
.db "WINGED BEAST.", Dialogue_NewLine
.db Word_Myau, " FLAPS HIS", Dialogue_NewLine
.db "WINGS PLOUDLY.", Dialogue_Terminator65

DialogueEndingAlis:
.db Dialogue_NewLine
.db "     ", Word_Alis, Dialogue_Terminator63

DialogueEndingOdin:
.db Dialogue_NewLine
.db "     ODIN", Dialogue_Terminator63

DialogueEndingNoah:
.db Dialogue_NewLine
.db "     NOAH", Dialogue_Terminator63

DialogueEndingMyau:
.db Dialogue_NewLine
.db "     AND ", Word_Myau, Dialogue_Terminator63

DialogueEndingEnd1:
.db "EVEN THOUGH THE", Dialogue_NewLine
.db "MEMORIES OF EVIL", Dialogue_NewLine
.db "FADE AWAY, THEIR", Dialogue_NewLine
.db "NAMES ", Word_Will, " BE KEPT", Dialogue_Terminator63

DialogueEndingEnd2:
.db $5F, "IN ", Word_The, "HEARTS OF", Dialogue_NewLine
.db Word_The, "PEOPLE OF ", Word_The, Dialogue_NewLine
.db "ALGOL FOREVER!!!", Dialogue_Terminator63


; This is a pointer table for the strings below
; When displaying dialogue, if bit 7 is set in a character the other 7 bits are used as an index into this table
; The corresponding word is loaded and displayed
DialogueWordBlock:
.dw Dialogue_Word_Index_00, Dialogue_Word_Index_01, Dialogue_Word_Index_02, Dialogue_Word_Index_03,
.dw Dialogue_Word_Index_04, Dialogue_Word_Index_05, Dialogue_Word_Index_06, Dialogue_Word_Index_07,
.dw Dialogue_Word_Index_08, Dialogue_Word_Index_09, Dialogue_Word_Index_0A, Dialogue_Word_Index_0B,
.dw Dialogue_Word_Index_0C, Dialogue_Word_Index_0D, Dialogue_Word_Index_0E, Dialogue_Word_Index_0F,
.dw Dialogue_Word_Index_10, Dialogue_Word_Index_11, Dialogue_Word_Index_12, Dialogue_Word_Index_13,
.dw Dialogue_Word_Index_14, Dialogue_Word_Index_15, Dialogue_Word_Index_16, Dialogue_Word_Index_17,
.dw Dialogue_Word_Index_18, Dialogue_Word_Index_19, Dialogue_Word_Index_1A, Dialogue_Word_Index_1B,
.dw Dialogue_Word_Index_1C, Dialogue_Word_Index_1D, Dialogue_Word_Index_1E, Dialogue_Word_Index_1F,
.dw Dialogue_Word_Index_20, Dialogue_Word_Index_21, Dialogue_Word_Index_22, Dialogue_Word_Index_23,
.dw Dialogue_Word_Index_24, Dialogue_Word_Index_25, Dialogue_Word_Index_26, Dialogue_Word_Index_27,
.dw Dialogue_Word_Index_28, Dialogue_Word_Index_29, Dialogue_Word_Index_2A, Dialogue_Word_Index_2B,
.dw Dialogue_Word_Index_2C, Dialogue_Word_Index_2D, Dialogue_Word_Index_2E, Dialogue_Word_Index_2F,
.dw Dialogue_Word_Index_30, Dialogue_Word_Index_31, Dialogue_Word_Index_32, Dialogue_Word_Index_33,
.dw Dialogue_Word_Index_34, Dialogue_Word_Index_35, Dialogue_Word_Index_36, Dialogue_Word_Index_37,
.dw Dialogue_Word_Index_38, Dialogue_Word_Index_39, Dialogue_Word_Index_3A, Dialogue_Word_Index_3B,
.dw Dialogue_Word_Index_3C, Dialogue_Word_Index_3D, Dialogue_Word_Index_3E, Dialogue_Word_Index_3F,
.dw Dialogue_Word_Index_40, Dialogue_Word_Index_41, Dialogue_Word_Index_42, Dialogue_Word_Index_43,
.dw Dialogue_Word_Index_44, Dialogue_Word_Index_45, Dialogue_Word_Index_46, Dialogue_Word_Index_47,
.dw Dialogue_Word_Index_48, Dialogue_Word_Index_49, Dialogue_Word_Index_4A, Dialogue_Word_Index_4B,
.dw Dialogue_Word_Index_4C, Dialogue_Word_Index_4D, Dialogue_Word_Index_4E, Dialogue_Word_Index_4F,
.dw Dialogue_Word_Index_50, Dialogue_Word_Index_51, Dialogue_Word_Index_52, Dialogue_Word_Index_53,
.dw Dialogue_Word_Index_54, Dialogue_Word_Index_55, Dialogue_Word_Index_56, Dialogue_Word_Index_57,
.dw Dialogue_Word_Index_58, Dialogue_Word_Index_59, Dialogue_Word_Index_5A, Dialogue_Word_Index_5B,
.dw Dialogue_Word_Index_5C, Dialogue_Word_Index_5D, Dialogue_Word_Index_5E, Dialogue_Word_Index_5F,
.dw Dialogue_Word_Index_60, Dialogue_Word_Index_61, Dialogue_Word_Index_62, Dialogue_Word_Index_63,
.dw Dialogue_Word_Index_64, Dialogue_Word_Index_65, Dialogue_Word_Index_66, Dialogue_Word_Index_67,
.dw Dialogue_Word_Index_68, Dialogue_Word_Index_69, Dialogue_Word_Index_6A, Dialogue_Word_Index_6B,
.dw Dialogue_Word_Index_6C, Dialogue_Word_Index_6D, Dialogue_Word_Index_6E, Dialogue_Word_Index_6F,
.dw Dialogue_Word_Index_70, Dialogue_Word_Index_71, Dialogue_Word_Index_72, Dialogue_Word_Index_73,
.dw Dialogue_Word_Index_74, Dialogue_Word_Index_75, Dialogue_Word_Index_76, Dialogue_Word_Index_77,
.dw Dialogue_Word_Index_78, Dialogue_Word_Index_79, Dialogue_Word_Index_7A, Dialogue_Word_Index_7B,
.dw Dialogue_Word_Index_7C, Dialogue_Word_Index_7D, Dialogue_Word_Index_7E, Dialogue_Word_Index_7F,

Dialogue_Word_Index_00:
.db "ALIS", Dialogue_Terminator65

Dialogue_Word_Index_01:
.db "MYAU", Dialogue_Terminator65

Dialogue_Word_Index_02:
.db "ATTACK", Dialogue_Terminator65

Dialogue_Word_Index_03:
.db "EFFECTIVE", Dialogue_Terminator65

Dialogue_Word_Index_04:
.db "MAGIC ", Dialogue_Terminator65

Dialogue_Word_Index_05:
.db "WALL", Dialogue_Terminator65

Dialogue_Word_Index_06:
.db "HEALED", Dialogue_Terminator65

Dialogue_Word_Index_07:
.db "DEFLECTS", Dialogue_Terminator65

Dialogue_Word_Index_08:
.db "CANNOT", Dialogue_Terminator65

Dialogue_Word_Index_09:
.db "CASTLE", Dialogue_Terminator65

Dialogue_Word_Index_0A:
.db "HAPSBY", Dialogue_Terminator65

Dialogue_Word_Index_0B:
.db "WE ARE ", Dialogue_Terminator65

Dialogue_Word_Index_0C:
.db "HEADING FOR", Dialogue_Terminator65

Dialogue_Word_Index_0D:
.db "CARRY", Dialogue_Terminator65

Dialogue_Word_Index_0E:
.db "RESURRECT", Dialogue_Terminator65

Dialogue_Word_Index_0F:
.db "SAVE", Dialogue_Terminator65

Dialogue_Word_Index_10:
.db "CURRENTLY", Dialogue_Terminator65

Dialogue_Word_Index_11:
.db "TURNED TO STONE", Dialogue_Terminator65

Dialogue_Word_Index_12:
.db "MY BROTHER", Dialogue_Terminator65

Dialogue_Word_Index_13:
.db "DEZORIS", Dialogue_Terminator65

Dialogue_Word_Index_14:
.db "MOTAVIA", Dialogue_Terminator65

Dialogue_Word_Index_15:
.db "GOTHIC", Dialogue_Terminator65

Dialogue_Word_Index_16:
.db "SCION", Dialogue_Terminator65

Dialogue_Word_Index_17:
.db "WISH", Dialogue_Terminator65

Dialogue_Word_Index_18:
.db "SPACEPORT", Dialogue_Terminator65

Dialogue_Word_Index_19:
.db "PASSPORT", Dialogue_Terminator65

Dialogue_Word_Index_1A:
.db "PLANET", Dialogue_Terminator65

Dialogue_Word_Index_1B:
.db "ALGOL", Dialogue_Terminator65

Dialogue_Word_Index_1C:
.db "SYSTEM", Dialogue_Terminator65

Dialogue_Word_Index_1D:
.db "TOWER", Dialogue_Terminator65

Dialogue_Word_Index_1E:
.db "VILLAGE", Dialogue_Terminator65

Dialogue_Word_Index_1F:
.db "TIME", Dialogue_Terminator65

Dialogue_Word_Index_20:
.db "ROADPASS", Dialogue_Terminator65

Dialogue_Word_Index_21:
.db "MESETAS", Dialogue_Terminator65

Dialogue_Word_Index_22:
.db "PASS", Dialogue_Terminator65

Dialogue_Word_Index_23:
.db "ANT LION", Dialogue_Terminator65

Dialogue_Word_Index_24:
.db "SOOTHING FLUTE", Dialogue_Terminator65

Dialogue_Word_Index_25:
.db "SECRET", Dialogue_Terminator65

Dialogue_Word_Index_26:
.db "LACONIAN POT", Dialogue_Terminator65

Dialogue_Word_Index_27:
.db "MAHARU", Dialogue_Terminator65

Dialogue_Word_Index_28:
.db "BORTEVO", Dialogue_Terminator65

Dialogue_Word_Index_29:
.db "YOURSELF", Dialogue_Terminator65

Dialogue_Word_Index_2A:
.db "GOVERNOR", Dialogue_Terminator65

Dialogue_Word_Index_2B:
.db "HILL", Dialogue_Terminator65

Dialogue_Word_Index_2C:
.db "STRANGE", Dialogue_Terminator65

Dialogue_Word_Index_2D:
.db "LUVENO", Dialogue_Terminator65

Dialogue_Word_Index_2E:
.db "HOWEVER", Dialogue_Terminator65

Dialogue_Word_Index_2F:
.db "KING", Dialogue_Terminator65

Dialogue_Word_Index_30:
.db "QUEEN", Dialogue_Terminator65

Dialogue_Word_Index_31:
.db "FATHER", Dialogue_Terminator65

Dialogue_Word_Index_32:
.db "NERO", Dialogue_Terminator65

Dialogue_Word_Index_33:
.db "THANKS", Dialogue_Terminator65

Dialogue_Word_Index_34:
.db "THANK YOU", Dialogue_Terminator65

Dialogue_Word_Index_35:
.db "WORLD", Dialogue_Terminator65

Dialogue_Word_Index_36:
.db "SHIELD", Dialogue_Terminator65

Dialogue_Word_Index_37:
.db "I SEE", Dialogue_Terminator65

Dialogue_Word_Index_38:
.db "PLANETS", Dialogue_Terminator65

Dialogue_Word_Index_39:
.db "TOWN", Dialogue_Terminator65

Dialogue_Word_Index_3A:
.db "PASSAGE", Dialogue_Terminator65

Dialogue_Word_Index_3B:
.db "SOOTHSAYER", Dialogue_Terminator65

Dialogue_Word_Index_3C:
.db "LACONIA", Dialogue_Terminator65

Dialogue_Word_Index_3D:
.db "LABORATORY", Dialogue_Terminator65

Dialogue_Word_Index_3E:
.db "KNOW", Dialogue_Terminator65

Dialogue_Word_Index_3F:
.db "REST", Dialogue_Terminator65

Dialogue_Word_Index_40:
.db "BAYA", Dialogue_Terminator65

Dialogue_Word_Index_41:
.db "MALAY", Dialogue_Terminator65

Dialogue_Word_Index_42:
.db "BAYA MALAY", Dialogue_Terminator65

Dialogue_Word_Index_43:
.db "DO YOU KNOW", Dialogue_Terminator65

Dialogue_Word_Index_44:
.db "FOREST", Dialogue_Terminator65

Dialogue_Word_Index_45:
.db "DO YOU HAVE", Dialogue_Terminator65

Dialogue_Word_Index_46:
.db "DO YOU", Dialogue_Terminator65

Dialogue_Word_Index_47:
.db "WILL", Dialogue_Terminator65

Dialogue_Word_Index_48:
.db "MUST", Dialogue_Terminator65

Dialogue_Word_Index_49:
.db "PLEASE ", Dialogue_Terminator65

Dialogue_Word_Index_4A:
.db "HELP", Dialogue_Terminator65

Dialogue_Word_Index_4B:
.db "YOU WILL", Dialogue_Terminator65

Dialogue_Word_Index_4C:
.db "I WILL", Dialogue_Terminator65

Dialogue_Word_Index_4D:
.db "WILL YOU", Dialogue_Terminator65

Dialogue_Word_Index_4E:
.db "YOU MUST", Dialogue_Terminator65

Dialogue_Word_Index_4F:
.db "PALMA", Dialogue_Terminator65

Dialogue_Word_Index_50:
.db "WHERE", Dialogue_Terminator65

Dialogue_Word_Index_51:
.db "THERE", Dialogue_Terminator65

Dialogue_Word_Index_52:
.db "HERE", Dialogue_Terminator65

Dialogue_Word_Index_53:
.db "INDEED", Dialogue_Terminator65

Dialogue_Word_Index_54:
.db "LASSIC", Dialogue_Terminator65

Dialogue_Word_Index_55:
.db "SOME", Dialogue_Terminator65

Dialogue_Word_Index_56:
.db "RESIDENTIAL AREA", Dialogue_Terminator65

Dialogue_Word_Index_57:
.db "LAERMA", Dialogue_Terminator65

Dialogue_Word_Index_58:
.db "DUNGEON", Dialogue_Terminator65

Dialogue_Word_Index_59:
.db "LANGUAGE", Dialogue_Terminator65

Dialogue_Word_Index_5A:
.db "THERE IS", Dialogue_Terminator65

Dialogue_Word_Index_5B:
.db "THERE ARE", Dialogue_Terminator65

Dialogue_Word_Index_5C:
.db "THAT", Dialogue_Terminator65

Dialogue_Word_Index_5D:
.db "THROUGH", Dialogue_Terminator65

Dialogue_Word_Index_5E:
.db "THE ", Dialogue_Terminator65

Dialogue_Word_Index_5F:
.db "PRESENT", Dialogue_Terminator65

Dialogue_Word_Index_60:
.db "WELCOME ", Dialogue_Terminator65

Dialogue_Word_Index_61:
.db "YOU ", Dialogue_Terminator65

Dialogue_Word_Index_62:
.db "YOUR ", Dialogue_Terminator65

Dialogue_Word_Index_63:
.db "HAVE ", Dialogue_Terminator65

Dialogue_Word_Index_64:
.db "THIS ", Dialogue_Terminator65

Dialogue_Word_Index_65:
.db "MOUNTAIN", Dialogue_Terminator65

Dialogue_Word_Index_66:
.db "GREAT ", Dialogue_Terminator65

Dialogue_Word_Index_67:
.db "NAMED ", Dialogue_Terminator65

Dialogue_Word_Index_68:
.db "SPACESHIP", Dialogue_Terminator65

Dialogue_Word_Index_69:
.db "PALMANS", Dialogue_Terminator65

Dialogue_Word_Index_6A:
.db "MEDUSA", Dialogue_Terminator65

Dialogue_Word_Index_6B:
.db "DON", Dialogue_Apostrophe, "T BE A FOOL!", Dialogue_Terminator65

Dialogue_Word_Index_6C:
.db "ARE ", Dialogue_Terminator65

Dialogue_Word_Index_6D:
.db "CAREFUL", Dialogue_Terminator65

Dialogue_Word_Index_6E:
.db "DELETE", Dialogue_Terminator65

Dialogue_Word_Index_6F:
.db "MAGIC", Dialogue_Terminator65

Dialogue_Word_Index_70:
.db "SABRUS CABRUS", Dialogue_Terminator65

Dialogue_Word_Index_71:
.db "TREASURE ", Dialogue_Terminator65

Dialogue_Word_Index_72:
.db "CHEST", Dialogue_Terminator65

Dialogue_Word_Index_73:
.db "MOVE", Dialogue_Terminator65

Dialogue_Word_Index_74:
.db "DEZORIAN", Dialogue_Terminator65

Dialogue_Word_Index_75:
.db "EMBARK", Dialogue_Terminator65

Dialogue_Word_Index_76:
.db "ANY", Dialogue_Terminator65

Dialogue_Word_Index_77:
.db "THING", Dialogue_Terminator65

Dialogue_Word_Index_78:
.db "NOT ", Dialogue_Terminator65

Dialogue_Word_Index_79:
.db "WANT ", Dialogue_Terminator65

Dialogue_Word_Index_7A:
.db "GAME", Dialogue_Terminator65

Dialogue_Word_Index_7B:
.db "FACING ", Dialogue_Terminator65

Dialogue_Word_Index_7C:
.db "SELECT", Dialogue_Terminator65

Dialogue_Word_Index_7D:
.db "ONE", Dialogue_Terminator65

Dialogue_Word_Index_7E:
.db "FROM ", Dialogue_Terminator65

Dialogue_Word_Index_7F:
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

