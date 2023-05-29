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
.define tied_up $D	; byte
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
.define	ItemID_Zillion $3F
.define	ItemID_Secrets $40

.define	InventoryMaxNum 24
.define	Maximum_Level 30

; Magic
.define MagicID_Nothing 0
.define MagicID_Heal 1
.define MagicID_Cure 2
.define MagicID_Wall 3
.define MagicID_Prot 4
.define MagicID_Fire 5
.define MagicID_Thun 6
.define MagicID_Wind 7
.define MagicID_Rope 8
.define MagicID_Bye 9
.define MagicID_Help $A
.define MagicID_Terr $B
.define MagicID_Trap $C
.define MagicID_Exit $D
.define MagicID_Open $E
.define MagicID_Rise $F
.define MagicID_Chat $10
.define MagicID_Tele $11
.define MagicID_Fly $12

; Enemies
.define EnemyID_Nothing 0
.define EnemyID_Sworm 1
.define EnemyID_GrSlime 2
.define EnemyID_WingEye 3
.define EnemyID_ManEater 4
.define EnemyID_Scorpion 5
.define EnemyID_GScorpi 6
.define EnemyID_BlSlime 7
.define EnemyID_NFarmer 8
.define EnemyID_OwlBear 9
.define EnemyID_DeadTree $A
.define EnemyID_Scorpius $B
.define EnemyID_EFarmer $C
.define EnemyID_GiantFly $D
.define EnemyID_Crawler $E
.define EnemyID_Barbrian $F
.define EnemyID_GoldLens $10
.define EnemyID_RdSlime $11
.define EnemyID_WereBat $12
.define EnemyID_BigClub $13
.define EnemyID_Fishman $14
.define EnemyID_EvilDead $15
.define EnemyID_Tarantul $16
.define EnemyID_Manticor $17
.define EnemyID_Skeleton $18
.define EnemyID_AntLion $19
.define EnemyID_Marman $1A
.define EnemyID_Dezorian $1B
.define EnemyID_Leech $1C
.define EnemyID_Vampire $1D
.define EnemyID_Elephant $1E
.define EnemyID_Ghoul $1F
.define EnemyID_Shelfish $20
.define EnemyID_Executer $21
.define EnemyID_Wight $22
.define EnemyID_SkullEn $23
.define EnemyID_Ammonite $24
.define EnemyID_Sphinx $25
.define EnemyID_Serpent $26
.define EnemyID_Sandworm $27
.define EnemyID_Lich $28
.define EnemyID_Octopus $29
.define EnemyID_Stalker $2A
.define EnemyID_EvilHead $2B
.define EnemyID_Zombie $2C
.define EnemyID_Batalion $2D
.define EnemyID_RobotCop $2E
.define EnemyID_Sorcerer $2F
.define EnemyID_Nessie $30
.define EnemyID_Tarzimal $31
.define EnemyID_Golem $32
.define EnemyID_AndroCop $33
.define EnemyID_Tentacle $34
.define EnemyID_Giant $35
.define EnemyID_Wyvern $36
.define EnemyID_Reaper $37
.define EnemyID_Magician $38
.define EnemyID_Horseman $39
.define EnemyID_Frostman $3A
.define EnemyID_Amundsen $3B
.define EnemyID_RdDragn $3C
.define EnemyID_GrDragn $3D
.define EnemyID_Shadow $3E
.define EnemyID_Mammoth $3F
.define EnemyID_Centaur $40
.define EnemyID_Marauder $41
.define EnemyID_Titan $42
.define EnemyID_Medusa $43
.define EnemyID_WtDragn $44
.define EnemyID_BlDragn $45
.define EnemyID_GdDragn $46
.define EnemyID_DrMad $47
.define EnemyID_Lassic $48
.define EnemyID_DarkFalz $49
.define EnemyID_Saccubus $4A

; Dungeons - Some dungeon IDs are shared
.define DungeonID_MedusaCave 0
.define DungeonID_GothicTunnel 0
.define DungeonID_BayaMalayPass 0
.define DungeonID_TriadaPrison 1
.define DungeonID_CamineetWarehouse 2
.define DungeonID_AbionWarehouse 2
.define DungeonID_MedusaTowerB1F 3
.define DungeonID_MedusaTower1F 4
.define DungeonID_MedusaTower2F 5
.define DungeonID_MedusaTower3F 6
.define DungeonID_MedusaTower4F 7
.define DungeonID_MedusaTower5F 8
.define DungeonID_BayaMalayTowerB3F 8
.define DungeonID_MedusaTower6F 9
.define DungeonID_BayaMalayTowerB2F 9
.define DungeonID_MedusaTower7F $A
.define DungeonID_ayaMalayTowerB1F $A
.define DungeonID_BayaMalayTower1F $B
.define DungeonID_BayaMalayTower2F $C
.define DungeonID_BayaMalayTower3F $D
.define DungeonID_BayaMalayTower4F $E
.define DungeonID_BayaMalayTower5F $F
.define DungeonID_IalaCaveB3F $10
.define DungeonID_NaulaCaveB3F $10
.define DungeonID_IalaCaveB2F $11
.define DungeonID_NaulaCaveB2F $11
.define DungeonID_IalaCaveB1F $12
.define DungeonID_NaulaCaveB1F $12
.define DungeonID_IalaCave1F $13
.define DungeonID_NaulaCave1F $13
.define DungeonID_BayaMalayPrison $14
.define DungeonID_DrasgowWarehouse $15
.define DungeonID_DrMadLab $15
.define DungeonID_BortevoPass $16
.define DungeonID_IslandTower1F $17
.define DungeonID_IslandTower2F $18
.define DungeonID_IslandTower3F $19
.define DungeonID_IslandTower4F $1A
.define DungeonID_IslandTower5F $1B
.define DungeonID_MaharuCaveB2F $1C
.define DungeonID_MaharuCaveB1F $1D
.define DungeonID_MaharuCave1F $1E
.define DungeonID_GovernorPalaceB3F $1F
.define DungeonID_GovernorPalaceB2F $20
.define DungeonID_GovernorPalaceB1F $21
.define DungeonID_PathToGovernor $21
.define DungeonID_TarzimalCaveB2F $22
.define DungeonID_TarzimalCaveB1F $23
.define DungeonID_TarzimalCave1F $24
.define DungeonID_CasbaCaveB2F $25
.define DungeonID_CasbaCaveB1F $26
.define DungeonID_CasbaCave1F $27
.define DungeonID_SkureTunnel $28
.define DungeonID_TwintownTunnel $28
.define DungeonID_FortGuaronB1F $29
.define DungeonID_FortGuaron1F $2A
.define DungeonID_CoronaTower1F $2B
.define DungeonID_CoronaTower2F $2C
.define DungeonID_CoronaTower3F $2D
.define DungeonID_CoronaTower4F $2E
.define DungeonID_DezolisPath1 $2F
.define DungeonID_DezolisPath5B1F $2F
.define DungeonID_LacShieldCaveB5F $2F
.define DungeonID_DezolisPath2 $30
.define DungeonID_DezolisPath51F $30
.define DungeonID_LacShieldCaveB4F $30
.define DungeonID_DezolisPath4 $31
.define DungeonID_LacShieldCaveB3F $31
.define DungeonID_DezolisPath3 $32
.define DungeonID_LacShieldCaveB2F $32
.define DungeonID_LacShieldCaveB1F $33
.define DungeonID_LacShieldCave1F $34
.define DungeonID_AirCastleB4F $35
.define DungeonID_AirCastleB3F $36
.define DungeonID_AirCastleB2F $37
.define DungeonID_AirCastleB1F $38
.define DungeonID_AirCastle1F $39
.define DungeonID_AeroPrismCave $3A
.define DungeonID_CreditsDungeonB1F $3B
.define DungeonID_CreditsDungeon1F $3C


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
.define Dialogue_NumberFromC2C5 $5E
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

.define DialogueFlag_VisitedSuelo 1           ; 1 if you have been there
.define DialogueFlag_PotFromNekise 2       ; 1 if you have
.define DialogueFlag_LuvenoPrisonVisitCounter 3  ; 0 on first visit, 1 after
.define DialogueFlag_LuvenoState 4               ; 0 -> in prison, 1 -> waiting for assistant, 2 -> have found assistant, 3 -> paid, 4..5 -> waiting, 6 -> built but no Hapsby, 7 -> all done
.define DialogueFlag_NoahJoined 6                  ; 0 -> not joined yet,1 -> has joined party
.define DialogueFlag_FluteUnhidden 7      ; 0 -> hidden,1 -> can find it
.define DialogueFlag_HovercraftUnhidden 8      ; 0 -> hidden,1 -> can find it
.define DialogueFlag_MirrorShieldUnhidden 9      ; 0 -> hidden,1 -> can find it
.define DialogueFlag_StoneOdin $A
.define DialogueFlag_BeatLassic $16
.define DialogueFlag_ShadowWarrior $17

; RAM
.define Sound_index $C004

.define VDP_reg_0 $C200
.define VDP_reg_1 $C201

.define	Game_mode $C202

.define	Ctrl_1 $C204
.define	Ctrl_1_held $C204
.define	Ctrl_1_pressed $C205

.define V_int_routine $C208
.define Region_setting $C20A
.define Reset_button $C20B

.define RNG_seed $C20C

.define	Tile_map_high_byte $C210

.define	Game_is_paused $C212
.define	Palette_move_delay $C213
.define	Fade_timer $C21B

.define	Normal_palette $C220
.define	Target_palette $C240

.define	Scroll_direction $C264
.define	Rotate_palette_flag $C265
.define	Battle_current_player $C267
.define	Cursor_enabled $C268
.define	CursorTileMapAddress $C269
.define	Cursor_pos $C26B
.define	Cursor_old_pos $C26C
.define	Cursor_counter $C26D
.define	Option_total_num $C26E	; number of options available for an interactive menu (e.g. player menu)

.define Anim_counters $C26F
.define	Selected_inventory_item $C29B
.define	Battle_flag $C29D
.define	Scene_type $C29E ; Background?

.define	Anim_delay_counter $C2BC

.define	CurrentCharacter $C2C2 ; Used for battle dialogue etc
.define	CurrentItem $C2C4 ; Used in dialogue, Inventory_AddItem etc
.define	NumberToShowInText $C2C5 ; unsigned 2 bytes, little endian, used in dialogue, control character $5E
.define	CurrentBattle_EnemyName $C2C8 ; 8 bytes
.define	CurrentBattle_EXPReward $C2D0 ; unsigned 2 bytes, little endian

.define Dungeon_moving_flag $C2D2
.define Text_box_open_flag $C2D3
.define Map_anim_flag $C2D6

.define Dungeon_entrance_points_addr $C2D9
.define Room_index $C2DB
.define Enemy_money $C2DD
.define Dungeon_item_index $C2DF
.define Dungeon_obj_flag_addr $C2E1

.define Battle_rate $C2E3
.define Battle_enemy_pool_index $C2E4
.define Battle_enemy_id $C2E6
.define Battle_escape_rate $C2E7
.define Battle_enemy_action $C2E8
.define Battle_player_hurt_flag $C2ED
.define Battle_player_target $C2EE
.define Magic_wall_active $C2EF

.define Current_sound $C2F4

.define Game_data $C300

.define	H_scroll $C300
.define	H_location $C301
.define	V_scroll $C304
.define	V_location $C305
.define	Scroll_screens $C307
.define	Location_index $C309
.define	Dungeon_direction $C30A
.define	Dungeon_position $C30C
.define	Dungeon_index $C30D
.define	Vehicle_movement_flags $C30E
.define	Dungeon_palette_index $C315
.define	Last_church_visited $C317

.define	Char_stats $C400
.define	Alis_stats $C400
.define	Myau_stats $C410
.define	Odin_stats $C420
.define	Noah_stats $C430
.define	Enemy_stats $C440

.define	Inventory $C4C0
.define	Current_money $C4E0
.define	Inventory_curr_num $C4E2

.define	Party_curr_num $C4F0	; starts from 0

.define Dialogue_flags $C500	; table holding flags for dialogues; if value is $FF, dialogue is not loaded
.define Event_flags $C600	; used for chests and scripted encounters in dungeons
.define Battle_flags $C6C0	; used for chests and scripted encounters in dungeons

.define Name_entry_mode $C780
.define Name_entry_char_index $C781
.define Name_entry_cursor_x $C784
.define Name_entry_cursor_y $C785
.define Name_entry_cursor_tilemap_addr $C786
.define Name_entry_currently_pointed $C788
.define Name_entry_key_repeat_counter $C789

.define Character_sprite_attributes $C800

.define Sprite_table $C900

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
								;	8 = Object (Check out B03_ObjectData)
								;	$A = Exit up
								;	$B = Exit down
								;	$C = Exit door
								;	$D = Exit locked door
								;	$E = Ext magical door

.define Tilemap_data = $D000