; Ports
.define	Port_PSG $7F
.define	Port_VDPData $BE
.define	Port_VDPAddress $BF

; Input Ports
.define	Port_VDPStatus $BF
.define	Port_IOPort1 $DC
.define	Port_IOPort2 $DD

; Stats offsets
.define	status 0	; byte
.define	curr_hp 1	; byte
.define	curr_mp 2	; byte
.define	exp 3	; word
.define	level 5	; byte
.define	max_hp 6	; byte
.define	max_mp 7	; byte
.define	attack 8	; byte
.define	defense 9	; byte
.define	weapon $A	; byte
.define	armor $B	; byte
.define shield $C	; byte
.define	battle_magic_num $E	; byte
.define	map_magic_num $F	; byte

; Items
.define	ItemID_Nothing 0
.define	ItemID_WoodCane 1
.define	ItemID_ShortSword 2
.define	ItemID_IronSword 3
.define	ItemID_Wand 4
.define	ItemID_IronFang 5
.define	ItemID_IronAxe 6
.define	ItemID_TitaniumSword 7
.define	ItemID_CeramicSword 8
.define	ItemID_NeedleGun 9
.define	ItemID_SilverFang $A
.define	ItemID_HeatGun $B
.define	ItemID_LightSaber $C
.define	ItemID_LaserGun $D
.define	ItemID_LaconiaSword $E
.define	ItemID_LaconiaAxe $F
.define	ItemID_LeatherArmor $10
.define	ItemID_WhiteMantle $11
.define	ItemID_LightSuit $12
.define	ItemID_IronArmor $13
.define	ItemID_ThickFur $14
.define	ItemID_ZirconiaArmor $15
.define	ItemID_DiamondArmor $16
.define	ItemID_LaconiaArmor $17
.define	ItemID_FradeMantle $18
.define	ItemID_LeatherShield $19
.define	ItemID_BronzeShield $1A
.define	ItemID_IronShield $1B
.define	ItemID_CeramicShield $1C
.define	ItemID_Gloves $1D
.define	ItemID_LaserShield $1E
.define	ItemID_MirrorShield $1F
.define	ItemID_LaconiaShield $20
.define	ItemID_Landrover $21
.define	ItemID_Hovercraft $22
.define	ItemID_IceDigger $23
.define	ItemID_Cola $24
.define	ItemID_Burger $25
.define	ItemID_Flute $26
.define	ItemID_Flash $27
.define	ItemID_Escaper $28
.define	ItemID_Transfer $29
.define	ItemID_MagicHat $2A
.define	ItemID_Alsulin $2B
.define	ItemID_Polymaterial $2C
.define	ItemID_DungeonKey $2D
.define	ItemID_Sphere $2E
.define	ItemID_EclipseTorch $2F
.define	ItemID_AeroPrism $30
.define	ItemID_Nuts $31
.define	ItemID_Hapsby $32
.define	ItemID_RoadPass $33
.define	ItemID_Passport $34
.define	ItemID_Compass $35
.define	ItemID_Cake $36
.define	ItemID_Letter $37
.define	ItemID_LaconiaPot $38
.define	ItemID_MagicLamp $39
.define	ItemID_AmberEye $3A
.define	ItemID_GasShield $3B
.define	ItemID_Crystal $3C
.define	ItemID_MSystem $3D
.define	ItemID_MiracleKey $3E

.define	InventoryMaxNum 24
.define	Maximum_Level 30

; Buttons
.define	ButtonUp 0
.define	ButtonDown 1
.define	ButtonLeft 2
.define	ButtonRight 3
.define	Button_1 4
.define	Button_2 5

.define	ButtonUp_Mask 1<<ButtonUp
.define	ButtonDown_Mask 1<<ButtonDown
.define	ButtonLeft_Mask 1<<ButtonLeft
.define	ButtonRight_Mask 1<<ButtonRight
.define	Button_1_Mask 1<<Button_1
.define	Button_2_Mask 1<<Button_2


; Dialogue
.define Dialogue_Apostrophe $40
.define Dialogue_CurrentCharacter $5B
.define Dialogue_EnemyName $5C
.define Dialogue_CurrentItem $5D
.define Dialogue_NewLine $60
.define Dialogue_NewPage $61
.define Dialogue_Terminator62 $62
.define Dialogue_Terminator63 $63
.define Dialogue_Terminator64 $64
.define Dialogue_Terminator65 $65

; Words
; See DialogueWordBlock for more info
.define Word_Alis $80
.define Word_Myau $81
.define Word_Attack $82
.define Word_Effective $83
.define Word_Magic_84 $84
.define Word_Wall $85
.define Word_Healed $86
.define Word_Deflects $87
.define Word_Cannot $88
.define Word_Castle $89
.define Word_Hapsby $8A
.define Word_We_Are $8B
.define Word_Heading_For $8C
.define Word_Carry $8D
.define Word_Resurrect $8E
.define Word_Save $8F
.define Word_Currently $90
.define Word_Turned_To_Stone $91
.define Word_My_Brother $92
.define Word_Dezoris $93
.define Word_Motavia $94
.define Word_Gothic $95
.define Word_Scion $96
.define Word_Wish $97
.define Word_Spaceport $98
.define Word_Passport $99
.define Word_Planet $9A
.define Word_Algol $9B
.define Word_System $9C
.define Word_Tower $9D
.define Word_Village $9E
.define Word_Time $9F
.define Word_Roadpass $A0
.define Word_Mesetas $A1
.define Word_Pass $A2
.define Word_Ant_Lion $A3
.define Word_Soothing_Flute $A4
.define Word_Secret $A5
.define Word_Laconian_Pot $A6
.define Word_Maharu $A7
.define Word_Bortevo $A8
.define Word_Yourself $A9
.define Word_Governor $AA
.define Word_Hill $AB
.define Word_Strange $AC
.define Word_Luveno $AD
.define Word_However $AE
.define Word_King $AF
.define Word_Queen $B0
.define Word_Father $B1
.define Word_Nero $B2
.define Word_Thanks $B3
.define Word_Thank_You $B4
.define Word_World $B5
.define Word_Shield $B6
.define Word_I_See $B7
.define Word_Planets $B8
.define Word_Town $B9
.define Word_Passage $BA
.define Word_Soothsayer $BB
.define Word_Laconia $BC
.define Word_Laboratory $BD
.define Word_Know $BE
.define Word_Rest $BF
.define Word_Baya $C0
.define Word_Malay $C1
.define Word_Baya_Malay $C2
.define Word_Do_You_Know $C3
.define Word_Forest $C4
.define Word_Do_You_Have $C5
.define Word_Do_You $C6
.define Word_Will $C7
.define Word_Must $C8
.define Word_Please $C9
.define Word_Help $CA
.define Word_You_Will $CB
.define Word_I_Will $CC
.define Word_Will_You $CD
.define Word_You_Must $CE
.define Word_Palma $CF
.define Word_Where $D0
.define Word_There $D1
.define Word_Here $D2
.define Word_Indeed $D3
.define Word_Lassic $D4
.define Word_Some $D5
.define Word_Residential_Area $D6
.define Word_Laerma $D7
.define Word_Dungeon $D8
.define Word_Language $D9
.define Word_There_Is $DA
.define Word_There_Are $DB
.define Word_That $DC
.define Word_Through $DD
.define Word_The $DE
.define Word_Present $DF
.define Word_Welcome $E0
.define Word_You $E1
.define Word_Your $E2
.define Word_Have $E3
.define Word_This $E4
.define Word_Mountain $E5
.define Word_Great $E6
.define Word_Named $E7
.define Word_Spaceship $E8
.define Word_Palmans $E9
.define Word_Medusa $EA
.define Word_Dont_Be_A_Fool $EB
.define Word_Are $EC
.define Word_Careful $ED
.define Word_Delete $EE
.define Word_Magic_EF $EF
.define Word_Sabrus_Cabrus $F0
.define Word_Treasure $F1
.define Word_Chest $F2
.define Word_Move $F3
.define Word_Dezorian $F4
.define Word_Embark $F5
.define Word_Any $F6
.define Word_Thing $F7
.define Word_Not $F8
.define Word_Want $F9
.define Word_Game $FA
.define Word_Facing $FB
.define Word_Select $FC
.define Word_One $FD
.define Word_From $FE
.define Word_Ould $FF

; RAM
.define	Game_mode $C202
.define	Game_is_paused $C212
.define	Fade_timer $C21B

.define	Ctrl_1 $C204
.define	Ctrl_1_held $C204
.define	Ctrl_1_pressed $C205

.define	Cursor_pos $C269
.define	Option_total_num $C26E	; number of options available for an interactive menu (e.g. player menu)

.define	Interaction_Type $C29E ; Background?

.define	CurrentCharacter $C2C2 ; Used for battle dialogue etc
.define	CurrentItem $C2C4 ; Used in dialogue, Inventory_AddItem etc
.define	CurrentBattle_EnemyName $C2C8 ; 8 bytes
.define	CurrentBattle_EXPReward $C2D0 ; unsigned 2 bytes, little endian

.define	Dungeon_direction $C30A
.define	Dungeon_position $C30C
.define	Dungeon_index $C30D

.define	Char_stats $C400
.define	Alis_stats $C400
.define	Myau_stats $C410
.define	Odin_stats $C420
.define	Noah_stats $C430

.define	Inventory $C4C0
.define	Current_money $C4E0
.define	Inventory_curr_num $C4E2

.define	Party_curr_num $C4F0	; starts from 0

.define	System_stack $CB00
.define	Dungeon_layout $CB00	; $100 bytes; 1 byte per tile;
								; 	0 = Empty
								;	1 = Wall
								;	2 = Floor up
								;	3 = Floor down
								;	4 = Unlocked door	; bit 7 determines if it's open (set) or not (clear)
								;	5 = Dungeon key door
								;	6 = Magically locked door
								;	7 = Fake wall
								;	8 = Special object (can be either trap or treasure chest)
								;	$A = Exit up
								;	$B = Exit down
								;	$C = Exit door
								;	$D = Exit locked door
								;	$E = Ext magical door