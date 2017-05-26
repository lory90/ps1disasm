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
.define	curr_tp 2	; byte
.define	exp 3	; word
.define	level 5	; byte
.define	max_hp 6	; byte
.define	max_tp 7	; byte
.define	attack 8	; byte
.define	defense 9	; byte
.define	weapon $A	; byte
.define	armor $B	; byte
.define shield $C	; byte
.define	magic_num $E	; byte
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


; RAM
.define	Game_mode $C202

.define	Ctrl_1 $C204
.define	Ctrl_1_held $C204
.define	Ctrl_1_pressed $C205

.define	Option_total_num $C26E	; number of options available for an interactive menu (e.g. player menu)

.define	Char_stats $C400
.define	Alis_stats $C400
.define	Myau_stats $C410
.define	Odin_stats $C420
.define	Noah_stats $C430

.define	Inventory $C4C0
.define	Money_owned $C4E0
.define	Inventory_curr_num $C4E2

.define	Party_curr_num $C4F0	; starts from 0