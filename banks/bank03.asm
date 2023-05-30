LABEL_B03_8000:
.db $10, $0C, $10, $0C, $10, $0C, $10, $0B
.db $10, $0B, $10, $05, $10, $05, $10, $0F
.db $10, $0C, $10, $0C, $10, $0B, $10, $0B
.db $10, $0B, $10, $04, $10, $0F, $10, $0E
.db $10, $0A, $10, $0A, $10, $0A, $10, $0B
.db $10, $0B, $10, $01, $10, $01, $10, $0E
.db $10, $0D, $10, $0A, $10, $0A, $10, $07
.db $10, $00, $10, $00, $10, $01, $10, $06
.db $10, $0A, $10, $0A, $10, $0A, $10, $07
.db $10, $00, $10, $00, $10, $01, $10, $06
.db $10, $09, $10, $09, $10, $08, $10, $07
.db $10, $02, $10, $02, $10, $01, $10, $06
.db $10, $09, $10, $09, $10, $08, $10, $08
.db $10, $03, $10, $03, $10, $06, $10, $0B
.db $10, $0A, $10, $09, $10, $08, $10, $08
.db $10, $03, $10, $03, $10, $0B, $10, $0D
.db $10, $09, $10, $09, $10, $08, $10, $03
.db $10, $03, $10, $06, $10, $06, $10, $06
.db $10, $09, $10, $0E, $10, $0E, $10, $0E
.db $10, $02, $10, $02, $10, $02, $10, $02
.db $10, $08, $10, $0E, $10, $0F, $10, $0E
.db $10, $0D, $10, $01, $10, $01, $10, $05
.db $10, $08, $10, $0C, $10, $0C, $10, $0D
.db $10, $0D, $10, $00, $10, $00, $10, $05
.db $10, $08, $10, $0A, $10, $0B, $10, $0B
.db $10, $07, $10, $00, $10, $01, $10, $04
.db $10, $08, $10, $09, $10, $0B, $10, $0A
.db $10, $07, $10, $05, $10, $04, $10, $04
.db $10, $08, $10, $09, $10, $0A, $10, $0A
.db $10, $07, $10, $05, $10, $05, $10, $05
.db $10, $09, $10, $09, $10, $08, $10, $08
.db $10, $07, $10, $06, $10, $06, $10, $06
.db $10, $0F, $10, $0F, $10, $0D, $10, $0C
.db $10, $0E, $10, $0E, $10, $0F, $10, $0F
.db $10, $0F, $10, $0D, $10, $0D, $10, $0C
.db $10, $0B, $10, $0B, $10, $0C, $10, $0F
.db $10, $0D, $10, $0D, $10, $0D, $10, $0C
.db $10, $0B, $10, $0A, $10, $09, $10, $09
.db $10, $04, $10, $06, $10, $06, $10, $03
.db $10, $07, $10, $08, $10, $08, $10, $04
.db $10, $04, $10, $05, $10, $03, $10, $01
.db $10, $0D, $10, $08, $10, $06, $10, $04
.db $10, $03, $10, $03, $10, $00, $10, $00
.db $10, $0D, $10, $08, $10, $04, $10, $03
.db $10, $03, $10, $03, $10, $00, $10, $00
.db $10, $0D, $10, $0D, $10, $04, $10, $03
.db $10, $0F, $10, $02, $10, $02, $10, $01
.db $10, $0D, $10, $0D, $10, $0F, $10, $0F


; =============================================================
B03_EncounterPoolData:

; 1
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion

; 2
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_ManEater
.db	EnemyID_ManEater
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion

; 3
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_ManEater
.db	EnemyID_ManEater
.db	EnemyID_ManEater
.db	EnemyID_ManEater
.db	EnemyID_EvilDead

; 4
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_EvilDead

; 5
.db	EnemyID_Sworm
.db	EnemyID_GScorpi
.db	EnemyID_GScorpi
.db	EnemyID_GScorpi
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree

; 6
.db	EnemyID_ManEater
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_Manticor

; 7
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_GScorpi
.db	EnemyID_GScorpi
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_Manticor

; 8
.db	EnemyID_GiantFly
.db	EnemyID_GiantFly
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_Elephant
.db	EnemyID_Elephant
.db	EnemyID_Nessie

; 9
.db	EnemyID_Scorpion
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_Manticor
.db	EnemyID_Manticor
.db	EnemyID_Skeleton
.db	EnemyID_Skeleton
.db	EnemyID_Skeleton

; $A
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_Wight
.db	EnemyID_Wight
.db	EnemyID_Giant

; $B
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Centaur
.db	EnemyID_Centaur
.db	EnemyID_Centaur
.db	EnemyID_Centaur
.db	EnemyID_Centaur
.db	EnemyID_Centaur

; $C
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_Tarantul

; $D
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_SkullEn
.db	EnemyID_SkullEn
.db	EnemyID_SkullEn

; $E
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx

; $F
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Giant
.db	EnemyID_Giant
.db	EnemyID_Giant

; $10
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear

; $11
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree

; $12
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_WereBat

; $13
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul

; $14
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Skeleton
.db	EnemyID_Vampire

; $15
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul

; $16
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul
.db	EnemyID_SkullEn
.db	EnemyID_SkullEn
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx

; $17
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent

; $18
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx

; $19
.db	EnemyID_WingEye
.db	EnemyID_DeadTree
.db	EnemyID_DeadTree
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_Tarantul
.db	EnemyID_Skeleton
.db	EnemyID_Skeleton

; $1A
.db	EnemyID_Vampire
.db	EnemyID_SkullEn
.db	EnemyID_Serpent
.db	EnemyID_Batalion
.db	EnemyID_Golem
.db	EnemyID_Golem
.db	EnemyID_Golem
.db	EnemyID_Golem

; $1B
.db	EnemyID_OwlBear
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder

; $1C
.db	EnemyID_DeadTree
.db	EnemyID_Titan
.db	EnemyID_Titan
.db	EnemyID_Titan
.db	EnemyID_Titan
.db	EnemyID_Titan
.db	EnemyID_Titan
.db	EnemyID_Titan

; $1D
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm
.db	EnemyID_Sworm

; $1E
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman

; $1F
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead

; $20
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus

; $21
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent

; $22
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite

; $23
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern

; $24
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman
.db	EnemyID_Fishman

; $25
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_BigClub

; $26
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish

; $27
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus
.db	EnemyID_Octopus

; $28
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie

; $29
.db	EnemyID_GiantFly
.db	EnemyID_Marman
.db	EnemyID_Marman
.db	EnemyID_Marman
.db	EnemyID_Marman
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Serpent

; $2A
.db	EnemyID_Tentacle
.db	EnemyID_Tentacle
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern

; $2B
.db	EnemyID_BigClub
.db	EnemyID_BigClub
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Wight
.db	EnemyID_Wight
.db	EnemyID_Wight
.db	EnemyID_Wight

; $2C
.db	EnemyID_Wight
.db	EnemyID_Wight
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern

; $2D
.db	EnemyID_Manticor
.db	EnemyID_Manticor
.db	EnemyID_Wight
.db	EnemyID_Wight
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Sorcerer
.db	EnemyID_Reaper

; $2E
.db	EnemyID_AntLion
.db	EnemyID_AntLion
.db	EnemyID_AntLion
.db	EnemyID_AntLion
.db	EnemyID_AntLion
.db	EnemyID_AntLion
.db	EnemyID_AntLion
.db	EnemyID_AntLion

; $2F
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_GScorpi
.db	EnemyID_GScorpi
.db	EnemyID_NFarmer
.db	EnemyID_EFarmer

; $30
.db	EnemyID_Crawler
.db	EnemyID_Crawler
.db	EnemyID_Crawler
.db	EnemyID_Crawler
.db	EnemyID_Crawler
.db	EnemyID_Crawler
.db	EnemyID_Barbrian
.db	EnemyID_Barbrian

; $31
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Leech

; $32
.db	EnemyID_EFarmer
.db	EnemyID_EFarmer
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul
.db	EnemyID_Manticor
.db	EnemyID_Manticor
.db	EnemyID_SkullEn
.db	EnemyID_SkullEn

; $33
.db	EnemyID_Shelfish
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm

; $34
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish
.db	EnemyID_Shelfish

; $35
.db	EnemyID_Sandworm
.db	EnemyID_Sandworm
.db	EnemyID_Sorcerer
.db	EnemyID_Sorcerer
.db	EnemyID_Sorcerer
.db	EnemyID_Sorcerer
.db	EnemyID_Nessie
.db	EnemyID_Nessie

; $36
.db	EnemyID_Barbrian
.db	EnemyID_Nessie
.db	EnemyID_Golem
.db	EnemyID_Golem
.db	EnemyID_Golem
.db	EnemyID_Golem
.db	EnemyID_Golem
.db	EnemyID_Golem

; $37
.db	EnemyID_NFarmer
.db	EnemyID_NFarmer
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_Horseman
.db	EnemyID_Horseman
.db	EnemyID_Horseman
.db	EnemyID_Horseman

; $38
.db	EnemyID_Scorpion
.db	EnemyID_Scorpion
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Leech
.db	EnemyID_Amundsen
.db	EnemyID_Amundsen

; $39
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Horseman
.db	EnemyID_Horseman
.db	EnemyID_Amundsen
.db	EnemyID_Amundsen
.db	EnemyID_Amundsen
.db	EnemyID_Amundsen

; $3A
.db	EnemyID_BlSlime
.db	EnemyID_BlSlime
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_GiantFly
.db	EnemyID_GiantFly
.db	EnemyID_Dezorian
.db	EnemyID_Dezorian

; $3B
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_Dezorian
.db	EnemyID_Dezorian
.db	EnemyID_Executer
.db	EnemyID_Executer
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite

; $3C
.db	EnemyID_Dezorian
.db	EnemyID_Dezorian
.db	EnemyID_Dezorian
.db	EnemyID_Dezorian
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx

; $3D
.db	EnemyID_Executer
.db	EnemyID_Executer
.db	EnemyID_Executer
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Lich
.db	EnemyID_Lich
.db	EnemyID_Stalker

; $3E
.db	EnemyID_GiantFly
.db	EnemyID_Ammonite
.db	EnemyID_Ammonite
.db	EnemyID_Stalker
.db	EnemyID_Stalker
.db	EnemyID_Stalker
.db	EnemyID_Batalion
.db	EnemyID_Batalion

; $3F
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Lich
.db	EnemyID_Lich
.db	EnemyID_Lich
.db	EnemyID_Horseman

; $40
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern

; $41
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Magician
.db	EnemyID_Magician

; $42
.db	EnemyID_BlSlime
.db	EnemyID_BlSlime
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth

; $43
.db	EnemyID_Stalker
.db	EnemyID_Stalker
.db	EnemyID_Frostman
.db	EnemyID_Frostman
.db	EnemyID_Frostman
.db	EnemyID_Frostman
.db	EnemyID_Frostman
.db	EnemyID_Frostman

; $44
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead
.db	EnemyID_Batalion
.db	EnemyID_Batalion
.db	EnemyID_Batalion
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder

; $45
.db	EnemyID_GiantFly
.db	EnemyID_GiantFly
.db	EnemyID_Frostman
.db	EnemyID_Frostman
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder

; $46
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Lich
.db	EnemyID_Lich
.db	EnemyID_Stalker
.db	EnemyID_Stalker

; $47
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Batalion
.db	EnemyID_Batalion
.db	EnemyID_Magician
.db	EnemyID_Magician
.db	EnemyID_Magician
.db	EnemyID_Magician

; $48
.db	EnemyID_Horseman
.db	EnemyID_Horseman
.db	EnemyID_Horseman
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder

; $49
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn

; $4A
.db	EnemyID_GrSlime
.db	EnemyID_GrSlime
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_GiantFly
.db	EnemyID_GiantFly

; $4B
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_EFarmer
.db	EnemyID_EFarmer
.db	EnemyID_RdSlime
.db	EnemyID_RdSlime
.db	EnemyID_Tarantul
.db	EnemyID_Tarantul

; $4C
.db	EnemyID_BlSlime
.db	EnemyID_BlSlime
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_EvilHead
.db	EnemyID_EvilHead

; $4D
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead
.db	EnemyID_Skeleton
.db	EnemyID_Skeleton
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Ghoul
.db	EnemyID_Ghoul

; $4E
.db	EnemyID_Manticor
.db	EnemyID_Manticor
.db	EnemyID_Lich
.db	EnemyID_Lich
.db	EnemyID_Stalker
.db	EnemyID_Stalker
.db	EnemyID_Zombie
.db	EnemyID_Zombie

; $4F
.db	EnemyID_Wight
.db	EnemyID_Wight
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Serpent
.db	EnemyID_Serpent
.db	EnemyID_Batalion
.db	EnemyID_Batalion

; $50
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_Scorpius
.db	EnemyID_GiantFly
.db	EnemyID_GiantFly
.db	EnemyID_GiantFly
.db	EnemyID_Ghoul

; $51
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Zombie
.db	EnemyID_Zombie

; $52
.db	EnemyID_Skeleton
.db	EnemyID_Skeleton
.db	EnemyID_Vampire
.db	EnemyID_Vampire
.db	EnemyID_Amundsen
.db	EnemyID_Amundsen
.db	EnemyID_RdDragn
.db	EnemyID_RdDragn

; $53
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Stalker
.db	EnemyID_Stalker
.db	EnemyID_GrDragn
.db	EnemyID_GrDragn
.db	EnemyID_Marauder
.db	EnemyID_Marauder

; $54
.db	EnemyID_Magician
.db	EnemyID_Magician
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth
.db	EnemyID_Centaur
.db	EnemyID_Centaur
.db	EnemyID_Titan
.db	EnemyID_Titan

; $55
.db	EnemyID_RdSlime
.db	EnemyID_RdSlime
.db	EnemyID_Reaper
.db	EnemyID_Reaper
.db	EnemyID_Reaper
.db	EnemyID_Reaper
.db	EnemyID_Reaper
.db	EnemyID_Reaper

; $56
.db	EnemyID_Sorcerer
.db	EnemyID_Sorcerer
.db	EnemyID_Sorcerer
.db	EnemyID_Sorcerer
.db	EnemyID_Centaur
.db	EnemyID_Centaur
.db	EnemyID_Titan
.db	EnemyID_Titan

; $57
.db	EnemyID_AndroCop
.db	EnemyID_AndroCop
.db	EnemyID_Wyvern
.db	EnemyID_Wyvern
.db	EnemyID_Magician
.db	EnemyID_Magician
.db	EnemyID_Horseman
.db	EnemyID_Horseman

; $58
.db	EnemyID_AndroCop
.db	EnemyID_AndroCop
.db	EnemyID_Giant
.db	EnemyID_Giant
.db	EnemyID_RdDragn
.db	EnemyID_RdDragn
.db	EnemyID_RdDragn
.db	EnemyID_RdDragn

; $59
.db	EnemyID_Stalker
.db	EnemyID_Stalker
.db	EnemyID_Frostman
.db	EnemyID_Frostman
.db	EnemyID_Mammoth
.db	EnemyID_Mammoth
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn

; $5A
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn
.db	EnemyID_WtDragn

; $5B
.db	EnemyID_GrSlime
.db	EnemyID_GrSlime
.db	EnemyID_GrSlime
.db	EnemyID_GrSlime
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye
.db	EnemyID_WingEye

; $5C
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_GoldLens
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_EvilDead
.db	EnemyID_EvilDead

; $5D
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Sphinx
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_Nessie
.db	EnemyID_AndroCop
.db	EnemyID_AndroCop

; $5E
.db	EnemyID_OwlBear
.db	EnemyID_OwlBear
.db	EnemyID_WereBat
.db	EnemyID_WereBat
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
.db	EnemyID_Marauder
; =============================================================


; =============================================================
; Encounter pool ID list when you're in the map
; =============================================================
B03_MapEncounterIDList:
.db $01, $02, $02, $03, $04, $05, $05, $06
.db $07, $07, $08, $09, $0A, $0A, $06, $0B
.db $01, $02, $02, $03, $04, $05, $05, $06
.db $07, $07, $08, $09, $0A, $0A, $06, $0B
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $0C, $0C, $0C, $0D, $0E, $0E, $0E, $0E
.db $0E, $0E, $0E, $0F, $0F, $0F, $0F, $0F
.db $10, $10, $11, $12, $13, $13, $14, $14
.db $17, $15, $16, $18, $19, $1A, $1B, $1C
.db $10, $10, $11, $12, $13, $13, $14, $14
.db $17, $15, $16, $18, $19, $1A, $1B, $1C
.db $1D, $1D, $1D, $1E, $1E, $1F, $1F, $20
.db $20, $21, $21, $20, $22, $22, $23, $23
.db $24, $24, $24, $24, $25, $25, $25, $26
.db $26, $26, $26, $27, $28, $28, $28, $28
.db $24, $24, $24, $24, $25, $25, $25, $26
.db $26, $26, $26, $27, $28, $28, $28, $28
.db $29, $29, $29, $29, $29, $2A, $29, $29
.db $29, $29, $29, $29, $29, $29, $2A, $2A
.db $2F, $2F, $30, $31, $32, $30, $32, $33
.db $32, $35, $36, $38, $37, $34, $39, $37
.db $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E
.db $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E
.db $3A, $3B, $3C, $3D, $3E, $3E, $3F, $40
.db $41, $42, $42, $41, $43, $42, $44, $45
.db $46, $46, $46, $46, $46, $46, $47, $47
.db $47, $47, $47, $48, $48, $48, $48, $49
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D
.db $2D, $2D, $2D, $2D, $2D, $2D, $2D, $2D
.db $2C, $2C, $2C, $2C, $2B, $2B, $2B, $2B
.db $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
.db $2F, $2F, $30, $31, $32, $30, $32, $33
.db $32, $35, $36, $38, $37, $34, $39, $37
.db $25, $26, $24, $24, $27, $27, $28, $28
.db $27, $26, $28, $27, $27, $26, $27, $28
; =============================================================


LABEL_B03_85A0:
.db $00, $00, $03, $03, $03, $03, $03, $04
.db $04, $00, $00, $00, $00, $00, $04, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $07, $07, $07, $07, $07, $07, $07, $07
.db $07, $00, $00, $00, $00, $05, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $08
.db $08, $08, $08, $06, $06, $06, $06, $06
.db $06, $06, $06, $06, $06, $07, $07, $07
.db $07, $06, $06, $06, $06, $06, $06, $06
.db $06, $06, $02, $02, $02, $02, $02, $02
.db $02, $02, $02, $01, $02, $05, $04, $09
.db $09, $09, $09, $09, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $02, $02
.db $02, $02, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $02, $01, $01, $01, $01, $05
.db $02, $02, $02, $02, $02, $02, $05, $05
.db $05, $05, $00, $00, $00, $00, $00, $02
.db $02, $02, $02, $02, $02, $02, $02


; -----------------------------------------------------------------
; Enemy Data
;
; Bytes 1-8 = Name; if shorter than 8 bytes, needs to be terminated with Dialogue_Terminator65
; Byte 17 = Bank where graphics are located
; Bytes 18-19 = Graphics pointer
; Byte 21 = Party number
; Byte 22 = HP
; Byte 23 = Attack
; Byte 24 = Defense
; Byte 25 = Item drop
; Bytes 26-27 = Meseta
; Byte 28 = Trap chance
; Bytes 29-30 = EXP
; Byte 32 = Run chance
; -----------------------------------------------------------------
B03_EnemyData:

Enemy_None:
.db	$02, $02, $02, $02, $02, $02, $02, $02
.db	$02, $02, $02, $02, $02, $02, $02, $02
.db	$02, $03, $00, $08, $08, $08, $08, $03
.db	$00, $00, $00, $00, $00, $00, $00, $00

Enemy_Sworm:
.db	"SWORM", Dialogue_Terminator65, "  "
.db	$2A, $25, $05, $0A, $08, $04, $0C, $2F
.db	:Bank11
.dw	LABEL_B11_9CDA
.db	$12
.db	$08	; Party number
.db	$08	; HP
.db	$0D	; Attack
.db	$09	; Defense
.db	$00	; Item Drop
.dw	3	; Meseta
.db	$0C	; Trap chance
.dw	2	; EXP
.db	$38
.db	$FF	; Run chance

Enemy_GrSlime:
.db	"GR.SLIME"
.db $10, $04, $0C, $0E, $00, $00, $00, $00
.db	:Bank11
.dw LABEL_B11_B869
.db	$02, $06, $12, $12, $0D, $00
.db $08, $00, $0C, $04, $00, $30, $CC

Enemy_WingEye:
.db	"WING EYE"
.db $00, $3E, $00, $3E, $3C, $34, $30, $00
.db	:Bank10
.dw LABEL_B10_B7E4
.db	$23, $06, $0B, $0C, $0A, $00
.db $06, $00, $0F, $02, $00, $38, $7F

Enemy_ManEater:
.db	"MANEATER"
.db	$00, $00, $05, $0A, $33, $21, $37, $00
.db	:Bank26
.dw LABEL_B26_A180
.db	$17, $05, $10, $0C, $0A, $00
.db $0D, $00, $0F, $03, $00, $30, $FF

Enemy_Scorpion:
.db	"SCORPION"
.db $2A, $25, $02, $03, $08, $00, $00, $37
.db	:Bank25
.dw LABEL_B25_A4D0
.db	$0F, $04, $0C, $0E, $0C, $00
.db $0D, $00, $0F, $04, $00, $38, $CC

Enemy_GScorpi:
.db	"G.SCORPI"
.db $2A, $25, $05, $0A, $08, $00, $00, $2F
.db	:Bank25
.dw LABEL_B25_A4D0
.db	$0F, $04, $14, $14, $11, $00
.db $0B, $00, $99, $05, $00, $38, $7F

Enemy_BlSlime:
.db	"BL.SLIME"
.db $20, $30, $38, $3C, $00, $00, $00, $00
.db	:Bank11
.dw LABEL_B11_B869
.db	$02, $06, $28, $1A, $14, $00
.db $13, $00, $0F, $05, $00, $32, $99

Enemy_NFarmer:
.db	"N.FARMER"
.db $20, $30, $34, $38, $01, $06, $0A, $0F
.db	:Bank19
.dw LABEL_B19_8DBE
.db	$19, $05, $26, $25, $25, ItemID_Cola
.db $08, $00, $00, $05, $00, $F0, $B2

Enemy_OwlBear:
.db	"OWL BEAR"
.db $00, $0F, $00, $0B, $07, $03, $01, $00
.db	:Bank10
.dw LABEL_B10_B7E4
.db	$23, $04, $12, $16, $12, $00
.db $0C, $00, $0C, $05, $00, $38, $99

Enemy_DeadTree:
.db	"DEADTREE"
.db $00, $00, $02, $03, $0C, $08, $2E, $00
.db	:Bank26
.dw LABEL_B26_A180
.db	$17, $03, $17, $17, $19, $00
.db $15, $00, $28, $04, $00, $30, $CC

Enemy_Scorpius:
.db	"SCORPIUS"
.db $0C, $08, $24, $25, $08, $00, $00, $2A
.db	:Bank25
.dw LABEL_B25_A4D0
.db	$0F, $05, $16, $19, $14, $00
.db $1B, $00, $0F, $08, $00, $39, $66

Enemy_EFarmer:
.db	"E.FARMER"
.db $20, $30, $34, $38, $01, $03, $07, $0F
.db	:Bank19
.dw LABEL_B19_8DBE
.db	$1B, $05, $2A, $1B, $28, $00
.db $1E, $00, $0F, $09, $00, $F0, $CC

Enemy_GiantFly:
.db	"GIANTFLY"
.db $2A, $25, $02, $03, $02, $01, $03, $0B
.db	:Bank11
.dw LABEL_B11_9CDA
.db	$12, $04, $19, $1E, $15, $00
.db $20, $00, $0F, $07, $00, $3C, $66

Enemy_Crawler:
.db	"CRAWLER", Dialogue_Terminator65
.db	$02, $06, $0A, $0E, $01, $03, $2F, $00
.db	:Bank10
.dw LABEL_B10_AA8C
.db	$22, $03, $28, $1F, $20, $00
.db $1E, $00, $0F, $09, $00, $30, $7F

Enemy_Barbrian:
.db	"BARBRIAN"
.db $20, $30, $34, $38, $04, $08, $0C, $0F
.db	:Bank19
.dw LABEL_B19_8DBE
.db	$1A, $08, $36, $23, $32, ItemID_Cola
.db $59, $00, $14, $0A, $00, $F0, $4C

Enemy_GoldLens:
.db	"GOLDLENS"
.db $00, $2A, $00, $2F, $0A, $06, $01, $00
.db	:Bank10
.dw LABEL_B10_B7E4
.db	$23, $04, $1C, $24, $23, $00
.db $18, $00, $0F, $09, $00, $38, $7F

Enemy_RdSlime:
.db	"RD.SLIME"
.db $01, $13, $33, $3A, $00, $00, $00, $00
.db	:Bank11
.dw LABEL_B11_B869
.db	$02, $03, $1D, $25, $19, $00
.db $1F, $00, $0F, $0B, $00, $31, $99

Enemy_WereBat:
.db	"WERE BAT"
.db $20, $34, $38, $3C, $03, $02, $00, $00
.db	:Bank10
.dw LABEL_B10_8000
.db	$24, $04, $32, $25, $23, $00
.db $3F, $00, $0F, $0B, $00, $3B, $7F

Enemy_BigClub:
.db	"BIG CLUB"
.db $01, $02, $03, $07, $0B, $00, $00, $00
.db	:Bank20
.dw LABEL_B20_8FEB
.db	$08, $02, $2E, $28, $24, $00
.db $28, $00, $0F, $09, $00, $30, $CC

Enemy_Fishman:
.db	"FISHMAN", Dialogue_Terminator65
.db	$05, $39, $0A, $13, $33, $0F, $3F, $00
.db	:Bank26
.dw LABEL_B26_A7B8
.db	$07, $05, $2A, $2A, $28, $00
.db $2A, $00, $0F, $0B, $00, $30, $99

Enemy_EvilDead:
.db	"EVILDEAD"
.db $02, $03, $34, $01, $04, $08, $0E, $38
.db	:Bank10
.dw LABEL_B10_9B85
.db	$21, $03, $1E, $2B, $24, $00
.db $08, $00, $0C, $0E, $00, $30, $E5

Enemy_Tarantul:
.db	"TARANTUL"
.db	$2A, $01, $2A, $05, $08, $04, $0C, $2F
.db	:Bank19
.dw LABEL_B19_B28A
.db	$11, $02, $32, $32, $2B, $00
.db $33, $00, $26, $0A, $00, $71, $99

Enemy_Manticor:
.db	"MANTICOR"
.db	$01
.db $03, $07, $0B, $28, $2D, $2F, $20
.db	:Bank26
.dw LABEL_B26_9748
.db	$14, $03, $3C, $35, $2C, $00
.db $31, $00, $0F, $0F, $00, $5C, $99

Enemy_Skeleton:
.db	"SKELETON"
.db	$3F
.db $2F, $2A, $25, $20, $3C, $00, $00
.db	:Bank25
.dw LABEL_B25_AA4A
.db	$0C, $05, $35, $3A, $29, $00
.db $19, $00, $0F, $0D, $00, $30, $CC

Enemy_AntLion:
.db	"ANT LION"
.db	$2A
.db $00, $25, $00, $06, $01, $0A, $2F
.db	:Bank19
.dw LABEL_B19_B28A
.db	$11, $01, $42, $3B, $34, $00
.db $07, $00, $0C, $08, $00, $31, $B2

Enemy_Marman:
.db	"MARMAN", Dialogue_Terminator65, " "
.db	$21
.db $3C, $36, $04, $2C, $3A, $07, $00
.db	:Bank26
.dw LABEL_B26_A7B8
.db	$07, $06, $3A, $43, $32, $00
.db $2B, $00, $0F, $0E, $00, $30, $7F

Enemy_Dezorian:
.db	"DEZORIAN"
.db	$02
.db $3C, $0A, $04, $2C, $01, $08, $2F
.db	:Bank19
.dw LABEL_B19_96ED
.db	$0A, $05, $4C, $4D, $3F, $00
.db $69, $00, $0C, $12, $00, $F0, $7F

Enemy_Leech:
.db	"LEECH", Dialogue_Terminator65, "  "
.db	$08
.db $22, $33, $37, $04, $0C, $2F, $06
.db	:Bank10
.dw LABEL_B10_AA8C
.db	$22, $04, $46, $43, $2F, $00
.db $2F, $00, $0C, $0F, $00, $33, $A5

Enemy_Vampire:
.db	"VAMPIRE", Dialogue_Terminator65
.db	$01
.db $06, $0A, $2F, $2A, $25, $00, $2A
.db	:Bank10
.dw LABEL_B10_8000
.db	$24, $02, $43, $44, $2E, ItemID_Flash
.db $47, $00, $0C, $0F, $00, $38, $CC

Enemy_Elephant:
.db	"ELEPHANT"
.db	$22
.db $33, $37, $3B, $2D, $2F, $2A, $0C
.db	:Bank19
.dw LABEL_B19_9C25
.db	$03, $05, $56, $3E, $30, $00
.db $26, $00, $0C, $11, $00, $20, $CC

Enemy_Ghoul:
.db	"GHOUL", Dialogue_Terminator65, "  "
.db	$0B
.db $03, $34, $38, $37, $33, $31, $3C
.db	:Bank25
.dw LABEL_B25_B326
.db	$13, $03, $44, $40, $2F, $00
.db $1A, $00, $0C, $10, $00, $30, $B2

Enemy_Shelfish:
.db	"SHELFISH"
.db	$03
.db $3A, $2B, $22, $33, $0F, $07, $3F
.db	:Bank20
.dw LABEL_B20_ABA2
.db	$09, $03, $3E, $4D, $34, $00
.db $2E, $00, $14, $10, $00, $30, $E5

Enemy_Executer:
.db	"EXECUTER"
.db	$01
.db $04, $08, $0C, $0F, $00, $00, $00
.db	:Bank20
.dw LABEL_B20_8FEB
.db	$08, $03, $3E, $49, $32, $00
.db $3F, $00, $35, $0C, $00, $30, $66

Enemy_Wight:
.db	"WIGHT", Dialogue_Terminator65, "  "
.db	$08
.db $0C, $03, $04, $02, $03, $07, $0F
.db	:Bank10
.dw LABEL_B10_9B85
.db	$21, $03, $32, $40, $30, $00
.db $28, $00, $0C, $12, $00, $31, $B2

Enemy_SkullEn:
.db	"SKULL-EN"
.db	$3F
.db $0F, $0D, $06, $00, $0C, $00, $00
.db	:Bank25
.dw LABEL_B25_AA4A
.db	$0D, $03, $39, $4B, $35, $00
.db $25, $00, $0C, $12, $00, $30, $B2

Enemy_Ammonite:
.db	"AMMONITE"
.db	$04
.db $3E, $0C, $38, $3C, $0F, $08, $3F
.db	:Bank20
.dw LABEL_B20_ABA2
.db	$09, $02, $5A, $58, $3C, $00
.db $47, $00, $3F, $13, $00, $30, $99

Enemy_Sphinx:
.db	"SPHINX", Dialogue_Terminator65, " "
.db	$01
.db $03, $07, $0B, $0A, $0F, $2F, $20
.db	:Bank26
.dw LABEL_B26_9748
.db	$14, $04, $4E, $50, $41, ItemID_Flash
.db $3A, $00, $0C, $15, $00, $58, $CC

Enemy_Serpent:
.db	"SERPENT", Dialogue_Terminator65
.db	$22
.db $32, $33, $37, $3B, $00, $00, $00
.db	:Bank25
.dw LABEL_B25_9755
.db	$10, $01, $50, $64, $42, $00
.db $60, $00, $0F, $17, $00, $38, $B2

Enemy_Sandworm:
.db	"SANDWORM"
.db	$0A
.db $34, $38, $3C, $05, $0F, $2F, $06
.db	:Bank10
.dw LABEL_B10_AA8C
.db	$22, $03, $52, $6B, $3F, $00
.db $81, $00, $0F, $14, $00, $30, $99

Enemy_Lich:
.db	"LICH", Dialogue_Terminator65, "   "
.db	$31
.db $35, $08, $21, $23, $33, $37, $0E
.db	:Bank10
.dw LABEL_B10_9B85
.db	$21, $02, $3C, $54, $3E, $00
.db $21, $00, $0C, $16, $00, $31, $CC

Enemy_Octopus:
.db	"OCTOPUS", Dialogue_Terminator65
.db	$02
.db $00, $00, $22, $33, $01, $00, $3F
.db	:Bank26
.dw LABEL_B26_B17E
.db	$05, $01, $5A, $55, $44, $00
.db $40, $00, $0C, $14, $00, $30, $BF

Enemy_Stalker:
.db	"STALKER", Dialogue_Terminator65
.db	$3F
.db $3D, $37, $33, $00, $0F, $00, $00
.db	:Bank25
.dw LABEL_B25_AA4A
.db	$0E, $04, $4F, $5A, $4B, $00
.db $57, $00, $0F, $16, $00, $30, $E5

Enemy_EvilHead:
.db	"EVILHEAD"
.db	$02
.db $3C, $03, $04, $2C, $01, $08, $07
.db	:Bank19
.dw LABEL_B19_96ED
.db	$0A, $03, $56, $76, $4D, $00
.db $88, $00, $0F, $14, $00, $F0, $7F

Enemy_Zombie:
.db	"ZOMBIE", Dialogue_Terminator65, " "
.db	$2A
.db $25, $05, $0A, $08, $08, $0C, $2F
.db	:Bank25
.dw LABEL_B25_B326
.db	$13, $04, $57, $6C, $3A, $00
.db $1B, $00, $0F, $14, $00, $30, $99

Enemy_Batalion:
.db	"BATALION"
.db	$03
.db $02, $25, $2A, $03, $02, $07, $03
.db	:Bank25
.dw LABEL_B25_B326
.db	$13, $03, $64, $70, $40, $00
.db $3B, $00, $0C, $15, $00, $30, $CC

Enemy_RobotCop:
.db	"ROBOTCOP"
.db	$25
.db $2A, $2F, $3F, $03, $26, $20, $00
.db	:Bank19
.dw LABEL_B19_AA0F
.db	$15, $01, $6E, $87, $5A, $00
.db $9C, $00, $0F, $19, $00, $00, $66

Enemy_Sorcerer:
.db	"SORCERER"
.db	$01
.db $31, $35, $39, $3D, $03, $23, $02
.db	:Bank11
.dw LABEL_B11_A25F
.db	$04, $02, $6E, $79, $4A, $00
.db $78, $00, $33, $1A, $00, $34, $CC

Enemy_Nessie:
.db	"NESSIE", Dialogue_Terminator65, " "
.db	$04
.db $08, $0C, $2F, $3F, $00, $00, $00
.db	:Bank25
.dw LABEL_B25_9755
.db	$10, $02, $5D, $7E, $4D, $00
.db $65, $00, $0C, $1C, $00, $38, $CC

Enemy_Tarzimal:
.db	"TARZIMAL"
.db	$2B
.db $20, $06, $2A, $25, $3E, $01, $0F
.db	:Bank17
.dw LABEL_B17_B94A
.db	$06, $01, $7D, $78, $64, $00
.db $00, $00, $0C, $00, $00, $14, $00

Enemy_Golem:
.db	"GOLEM", Dialogue_Terminator65, "  "
.db	$01
.db $02, $03, $34, $30, $00, $00, $00
.db	:Bank20
.dw LABEL_B20_B395
.db	$1F, $02, $8C, $79, $60, $00
.db $96, $00, $0C, $18, $00, $20, $B2

Enemy_AndroCop:
.db	"ANDROCOP"
.db	$02
.db $03, $07, $3F, $3C, $03, $02, $00
.db	:Bank19
.dw LABEL_B19_AA0F
.db	$15, $02, $78, $91, $59, $00
.db $7B, $00, $0C, $1D, $00, $00, $7F

Enemy_Tentacle:
.db	"TENTACLE"
.db	$00
.db $00, $00, $20, $25, $30, $00, $0B
.db	:Bank26
.dw LABEL_B26_B17E
.db	$05, $01, $76, $76, $57, $00
.db $62, $00, $0C, $1B, $00, $30, $B2

Enemy_Giant:
.db	"GIANT", Dialogue_Terminator65, "  "
.db	$04
.db $08, $0C, $03, $02, $00, $00, $00
.db	:Bank20
.dw LABEL_B20_B395
.db	$1F, $02, $78, $7A, $58, $00
.db $77, $00, $0C, $1E, $00, $20, $7F

Enemy_Wyvern:
.db	"WYVERN", Dialogue_Terminator65, " "
.db	$01
.db $05, $1A, $2F, $3F, $00, $00, $00
.db	:Bank25
.dw LABEL_B25_9755
.db	$10, $01, $6E, $7B, $54, $00
.db $7D, $00, $0C, $1A, $00, $38, $7F

Enemy_Reaper:
.db	"REAPER", Dialogue_Terminator65, " "
.db	$20
.db $25, $2A, $2F, $3F, $02, $01, $30
.db	:Bank10
.dw LABEL_B10_8D7E
.db	$1E, $01, $B9, $87, $66, $00
.db $FE, $00, $33, $1E, $00, $23, $CC

Enemy_Magician:
.db	"MAGICIAN"
.db	$00
.db $25, $25, $2A, $2F, $08, $0C, $04
.db	:Bank11
.dw LABEL_B11_A25F
.db	$04, $01, $8A, $91, $5A, $00
.db $BB, $00, $0C, $20, $00, $35, $7F

Enemy_Horseman:
.db	"HORSEMAN"
.db	$20
.db $30, $34, $38, $3C, $10, $0C, $2F
.db	:Bank26
.dw LABEL_B26_8000
.db	$1D, $02, $82, $7E, $59, ItemID_Flash
.db $94, $00, $00, $1E, $00, $44, $59

Enemy_Frostman:
.db	"FROSTMAN"
.db	$20
.db $30, $34, $38, $3C, $3F, $3A, $3E
.db	:Bank26
.dw LABEL_B26_8A1F
.db	$1C, $01, $8C, $8A, $62, $00
.db $80, $00, $14, $24, $00, $10, $BF

Enemy_Amundsen:
.db	"AMUNDSEN"
.db	$01
.db $02, $03, $07, $0B, $0F, $0B, $0F
.db	:Bank26
.dw LABEL_B26_8A1F
.db	$1C, $01, $85, $8C, $62, $00
.db $78, $00, $0C, $20, $00, $10, $B2

Enemy_RdDragn:
.db	"RD.DRAGN"
.db	$01
.db $20, $34, $02, $03, $07, $30, $38
.db	:Bank25
.dw LABEL_B25_893B
.db	$01, $01, $AF, $A0, $69, $00
.db $C1, $00, $0F, $41, $00, $58, $7F

Enemy_GrDragn:
.db	"GR.DRAGN"
.db	$04
.db $03, $0B, $08, $0C, $0E, $07, $0F
.db	:Bank25
.dw LABEL_B25_893B
.db	$01, $01, $A0, $91, $5F, $00
.db $B0, $00, $0C, $35, $00, $58, $99

Enemy_Shadow:
.db	"SHADOW", Dialogue_Terminator65, " "
.db	$20
.db $30, $34, $38, $25, $2A, $2F, $00
.db	:Bank25
.dw LABEL_B25_8000
.db	$18, $01, $A5, $AC, $68, $00
.db $00, $00, $0C, $3C, $00, $30, $7F

Enemy_Mammoth:
.db	"MAMMOTH", Dialogue_Terminator65
.db	$31
.db $35, $39, $3D, $23, $2F, $2A, $02
.db	:Bank19
.dw LABEL_B19_9C25
.db	$03, $05, $B4, $9A, $64, $00
.db $7D, $00, $0F, $28, $00, $20, $B2

Enemy_Centaur:
.db	"CENTAUR", Dialogue_Terminator65
.db	$06
.db $07, $0B, $0F, $2F, $03, $0B, $0F
.db	:Bank26
.dw LABEL_B26_8000
.db	$1D, $01, $BE, $9B, $64, $00
.db $85, $00, $28, $1F, $00, $41, $7F

Enemy_Marauder:
.db	"MARAUDER"
.db	$10
.db $20, $30, $34, $38, $03, $02, $00
.db	:Bank10
.dw LABEL_B10_8D7E
.db	$1E, $01, $87, $86, $58, $00
.db $AD, $00, $0F, $1E, $00, $25, $B2

Enemy_Titan:
.db	"TITAN", Dialogue_Terminator65, "  "
.db	$01
.db $06, $0A, $2A, $25, $00, $00, $00
.db	:Bank20
.dw LABEL_B20_B395
.db	$1F, $02, $BE, $92, $61, $00
.db $8A, $00, $21, $20, $00, $20, $7F

Enemy_Medusa:
.db	"MEDUSA", Dialogue_Terminator65, " "
.db	$01
.db $12, $37, $2B, $32, $02, $22, $10
.db	:Bank10
.dw LABEL_B10_A044
.db	$20, $01, $C8, $A6, $67, ItemID_Flash
.db $C2, $00, $00, $32, $00, $26, $99

Enemy_WtDragn:
.db	"WT.DRAGN"
.db	$34
.db $3C, $3F, $38, $3C, $2F, $3F, $3F
.db	:Bank25
.dw LABEL_B25_893B
.db	$01, $01, $C8, $B4, $68, $00
.db $EA, $00, $0F, $4B, $00, $48, $99

Enemy_BlDragn:
.db	"BL.DRAGN"
.db	$20
.db $3E, $3F, $25, $2A, $2F, $3F, $3F
.db	:Bank25
.dw LABEL_B25_893B
.db	$01, $01, $D2, $9B, $5A, $00
.db $B2, $00, $0C, $58, $00, $48, $99

Enemy_GdDragn:
.db	"GD.DRAGN"
.db	$03
.db $07, $0B, $0F, $25, $2A, $2F, $00
.db	:Bank11
.dw LABEL_B11_8AEB
.db	$16, $01, $AA, $C8, $62, $00
.db $00, $00, $00, $64, $00, $0A, $00

Enemy_DrMad:
.db	"DR.MAD", Dialogue_Terminator65, " "
.db	$38
.db $3C, $3E, $3F, $25, $2A, $2F, $00
.db	:Bank25
.dw LABEL_B25_8000
.db	$18, $01, $E9, $B4, $55, $00
.db $8C, $00, $00, $19, $00, $30, $66

Enemy_Lassic:
.db	"LASSIC", Dialogue_Terminator65, " "
.db	$01
.db $06, $34, $30, $2F, $0F, $0B, $02
.db	:Bank11
.dw LABEL_B11_AD79
.db	$26, $01, $EE, $E6, $B4, $00
.db $00, $00, $00, $00, $00, $07, $00

Enemy_DarkFalz:
.db	"DARKFALZ"
.db	$20
.db $30, $34, $38, $3C, $02, $03, $01
.db	:Bank20
.dw LABEL_B20_97C4
.db	$27, $82, $FF, $FF, $96, $00
.db $00, $00, $00, $00, $00, $00, $00

Enemy_Saccubus:
.db	"SACCUBUS"
.db	$20
.db $25, $2A, $2F, $3F, $02, $03, $01
.db	:Bank19
.dw LABEL_B19_BD83
.db	$25, $01, $FF, $96, $FA, $00
.db $00, $00, $00, $0A, $00, $01, $00


LABEL_B03_8FC7:
.db	$0F
.db $02, $27, $60, $57, $80, $57, $80, $03
.db $87, $93, $87, $93, $70, $B9, $5C, $D1
.db $0D, $07, $10, $01, $1F, $60, $CA, $0F
.db $09, $57, $68, $6F, $7C, $6F, $7C, $07
.db $90, $93, $90, $93, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C7, $0F
.db $16, $2F, $70, $4B, $80, $4B, $80, $07
.db $9F, $93, $9F, $93, $26, $BA, $D8, $D1
.db $0A, $08, $10, $15, $2F, $58, $C7, $0F
.db $1C, $37, $60, $57, $78, $5C, $86, $0F
.db $A8, $93, $AE, $93, $C6, $BA, $1C, $D2
.db $09, $03, $00, $00, $00, $00, $C7, $0F
.db $20, $3F, $68, $57, $80, $57, $80, $07
.db $B2, $93, $B2, $93, $FC, $BA, $5C, $D3
.db $04, $06, $00, $00, $00, $00, $C8, $0F
.db $24, $4F, $68, $67, $7E, $5F, $6A, $07
.db $BA, $93, $BA, $93, $2C, $BB, $1E, $D3
.db $06, $02, $00, $00, $00, $00, $C6, $0F
.db $28, $4F, $68, $57, $74, $57, $74, $07
.db $C4, $93, $C4, $93, $44, $BB, $DE, $D2
.db $06, $03, $00, $00, $00, $00, $C8, $0F
.db $2D, $57, $6C, $3F, $7C, $3F, $7C, $07
.db $CC, $93, $CC, $93, $00, $00, $00, $00
.db $00, $00, $10, $2C, $27, $6C, $C6, $0F
.db $35, $47, $70, $4F, $80, $4F, $80, $07
.db $D6, $93, $D6, $93, $00, $00, $00, $00
.db $00, $00, $10, $34, $2F, $70, $C6, $0F
.db $40, $37, $74, $4F, $7C, $4F, $7C, $07
.db $E1, $93, $E1, $93, $00, $00, $00, $00
.db $00, $00, $10, $3F, $37, $74, $CB, $0F
.db $45, $37, $74, $4F, $7C, $4F, $7C, $07
.db $E1, $93, $E1, $93, $00, $00, $00, $00
.db $00, $00, $10, $3F, $37, $74, $00, $0F
.db $4A, $2F, $68, $47, $7C, $47, $7C, $07
.db $EA, $93, $EA, $93, $00, $00, $00, $00
.db $00, $00, $10, $47, $2F, $68, $CB, $0F
.db $4A, $2F, $68, $47, $7C, $47, $7C, $07
.db $EA, $93, $EA, $93, $00, $00, $00, $00
.db $00, $00, $10, $48, $2F, $68, $CB, $0F
.db $4A, $2F, $68, $47, $7C, $47, $7C, $07
.db $EA, $93, $EA, $93, $00, $00, $00, $00
.db $00, $00, $10, $49, $2F, $68, $CB, $0F
.db $50, $4F, $68, $6F, $74, $6F, $74, $01
.db $F2, $93, $F2, $93, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C9, $0F
.db $54, $47, $68, $5F, $74, $5F, $74, $03
.db $FD, $93, $FD, $93, $68, $BB, $9C, $D1
.db $09, $06, $10, $53, $27, $68, $CA, $0F
.db $5D, $6F, $68, $77, $7C, $77, $7C, $07
.db $0C, $94, $0C, $94, $D4, $BB, $18, $D3
.db $06, $08, $10, $5C, $57, $60, $C6, $0F
.db $66, $3F, $68, $57, $7C, $5F, $7C, $01
.db $17, $94, $17, $94, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C9, $0F
.db $69, $37, $70, $47, $7C, $47, $7C, $0B
.db $22, $94, $22, $94, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C8, $0F
.db $70, $37, $68, $67, $70, $6F, $6E, $05
.db $31, $94, $31, $94, $34, $BC, $1C, $D3
.db $04, $04, $00, $00, $00, $00, $C7, $0F
.db $79, $47, $84, $4F, $7C, $4F, $7C, $03
.db $3C, $94, $3C, $94, $00, $00, $00, $00
.db $00, $00, $10, $78, $3F, $6C, $C6, $0F
.db $E3, $27, $60, $3F, $7C, $3F, $7C, $03
.db $48, $94, $48, $94, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $CA, $0F
.db $82, $6F, $78, $6F, $7C, $6F, $7C, $03
.db $5A, $94, $5A, $94, $00, $00, $00, $00
.db $00, $00, $10, $81, $5F, $68, $C8, $0F
.db $00, $4F, $68, $4F, $78, $4F, $78, $03
.db $66, $94, $66, $94, $54, $BC, $5C, $D2
.db $09, $04, $10, $8D, $3F, $68, $C6, $0F
.db $99, $4F, $68, $5F, $7C, $5F, $7C, $03
.db $73, $94, $73, $94, $00, $00, $00, $00
.db $00, $00, $10, $96, $4F, $68, $CB, $0F
.db $9D, $4F, $68, $5F, $7C, $5F, $7C, $03
.db $7A, $94, $7A, $94, $00, $00, $00, $00
.db $00, $00, $10, $97, $4F, $68, $C6, $0F
.db $99, $4F, $68, $5F, $7C, $5F, $7C, $03
.db $73, $94, $73, $94, $00, $00, $00, $00
.db $00, $00, $10, $98, $4F, $68, $CB, $0F
.db $A3, $1F, $60, $37, $7C, $37, $7C, $07
.db $84, $94, $84, $94, $9C, $BC, $9E, $D1
.db $0C, $02, $10, $AB, $57, $60, $CA, $0F
.db $AD, $27, $60, $3F, $7C, $4B, $86, $07
.db $92, $94, $9A, $94, $CC, $BC, $DE, $D1
.db $0A, $03, $10, $AC, $27, $60, $CB, $0F
.db $B5, $27, $60, $3F, $80, $43, $81, $05
.db $A0, $94, $A9, $94, $08, $BD, $DA, $D1
.db $0B, $05, $10, $B4, $27, $60, $CC, $0F
.db $BB, $1F, $60, $3F, $80, $3F, $80, $07
.db $AC, $94, $AC, $94, $76, $BD, $5A, $D1
.db $0D, $06, $10, $BA, $1F, $60, $C7, $0F
.db $C0, $2F, $60, $3F, $78, $3F, $78, $03
.db $B2, $94, $B2, $94, $12, $BE, $DC, $D1
.db $0B, $04, $10, $BF, $2F, $60, $C6, $0F
.db $00, $27, $60, $4F, $7C, $4F, $7C, $07
.db $BB, $94, $BB, $94, $6A, $BE, $1E, $D2
.db $04, $03, $10, $C6, $27, $60, $C9, $0F
.db $CE, $37, $70, $77, $7C, $77, $7C, $07
.db $C6, $94, $C6, $94, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C8, $0F
.db $D3, $2F, $64, $4F, $77, $4F, $77, $05
.db $D0, $94, $D0, $94, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C9, $0F
.db $D7, $1F, $60, $47, $7C, $47, $7C, $03
.db $DD, $94, $DD, $94, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $C9, $0F
.db $DF, $47, $70, $57, $7C, $57, $7C, $07
.db $EE, $94, $EE, $94, $82, $BE, $5C, $D2
.db $06, $04, $00, $00, $00, $00, $C6, $13
.db $00, $FF, $8D, $4F, $7C, $4F, $7C, $03
.db $F6, $94, $F6, $94, $B2, $BE, $9C, $D2
.db $0B, $05, $10, $CB, $FF, $68, $A9, $14
.db $00, $4F, $70, $47, $7C, $47, $7C, $05
.db $27, $95, $27, $95, $20, $BF, $5C, $D2
.db $06, $04, $00, $00, $00, $00, $A9, $02
.db $03, $04, $05, $06, $07, $08, $00, $00
.db $09, $0A, $0B, $0C, $0D, $0D, $0E, $0F
.db $0E, $0F, $0D, $00, $0C, $0B, $00, $16
.db $17, $18, $19, $1A, $1B, $00, $1A, $00
.db $1C, $1D, $1E, $00, $1D, $00, $1C, $1F
.db $00, $00, $20, $21, $22, $23, $00, $22
.db $21, $00, $24, $25, $26, $27, $26, $27
.db $00, $26, $25, $00, $28, $29, $2A, $2B
.db $00, $2A, $29, $00, $2D, $2E, $2F, $30
.db $31, $32, $33, $00, $31, $00, $35, $36
.db $37, $38, $39, $3A, $3B, $3C, $00, $36
.db $00, $40, $41, $42, $43, $44, $00, $43
.db $42, $00, $4A, $4B, $4C, $4D, $4E, $00
.db $4F, $00, $50, $51, $52, $51, $50, $51
.db $52, $51, $50, $00, $00, $54, $55, $56
.db $56, $57, $58, $59, $5A, $5B, $59, $5A
.db $5B, $00, $56, $00, $5D, $5E, $5F, $60
.db $61, $62, $63, $64, $65, $00, $00, $66
.db $67, $66, $68, $66, $67, $66, $68, $66
.db $00, $00, $69, $6A, $69, $6A, $6B, $6C
.db $6D, $6E, $6F, $00, $6E, $6D, $6C, $6B
.db $00, $70, $71, $72, $72, $73, $74, $75
.db $00, $74, $73, $00, $79, $7A, $7B, $7B
.db $7C, $7D, $7E, $7F, $80, $00, $7B, $00
.db $E3, $E4, $E4, $E5, $E5, $E6, $E7, $E8
.db $E9, $EA, $EB, $EA, $EB, $EA, $EB, $00
.db $E4, $00, $82, $83, $84, $85, $86, $87
.db $00, $86, $85, $84, $83, $00, $00, $8F
.db $90, $90, $91, $91, $92, $93, $94, $95
.db $00, $8F, $00, $99, $9A, $9B, $9B, $9C
.db $00, $00, $9D, $9E, $9F, $9F, $A0, $A1
.db $00, $A2, $9F, $00, $A3, $A4, $A5, $A5
.db $A4, $A3, $A6, $A6, $A7, $A8, $A9, $AA
.db $00, $00, $AD, $B0, $B1, $B1, $B2, $AD
.db $00, $00, $AD, $AE, $AF, $00, $AE, $00
.db $B5, $B6, $B6, $B7, $B8, $B9, $00, $B9
.db $00, $B5, $00, $00, $BB, $BC, $BD, $BE
.db $00, $00, $C0, $C1, $C2, $C3, $C4, $C5
.db $C0, $00, $00, $00, $C7, $C8, $C9, $CA
.db $C7, $C8, $C9, $CA, $00, $00, $CE, $CF
.db $D0, $D1, $D2, $00, $D1, $D0, $CF, $00
.db $D3, $D4, $D5, $D6, $D4, $D3, $D4, $D5
.db $D6, $D4, $D3, $00, $00, $D7, $D8, $D8
.db $D9, $D9, $DA, $DB, $DC, $DD, $DB, $DC
.db $00, $DD, $DE, $D9, $D9, $00, $DF, $E0
.db $E1, $E2, $E1, $E2, $00, $00

LABEL_B03_94F6:
.db	$00, $EC
.db $ED, $EE, $ED, $EE, $EF, $F0, $F1, $F2
.db $F3, $F4, $F5, $00, $F6, $00

LABEL_B03_9506:
.db	$00, $EF
.db $F0, $F1, $F7, $F8, $F9, $FA, $00, $FB
.db $00

LABEL_B03_9511:
.db	$00, $EF, $F0, $F1, $FC, $FD, $FE
.db $FF, $00, $10, $00

LABEL_B03_951C:
.db	$00, $EF, $F0, $F1
.db $11, $12, $B3, $46, $00, $8E, $00, $00
.db $13, $13, $14, $3D, $3E, $76, $3D, $3E
.db $76, $3D, $3E, $76, $3D, $77, $77, $88
.db $89, $8A, $8B, $8C, $CC, $00, $CD, $00


; =============================================================
; Byte 1 = Index to DialogueSpritesPalettes_B03
; Byte 2 = Index to DialogueSprites_B03
; =============================================================
DialogueSpritesPaletteIndices_B03:
.db $00, $00
.db $00, $00
.db $01, $00
.db $02, $00
.db $03, $00
.db $04, $00
.db $05, $00
.db $06, $00
.db $07, $00
.db $08, $00
.db $09, $00
.db $0A, $00
.db $0B, $00
.db $00, $01
.db $01, $01
.db $02, $01
.db $03, $01
.db $04, $01
.db $05, $01
.db $06, $01
.db $07, $01
.db $08, $01
.db $09, $01
.db $0A, $01
.db $0B, $01
.db $00, $02
.db $01, $02
.db $02, $02
.db $03, $02
.db $04, $02
.db $05, $02
.db $06, $02
.db $07, $02
.db $08, $02
.db $09, $02
.db $0A, $02
.db $0B, $02
.db $00, $03
.db $01, $03
.db $02, $03
.db $03, $03
.db $04, $03
.db $05, $03
.db $06, $03
.db $07, $03
.db $08, $03
.db $09, $03
.db $0A, $03
.db $0B, $03
.db $0C, $04
.db $0D, $05
.db $0C, $06
.db $0E, $07
.db $0F, $08
.db $10, $09
.db $10, $0A
.db $11, $0B
.db $12, $0C
.db $13, $0D
.db $14, $0E
.db $15, $0F
.db $15, $10
; =============================================================


; =============================================================
DialogueSpritesPalettes_B03:
.db	$2B, $0B, $06, $2A, $25, $03, $02, $0F	; 0
.db	$2B, $0B, $06, $2A, $25, $0C, $08, $0F	; 1
.db	$2B, $0B, $06, $2A, $25, $3C, $38, $0F	; 2
.db	$2B, $0B, $06, $2A, $25, $3F, $3C, $0F	; 3
.db	$2B, $00, $06, $2A, $25, $03, $02, $25	; 4
.db	$2B, $00, $06, $2A, $25, $0C, $08, $25	; 5
.db	$2B, $00, $06, $2A, $25, $3C, $38, $25	; 6
.db	$2B, $00, $06, $2A, $25, $3F, $3C, $25	; 7
.db	$2B, $34, $06, $2A, $25, $03, $02, $38	; 8
.db	$2B, $34, $06, $2A, $25, $0C, $08, $38	; 9
.db	$2B, $34, $06, $2A, $25, $3C, $38, $38	; $A
.db	$2B, $34, $06, $2A, $25, $3F, $3C, $38	; $B
.db	$2B, $0B, $06, $2A, $25, $03, $02, $0F	; $C
.db	$2B, $0B, $06, $2A, $25, $01, $02, $0F	; $D
.db	$2B, $0B, $06, $2A, $25, $0A, $05, $0F	; $E
.db	$2B, $0B, $06, $2A, $25, $3C, $20, $02	; $F
.db	$2B, $0B, $06, $2A, $25, $3E, $3C, $02	; $10
.db	$04, $01, $06, $3F, $3E, $3C, $3E, $3F	; $11
.db	$2B, $0B, $06, $2A, $3E, $21, $02, $36	; $12
.db	$2A, $25, $2A, $2A, $3F, $2A, $25, $25	; $13
.db	$2B, $3E, $06, $2A, $25, $3C, $00, $00	; $14
.db	$02, $3C, $0A, $04, $2C, $01, $08, $2F	; $15
; =============================================================

; =============================================================
DialogueSprites_B03:
.db	$10, $50, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_8000

.db	$10, $51, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_8000

.db	$10, $52, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_8000

.db	$10, $53, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_8000

.db	$10, $54, $4F, $68, $00
.db	:Bank27
.dw	LABEL_B27_8E19

.db	$10, $55, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_8E19

.db	$10, $56, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_8E19

.db	$10, $57, $4F, $70, $00
.db	:Bank06
.dw	LABEL_B06_BB80

.db	$10, $58, $4F, $68, $00
.db	:Bank27
.dw	LABEL_B27_9979

.db	$10, $59, $6F, $64, $00
.db	:Bank27
.dw	LABEL_B27_9F26

.db	$10, $5A, $6F, $6C, $00
.db	:Bank27
.dw	LABEL_B27_9F26

.db	$10, $5B, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_A75E

.db	$10, $5C, $4F, $70, $00
.db	:Bank27
.dw	LABEL_B27_AB04

.db	$10, $5D, $4F, $6C, $00
.db	:Bank27
.dw	LABEL_B27_AE6C

.db	$10, $5E, $4F, $68, $00
.db	:Bank21
.dw	LABEL_B21_BA97

.db	$10, $82, $4F, $74, $00
.db	:Bank19
.dw	LABEL_B19_96ED

.db	$10, $83, $4F, $74, $00
.db	:Bank19
.dw	LABEL_B19_96ED
; =============================================================


CharacterSpriteData_B03:
.dw	LABEL_B03_980C
.dw	LABEL_B03_980C
.dw	LABEL_B03_981F
.dw	LABEL_B03_9832
.dw	LABEL_B03_9845
.dw	LABEL_B03_9852
.dw	LABEL_B03_9883
.dw	LABEL_B03_9890
.dw	LABEL_B03_989D
.dw	LABEL_B03_98B3
.dw	LABEL_B03_98C6
.dw	LABEL_B03_98CD
.dw	LABEL_B03_98DA
.dw	LABEL_B03_98F3
.dw	LABEL_B03_9909
.dw	LABEL_B03_9910
.dw	LABEL_B03_9917
.dw	LABEL_B03_991B
.dw	LABEL_B03_9925
.dw	LABEL_B03_992C
.dw	LABEL_B03_9939
.dw	LABEL_B03_9952
.dw	LABEL_B03_9965
.dw	LABEL_B03_9972
.dw	LABEL_B03_9976
.dw	LABEL_B03_997A
.dw	LABEL_B03_9981
.dw	LABEL_B03_998E
.dw	LABEL_B03_999B
.dw	LABEL_B03_99A2
.dw	LABEL_B03_99A6
.dw	LABEL_B03_99AA
.dw	LABEL_B03_99AE
.dw	LABEL_B03_99B2
.dw	LABEL_B03_99B9
.dw	LABEL_B03_99C6
.dw	LABEL_B03_99DF
.dw	LABEL_B03_99EC
.dw	LABEL_B03_99F3
.dw	LABEL_B03_99F7
.dw	LABEL_B03_99FE
.dw	LABEL_B03_9A05
.dw	LABEL_B03_9A0C
.dw	LABEL_B03_9A19
.dw	LABEL_B03_9A2F
.dw	LABEL_B03_9A3F
.dw	LABEL_B03_9A52
.dw	LABEL_B03_9A5C
.dw	LABEL_B03_9A60
.dw	LABEL_B03_9A64
.dw	LABEL_B03_9A68
.dw	LABEL_B03_9A6F
.dw	LABEL_B03_9A7C
.dw	LABEL_B03_9A95
.dw	LABEL_B03_9AAE
.dw	LABEL_B03_9ABB
.dw	LABEL_B03_9ABF
.dw	LABEL_B03_9AC6
.dw	LABEL_B03_9D5C
.dw	LABEL_B03_9DA2
.dw	LABEL_B03_9DE8
.dw	LABEL_B03_9E3D
.dw	LABEL_B03_9E80
.dw	LABEL_B03_9EC3
.dw	LABEL_B03_9F06
.dw	LABEL_B03_9F55
.dw	LABEL_B03_9FC8
.dw	LABEL_B03_A011
.dw	LABEL_B03_A054
.dw	LABEL_B03_A097
.dw	LABEL_B03_A0E0
.dw	LABEL_B03_9C9B
.dw	LABEL_B03_9CA2
.dw	LABEL_B03_9CA9
.dw	LABEL_B03_9CB0
.dw	LABEL_B03_9CBA
.dw	LABEL_B03_9CCD
.dw	LABEL_B03_9CDA
.dw	LABEL_B03_9CE1
.dw	LABEL_B03_9CE1
.dw	LABEL_B03_A13B
.dw	LABEL_B03_A199
.dw	LABEL_B03_A1FD
.dw	LABEL_B03_A26D
.dw	LABEL_B03_A2D7
.dw	LABEL_B03_A34D
.dw	LABEL_B03_A3B7
.dw	LABEL_B03_A41E
.dw	LABEL_B03_A49D
.dw	LABEL_B03_A58F
.dw	LABEL_B03_A53A
.dw	LABEL_B03_A60B
.dw	LABEL_B03_A681
.dw	LABEL_B03_A6F7
.dw	LABEL_B03_A788
.dw	LABEL_B03_9ACA
.dw	LABEL_B03_9AD7
.dw	LABEL_B03_9AEA
.dw	LABEL_B03_9B03
.dw	LABEL_B03_9B13
.dw	LABEL_B03_9B20
.dw	LABEL_B03_9B33
.dw	LABEL_B03_9B4C
.dw	LABEL_B03_9B62
.dw	LABEL_B03_9B7B
.dw	LABEL_B03_9B8E
.dw	LABEL_B03_9BA7
.dw	LABEL_B03_9BB4
.dw	LABEL_B03_9BC1
.dw	LABEL_B03_9BC8
.dw	LABEL_B03_9BDB
.dw	LABEL_B03_9BF1
.dw	LABEL_B03_9BF8
.dw	LABEL_B03_9C0B
.dw	LABEL_B03_9C15
.dw	LABEL_B03_9C22
.dw	LABEL_B03_9C2F
.dw	LABEL_B03_9C3F
.dw	LABEL_B03_9C4C
.dw	LABEL_B03_9C5F
.dw	LABEL_B03_9C78
.dw	LABEL_B03_9C8E
.dw	LABEL_B03_9CEE
.dw	LABEL_B03_9CF5
.dw	LABEL_B03_9CFC
.dw	LABEL_B03_9D09
.dw	LABEL_B03_9D1C
.dw	LABEL_B03_9D3B
.dw	LABEL_B03_9D48
.dw	LABEL_B03_9D4F
.dw	LABEL_B03_A816
.dw	LABEL_B03_A874
.dw	LABEL_B03_A8D2
.dw	LABEL_B03_A8E2
.dw	LABEL_B03_A8F2
.dw	LABEL_B03_A8E2
.dw	LABEL_B03_A902
.dw	LABEL_B03_A912
.dw	LABEL_B03_A922
.dw	LABEL_B03_A912


LABEL_B03_980C:
.db	$06, $F7, $F7, $FF
.db $FF, $07, $07, $00, $AA, $08, $AB, $00
.db $AC, $08, $AD, $00, $AE, $08, $AF

LABEL_B03_981F:
.db	$06
.db $F7, $F7, $FF, $FF, $07, $07, $00, $B0
.db $08, $B1, $00, $B2, $08, $B3, $00, $B4
.db $08, $B5

LABEL_B03_9832:
.db	$06, $F7, $F7, $FF, $FF, $07
.db $07, $00, $B6, $08, $B7, $00, $B8, $08
.db $B9, $00, $BA, $08, $BB

LABEL_B03_9845:
.db	$04, $FF, $FF
.db $07, $07, $00, $BC, $08, $BD, $00, $BE
.db $08, $BF

LABEL_B03_9852:
.db	$10, $EF, $EF, $EF, $EF, $F7
.db $F7, $F7, $F7, $FF, $FF, $FF, $FF, $07
.db $07, $07, $07, $F0, $AA, $F8, $AB, $00
.db $AC, $08, $AD, $F0, $AE, $F8, $AF, $00
.db $B0, $08, $B1, $F0, $B2, $F8, $B3, $00
.db $B4, $08, $B5, $F0, $B6, $F8, $B7, $00
.db $B8, $08, $B9

LABEL_B03_9883:
.db	$04, $DC, $E4, $EC, $F4
.db $14, $A0, $0F, $A1, $0B, $A2, $07, $A3

LABEL_B03_9890:
.db $04, $FC, $FC, $04, $04, $00, $A4, $08
.db $A5, $FF, $A6, $07, $A7

LABEL_B03_989D:
.db	$07, $FC, $FC
.db $04, $0C, $14, $1C, $24, $00, $A8, $08
.db $A9, $01, $AA, $FB, $AB, $F8, $AC, $F4
.db $AD, $F0, $A0

LABEL_B03_98B3:
.db	$06, $FC, $FC, $04, $14
.db $1C, $24, $00, $AE, $0D, $AF, $03, $B0
.db $F8, $B1, $F4, $B2, $F0, $B3

LABEL_B03_98C6:
.db	$02, $60
.db $68, $2D, $A0, $2D, $A1

LABEL_B03_98CD:
.db	$04, $60, $60
.db $68, $68, $28, $A2, $30, $A3, $28, $A4
.db $30, $A5

LABEL_B03_98DA:
.db	$08, $48, $48, $50, $50, $58
.db $58, $60, $60, $23, $A6, $2B, $A7, $24
.db $A8, $2C, $A9, $27, $AA, $2F, $AB, $2A
.db $AC, $32, $AD

LABEL_B03_98F3:
.db	$07, $28, $30, $30, $38
.db $38, $40, $40, $15, $AE, $17, $AF, $1F
.db $A7, $1A, $B0, $22, $B1, $1D, $B2, $25
.db $B3

LABEL_B03_9909:
.db	$02, $18, $20, $0E, $B4, $10, $B5

LABEL_B03_9910:
.db $02, $08, $10, $08, $B6, $0A, $B7

LABEL_B03_9917:
.db	$01
.db $08, $05, $B8

LABEL_B03_991B:
.db	$03, $00, $08, $08, $04
.db $B9, $02, $BA, $0A, $BB

LABEL_B03_9925:
.db	$02, $60, $68
.db $2C, $A0, $2C, $A1

LABEL_B03_992C:
.db	$04, $60, $60, $68
.db $68, $28, $A2, $30, $A3, $28, $A4, $30
.db $A5

LABEL_B03_9939:
.db	$08, $38, $40, $48, $50, $50, $58
.db $58, $60, $1A, $A6, $1E, $A7, $20, $A8
.db $23, $A9, $2B, $AA, $26, $AB, $2E, $AC
.db $2C, $AD

LABEL_B03_9952:
.db	$06, $18, $20, $28, $28, $30
.db $38, $0D, $AE, $11, $AF, $13, $B0, $1B
.db $B1, $16, $B2, $1B, $B3

LABEL_B03_9965:
.db	$04, $00, $08
.db $10, $18, $06, $B4, $07, $B5, $0A, $B6
.db $10, $B7

LABEL_B03_9972:
.db	$01, $00, $02, $B8

LABEL_B03_9976:
.db	$01, $00
.db $00, $B9

LABEL_B03_997A:
.db	$02, $60, $68, $2D, $A0, $2E
.db $A1

LABEL_B03_9981:
.db	$04, $60, $60, $68, $68, $28, $A2
.db $30, $A3, $2A, $A4, $32, $A5

LABEL_B03_998E:
.db	$04, $48
.db $48, $50, $50, $22, $A6, $2A, $A7, $24
.db $A8, $2C, $A9

LABEL_B03_999B:
.db	$02, $28, $28, $13, $AA
.db $1B, $AB

LABEL_B03_99A2:
.db	$01, $10, $0A, $AC

LABEL_B03_99A6:
.db	$01, $00
.db $05, $AD

LABEL_B03_99AA:
.db	$01, $00, $02, $AE

LABEL_B03_99AE:
.db	$01, $00
.db $00, $AF

LABEL_B03_99B2:
.db	$02, $60, $68, $2C, $A0, $2C
.db $A1

LABEL_B03_99B9:
.db	$04, $60, $60, $68, $68, $28, $A2
.db $30, $A3, $28, $A4, $30, $A5

LABEL_B03_99C6:
.db	$08, $38
.db $38, $40, $40, $48, $50, $50, $58, $18
.db $A6, $20, $A7, $19, $A8, $21, $A9, $20
.db $AA, $23, $AB, $2B, $AC, $29, $AD

LABEL_B03_99DF:
.db	$04
.db $18, $18, $20, $28, $0D, $AE, $16, $AF
.db $10, $B0, $13, $B1

LABEL_B03_99EC:
.db	$02, $08, $10, $07
.db $B2, $0C, $B3

LABEL_B03_99F3:
.db	$01, $00, $02, $B4

LABEL_B03_99F7:
.db	$02
.db $00, $00, $00, $B5, $08, $B6

LABEL_B03_99FE:
.db	$02, $00
.db $08, $02, $B7, $00, $B8

LABEL_B03_9A05:
.db	$02, $60, $68
.db $2C, $A0, $2C, $A1

LABEL_B03_9A0C:
.db	$04, $60, $60, $68
.db $68, $28, $A2, $30, $A3, $28, $A4, $30
.db $A5

LABEL_B03_9A19:
.db	$07, $38, $40, $48, $50, $58, $60
.db $60, $22, $A6, $28, $A7, $29, $A8, $28
.db $A9, $28, $AA, $29, $AB, $31, $AC

LABEL_B03_9A2F:
.db	$05
.db $18, $20, $28, $30, $38, $20, $AD, $20
.db $AE, $20, $AF, $21, $B0, $22, $B1

LABEL_B03_9A3F:
.db	$06
.db $00, $00, $08, $08, $10, $18, $10, $B2
.db $18, $B3, $10, $B4, $18, $B5, $1B, $B6
.db $20, $B7

LABEL_B03_9A52:
.db	$03, $00, $00, $08, $03, $B8
.db $0B, $B9, $08, $BA

LABEL_B03_9A5C:
.db	$01, $00, $02, $BB

LABEL_B03_9A60:
.db $01, $00, $00, $BC

LABEL_B03_9A64:
.db	$01, $00, $00, $BD

LABEL_B03_9A68:
.db $02, $60, $68, $2C, $A0, $2C, $A1

LABEL_B03_9A6F:
.db	$04
.db $60, $60, $68, $68, $28, $A2, $30, $A3
.db $28, $A4, $30, $A5

LABEL_B03_9A7C:
.db	$08, $40, $40, $48
.db $48, $50, $50, $58, $58, $1D, $A6, $25
.db $A7, $1D, $A8, $25, $A9, $1F, $AA, $27
.db $AB, $20, $AC, $28, $AD

LABEL_B03_9A95:
.db	$08, $20, $20
.db $28, $28, $30, $30, $38, $38, $11, $AE
.db $19, $AF, $13, $B0, $1B, $B1, $15, $B2
.db $1D, $B3, $17, $B4, $1F, $B5

LABEL_B03_9AAE:
.db	$04, $08
.db $10, $10, $18, $09, $B6, $09, $B7, $11
.db $B8, $0D, $B9

LABEL_B03_9ABB:
.db	$01, $00, $06, $BA

LABEL_B03_9ABF:
.db	$02
.db $00, $00, $00, $BB, $08, $BC

LABEL_B03_9AC6:
.db	$01, $00
.db $04, $BD

LABEL_B03_9ACA:
.db	$04, $DC, $E4, $EC, $F4, $12
.db $A0, $0E, $A1, $0A, $A1, $06, $A1

LABEL_B03_9AD7:
.db	$06
.db $EC, $F4, $FC, $FC, $04, $04, $0C, $A2
.db $07, $A3, $FC, $A4, $04, $A5, $FE, $A6
.db $06, $A7

LABEL_B03_9AEA:
.db	$08, $FC, $FC, $04, $04, $0C
.db $14, $1C, $24, $01, $A8, $09, $A9, $FB
.db $AA, $03, $AB, $FA, $A1, $F6, $A1, $F2
.db $A1, $F2, $AC

LABEL_B03_9B03:
.db	$05, $FC, $04, $14, $1C
.db $24, $03, $AD, $00, $AD, $F8, $AE, $F4
.db $AF, $F0, $B0

LABEL_B03_9B13:
.db	$04, $DC, $E4, $EC, $F4
.db $13, $A0, $0F, $A1, $09, $A2, $06, $A3

LABEL_B03_9B20:
.db $06, $F4, $FC, $FC, $04, $04, $0C, $05
.db $A4, $FF, $A5, $07, $A6, $FC, $A7, $04
.db $A8, $FB, $A9

LABEL_B03_9B33:
.db	$08, $FC, $FC, $04, $04
.db $0C, $14, $1C, $24, $FD, $AA, $05, $AB
.db $00, $AC, $08, $AD, $FA, $AE, $F7, $AF
.db $F3, $A1, $F1, $B0

LABEL_B03_9B4C:
.db	$07, $F4, $FC, $04
.db $0C, $14, $1C, $24, $03, $B1, $03, $B2
.db $FD, $B3, $04, $B1, $F7, $B4, $F4, $B4
.db $F0, $B5

LABEL_B03_9B62:
.db	$08, $D8, $E0, $E0, $E8, $E8
.db $F0, $F0, $F8, $10, $A0, $0C, $A1, $14
.db $A2, $07, $A3, $0F, $A4, $05, $A5, $0D
.db $A6, $07, $A7

LABEL_B03_9B7B:
.db	$06, $F0, $F8, $F8, $00
.db $00, $08, $03, $A8, $FF, $A9, $07, $AA
.db $FD, $AB, $05, $AC, $01, $AD

LABEL_B03_9B8E:
.db	$08, $00
.db $00, $08, $08, $10, $10, $18, $18, $FB
.db $AE, $03, $AF, $F8, $B0, $00, $B1, $F4
.db $B2, $FC, $B3, $F2, $B4, $FA, $B5

LABEL_B03_9BA7:
.db	$04
.db $08, $18, $18, $20, $FA, $B6, $F0, $B7
.db $F8, $B8, $F0, $B9

LABEL_B03_9BB4:
.db	$04, $DC, $E4, $EC
.db $F4, $12, $A0, $0E, $A1, $0A, $A1, $08
.db $A2

LABEL_B03_9BC1:
.db	$02, $FC, $04, $02, $A3, $00, $A2

LABEL_B03_9BC8:
.db $06, $FC, $04, $0C, $14, $1C, $24, $00
.db $A4, $00, $A5, $FA, $A3, $F6, $A1, $F2
.db $A1, $F0, $A6


LABEL_B03_9BDB:
.db	$07, $DC, $E4, $EC, $F4
.db $14, $1C, $24, $F0, $A7, $F2, $A8, $F6
.db $A8, $FA, $A9, $F9, $AA, $F4, $AB, $F0
.db $AC

LABEL_B03_9BF1:
.db	$02, $FC, $04, $00, $AD, $02, $A9

LABEL_B03_9BF8:
.db $06, $FC, $04, $0C, $14, $1C, $24, $00
.db $AE, $00, $AF, $08, $AD, $0A, $A8, $0E
.db $A8, $12, $B0

LABEL_B03_9C0B:
.db	$03, $14, $1C, $24, $0D
.db $B1, $0F, $B2, $12, $B3

LABEL_B03_9C15:
.db	$04, $DC, $E4
.db $EC, $F4, $F0, $A0, $F4, $A1, $F6, $A2
.db $FA, $A2

LABEL_B03_9C22:
.db	$04, $F4, $FC, $04, $0C, $FC
.db $A1, $FE, $A2, $02, $A2, $06, $A3

LABEL_B03_9C2F:
.db	$05
.db $FC, $04, $0C, $14, $1C, $00, $A4, $00
.db $A5, $06, $A2, $0A, $A2, $0E, $A3

LABEL_B03_9C3F:
.db	$04
.db $FC, $04, $1C, $24, $03, $A6, $FD, $A6
.db $10, $A7, $14, $A8

LABEL_B03_9C4C:
.db	$06, $DC, $E4, $EC
.db $EC, $F4, $F4, $F0, $A0, $F4, $A1, $F6
.db $A2, $FE, $A3, $F8, $A4, $00, $A5

LABEL_B03_9C5F:
.db	$08
.db $F4, $F4, $FC, $FC, $04, $04, $0C, $0C
.db $F8, $A4, $00, $A5, $FD, $A6, $05, $A7
.db $00, $A8, $08, $A7, $04, $A9, $0C, $AA

LABEL_B03_9C78:
.db $07, $FC, $04, $0C, $0C, $14, $14, $1C
.db $00, $AB, $00, $AC, $04, $A9, $0C, $AA
.db $08, $AD, $10, $A3, $0E, $AE

LABEL_B03_9C8E:
.db	$04, $FC
.db $04, $1C, $24, $04, $AF, $FC, $AF, $0E
.db $B0, $14, $B1

LABEL_B03_9C9B:
.db	$02, $FC, $04, $02, $A0
.db $02, $A1

LABEL_B03_9CA2:
.db	$02, $FC, $04, $00, $A2, $00
.db $A3

LABEL_B03_9CA9:
.db	$02, $04, $0C, $04, $A4, $03, $A5

LABEL_B03_9CB0:
.db $03, $0C, $14, $1C, $01, $A6, $FF, $A7
.db $FD, $A8

LABEL_B03_9CBA:
.db	$06, $2C, $34, $3C, $3C, $44
.db $44, $02, $A9, $01, $AA, $FD, $AB, $05
.db $AC, $FD, $AD, $05, $AE

LABEL_B03_9CCD:
.db	$04, $44, $44
.db $4C, $4C, $FD, $AF, $05, $B0, $FC, $B1
.db $04, $B2

LABEL_B03_9CDA:
.db	$02, $44, $4C, $00, $A2, $00
.db $A3

LABEL_B03_9CE1:
.db	$04, $44, $44, $4C, $4C, $FC, $B3
.db $04, $B4, $FC, $B5, $04, $B6

LABEL_B03_9CEE:
.db	$02, $FC
.db $04, $02, $A0, $02, $A1

LABEL_B03_9CF5:
.db	$02, $FC, $04
.db $00, $A2, $00, $A3

LABEL_B03_9CFC:
.db	$04, $FC, $04, $04
.db $0C, $02, $A0, $02, $A4, $0A, $A5, $03
.db $A6

LABEL_B03_9D09:
.db	$06, $04, $0C, $14, $1C, $1C, $24
.db $FC, $A7, $FC, $A8, $FC, $A9, $FD, $AA
.db $05, $AB, $02, $AC

LABEL_B03_9D1C:
.db	$0A, $0C, $14, $14
.db $1C, $24, $2C, $2C, $34, $3C, $44, $03
.db $AD, $FF, $AE, $07, $AF, $FE, $B0, $03
.db $B0, $FE, $B1, $06, $B2, $FD, $B3, $00
.db $B4, $00, $A3

LABEL_B03_9D3B:
.db	$04, $44, $44, $4C, $4C
.db $FD, $B5, $05, $B6, $FC, $B7, $04, $B8

LABEL_B03_9D48:
.db $02, $44, $4C, $00, $A2, $00, $A3

LABEL_B03_9D4F:
.db	$04
.db $44, $44, $4C, $4C, $FC, $B9, $04, $BA
.db $FC, $BB, $04, $BC

LABEL_B03_9D5C:
.db	$17, $10, $10, $10
.db $10, $10, $18, $18, $18, $18, $18, $18
.db $20, $20, $20, $20, $20, $20, $28, $28
.db $28, $28, $28, $28, $0C, $00, $14, $01
.db $1C, $02, $24, $03, $2C, $04, $0A, $05
.db $12, $06, $1A, $07, $22, $08, $2A, $09
.db $32, $0A, $0B, $0B, $13, $0C, $1B, $0D
.db $23, $0E, $2B, $0F, $33, $10, $08, $11
.db $10, $12, $18, $13, $20, $13, $28, $14
.db $30, $15

LABEL_B03_9DA2:
.db	$17, $10, $10, $10, $10, $10
.db $18, $18, $18, $18, $18, $18, $20, $20
.db $20, $20, $20, $20, $28, $28, $28, $28
.db $28, $28, $0C, $16, $14, $17, $1C, $18
.db $24, $19, $2C, $1A, $0B, $1B, $13, $1C
.db $1B, $1D, $23, $1E, $2B, $1F, $33, $20
.db $0B, $0B, $13, $0C, $1B, $0D, $23, $0E
.db $2B, $0F, $33, $10, $08, $11, $10, $12
.db $18, $13, $20, $13, $28, $14, $30, $15

LABEL_B03_9DE8:
.db $1C, $08, $08, $08, $08, $08, $10, $10
.db $10, $10, $10, $18, $18, $18, $18, $18
.db $18, $20, $20, $20, $20, $20, $20, $28
.db $28, $28, $28, $28, $28, $0F, $21, $17
.db $22, $1F, $22, $27, $23, $2F, $24, $0F
.db $25, $17, $26, $1F, $26, $27, $27, $2F
.db $28, $0B, $29, $13, $2A, $1B, $1D, $23
.db $1E, $2B, $2B, $33, $20, $0B, $0B, $13
.db $0C, $1B, $0D, $23, $0E, $2B, $0F, $33
.db $10, $08, $11, $10, $12, $18, $13, $20
.db $13, $28, $14, $30, $15

LABEL_B03_9E3D:
.db	$16, $10, $10
.db $10, $10, $18, $18, $18, $18, $18, $18
.db $20, $20, $20, $20, $20, $20, $28, $28
.db $28, $28, $28, $28, $10, $2C, $18, $2D
.db $20, $2D, $28, $2E, $0B, $29, $13, $2A
.db $1B, $1D, $23, $1E, $2B, $2B, $33, $20
.db $0B, $0B, $13, $0C, $1B, $0D, $23, $0E
.db $2B, $0F, $33, $10, $08, $11, $10, $12
.db $18, $13, $20, $13, $28, $14, $30, $15

LABEL_B03_9E80:
.db $16, $10, $10, $10, $10, $18, $18, $18
.db $18, $18, $18, $20, $20, $20, $20, $20
.db $20, $28, $28, $28, $28, $28, $28, $10
.db $2C, $18, $2D, $20, $2D, $28, $2E, $0B
.db $29, $13, $2A, $1B, $2F, $23, $30, $2B
.db $2B, $33, $20, $0B, $0B, $13, $0C, $1B
.db $0D, $23, $0E, $2B, $0F, $33, $10, $08
.db $11, $10, $12, $18, $13, $20, $13, $28
.db $14, $30, $15

LABEL_B03_9EC3:
.db	$16, $10, $10, $10, $10
.db $18, $18, $18, $18, $18, $18, $20, $20
.db $20, $20, $20, $20, $28, $28, $28, $28
.db $28, $28, $10, $31, $18, $32, $20, $33
.db $28, $34, $0B, $35, $13, $36, $1B, $37
.db $23, $38, $2B, $39, $33, $3A, $0B, $3B
.db $13, $3C, $1B, $3D, $23, $3E, $2B, $3F
.db $33, $40, $08, $41, $10, $42, $18, $43
.db $20, $43, $28, $44, $30, $45

LABEL_B03_9F06:
.db	$1A, $08
.db $08, $08, $10, $10, $10, $10, $10, $18
.db $18, $18, $18, $18, $18, $20, $20, $20
.db $20, $20, $20, $28, $28, $28, $28, $28
.db $28, $18, $46, $20, $47, $28, $48, $10
.db $49, $18, $4A, $20, $4B, $28, $4C, $30
.db $4D, $0B, $4E, $13, $4F, $1B, $50, $23
.db $51, $2B, $52, $33, $53, $08, $54, $10
.db $55, $18, $56, $20, $57, $28, $58, $30
.db $59, $08, $5A, $10, $5B, $18, $5C, $20
.db $5D, $28, $5E, $30, $5F

LABEL_B03_9F55:
.db	$26, $00, $00
.db $00, $00, $08, $08, $08, $08, $08, $08
.db $10, $10, $10, $10, $10, $10, $18, $18
.db $18, $18, $18, $18, $20, $20, $20, $20
.db $20, $20, $20, $20, $28, $28, $28, $28
.db $28, $28, $28, $28, $0D, $60, $15, $61
.db $23, $62, $2B, $63, $09, $64, $11, $65
.db $19, $66, $21, $67, $29, $68, $31, $69
.db $08, $6A, $10, $6B, $18, $6C, $20, $6D
.db $28, $6E, $30, $6F, $08, $70, $10, $71
.db $18, $72, $20, $73, $28, $74, $30, $75
.db $01, $76, $09, $77, $11, $78, $19, $79
.db $21, $7A, $29, $7B, $31, $7C, $39, $7D
.db $00, $7E, $08, $7F, $10, $80, $18, $81
.db $20, $82, $28, $83, $30, $84, $38, $85

LABEL_B03_9FC8:
.db $18, $10, $10, $10, $10, $10, $18, $18
.db $18, $18, $18, $18, $18, $20, $20, $20
.db $20, $20, $20, $28, $28, $28, $28, $28
.db $28, $08, $86, $10, $2C, $18, $2D, $20
.db $2D, $28, $2E, $0B, $29, $13, $87, $1B
.db $88, $23, $1E, $2B, $2B, $33, $89, $3B
.db $8A, $0B, $0B, $13, $0C, $1B, $0D, $23
.db $0E, $2B, $0F, $33, $10, $08, $11, $10
.db $12, $18, $13, $20, $13, $28, $14, $30
.db $15

LABEL_B03_A011:
.db	$16, $10, $10, $10, $10, $18, $18
.db $18, $18, $18, $18, $20, $20, $20, $20
.db $20, $20, $28, $28, $28, $28, $28, $28
.db $10, $2C, $18, $2D, $20, $2D, $28, $2E
.db $0B, $29, $13, $2A, $1B, $8B, $23, $8C
.db $2B, $2B, $33, $20, $0B, $0B, $13, $0C
.db $1B, $0D, $23, $0E, $2B, $0F, $33, $10
.db $08, $11, $10, $12, $18, $13, $20, $13
.db $28, $14, $30, $15

LABEL_B03_A054:
.db	$16, $10, $10, $10
.db $10, $18, $18, $18, $18, $18, $18, $20
.db $20, $20, $20, $20, $20, $28, $28, $28
.db $28, $28, $28, $10, $2C, $18, $2D, $20
.db $2D, $28, $2E, $0B, $29, $13, $2A, $1B
.db $8D, $23, $1E, $2B, $2B, $33, $20, $0B
.db $0B, $13, $0C, $1B, $8E, $23, $8F, $2B
.db $0F, $33, $10, $08, $11, $10, $12, $18
.db $90, $20, $91, $28, $14, $30, $15

LABEL_B03_A097:
.db	$18
.db $10, $10, $10, $10, $18, $18, $18, $18
.db $18, $18, $20, $20, $20, $20, $20, $20
.db $28, $28, $28, $28, $28, $28, $30, $30
.db $10, $2C, $18, $2D, $20, $2D, $28, $2E
.db $0B, $29, $13, $2A, $1B, $1D, $23, $1E
.db $2B, $2B, $33, $20, $0B, $0B, $13, $0C
.db $1B, $0D, $23, $0E, $2B, $0F, $33, $10
.db $08, $11, $10, $12, $18, $92, $20, $93
.db $28, $14, $30, $15, $18, $94, $20, $95

LABEL_B03_A0E0:
.db $1E, $10, $10, $10, $10, $18, $18, $18
.db $18, $18, $18, $20, $20, $20, $20, $20
.db $20, $28, $28, $28, $28, $28, $28, $30
.db $30, $38, $38, $38, $38, $40, $40, $10
.db $2C, $18, $2D, $20, $2D, $28, $2E, $0B
.db $29, $13, $2A, $1B, $1D, $23, $1E, $2B
.db $2B, $33, $20, $0B, $0B, $13, $0C, $1B
.db $0D, $23, $0E, $2B, $0F, $33, $10, $08
.db $11, $10, $12, $18, $96, $20, $97, $28
.db $14, $30, $15, $1A, $98, $22, $99, $13
.db $9A, $1B, $9B, $23, $9C, $2B, $9D, $18
.db $9E, $20, $9F

LABEL_B03_A13B:
.db	$1F, $00, $00, $08, $08
.db $10, $10, $10, $18, $18, $18, $18, $20
.db $20, $20, $20, $28, $28, $28, $28, $30
.db $30, $30, $38, $38, $40, $40, $48, $48
.db $50, $50, $50, $0A, $00, $12, $01, $08
.db $02, $10, $03, $06, $04, $0E, $05, $16
.db $06, $04, $07, $0C, $08, $14, $09, $1C
.db $0A, $02, $0B, $0A, $0C, $12, $0D, $1A
.db $0E, $00, $0F, $08, $10, $10, $11, $18
.db $12, $00, $13, $08, $14, $10, $15, $09
.db $16, $11, $17, $0A, $18, $12, $19, $0A
.db $1A, $12, $1B, $04, $1C, $0C, $1D, $14
.db $1E

LABEL_B03_A199:
.db	$21, $00, $00, $08, $08, $10, $10
.db $10, $10, $18, $18, $18, $18, $20, $20
.db $20, $28, $28, $28, $30, $30, $30, $38
.db $38, $38, $40, $40, $48, $48, $48, $50
.db $50, $50, $50, $09, $1F, $11, $20, $09
.db $21, $11, $22, $03, $23, $0B, $24, $13
.db $25, $1B, $26, $03, $27, $0B, $28, $13
.db $29, $1B, $2A, $05, $2B, $0D, $2C, $15
.db $2D, $06, $2E, $0E, $2F, $16, $30, $06
.db $31, $0E, $32, $16, $33, $06, $34, $11
.db $35, $19, $36, $06, $37, $12, $38, $06
.db $39, $13, $3A, $1B, $3B, $00, $3C, $08
.db $3D, $10, $3E, $18, $3F

LABEL_B03_A1FD:
.db	$25, $00, $00
.db $08, $08, $10, $10, $10, $18, $18, $18
.db $18, $20, $20, $20, $20, $28, $28, $28
.db $30, $30, $30, $30, $38, $38, $38, $40
.db $40, $40, $40, $48, $48, $48, $48, $50
.db $50, $50, $50, $0A, $40, $12, $01, $08
.db $41, $10, $42, $06, $43, $0E, $44, $16
.db $45, $03, $46, $0B, $47, $13, $48, $1B
.db $49, $02, $4A, $0A, $4B, $12, $4C, $1A
.db $4D, $00, $4E, $08, $4F, $10, $50, $00
.db $51, $08, $52, $10, $53, $18, $54, $04
.db $55, $0C, $56, $14, $57, $01, $58, $09
.db $59, $11, $5A, $19, $5B, $02, $5C, $0A
.db $5D, $12, $5E, $1A, $5F, $03, $60, $0B
.db $61, $13, $62, $1B, $63

LABEL_B03_A26D:
.db	$23, $00, $00
.db $08, $08, $10, $10, $10, $10, $18, $18
.db $18, $18, $20, $20, $20, $20, $28, $28
.db $28, $28, $30, $30, $30, $38, $38, $38
.db $40, $40, $40, $48, $48, $50, $50, $50
.db $50, $09, $64, $11, $65, $09, $66, $11
.db $67, $02, $68, $0A, $69, $12, $6A, $1A
.db $6B, $00, $6C, $08, $6D, $10, $6E, $18
.db $6F, $00, $70, $08, $71, $10, $72, $18
.db $73, $03, $74, $0B, $75, $13, $76, $1B
.db $77, $06, $78, $0E, $79, $16, $7A, $05
.db $7B, $0D, $7C, $15, $7D, $04, $7E, $0C
.db $7F, $14, $80, $03, $81, $14, $82, $00
.db $83, $08, $84, $10, $85, $18, $86

LABEL_B03_A2D7:
.db	$27
.db $00, $00, $00, $08, $08, $08, $08, $10
.db $10, $10, $10, $18, $18, $18, $18, $20
.db $20, $20, $20, $20, $28, $28, $28, $28
.db $30, $30, $30, $30, $38, $38, $38, $40
.db $40, $48, $48, $50, $50, $50, $50, $0B
.db $00, $13, $01, $1B, $02, $0A, $03, $12
.db $04, $1A, $05, $22, $06, $08, $07, $10
.db $08, $18, $09, $20, $0A, $08, $0B, $10
.db $0C, $18, $0D, $20, $0E, $06, $0F, $0E
.db $10, $16, $11, $1E, $12, $26, $13, $06
.db $14, $0E, $15, $16, $16, $1E, $17, $08
.db $18, $10, $19, $18, $1A, $20, $1B, $0C
.db $1C, $14, $1D, $1C, $1E, $0C, $1F, $1B
.db $20, $0B, $21, $1C, $22, $08, $23, $10
.db $24, $18, $25, $20, $26

LABEL_B03_A34D:
.db	$23, $08, $08
.db $10, $10, $10, $10, $18, $18, $18, $18
.db $20, $20, $20, $20, $28, $28, $28, $30
.db $30, $30, $38, $38, $38, $38, $40, $40
.db $40, $40, $48, $48, $48, $50, $50, $50
.db $50, $0A, $27, $12, $28, $03, $29, $0B
.db $2A, $13, $2B, $1B, $2C, $02, $2D, $0A
.db $2E, $12, $2F, $1A, $30, $02, $31, $0A
.db $32, $12, $33, $1A, $34, $05, $35, $0D
.db $36, $15, $37, $03, $38, $0B, $39, $13
.db $3A, $02, $3B, $0A, $3C, $12, $3D, $1A
.db $3E, $02, $3F, $0A, $40, $12, $41, $1A
.db $42, $04, $43, $0C, $44, $14, $45, $00
.db $46, $08, $47, $10, $48, $18, $49

LABEL_B03_A3B7:
.db	$22
.db $00, $00, $08, $08, $10, $10, $10, $18
.db $18, $18, $18, $20, $20, $20, $20, $28
.db $28, $28, $30, $30, $30, $38, $38, $38
.db $40, $40, $40, $48, $48, $48, $50, $50
.db $50, $50, $0B, $4A, $13, $4B, $08, $4C
.db $10, $4D, $04, $4E, $0C, $4F, $14, $50
.db $02, $51, $0A, $52, $12, $53, $1A, $54
.db $02, $55, $0A, $56, $12, $57, $1A, $58
.db $04, $59, $0C, $5A, $14, $5B, $04, $5C
.db $0C, $5D, $14, $5E, $05, $5F, $0D, $60
.db $15, $61, $06, $62, $0E, $63, $16, $64
.db $05, $65, $0D, $66, $15, $67, $04, $68
.db $0C, $69, $14, $6A, $1C, $6B

LABEL_B03_A41E:
.db	$2A, $00
.db $00, $00, $08, $08, $08, $10, $10, $10
.db $10, $18, $18, $18, $18, $20, $20, $20
.db $20, $28, $28, $28, $28, $30, $30, $30
.db $30, $38, $38, $38, $38, $40, $40, $40
.db $40, $48, $48, $48, $48, $50, $50, $50
.db $50, $05, $00, $0D, $01, $15, $02, $06
.db $03, $0E, $04, $16, $05, $01, $06, $09
.db $07, $11, $08, $19, $09, $00, $0A, $08
.db $0B, $10, $0C, $18, $0D, $00, $0E, $08
.db $0F, $10, $10, $18, $11, $02, $12, $0A
.db $13, $12, $14, $1A, $15, $02, $16, $0A
.db $17, $12, $18, $1A, $19, $01, $1A, $09
.db $1B, $11, $1C, $19, $1D, $01, $1E, $09
.db $1F, $11, $20, $19, $21, $03, $22, $0B
.db $23, $13, $24, $1B, $25, $00, $26, $08
.db $27, $10, $28, $18, $29

LABEL_B03_A49D:
.db	$34, $00, $00
.db $00, $00, $08, $08, $08, $08, $10, $10
.db $10, $10, $18, $18, $18, $18, $20, $20
.db $20, $20, $28, $28, $28, $28, $28, $28
.db $30, $30, $30, $30, $30, $30, $38, $38
.db $38, $38, $38, $40, $40, $40, $40, $40
.db $48, $48, $48, $48, $48, $50, $50, $50
.db $50, $50, $0B, $00, $13, $01, $1B, $02
.db $23, $03, $0B, $04, $13, $05, $1B, $06
.db $23, $07, $0B, $08, $13, $09, $1B, $0A
.db $23, $07, $0A, $0B, $12, $0C, $1A, $0D
.db $22, $0E, $0A, $0F, $12, $10, $1A, $11
.db $22, $12, $03, $13, $0B, $14, $13, $15
.db $1B, $16, $23, $17, $2B, $18, $02, $19
.db $0A, $1A, $12, $1B, $1A, $1C, $22, $1D
.db $2A, $1E, $05, $1F, $0D, $20, $15, $21
.db $1D, $22, $25, $23, $04, $24, $0C, $25
.db $14, $26, $1C, $27, $24, $28, $04, $29
.db $0C, $2A, $14, $2B, $1C, $2C, $24, $2D
.db $04, $2E, $0C, $2F, $14, $30, $1C, $31
.db $24, $32

LABEL_B03_A53A:
.db	$1C, $00, $00, $00, $08, $08
.db $08, $08, $10, $10, $10, $10, $18, $18
.db $18, $18, $20, $20, $20, $20, $28, $28
.db $28, $28, $30, $30, $30, $30, $30, $09
.db $00, $11, $01, $19, $02, $04, $03, $0C
.db $04, $14, $05, $1C, $06, $04, $07, $0C
.db $08, $14, $09, $1C, $0A, $05, $0B, $0D
.db $0C, $15, $0D, $1D, $0E, $04, $0F, $0C
.db $10, $14, $11, $1C, $12, $04, $13, $0C
.db $14, $14, $15, $1C, $16, $02, $17, $0A
.db $18, $12, $19, $1A, $1A, $22, $1B

LABEL_B03_A58F:
.db	$29
.db $00, $00, $00, $00, $08, $08, $08, $08
.db $08, $08, $10, $10, $10, $10, $10, $10
.db $18, $18, $18, $18, $18, $18, $20, $20
.db $20, $20, $20, $28, $28, $28, $28, $28
.db $28, $28, $30, $30, $30, $30, $30, $30
.db $30, $10, $1C, $18, $1D, $20, $1E, $28
.db $1F, $08, $20, $10, $21, $18, $22, $20
.db $23, $28, $24, $30, $25, $08, $26, $10
.db $27, $18, $28, $20, $29, $28, $2A, $30
.db $2B, $01, $2C, $09, $2D, $11, $2E, $19
.db $2F, $21, $30, $29, $31, $08, $32, $10
.db $33, $18, $34, $20, $35, $28, $36, $00
.db $37, $08, $38, $10, $39, $18, $3A, $20
.db $3B, $28, $3C, $30, $3D, $00, $3E, $08
.db $3F, $10, $40, $18, $41, $20, $42, $28
.db $43, $30, $44

LABEL_B03_A60B:
.db	$27, $00, $00, $08, $08
.db $08, $10, $10, $10, $10, $18, $18, $18
.db $18, $20, $20, $20, $20, $28, $28, $28
.db $28, $30, $30, $30, $30, $38, $38, $38
.db $38, $40, $40, $40, $40, $48, $48, $50
.db $50, $50, $50, $08, $00, $10, $01, $05
.db $02, $0D, $03, $15, $04, $04, $05, $0C
.db $06, $14, $07, $1C, $08, $01, $09, $09
.db $0A, $11, $0B, $19, $0C, $00, $0D, $08
.db $0E, $10, $0F, $18, $10, $01, $11, $09
.db $12, $11, $13, $19, $14, $00, $0D, $08
.db $0E, $10, $0F, $18, $10, $01, $11, $09
.db $12, $11, $13, $19, $14, $01, $15, $09
.db $16, $11, $17, $19, $18, $08, $19, $10
.db $1A, $00, $1B, $08, $1C, $10, $1D, $18
.db $1E

LABEL_B03_A681:
.db	$27, $00, $00, $08, $08, $10, $10
.db $10, $18, $18, $18, $18, $20, $20, $20
.db $20, $28, $28, $28, $28, $30, $30, $30
.db $30, $38, $38, $38, $38, $40, $40, $40
.db $40, $48, $48, $48, $48, $50, $50, $50
.db $50, $0A, $00, $12, $01, $0A, $02, $12
.db $03, $05, $04, $0D, $05, $15, $06, $00
.db $07, $08, $08, $10, $09, $18, $0A, $00
.db $0B, $08, $0C, $10, $0D, $18, $0E, $00
.db $0F, $08, $10, $10, $11, $18, $12, $00
.db $13, $08, $14, $10, $15, $18, $16, $00
.db $17, $08, $18, $10, $19, $18, $1A, $00
.db $1B, $08, $18, $10, $1C, $18, $1D, $00
.db $1E, $08, $18, $10, $19, $18, $1F, $00
.db $20, $08, $21, $10, $22, $18, $23

LABEL_B03_A6F7:
.db	$30
.db $00, $00, $00, $08, $08, $08, $08, $08
.db $10, $10, $10, $10, $10, $18, $18, $18
.db $18, $18, $20, $20, $20, $20, $20, $28
.db $28, $28, $28, $30, $30, $30, $30, $38
.db $38, $38, $38, $40, $40, $40, $40, $48
.db $48, $48, $48, $50, $50, $50, $50, $50
.db $0E, $00, $16, $01, $1E, $02, $01, $03
.db $09, $04, $11, $05, $19, $06, $21, $07
.db $01, $08, $09, $09, $11, $0A, $19, $0B
.db $21, $0C, $00, $0D, $08, $0E, $10, $0F
.db $18, $10, $20, $11, $00, $12, $0A, $13
.db $12, $14, $1A, $15, $22, $16, $01, $17
.db $09, $18, $11, $19, $19, $1A, $06, $1B
.db $0E, $1C, $16, $1D, $1E, $1E, $04, $1F
.db $0C, $20, $17, $21, $1F, $22, $02, $23
.db $0A, $24, $17, $25, $1F, $26, $02, $27
.db $0A, $28, $18, $29, $20, $2A, $00, $2B
.db $08, $2C, $10, $2D, $18, $2E, $20, $2F

LABEL_B03_A788:
.db $2F, $00, $00, $08, $08, $08, $10, $10
.db $10, $10, $18, $18, $18, $18, $20, $20
.db $20, $20, $28, $28, $28, $28, $30, $30
.db $30, $30, $38, $38, $38, $38, $38, $40
.db $40, $40, $40, $40, $48, $48, $48, $48
.db $48, $48, $50, $50, $50, $50, $50, $50
.db $12, $00, $1A, $01, $0F, $02, $17, $03
.db $1F, $04, $0C, $05, $14, $06, $1C, $07
.db $24, $08, $0A, $09, $12, $0A, $1A, $0B
.db $22, $0C, $0A, $0D, $12, $0E, $1A, $0F
.db $22, $10, $0A, $11, $12, $12, $1A, $13
.db $22, $14, $0A, $15, $12, $16, $1A, $17
.db $22, $18, $07, $19, $0F, $1A, $17, $1B
.db $1F, $1C, $27, $1D, $04, $1E, $0C, $1F
.db $14, $20, $1C, $21, $24, $22, $02, $23
.db $0A, $24, $12, $25, $1A, $26, $22, $27
.db $2A, $28, $02, $29, $0A, $2A, $12, $2B
.db $1A, $2C, $22, $2D, $2A, $2E

LABEL_B03_A816:
.db	$1F, $00
.db $00, $08, $08, $10, $10, $18, $18, $20
.db $20, $28, $28, $28, $30, $30, $30, $38
.db $38, $38, $40, $40, $48, $48, $50, $50
.db $50, $08, $10, $18, $20, $28, $08, $00
.db $10, $01, $06, $02, $0E, $03, $08, $04
.db $10, $05, $08, $06, $10, $07, $08, $08
.db $10, $09, $05, $0A, $0D, $0B, $15, $0C
.db $04, $0D, $0C, $0E, $14, $0F, $05, $10
.db $0D, $11, $15, $12, $05, $13, $0D, $14
.db $06, $15, $0E, $16, $00, $17, $08, $18
.db $10, $19, $01, $1A, $00, $1B, $00, $1C
.db $00, $1D, $02, $1E

LABEL_B03_A874:
.db	$1F, $00, $00, $08
.db $08, $10, $10, $18, $18, $20, $20, $28
.db $28, $28, $30, $30, $30, $38, $38, $38
.db $40, $40, $48, $48, $50, $50, $50, $08
.db $10, $18, $20, $28, $08, $00, $10, $01
.db $06, $02, $0E, $03, $08, $04, $10, $05
.db $08, $06, $10, $07, $08, $08, $10, $09
.db $05, $0A, $0D, $0B, $15, $0C, $04, $0D
.db $0C, $0E, $14, $0F, $05, $10, $0D, $11
.db $15, $12, $05, $13, $0D, $14, $06, $15
.db $0E, $16, $00, $17, $08, $18, $10, $19
.db $02, $2E, $02, $2F, $01, $30, $00, $29
.db $02, $1E

LABEL_B03_A8D2:
.db	$05, $00, $00, $00, $08, $08
.db $00, $00, $08, $01, $10, $02, $08, $03
.db $10, $04

LABEL_B03_A8E2:
.db	$05, $00, $00, $08, $08, $08
.db $04, $05, $0C, $06, $00, $07, $08, $08
.db $10, $09

LABEL_B03_A8F2:
.db	$05, $00, $00, $08, $08, $08
.db $06, $0A, $0E, $0B, $02, $0C, $0A, $0D
.db $12, $0E

LABEL_B03_A902:
.db	$05, $00, $08, $08, $08, $10
.db $0B, $0F, $01, $10, $09, $11, $11, $12
.db $08, $13

LABEL_B03_A912:
.db	$05, $00, $08, $08, $08, $10
.db $0B, $0F, $01, $14, $09, $15, $11, $16
.db $08, $13

LABEL_B03_A922:
.db	$06, $04, $00, $00, $08, $08
.db $10, $10, $17, $02, $18, $0B, $0F, $03
.db $19, $0B, $1A, $08, $13


; =================================================================
; 6 bytes per data
; =================================================================
PalmaDungeonEntrancePoints_B03:
.db	$38, $52, $08, $04, $1B, $6C
.db	$47, $46, $08, $06, $67, $1E
.db	$37, $67, $08, $0D, $60, $51
.db	$65, $76, $08, $0C, $1B, $19
.db	$06, $72, $0A, $00, $15, $01
.db	$10, $78, $0A, $00, $5A, $00
.db	$2B, $16, $0A, $16, $21, $02
.db	$39, $19, $0A, $16, $DE, $00
.db	$53, $4C, $0A, $00, $DC, $00
.db	$46, $76, $0A, $13, $DE, $00
.db	$09, $62, $0A, $13, $13, $03
.db	$35, $86, $0A, $17, $D7, $00
.db	$16, $68, $0A, $0B, $B9, $00
.db	$64, $20, $0A, $04, $D8, $00
.db	$24, $43, $08, $09, $1A, $61
.db	$12, $0E, $08, $0A, $5A, $21
.db	$64, $55, $08, $08, $24, $47
.db	$40, $18, $08, $0B, $4A, $41
.db	$46, $36, $08, $07, $1B, $2E
.db	$28, $68, $0A, $14, $CB, $00
.db	$26, $68, $0A, $14, $21, $02
.db	$68, $32, $0A, $01, $D2, $00

MotaviaDungeonEntrancePoints_B03:
.db	$28, $64, $08, $0E, $11, $13
.db	$70, $58, $08, $11, $4A, $56
.db	$25, $27, $08, $12, $4A, $78
.db	$52, $71, $08, $0F, $18, $53
.db	$08, $36, $0A, $1E, $69, $01
.db	$5A, $2A, $0A, $24, $D9, $00
.db	$77, $5C, $0A, $27, $D3, $00

DezorisDungeonEntrancePoints_B03:
.db	$84, $4E, $0A, $2A, $DD, $03
.db	$0A, $34, $0A, $2B, $D1, $00
.db	$36, $48, $08, $14, $19, $39
.db	$5A, $2A, $08, $13, $18, $18
.db	$28, $0A, $0A, $34, $D3, $00
.db	$2A, $60, $0A, $30, $2E, $02
.db	$36, $5E, $0A, $30, $79, $00
.db	$36, $42, $0A, $31, $1C, $03
.db	$3A, $2C, $0A, $31, $E2, $01
.db	$48, $0E, $0A, $32, $59, $02
.db	$56, $10, $0A, $32, $DB, $00
.db	$64, $16, $0A, $30, $87, $02
.db	$6A, $1E, $0A, $30, $ED, $03
.db	$74, $24, $0A, $2F, $D2, $01
.db	$74, $36, $0A, $2F, $DD, $03
.db	$84, $85, $0C, $06, $AF, $38
.db	$6A, $46, $0A, $3A, $DD, $00

LABEL_AA49_B03:
.db	$FF

LABEL_AA4A_B03:
.db	$14, $69, $0C, $10, $AD, $00
.db	$13, $55, $0C, $10, $02, $0E
.db	$19, $66, $0C, $10, $01, $19
.db	$20, $58, $0C, $10, $08, $32
.db	$27, $63, $0C, $10, $04, $0E
.db $20, $5E, $0C, $16, $01, $0D
.db	$20, $61, $0C, $18, $03, $0F
.db	$20, $63, $0C, $1A, $02, $0E
.db	$25, $6B, $0C, $14, $01, $39
.db $1A, $6D, $08, $00, $39, $55
.db	$27, $5B, $08, $00, $3B, $52
.db	$12, $6C, $0A, $02, $5E, $00
.db	$12, $5E, $0C, $08, $05, $0D
.db $18, $5C, $0C, $08, $06, $0D
.db	$23, $55, $0C, $08, $07, $0D
.db	$24, $5E, $0C, $08, $03, $0D
.db	$1B, $51, $0C, $08, $0B, $31
.db $21, $51, $0C, $08, $0C, $31
.db	$27, $59, $0C, $08, $09, $31
.db	$27, $5D, $0C, $08, $0A, $31
.db	$19, $6B, $0C, $08, $09, $31
.db $20, $6E, $0C, $08, $0A, $31
.db	$1A, $22, $0C, $18, $0A, $03
.db	$1A, $26, $0C, $10, $1D, $02
.db	$21, $21, $0C, $0A, $17, $0F
.db $24, $27, $0C, $0A, $18, $0F
.db	$25, $2A, $0C, $0A, $19, $0F
.db	$1B, $15, $0C, $0A, $1A, $31
.db	$1B, $2D, $0C, $0A, $1B, $31
.db $21, $2D, $0C, $0A, $1B, $31
.db	$28, $20, $0C, $0A, $1C, $31
.db	$16, $15, $0C, $0A, $B3, $0F
.db	$16, $20, $0C, $0A, $B3, $0F
.db $16, $26, $0C, $0A, $B3, $0F
.db	$52, $18, $0C, $10, $0F, $0E
.db	$52, $23, $0C, $10, $0E, $0D
.db	$60, $26, $0C, $10, $0D, $01
.db $59, $19, $0C, $16, $04, $0D
.db	$59, $1B, $0C, $18, $06, $03
.db	$59, $1D, $0C, $1A, $05, $0E
.db	$59, $24, $0C, $12, $02, $04
.db $65, $1E, $08, $00, $48, $49
.db	$56, $15, $0C, $08, $10, $0D
.db	$59, $27, $0C, $08, $11, $0D
.db	$60, $17, $0C, $08, $12, $0D
.db $52, $1F, $0C, $08, $0B, $31
.db	$52, $21, $0C, $08, $0C, $31
.db	$65, $1C, $0C, $08, $09, $31
.db	$65, $20, $0C, $08, $0A, $31

LABEL_AB70_B03:
.db $12, $2C, $0A, $00, $2E, $02, $17, $25
.db $0C, $11, $3E, $00, $17, $27, $0C, $11
.db $3F, $00, $21, $2B, $0C, $13, $02, $1C
.db $15, $20, $0C, $1B, $0F, $25, $27, $2A
.db $0C, $15, $02, $39, $20, $22, $0C, $09
.db $3C, $33, $27, $27, $0C, $09, $3D, $33
.db $1A, $1B, $0C, $09, $AA, $33, $27, $25
.db $0C, $1C, $B6, $00, $24, $11, $0C, $02
.db $B5, $37, $42, $19, $0C, $11, $47, $27
.db $49, $1E, $0A, $15, $D8, $00, $42, $20
.db $0C, $11, $49, $27, $55, $17, $0C, $17
.db $11, $25, $55, $23, $0C, $1B, $12, $26
.db $55, $25, $0C, $19, $13, $27, $4B, $12
.db $0A, $02, $12, $01, $4B, $20, $0A, $02
.db $DE, $00, $55, $19, $0C, $13, $02, $1C
.db $45, $14, $0C, $09, $48, $1D, $46, $28
.db $0C, $09, $46, $28, $55, $2A, $0C, $09
.db $45, $1D, $15, $41, $0C, $11, $26, $26
.db $13, $44, $0C, $11, $27, $1A, $13, $4A
.db $0C, $11, $28, $25, $15, $4D, $0C, $11
.db $2B, $32, $12, $47, $0C, $11, $2A, $32
.db $21, $45, $0C, $17, $0E, $25, $21, $49
.db $0C, $13, $00, $1C, $16, $48, $0C, $09
.db $29, $1D, $13, $6B, $0C, $11, $40, $25
.db $17, $68, $0C, $11, $41, $26, $1B, $6A
.db $0C, $11, $42, $1A, $15, $63, $0C, $17
.db $10, $25, $1B, $66, $0C, $1C, $43, $33
.db $20, $63, $0C, $09, $44, $27, $13, $69
.db $0C, $13, $02, $1B, $17, $66, $0C, $15
.db $03, $39, $45, $45, $0C, $1C, $3A, $33
.db $45, $49, $0C, $1C, $A1, $36, $48, $43
.db $0C, $1C, $A2, $36, $4A, $4C, $0C, $1C
.db $B6, $36, $53, $43, $0C, $1C, $B6, $36
.db $55, $46, $0C, $1C, $B6, $36, $54, $4C
.db $0C, $1C, $B6, $36, $50, $45, $0C, $09
.db $3B, $33, $FF

LABEL_AC8B_B03:
.db	$18, $1C, $0C, $10, $59
.db $0D, $1A, $20, $0C, $10, $5A, $1F, $22
.db $22, $0A, $15, $D1, $00, $19, $23, $0C
.db $08, $57, $0D, $21, $1B, $0C, $08, $56
.db $03, $22, $1E, $0C, $08, $58, $0D, $5A
.db $5F, $0C, $10, $1E, $0E, $67, $5E, $0C
.db $10, $1F, $0E, $64, $62, $0C, $10, $20
.db $0F, $53, $57, $0C, $10, $24, $0F, $67
.db $56, $0C, $10, $22, $0E, $55, $5E, $0C
.db $10, $23, $02, $5A, $57, $0C, $16, $07
.db $0D, $55, $61, $0C, $10, $15, $0F, $63
.db $56, $0C, $1A, $08, $0E, $53, $54, $0C
.db $12, $02, $04, $56, $5A, $0C, $08, $21
.db $0D, $58, $64, $0C, $08, $25, $03

LABEL_ACF7_B03:
.db	$11
.db $11, $0C, $08, $09, $31, $11, $15, $0C
.db $08, $09, $31, $1B, $14, $0C, $08, $2F
.db $11, $12, $1E, $0C, $1D, $37, $00, $16
.db $1D, $0A, $21, $61, $02, $12, $20, $0C
.db $1D, $37, $00, $16, $21, $0C, $10, $39
.db $06, $13, $27, $0C, $08, $32, $11, $13
.db $2C, $0C, $08, $35, $11, $16, $28, $0C
.db $08, $30, $07, $23, $17, $0C, $1A, $0B
.db $11, $23, $19, $0C, $16, $0C, $11, $23
.db $1B, $0C, $10, $36, $12, $23, $1D, $0C
.db $12, $00, $08, $27, $19, $0C, $14, $04
.db $39, $21, $1F, $0C, $08, $38, $31, $21
.db $21, $0A, $21, $D4, $00, $21, $23, $0C
.db $08, $38, $31, $23, $25, $0C, $10, $33
.db $07, $23, $27, $0C, $10, $34, $11, $27
.db $27, $0C, $10, $31, $07, $29, $1D, $0C
.db $08, $13, $31, $29, $1F, $0C, $08, $14
.db $31, $13, $43, $0C, $15, $05, $39, $12
.db $4F, $0C, $11, $4C, $1D, $12, $48, $0C
.db $11, $4F, $2A, $18, $44, $0C, $09, $4B
.db $1D, $12, $46, $0C, $11, $4E, $2B, $12
.db $4B, $0C, $09, $4D, $1D, $18, $4D, $0C
.db $11, $4A, $2A, $1A, $4B, $0C, $13, $00
.db $20, $1B, $59, $0C, $05, $B5, $37, $21
.db $43, $0C, $17, $15, $29, $21, $45, $0C
.db $19, $14, $1F, $44, $15, $0C, $0A, $2E
.db $13, $46, $18, $0C, $0A, $2D, $13, $46
.db $23, $0C, $0A, $2C, $13, $52, $1B, $0C
.db $0A, $B4, $13, $52, $15, $0C, $0A, $B4
.db $13, $41, $1D, $0C, $0A, $0B, $31, $41
.db $1F, $0C, $0A, $0C, $31, $43, $44, $0C
.db $11, $52, $32, $43, $4A, $0C, $1C, $54
.db $33, $47, $43, $0C, $11, $53, $2B, $47
.db $45, $0C, $11, $55, $29, $47, $4C, $0C
.db $13, $05, $2C, $46, $4D, $0C, $09, $50
.db $1D, $42, $53, $0A, $27, $DC, $00, $51
.db $43, $0C, $1B, $16, $2A, $51, $46, $0C
.db $1B, $17, $29, $51, $4F, $0C, $09, $51
.db $1D, $51, $52, $0C, $15, $06, $39, $41
.db $72, $0C, $1C, $78, $33, $41, $77, $0C
.db $11, $77, $2B, $41, $7B, $0C, $1C, $79
.db $33, $44, $75, $0C, $11, $74, $32, $44
.db $78, $0C, $11, $75, $1E, $47, $73, $0C
.db $11, $76, $2D, $47, $76, $0C, $11, $73
.db $1F, $47, $7A, $0C, $13, $00, $20

LABEL_AE5F_B03:
.db	$13
.db $13, $0A, $28, $23, $02, $17, $1C, $0C
.db $06, $B5, $37, $15, $38, $0A, $28, $DD
.db $00


LABEL_AE71_B03:
.db	$13, $13, $0C, $11, $69, $3C, $13
.db $19, $0C, $11, $6A, $3C, $1A, $16, $0C
.db $11, $6B, $3C, $13, $24, $0C, $11, $6E
.db $3C, $13, $2C, $0C, $15, $07, $3C, $17
.db $24, $0C, $11, $6F, $3C, $17, $2A, $0C
.db $11, $70, $3C, $22, $12, $0C, $11, $6C
.db $3C, $22, $14, $0C, $11, $6D, $3C, $23
.db $1B, $0C, $11, $68, $3C, $26, $12, $0C
.db $1B, $1B, $3C, $26, $14, $0C, $1B, $1C
.db $3C, $26, $16, $0C, $13, $00, $3C, $22
.db $1F, $0A, $28, $87, $00, $21, $24, $0C
.db $11, $68, $3C, $21, $2C, $0C, $11, $71
.db $3C, $27, $2D, $0C, $11, $72, $3C, $16
.db $54, $0C, $12, $00, $0C, $1B, $5C, $0C
.db $10, $61, $32, $1B, $68, $0C, $10, $63
.db $0B, $1B, $6A, $0C, $10, $64, $09, $23
.db $6A, $0C, $10, $65, $0A, $26, $54, $0C
.db $10, $66, $17, $26, $56, $0C, $10, $67
.db $32, $26, $6A, $0C, $10, $62, $16, $12
.db $5F, $0A, $28, $6B, $02, $16, $61, $0C
.db $16, $18, $15, $16, $63, $0C, $18, $1A
.db $15, $16, $68, $0C, $1A, $19, $17, $26
.db $61, $0C, $14, $08, $39, $16, $60, $0C
.db $08, $5E, $15, $1B, $59, $0C, $08, $5F
.db $15, $23, $57, $0C, $08, $60, $0B

LABEL_AF37_B03:
.db	$19
.db $13, $0C, $10, $7A, $32, $19, $17, $0C
.db $10, $52, $32, $19, $1B, $0C, $10, $7A
.db $32, $14, $1F, $0A, $39, $D6, $00, $17
.db $25, $0C, $10, $A7, $00, $17, $29, $0C
.db $10, $7B, $32, $FF
; =================================================================


; =================================================================
; Objects found in dungeons. These include chests and scripted encounters
;
; 7 bytes per entry:
; byte 1 = Dungeon ID
; byte 2 = Coordinates (YX)
; bytes 3-4 = Flag address in RAM; if value in that address is $FF, the current object will be ignored
; byte 5 = Object type; 0 = Item; 1 = Meseta; 2 = Battle; 3 = Dialogue
; bytes 6-7 = Content which depends on type (byte 5)
;				if type = Item, it holds the item ID; if byte 7 is > 0, the chest contains a trap
;				if type = Meseta, it holds the Meseta value (word)
;				if type = Battle, byte 6 is the enemy ID, byte 7 is the item dropped
;				if type = Dialogue, byte 6 is the dialogue ID
; =================================================================
B03_ObjectData:

.db	$00, $36
.dw	Event_flags+0
.db $00
.db	ItemID_Compass, $00

.db	$00, $E8
.dw	Event_flags+1
.db	$01
.dw 20

.db	$00, $53
.dw	Event_flags+$C0
.db	$02
.db	EnemyID_DrMad, $00

.db $00, $E3
.dw	Dialogue_flags+$A
.db	$03
.db	$A3, $3A

.db $00, $7C
.dw	Event_flags+2
.db	$01
.dw	10

.db	$01, $17
.dw	Event_flags+3
.db	$00
.db	$00, $FC

.db	$01, $5D
.dw Event_flags+$C1
.db	$02
.db	EnemyID_Skeleton, $00

.db	$01, $B2
.dw	Dialogue_flags+$0C
.db	$03
.db	$82, $00

.db	$01, $E9
.dw	Dialogue_flags+$0B
.db $03
.db	$88, $00

.db	$02, $17
.dw	Event_flags+4
.db	$00
.db ItemID_DungeonKey, $00

.db	$02, $67
.dw	Event_flags+5
.db	$01
.dw	50

.db $02, $3A
.dw	Event_flags+6
.db	$01
.dw	30

.db $02, $63
.dw	Event_flags+7
.db	$01
.dw	20

.db	$03, $9C
.dw	Event_flags+8
.db	$00
.db	$00, $FC

.db	$03, $9E
.dw Event_flags+9
.db	$00
.db	ItemID_Burger, $00

.db	$03, $E1
.dw	Event_flags+$0A
.db	$01
.dw	10

.db	$03, $E8
.dw	Event_flags+$0B
.db $00
.db	ItemID_Burger, $00

.db	$03, $E1
.dw	Event_flags+$0C
.db	$01
.dw 100

.db	$03, $56
.dw	Event_flags+$0D
.db	$00
.db	ItemID_Escaper, $00

.db	$03, $58
.dw	Event_flags+$0E
.db	$00
.db	ItemID_Flash, $00

.db $04, $13
.dw	Event_flags+$0F
.db	$01
.dw	20

.db	$04, $E5
.dw	Event_flags+$10
.db	$00
.db	ItemID_Cola, $00

.db	$04, $13
.dw Event_flags+$11
.db	$01
.dw	100

.db	$04, $1D
.dw	Event_flags+$12
.db $00
.db	$00, $FC

.db	$05, $5B
.dw	Event_flags+$13
.db $01
.dw	10

.db	$05, $A1
.dw	Event_flags+$14
.db	$01
.dw 5

.db	$05, $A3
.dw	Event_flags+$15
.db	$00
.db	$00, $FF

.db	$05, $DD
.dw	Event_flags+$16
.db	$00
.db	ItemID_Burger, $00

.db $05, $5B
.dw	Event_flags+$17
.db	$01
.dw	100

.db	$05, $A1
.dw	Event_flags+$18
.db	$01
.dw	50

.db	$06, $55
.dw Event_flags+$19
.db	$01
.dw	35

.db	$06, $93
.dw	Event_flags+$1A
.db $00
.db	$00, $FC

.db	$06, $55
.dw	Event_flags+$1B
.db $01
.dw	100

.db	$06, $29
.dw	Event_flags+$1C
.db	$01
.dw 10

.db	$07, $65
.dw	Event_flags+$1D
.db	$00
.db	ItemID_Burger, $00

.db	$07, $AC
.dw	Event_flags+$1E
.db	$01
.dw	100

.db $07, $AC
.dw	Event_flags+$1F
.db	$01
.dw	500

.db	$07, $89
.dw	Event_flags+$20
.db	$00
.db	$00, $FF

.db	$08, $29
.dw Event_flags+$C2
.db	$02
.db	EnemyID_SkullEn, $00

.db	$08, $65
.dw	Event_flags+$C3
.db $02
.db	EnemyID_GiantFly, $00

.db	$08, $C3
.dw	Event_flags+$21
.db $00
.db	ItemID_Burger, $00

.db	$08, $C5
.dw	Event_flags+$22
.db	$01
.dw 50

.db	$08, $EE
.dw	Event_flags+$23
.db	$00
.db	$00, $FF

.db	$09, $64
.dw	Event_flags+$24
.db	$00
.db	ItemID_Cola, $00

.db $09, $EE
.dw	Event_flags+$25
.db	$00
.db	ItemID_Burger, $00

.db	$09, $91
.dw	Event_flags+$26
.db	$00
.db	ItemID_MagicLamp, $00

.db	$0A, $48
.dw Event_flags+$C4
.db	$02
.db	EnemyID_Scorpius, $00

.db	$0A, $61
.dw	Event_flags+$27
.db $00
.db	$00, $FF

.db	$0A, $67
.dw	Event_flags+$C5
.db $02
.db	EnemyID_Medusa, ItemID_LaconiaAxe

.db	$0A, $EE
.dw	Event_flags+$28
.db	$00
.db ItemID_Cola, $00

.db	$0A, $17
.dw	Event_flags+$29
.db	$01
.dw	500

.db $0A, $E3
.dw	Event_flags+$2A
.db	$01
.dw	500

.db $0A, $A9
.dw	Event_flags+$2B
.db	$00
.db	ItemID_Escaper, $00

.db	$0A, $AB
.dw	Event_flags+$2C
.db	$00
.db	$00, $FC

.db	$0B, $71
.dw Event_flags+$2D
.db	$00
.db	ItemID_ShortSword, $00

.db	$0B, $ED
.dw	Event_flags+$2E
.db $00
.db	ItemID_LightSaber, $00

.db	$0B, $1C
.dw	Event_flags+$2F
.db $00
.db	ItemID_Burger, $00

.db	$0B, $63
.dw	Event_flags+$30
.db	$00
.db ItemID_IronSword, $00

.db	$0C, $11
.dw	Event_flags+$31
.db	$00
.db	ItemID_MiracleKey, $FC

.db	$0C, $2B
.dw	Event_flags+$32
.db	$01
.dw	20

.db $0C, $39
.dw	Event_flags+$C6
.db	$02
.db	EnemyID_WereBat, $00

.db	$0C, $85
.dw	Event_flags+$C7
.db	$02
.db	EnemyID_Stalker, $00

.db	$0C, $A9
.dw Event_flags+$C8
.db	$02
.db	EnemyID_Stalker, $00

.db	$0C, $A5
.dw	Event_flags+$33
.db $00
.db	ItemID_Burger, $00

.db	$0D, $68
.dw	Event_flags+$34
.db $01
.dw	100

.db	$0D, $EB
.dw	Event_flags+$35
.db	$00
.db ItemID_IronAxe, $00

.db	$0D, $EE
.dw	Event_flags+$36
.db	$00
.db	$00, $FC

.db	$0D, $68
.dw	Event_flags+$37
.db	$01
.dw	100

.db $0D, $E8
.dw	Event_flags+$38
.db	$00
.db	$00, $FF

.db	$0E, $11
.dw	Event_flags+$39
.db	$00
.db ItemID_Burger, $00

.db	$0E, $41
.dw Event_flags+$3A
.db	$00
.db	$00, $FF

.db	$0E, $AC
.dw	Event_flags+$3B
.db $00
.db	ItemID_Burger, $00

.db	$0E, $E9
.dw	Event_flags+$3C
.db $00
.db	$00, $FC

.db	$0F, $EE
.dw	Event_flags+$3D
.db	$00
.db ItemID_Burger, $00

.db	$10, $1E
.dw	Event_flags+$3E
.db	$00
.db	ItemID_Cola, $00

.db	$10, $8B
.dw	Event_flags+$3F
.db	$00
.db	$00, $FC

.db $10, $61
.dw	Event_flags+$40
.db	$00
.db	ItemID_Flash, $00

.db	$10, $9C
.dw	Event_flags+$41
.db	$00
.db	ItemID_Flash, $00

.db	$10, $C7
.dw Event_flags+$C9
.db	$02
.db	EnemyID_Skeleton, ItemID_IronFang

.db	$10, $D1
.dw	Event_flags+$42
.db	$00
.db	ItemID_Burger, $00

.db	$11, $26
.dw	Event_flags+$43
.db $01
.dw	10

.db	$11, $5E
.dw	Event_flags+$44
.db	$01
.dw 50

.db	$11, $71
.dw	Event_flags+$45
.db	$01
.dw	20

.db $11, $7D
.dw	Event_flags+$46
.db	$01
.dw	20

.db $11, $26
.dw	Event_flags+$47
.db	$01
.dw	20

.db	$12, $19
.dw	Event_flags+$48
.db	$00
.db	$00, $FC

.db	$12, $1E
.dw Event_flags+$49
.db	$00
.db	ItemID_Cola, $00

.db	$12, $CC
.dw	Event_flags+$4A
.db $00
.db	ItemID_Flash, $00

.db	$12, $77
.dw	Event_flags+$4B
.db $00
.db	ItemID_ShortSword, $00

.db	$12, $92
.dw	Event_flags+$4C
.db	$01
.dw 20

.db	$12, $94
.dw	Event_flags+$4D
.db	$00
.db	$00, $FF

.db	$13, $1E
.dw	Event_flags+$4E
.db	$00
.db	ItemID_Cola, $00

.db $13, $33
.dw	Event_flags+$4F
.db	$01
.dw	20

.db	$13, $A5
.dw	Event_flags+$50
.db	$00
.db	$00, $00

.db	$13, $EC
.dw Event_flags+$51
.db	$00
.db	$00, $7F

.db	$13, $EC
.dw	Event_flags+$52
.db $01
.dw	20

.db	$14, $41
.dw	Dialogue_flags+$0D
.db $03
.db	$93, $00

.db	$15, $55
.dw	Dialogue_flags+$0E
.db	$03
.db $91, $0F

.db	$15, $A1
.dw	Dialogue_flags+$0F
.db	$03
.db	$90, $29

.db	$15, $C8
.dw	Dialogue_flags+$18
.db	$03
.db	$16, $00

.db $16, $3E
.dw	Event_flags+$53
.db	$01
.dw	100

.db	$16, $5E
.dw	Event_flags+$54
.db	$00
.db	$00, $FC

.db	$16, $81
.dw Event_flags+$55
.db	$00
.db	ItemID_Flash, $00

.db	$16, $C8
.dw	Event_flags+$56
.db $00
.db	ItemID_Escaper, $00

.db	$17, $AA
.dw	Event_flags+$57
.db $01
.dw	20

.db	$17, $AA
.dw	Event_flags+$58
.db	$01
.dw 200

.db	$18, $16
.dw	Event_flags+$59
.db	$00
.db	$00, $FF

.db	$18, $1C
.dw	Event_flags+$CA
.db	$02
.db	EnemyID_RdSlime, $00

.db $19, $1A
.dw	Event_flags+$5A
.db	$00
.db	$25, $00

.db	$19, $B9
.dw	Event_flags+$5B
.db	$00
.db	$00, $FF

.db	$19, $35
.dw Event_flags+$5C
.db	$01
.dw	100

.db	$19, $C3
.dw	Event_flags+$5D
.db $01
.dw	1

.db	$19, $74
.dw	Event_flags+$5E
.db $00
.db	ItemID_Burger, $00

.db	$19, $A3
.dw	Event_flags+$5F
.db	$00
.db $00, $FC

.db	$1A, $1E
.dw	Event_flags+$60
.db	$00
.db	$00, $FC

.db	$1A, $33
.dw	Event_flags+$61
.db	$01
.dw	20

.db $1A, $51
.dw	Event_flags+$62
.db	$00
.db	ItemID_Burger, $00

.db	$1A, $CB
.dw	Event_flags+$63
.db	$00
.db	$00, $00

.db	$1B, $5A
.dw Event_flags+$CB
.db	$02
.db	EnemyID_RdDragn, ItemID_LaconiaSword

.db	$1B, $E1
.dw	Event_flags+$64
.db $00
.db	ItemID_Burger, $00

.db	$1C, $1E
.dw	Event_flags+$CC
.db $02
.db	EnemyID_RdDragn, $00

.db	$1C, $31
.dw	Event_flags+$65
.db	$01
.dw 2000

.db	$1D, $1B
.dw	Event_flags+$66
.db	$00
.db	ItemID_Flash, $00

.db	$1D, $21
.dw	Event_flags+$67
.db	$00
.db	ItemID_Burger, $00

.db $1D, $41
.dw	Event_flags+$68
.db	$00
.db	ItemID_Burger, $FC

.db	$1D, $8C
.dw	Event_flags+$69
.db	$00
.db	ItemID_Flash, $00

.db	$1D, $CA
.dw Event_flags+$6A
.db	$01
.dw	50

.db	$1D, $B1
.dw	Event_flags+$CD
.db $02
.db	EnemyID_NFarmer, $00

.db	$1E, $1E
.dw	Event_flags+$6B
.db $00
.db	ItemID_Cola, $00

.db	$1E, $11
.dw	Event_flags+$6C
.db	$01
.dw 20

.db	$21, $94
.dw	Dialogue_flags+$11
.db	$03
.db	$9B, $00

.db	$22, $11
.dw	Event_flags+$6D
.db	$01
.dw	500

.db $22, $24
.dw	Dialogue_flags+$12
.db	$03
.db	$9D, $00

.db	$22, $6E
.dw	Event_flags+$6E
.db	$00
.db	$00, $FC

.db	$22, $91
.dw Event_flags+$6F
.db	$00
.db	$00, $FF

.db	$22, $EA
.dw	Event_flags+$70
.db $00
.db	ItemID_TitaniumSword, $00

.db	$22, $EE
.dw	Event_flags+$71
.db $00
.db	$00, $FF

.db	$22, $E3
.dw	Event_flags+$72
.db	$01
.dw 500

.db	$23, $79
.dw	Event_flags+$73
.db	$00
.db	ItemID_Flash, $00

.db	$23, $91
.dw	Event_flags+$74
.db	$00
.db	$00, $FC

.db $23, $C1
.dw	Event_flags+$75
.db	$00
.db	ItemID_Burger, $00

.db	$24, $47
.dw	Event_flags+$76
.db	$01
.dw	3000

.db	$24, $11
.dw Event_flags+$77
.db	$00
.db	ItemID_WhiteMantle, $00

.db	$24, $1E
.dw	Event_flags+$78
.db	$00
.db	ItemID_WoodCane, $00

.db	$24, $EE
.dw	Event_flags+$79
.db $00
.db	ItemID_Cola, $00

.db	$25, $1D
.dw	Event_flags+$CE
.db	$02
.db EnemyID_BlDragn, ItemID_AmberEye

.db	$25, $86
.dw	Event_flags+$7A
.db	$01
.dw	100

.db $25, $8A
.dw	Event_flags+$7B
.db	$00
.db	$00, $FC

.db $25, $3E
.dw	Event_flags+$7C
.db	$01
.dw	100

.db	$26, $7B
.dw	Event_flags+$7D
.db	$01
.dw	5000

.db	$27, $9E
.dw Event_flags+$CF
.db	$02
.db	EnemyID_RdDragn, ItemID_LightSaber

.db	$27, $71
.dw	Event_flags+$7E
.db $01
.dw	500

.db	$28, $D1
.dw	Event_flags+$7F
.db $01
.dw	500

.db	$29, $67
.dw	Event_flags+$D0
.db	$02
.db EnemyID_Zombie, $00

.db	$29, $79
.dw	Event_flags+$D1
.db	$02
.db	EnemyID_Zombie, $00

.db	$29, $99
.dw	Event_flags+$80
.db	$00
.db	ItemID_Burger, $00

.db $29, $A4
.dw	Event_flags+$D2
.db	$02
.db	EnemyID_Wight, $00

.db	$29, $D5
.dw	Event_flags+$D3
.db	$02
.db	EnemyID_Zombie, $00

.db	$2A, $53
.dw Event_flags+$D4
.db	$02
.db	EnemyID_Zombie, $00

.db	$2A, $73
.dw	Event_flags+$D5
.db $02
.db	EnemyID_Zombie, $00

.db	$2A, $B1
.dw	Event_flags+$D6
.db $02
.db	EnemyID_Zombie, $00

.db	$2A, $DB
.dw	Dialogue_flags+$13
.db	$03
.db $A4, $00

.db	$2A, $99
.dw	Event_flags+$81
.db	$00
.db	ItemID_LaconiaArmor, $7F

.db	$2B, $79
.dw	Event_flags+$82
.db	$00
.db	ItemID_Escaper, $00

.db $2C, $45
.dw	Event_flags+$83
.db	$00
.db	$00, $FC

.db	$2C, $ED
.dw	Event_flags+$84
.db	$00
.db	ItemID_Burger, $00

.db	$2C, $4B
.dw Event_flags+$85
.db	$01
.dw	500

.db	$2D, $18
.dw	Event_flags+$86
.db $01
.dw	20

.db	$2D, $83
.dw	Event_flags+$87
.db $00
.db	$24, $00

.db	$2D, $AD
.dw	Event_flags+$88
.db	$00
.db ItemID_Flash, $00

.db	$2D, $E3
.dw	Event_flags+$89
.db	$01
.dw	20

.db $2D, $A3
.dw	Event_flags+$8A
.db	$00
.db	$00, $FF

.db $2F, $11
.dw	Event_flags+$8B
.db	$00
.db	ItemID_LaconiaShield, $7F

.db	$2F, $2B
.dw	Event_flags+$8C
.db	$00
.db	$00, $FF

.db	$2F, $73
.dw Event_flags+$8D
.db	$00
.db	$00, $FC

.db	$2F, $D6
.dw	Event_flags+$8E
.db $01
.dw	100

.db	$32, $3B
.dw	Event_flags+$8F
.db $00
.db	$00, $FC

.db	$33, $19
.dw	Event_flags+$90
.db	$00
.db $00, $FF

.db	$33, $D9
.dw	Event_flags+$D7
.db	$02
.db	EnemyID_Scorpius, $00

.db	$34, $16
.dw	Event_flags+$91
.db	$01
.dw	50

.db $34, $1E
.dw	Event_flags+$92
.db	$00
.db	ItemID_MagicHat, $00

.db	$34, $EE
.dw	Event_flags+$93
.db	$00
.db	ItemID_CeramicShield, $00

.db	$34, $C3
.dw Dialogue_flags+$14
.db	$03
.db	$A6, $00

.db	$35, $C2
.dw	Dialogue_flags+$17
.db $03
.db	$9E, $00

.db	$3A, $79
.dw	Event_flags+$D8
.db $02
.db	EnemyID_Titan, ItemID_AeroPrism

.db	$3A, $82
.dw	Event_flags+$94
.db	$00
.db	ItemID_MagicHat, $00

.db	$FF
; =================================================================


; =================================================================
; Dungeon transition data
; 
; This table determines where you're sent inside a dungeon
;
; 5 bytes per entry
; 	byte 1 = Dungeon ID
; 	byte 2 = Coordinates (YX)
; 	byte 3 = Target Map; $FF means it's a room with an NPC
; 	byte 4 = Y position; if byte 3 = $FF, it holds the dialogue ID
; 	byte 5 = X position; if byte 3 = $FF, it holds the sprite index
; =================================================================
B03_DungeonTransitionData:
.db	$00, $EE, $05, $27, $12
.db $00, $5C, $FF, $7F, $00
.db	$00, $1E, $07, $14, $2D
.db	$00, $EC, $00, $54, $4E
.db	$00, $6A, $00, $12, $79
.db	$00, $14, $00, $07, $74
.db	$01, $34, $FF, $84, $33
.db	$01, $75, $FF, $85, $33
.db	$01, $79, $FF, $81, $00
.db $01, $87, $FF, $86, $33
.db	$01, $8C, $FF, $87, $33
.db	$01, $C5, $FF, $83, $33
.db	$02, $11, $0A, $51, $13
.db	$02, $EE, $0A, $51, $21
.db	$04, $E8, $00, $65, $22
.db	$04, $DA, $FF, $89, $32
.db	$06, $43, $FF, $8A, $32
.db $07, $A8, $FF, $8B, $32
.db	$08, $81, $FF, $8F, $32
.db	$08, $8C, $FF, $01, $00
.db	$0B, $C9, $00, $19, $69
.db	$0F, $C5, $FF, $8E, $32
.db	$0F, $1D, $FE, $B0, $00
.db	$10, $65, $FF, $7C, $2F
.db	$13, $3C, $FF, $80, $33
.db $14, $11, $00, $26, $68
.db	$14, $DB, $00, $29, $69
.db	$14, $49, $FF, $94, $33
.db	$14, $4D, $FF, $95, $33
.db	$14, $63, $FF, $99, $17
.db	$14, $79, $FF, $A8, $3C
.db	$14, $7D, $FF, $97, $33
.db	$14, $83, $FF, $98, $33
.db $14, $A4, $FF, $96, $1B
.db	$15, $3E, $FF, $92, $0F
.db	$15, $CC, $FF, $9A, $32
.db	$16, $11, $00, $30, $18
.db	$16, $1D, $FF, $8C, $33
.db	$16, $EE, $00, $3A, $1B
.db	$19, $2E, $FF, $8D, $32
.db	$1D, $78, $FF, $7E, $00
.db $1F, $CE, $FC, $AB, $00
.db	$21, $51, $0E, $18, $1D
.db	$21, $E4, $0E, $23, $22
.db	$27, $E3, $01, $79, $5D
.db	$27, $EC, $11, $44, $54
.db	$28, $13, $13, $15, $13
.db	$28, $5B, $15, $14, $60
.db	$28, $97, $16, $24, $20
.db $28, $ED, $14, $17, $39
.db	$2B, $76, $FF, $A5, $3C
.db	$2B, $98, $FF, $B1, $3C
.db	$2E, $3D, $FF, $9C, $3D
.db	$2F, $D1, $02, $75, $23
.db	$2F, $DE, $02, $75, $35
.db	$30, $1E, $02, $2B, $5F
.db	$30, $77, $02, $63, $17
.db $30, $89, $02, $38, $5F
.db	$30, $EE, $02, $70, $20
.db	$31, $1D, $02, $38, $43
.db	$31, $E1, $02, $3B, $2B
.db	$32, $49, $02, $49, $10
.db	$32, $EB, $02, $58, $11
.db	$39, $CB, $FD, $9F, $00
.db	$3A, $98, $FF, $B2, $1D
.db $FF
; =================================================================



Palette_Dungeons_B03:
.db	$00, $00, $00, $00, $00, $00, $00
.db $00, $07, $0B, $00, $02, $1F, $03, $07
.db $0B, $18, $1C, $00, $14, $2E, $19, $1D
.db $2E, $34, $38, $00, $20, $3C, $30, $34
.db $38, $30, $34, $00, $10, $38, $10, $20
.db $30, $25, $2A, $00, $10, $3F, $20, $25
.db $2A, $0B, $0F, $00, $06, $3F, $0B, $0F
.db $3F, $1B, $1F, $00, $06, $3F, $17, $1B
.db $1F, $02, $03, $00, $01, $07, $01, $02
.db $03, $38, $3C, $00, $00, $3F, $00, $00
.db $00, $38, $3C, $00, $30, $3F, $34, $38
.db $3C, $08, $0C, $00, $04, $3F, $04, $08
.db $0C

DungeonData_B03:
.db	$19, $5B, $03

DungeonSoundData_B03:
.db	$86, $00, $00, $04
.db $86, $00, $00, $01, $86, $19, $56, $00
.db $91, $19, $53, $00, $91, $19, $5E, $00
.db $91, $19, $53, $00, $91, $19, $55, $00
.db $91, $19, $57, $00, $91, $19, $57, $00
.db $91, $19, $53, $00, $91, $19, $56, $00
.db $91, $19, $56, $00, $91, $19, $55, $00
.db $91, $19, $57, $00, $91, $00, $00, $00
.db $91, $19, $5C, $03, $86, $19, $5C, $03
.db $86, $19, $5C, $03, $86, $19, $5C, $03
.db $86, $00, $00, $02, $86, $00, $00, $02
.db $86, $19, $4D, $03, $86, $19, $4D, $01
.db $91, $19, $5D, $01, $91, $19, $5D, $01
.db $91, $19, $5E, $01, $91, $19, $53, $01
.db $91, $19, $4B, $06, $86, $19, $4B, $06
.db $86, $19, $4B, $06, $86, $19, $54, $05
.db $85, $19, $58, $05, $85, $00, $00, $05
.db $85, $19, $52, $06, $86, $19, $4F, $06
.db $86, $19, $4B, $06, $86, $19, $50, $06
.db $86, $19, $50, $06, $86, $19, $4B, $06
.db $86, $19, $4C, $09, $86, $19, $51, $09
.db $86, $19, $51, $09, $86, $19, $52, $07
.db $91, $19, $4F, $07, $91, $19, $4F, $07
.db $91, $19, $56, $07, $91, $19, $50, $08
.db $86, $19, $51, $08, $86, $19, $4F, $08
.db $86, $19, $5A, $08, $86, $19, $59, $08
.db $86, $19, $59, $08, $86, $19, $55, $05
.db $91, $19, $53, $05, $91, $19, $57, $05
.db $91, $19, $57, $05, $91, $19, $58, $05
.db $91, $19, $59, $09, $86, $19, $01, $0A
.db $91, $19, $01, $02, $91


; =================================================================
; 10 bytes per shop. The first byte is the number of items; 
; then there are 3 bytes per item; the first byte is the item ID; the
; other 2 are the Meseta cost
; =================================================================
B03_ShopData:

; 0 - Unused
.db	0
.db	ItemID_Nothing
.dw	0
.db	ItemID_Nothing
.dw	0
.db	ItemID_Nothing
.dw	0

; 1 - Camineet Armory
.db	$02
.db ItemID_LeatherShield
.dw	30
.db	ItemID_IronShield
.dw	520
.db	ItemID_CeramicShield
.dw	1400

; 2 - Camineet Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db	ItemID_Escaper
.dw	10
.db ItemID_Transfer
.dw	48

; 3 - Camineet First Food Shop
.db	$01
.db	ItemID_Cola
.dw	10
.db	ItemID_Burger
.dw 40
.db	ItemID_Nothing
.dw	0

; 4 - Parolit Armory
.db	$02
.db	ItemID_IronSword
.dw	75
.db ItemID_TitaniumSword
.dw	320
.db	ItemID_CeramicSword
.dw	1120

; 5 - Parolit Second Hand Shop
.db	$02
.db ItemID_Flash
.dw	20
.db	ItemID_Escaper
.dw	10
.db	ItemID_MagicLamp
.dw	1400

; 6 - Parolit First Food Shop
.db $01
.db	ItemID_Cola
.dw	10
.db	ItemID_Burger
.dw	40
.db ItemID_Nothing
.dw	0

; 7 - Scion Armor
.db	$02
.db	ItemID_LeatherArmor
.dw	28
.db	ItemID_LightSuit
.dw 290
.db	ItemID_ZirconiaArmor
.dw	1000

; 8 - Scion Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db ItemID_Transfer
.dw	48
.db	ItemID_Secrets
.dw	200

; 9 - Unused
.db	0
.db	ItemID_Nothing
.dw	0
.db	ItemID_Nothing
.dw	0
.db	ItemID_Nothing
.dw	0

; $A - Palma Spaceport First Food Shop
.db	$01
.db	ItemID_Cola
.dw	10
.db	ItemID_Burger
.dw	40
.db ItemID_Nothing
.dw	0

; $B - Paseo Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db	ItemID_Escaper
.dw 10
.db	ItemID_Passport
.dw	100

; $C - Paseo Armory
.db	$02
.db	ItemID_ShortSword
.dw	30
.db ItemID_ThickFur
.dw	630
.db	ItemID_DiamondArmor
.dw	15000

; $D - Unused
.db	0
.db	ItemID_Nothing
.dw	0
.db	ItemID_Nothing
.dw	0
.db	ItemID_Nothing
.dw	0

; $E - Eppi Armory
.db	$02
.db	ItemID_IronAxe
.dw	64
.db	ItemID_NeedleGun
.dw	400
.db ItemID_BronzeShield
.dw	310

; $F - Gothic Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db	ItemID_Transfer
.dw 48
.db	ItemID_MagicLamp
.dw	1400

; $10 - Loar Armory
.db	$02
.db	ItemID_WhiteMantle
.dw	78
.db ItemID_HeatGun
.dw	1540
.db	ItemID_SilverFang
.dw	1620

; $11 - Abion Armory
.db	$02
.db ItemID_WoodCane
.dw	25
.db	ItemID_IronArmor
.dw	84
.db	ItemID_LaserShield
.dw	4800

; $12 - Abion Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db	ItemID_MagicHat
.dw	20
.db ItemID_MagicLamp
.dw	1400

; $13 - Abion First Food Shop
.db	$02
.db	ItemID_Cola
.dw	10
.db	ItemID_Burger
.dw 40
.db	ItemID_Polymaterial
.dw	1600

; $14 - Uzo First Food Shop
.db	$01
.db	ItemID_Cola
.dw	10
.db ItemID_Burger
.dw	40
.db	ItemID_Nothing
.dw	0

; $15 - Uzo Armory
.db	$02
.db ItemID_HeatGun
.dw	1540
.db	ItemID_LightSaber
.dw	2980
.db	ItemID_CeramicShield
.dw	1400

; $16 - Casba Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db	ItemID_Transfer
.dw	48
.db ItemID_Sphere
.dw	30

; $17 - Casba Vehicle Shop
.db	$00
.db	ItemID_Landrover
.dw	5200
.db	ItemID_Nothing
.dw 0
.db	ItemID_Nothing
.dw	0

; $18 - Skure Armory
.db	$02
.db	ItemID_Wand
.dw	1200
.db	ItemID_LaserGun
.dw	4120
.db	ItemID_Gloves
.dw	3300

; $19 - Skure Second Hand Shop
.db	$02
.db ItemID_Flash
.dw	20
.db	ItemID_MagicHat
.dw	20
.db	ItemID_Sphere
.dw	30

; $1A - Skure First Food Shop
.db $01
.db	ItemID_Cola
.dw	10
.db	ItemID_Burger
.dw	40
.db ItemID_Nothing
.dw	0

; $1B - Twintown Vehicle Shop
.db	$00
.db	ItemID_IceDigger
.dw	12000
.db	ItemID_Nothing
.dw 0
.db	ItemID_Nothing
.dw	0

; $1C - Twintown Second Hand Shop
.db	$02
.db	ItemID_Flash
.dw	20
.db ItemID_Escaper
.dw	10
.db	ItemID_Transfer
.dw	48
; =================================================================


; =================================================================
; 0 means you can't sell the item
ItemSellingPriceData_B03:
.dw	0		; ItemID_Nothing
.dw	12		; ItemID_WoodCane
.dw	15		; ItemID_ShortSword
.dw	37		; ItemID_IronSword
.dw	600		; ItemID_Wand
.dw	350		; ItemID_IronFang
.dw	32		; ItemID_IronAxe
.dw	160		; ItemID_TitaniumSword
.dw	560		; ItemID_CeramicSword
.dw	200		; ItemID_NeedleGun
.dw	810		; ItemID_SilverFang
.dw	770		; ItemID_HeatGun
.dw	1490	; ItemID_LightSaber
.dw	2060	; ItemID_LaserGun
.dw	500		; ItemID_LaconiaSword
.dw	390		; ItemID_LaconiaAxe
.dw	14		; ItemID_LeatherArmor
.dw	39		; ItemID_WhiteMantle
.dw	145		; ItemID_LightSuit
.dw	42		; ItemID_IronArmor
.dw	315		; ItemID_ThickFur
.dw	500		; ItemID_ZirconiaArmor
.dw	7500	; ItemID_DiamondArmor
.dw	490		; ItemID_LaconiaArmor
.dw	420		; ItemID_FradeMantle
.dw	15		; ItemID_LeatherShield
.dw	155		; ItemID_BronzeShield
.dw	260		; ItemID_IronShield
.dw	700		; ItemID_CeramicShield
.dw	1650	; ItemID_Gloves
.dw	2400	; ItemID_LaserShield
.dw	0		; ItemID_MirrorShield
.dw	410		; ItemID_LaconiaShield
.dw	0		; ItemID_Landrover
.dw	0		; ItemID_Hovercraft
.dw	6000	; ItemID_IceDigger
.dw	5		; ItemID_Cola
.dw	20		; ItemID_Burger
.dw	160		; ItemID_Flute
.dw	10		; ItemID_Flash
.dw	5		; ItemID_Escaper
.dw	24		; ItemID_Transfer
.dw	10		; ItemID_MagicHat
.dw	0		; ItemID_Alsulin
.dw	800		; ItemID_Polymaterial
.dw	0		; ItemID_DungeonKey
.dw	15		; ItemID_Sphere
.dw	0		; ItemID_EclipseTorch
.dw	0		; ItemID_AeroPrism
.dw	0		; ItemID_Nuts
.dw	0		; ItemID_Hapsby
.dw	0		; ItemID_RoadPass
.dw	50		; ItemID_Passport
.dw	0		; ItemID_Compass
.dw	140		; ItemID_Cake
.dw	0		; ItemID_Letter
.dw	0		; ItemID_LaconiaPot
.dw	700		; ItemID_MagicLamp
.dw	0		; ItemID_AmberEye
.dw	500		; ItemID_GasShield
.dw	0		; ItemID_Crystal
.dw	0		; ItemID_MSystem
.dw	0		; ItemID_MiracleKey
.dw	0		; ItemID_Zillion
; =================================================================


; -----------------------------------------------------------------
; Level tables
;
; 8 bytes per level
;
; 1 = max HP
; 2 = attack
; 3 = defense
; 4 = max MP
; 5-6 = exp ; it's little endian so you need to read byte 6 first, byte 5 second
; 7 = number of spells available in battle
; 8 = number of spells available outside of battle
; -----------------------------------------------------------------

; =================================================================
B03_AlisLevelTable:
.db	$10, $08, $08, $00, $00, $00, $00, $00	; 1
.db	$14, $0A, $0B, $00, $14, $00, $00, $00	; 2
.db	$19, $0C, $0F, $00, $32, $00, $00, $00	; 3
.db	$22, $0E, $14, $04, $64, $00, $01, $01	; 4
.db	$2D, $0F, $18, $06, $E6, $00, $02, $01	; 5
.db	$36, $12, $1B, $08, $4A, $01, $03, $01	; 6
.db	$42, $15, $1E, $0A, $C2, $01, $03, $01	; 7
.db	$4C, $17, $21, $0C, $58, $02, $03, $01	; 8
.db	$51, $18, $28, $0D, $20, $03, $03, $01	; 9
.db	$5D, $19, $33, $0E, $1A, $04, $03, $01	; 10
.db	$63, $1B, $3C, $0F, $14, $05, $03, $01	; 11
.db	$6F, $1E, $40, $10, $A4, $06, $04, $01	; 12
.db	$7B, $1F, $44, $12, $98, $08, $04, $01	; 13
.db	$84, $22, $4B, $14, $F0, $0A, $05, $01	; 14
.db	$8C, $24, $50, $16, $AC, $0D, $05, $01	; 15
.db	$99, $26, $55, $16, $04, $10, $05, $02	; 16
.db	$9F, $28, $5A, $18, $88, $13, $05, $02	; 17
.db	$A6, $29, $60, $18, $70, $17, $05, $02	; 18
.db	$AD, $2B, $64, $19, $20, $1C, $05, $02	; 19
.db	$B6, $2C, $6B, $19, $34, $21, $05, $02	; 20
.db	$BB, $2E, $6E, $1A, $10, $27, $05, $02	; 21
.db	$C0, $30, $70, $1A, $E0, $2E, $05, $02	; 22
.db	$C8, $31, $71, $1B, $A4, $38, $05, $02	; 23
.db	$CC, $32, $72, $1C, $5C, $44, $05, $02	; 24
.db	$D0, $33, $73, $1D, $D8, $59, $05, $02	; 25
.db	$D2, $34, $77, $1D, $30, $75, $05, $02	; 26
.db	$D4, $35, $75, $1E, $70, $94, $05, $02	; 27
.db	$D6, $36, $76, $1E, $C8, $AF, $05, $02	; 28
.db	$D8, $37, $77, $20, $20, $CB, $05, $02	; 29
.db	$DA, $38, $78, $20, $18, $F6, $05, $02	; 30
; =================================================================


; =================================================================
B03_MyauLevelTable:
.db	$16, $12, $16, $00, $00, $00, $00, $00	; 1
.db	$1E, $15, $1A, $00, $32, $00, $00, $00	; 2
.db	$26, $19, $1F, $00, $78, $00, $00, $00	; 3
.db	$2A, $1C, $22, $00, $DC, $00, $00, $00	; 4
.db	$2C, $1F, $26, $00, $5E, $01, $00, $00	; 5
.db	$36, $23, $29, $0C, $A8, $02, $01, $01	; 6
.db	$3C, $27, $2D, $0F, $B6, $03, $01, $01	; 7
.db	$40, $2A, $35, $11, $7E, $04, $01, $01	; 8
.db	$46, $2D, $37, $13, $78, $05, $02, $01	; 9
.db	$4E, $30, $3C, $15, $A4, $06, $02, $01	; 10
.db	$54, $32, $3F, $16, $34, $08, $02, $01	; 11
.db	$5A, $33, $44, $17, $28, $0A, $03, $01	; 12
.db	$74, $34, $47, $19, $80, $0C, $03, $01	; 13
.db	$76, $38, $4A, $1B, $3C, $0F, $03, $01	; 14
.db	$79, $3B, $50, $1E, $94, $11, $03, $02	; 15
.db	$84, $3D, $55, $22, $50, $14, $03, $02	; 16
.db	$8E, $3F, $59, $24, $D4, $17, $03, $03	; 17
.db	$96, $43, $5F, $26, $58, $1B, $03, $03	; 18
.db	$9B, $46, $64, $28, $08, $20, $03, $03	; 19
.db	$A2, $49, $66, $2C, $1C, $25, $04, $03	; 20
.db	$AF, $4C, $68, $2E, $04, $29, $04, $03	; 21
.db	$B7, $4D, $6A, $2F, $C8, $32, $04, $03	; 22
.db	$C1, $4F, $6C, $30, $98, $3A, $04, $03	; 23
.db	$CA, $50, $70, $31, $50, $46, $04, $03	; 24
.db	$D0, $51, $71, $32, $F0, $55, $04, $03	; 25
.db	$D2, $52, $72, $33, $30, $75, $04, $03	; 26
.db	$D3, $53, $73, $34, $A0, $8C, $04, $03	; 27
.db	$D4, $54, $74, $35, $10, $A4, $04, $03	; 28
.db	$D5, $55, $75, $36, $50, $C3, $04, $03	; 29
.db	$D6, $56, $76, $37, $60, $EA, $04, $03	; 30
; =================================================================


; =================================================================
B03_OdinLevelTable:
.db	$2A, $0D, $0D, $00, $00, $00, $00, $00	; 1
.db	$2F, $0F, $0F, $00, $50, $00, $00, $00	; 2
.db	$34, $11, $11, $00, $A0, $00, $00, $00	; 3
.db	$39, $12, $13, $00, $FA, $00, $00, $00	; 4
.db	$3C, $13, $15, $00, $5E, $01, $00, $00	; 5
.db	$3F, $14, $17, $00, $E0, $01, $00, $00	; 6
.db	$43, $15, $19, $00, $76, $02, $00, $00	; 7
.db	$4B, $17, $1B, $00, $52, $03, $00, $00	; 8
.db	$52, $18, $1D, $00, $4C, $04, $00, $00	; 9
.db	$5E, $19, $1F, $00, $78, $05, $00, $00	; 10
.db	$64, $1A, $22, $00, $08, $07, $00, $00	; 11
.db	$6B, $1B, $25, $00, $FC, $08, $00, $00	; 12
.db	$74, $1C, $28, $00, $B8, $0B, $00, $00	; 13
.db	$81, $1E, $2B, $00, $D8, $0E, $00, $00	; 14
.db	$83, $1F, $2D, $00, $04, $10, $00, $00	; 15
.db	$87, $20, $2F, $00, $88, $13, $00, $00	; 16
.db	$8C, $21, $31, $00, $70, $17, $00, $00	; 17
.db	$93, $23, $35, $00, $E8, $1C, $00, $00	; 18
.db	$96, $24, $38, $00, $28, $23, $00, $00	; 19
.db	$9C, $25, $3D, $00, $04, $29, $00, $00	; 20
.db	$A2, $26, $41, $00, $E0, $2E, $00, $00	; 21
.db	$A9, $27, $42, $00, $BC, $34, $00, $00	; 22
.db	$AF, $28, $43, $00, $8C, $3C, $00, $00	; 23
.db	$B3, $29, $44, $00, $5C, $44, $00, $00	; 24
.db	$BB, $2A, $45, $00, $20, $4E, $00, $00	; 25
.db	$BC, $2B, $46, $00, $60, $6D, $00, $00	; 26
.db	$BD, $2C, $47, $00, $B8, $88, $00, $00	; 27
.db	$BE, $2D, $48, $00, $28, $A0, $00, $00	; 28
.db	$BF, $2E, $49, $00, $50, $C3, $00, $00	; 29
.db	$C0, $2F, $4A, $00, $60, $EA, $00, $00	; 30
; =================================================================


; =================================================================
B03_NoahLevelTable:
.db	$2D, $12, $1E, $0C, $00, $00, $01, $01	; 1
.db	$31, $16, $24, $12, $46, $00, $01, $01	; 2
.db	$36, $17, $29, $16, $96, $00, $01, $01	; 3
.db	$39, $1A, $2F, $19, $FA, $00, $01, $01	; 4
.db	$3D, $1D, $35, $1C, $7C, $01, $01, $01	; 5
.db	$41, $1E, $3C, $20, $08, $02, $01, $02	; 6
.db	$47, $20, $41, $24, $BC, $02, $01, $02	; 7
.db	$4F, $22, $47, $24, $20, $03, $02, $03	; 8
.db	$53, $24, $4B, $29, $84, $03, $02, $03	; 9
.db	$59, $26, $52, $2B, $4C, $04, $02, $03	; 10
.db	$5F, $28, $55, $2E, $78, $05, $02, $03	; 11
.db	$65, $29, $58, $30, $6C, $07, $03, $03	; 12
.db	$6B, $2B, $5C, $31, $C4, $09, $03, $03	; 13
.db	$70, $2D, $60, $32, $E4, $0C, $04, $03	; 14
.db	$76, $2F, $63, $34, $68, $10, $04, $03	; 15
.db	$7C, $30, $64, $36, $B4, $14, $04, $03	; 16
.db	$83, $32, $67, $3A, $64, $19, $04, $04	; 17
.db	$89, $35, $6A, $3E, $60, $22, $05, $04	; 18
.db	$8F, $39, $6C, $42, $10, $27, $05, $04	; 19
.db	$9B, $3C, $6E, $46, $E0, $2E, $05, $05	; 20
.db	$A1, $3E, $70, $48, $B0, $36, $05, $05	; 21
.db	$A8, $40, $73, $4B, $B8, $3D, $05, $05	; 22
.db	$AC, $42, $74, $4C, $50, $46, $05, $05	; 23
.db	$BA, $44, $75, $4D, $2C, $4C, $05, $05	; 24
.db	$BE, $46, $76, $4E, $08, $52, $05, $05	; 25
.db	$BF, $47, $77, $4F, $A8, $61, $05, $05	; 26
.db	$C0, $48, $78, $50, $30, $75, $05, $05	; 27
.db	$C1, $49, $79, $51, $70, $94, $05, $05	; 28
.db	$C2, $4A, $7A, $52, $C8, $AF, $05, $05	; 29
.db	$C3, $4B, $7B, $53, $50, $C3, $05, $05	; 30
; =================================================================



LABEL_B03_BC6F:
.db	$12
.db $12, $12, $12, $12, $12, $12, $22, $22
.db $12, $8A, $8A, $8A, $8A, $22, $13, $13
.db $13, $13, $13, $13, $13, $13, $52, $52
.db $52, $52, $52, $52, $52, $52, $52, $52
.db $12, $12, $12, $12, $B2, $52, $9A, $9A
.db $9A, $9A, $13, $13, $13, $13, $13, $13
.db $13, $13, $13, $13, $1A, $13, $40, $40
.db $40, $40, $41, $41, $41, $41, $41, $41
.db $41, $41, $31, $31, $52, $52, $52, $52
.db $32, $32, $32, $32, $32, $32, $32, $32
.db $32, $1A, $1A, $1A, $1A, $1A, $1A, $1A
.db $1A, $1A, $12, $12, $22, $26, $74, $74
.db $74, $74, $74, $13, $13, $13, $13, $13
.db $13, $53, $53, $5A, $5A, $63, $63, $6A
.db $6A, $13, $13, $13, $13, $9A, $9A, $9A
.db $9A, $1A, $1A, $1A, $1A, $1A, $1A, $1A
.db $1A, $12, $12, $12, $12, $12, $12, $12
.db $12, $12, $12, $12, $12, $12, $12, $12
.db $12, $12, $12, $12, $12, $12, $12, $12
.db $12, $12, $12, $12, $12, $12, $12, $12
.db $12, $12, $12, $12, $12, $12, $12, $12
.db $12, $12, $12, $12, $12, $12, $12, $12
.db $12, $12, $12, $12, $12, $12, $12, $12
.db $12, $13, $13, $13, $13, $13, $13, $13
.db $13, $62, $56, $56, $56, $56, $B6, $12
.db $12, $12, $12, $12, $12, $B6, $B6, $B6
.db $B6, $43, $12, $12, $12, $12, $66, $63
.db $63, $63, $63, $63, $63, $63, $63, $12
.db $12, $12, $12, $12, $12, $12, $12, $1A
.db $1A, $1A, $1A, $12, $12, $12, $62, $C2
.db $12, $43, $43, $43, $43, $6A, $10, $10
.db $10, $10, $10, $10, $10, $10, $10, $82
.db $82, $83, $83, $83, $83, $83, $83, $83
.db $83, $83, $83, $8A, $8A, $83, $83, $8A
.db $8A, $83, $83, $8A, $8A, $83, $83, $8A
.db $8A, $83, $83, $8A, $8A, $83, $83, $8A
.db $8A, $83, $83, $83, $83, $83, $83, $83
.db $83, $83, $82, $82, $83, $83, $83, $83
.db $83, $83, $83, $83, $83, $83, $83, $83
.db $83, $83, $83, $83, $83, $83, $83, $83
.db $83, $83, $83, $83, $83, $8A, $83, $8A
.db $82, $82, $82, $A4, $A3, $A3, $A3, $A3
.db $A3, $A3, $AA, $AA, $AA, $AA, $A2, $A2
.db $A2, $A2, $12, $A3, $A2, $AA, $A2, $83
.db $83, $8A, $8A, $83, $8A, $83, $93, $93
.db $93, $93, $93, $93, $93, $93, $93, $93
.db $93, $93, $93, $93, $93, $93, $92, $93
.db $93, $9A, $9A, $93, $93, $9A, $9A, $93
.db $93, $9A, $9A, $93, $93, $9A, $9A, $93
.db $93, $9A, $9A, $93, $9A, $93, $9A, $93
.db $9A, $A2, $A3, $A2, $AA, $83, $83, $83
.db $83, $1A, $1A, $1A, $1A, $83, $83, $83
.db $83, $83, $8A, $8A, $83, $83, $A2, $A2
.db $A2, $92, $92, $92, $16

LABEL_B03_BE1D:
.db	$3C, $38, $3C
.db $3C, $3F, $3C, $38, $38, $3E, $3C, $3E
.db $3E, $3F, $3E, $3C, $3C, $3F, $3E, $3F
.db $3F, $3F, $3F, $3E, $3E, $3F, $2B, $0F
.db $2F, $2F, $3E, $3C, $0F, $2F, $06, $0B
.db $1F, $0F, $3C, $38, $0B, $2B, $01, $06
.db $0F, $0B, $2A, $25, $06

LABEL_B03_BE4D:
.db	$0C, $08, $04
.db $03, $0B

LABEL_B03_BE52:
.db	$34, $38, $35, $3C, $38, $3E
.db $3C, $3E, $3D, $3E, $2C, $3E, $1E, $3E
.db $0C, $3E, $0E, $3E, $0F, $3E, $1B, $3E
.db $0B, $3E, $07, $3E, $27, $3E, $37, $3E
.db $3B, $3E, $3A, $3E, $36, $3E, $35, $3E
.db $34, $3E, $38, $3E, $35, $3C, $34, $38
.db $30, $2A

LABEL_B03_BE82:
.db	$34, $34, $34, $34, $34, $34
.db $35, $35, $35, $35, $35, $35, $38, $38
.db $38, $38, $38, $38, $38, $38, $38, $38
.db $3C, $38, $38, $3C, $38, $3C, $3E, $38
.db $38, $3E, $3C, $3E, $3F, $38, $3C, $3F
.db $3E, $3F, $3F, $3C, $3E, $3F, $3F, $3F
.db $3F, $3E, $3F, $3F, $3F, $3F, $3F, $3F
.db $2F, $3F, $2F, $3F, $3F, $3D, $1F, $2F
.db $0F, $2F, $3F, $2C, $1A, $0F, $0B, $1F
.db $2F, $2C, $15, $0B, $06, $1A, $2F, $28

LABEL_B03_BED0:
.db $30, $2A, $34, $38, $38, $3E, $3C, $3E
.db $3E, $3F, $3F, $3F, $3E, $3F, $3C, $3E
.db $38, $3E