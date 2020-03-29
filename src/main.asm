.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
adrLowByte:       .res 1
adrHiByte:        .res 1
countLoByte:      .res 1
countHiByte:      .res 1
ballDirection:    .res 1
gameState:        .res 1
playerPosX:       .res 1
playerPosY:       .res 1
oppntPosX:        .res 1
oppntPosY:        .res 1
ballX:            .res 1
ballY:            .res 1
controllerInput:  .res 1
;collision boxes
playerBoxUpper:   .res 1
playerBoxMiddle:  .res 1
playerBoxLower:   .res 1
oppnBoxUpper:     .res 1
oppnBoxMiddle:    .res 1
oppnBoxLower:     .res 1
ballBoxY:         .res 1
ballBoxX:         .res 1
;ball speeds
ballDirX:         .res 1
ballDirY:         .res 1
ballspeed:        .res 1

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
  STA $2005
  STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX PPUSTATUS
  LDX #$3F
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDX #$00
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$10
  BNE load_palettes
  LDX #$00
load_spritePalettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$10
  BNE load_spritePalettes
  LDX #$00
load_background:
  LDA PPUSTATUS
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDX #.lobyte(nametable1)
  STX adrLowByte
  LDX #.hibyte(nametable1)
  STX adrHiByte
  LDX #$00
  LDY #$00
  STY countLoByte
load_backgroundLoop:
  LDA (adrLowByte),Y
  STA $2007
  CMP #$FF
  INC adrLowByte
  BEQ increaseHigh
  INX
  CPX #$00
  BNE load_backgroundLoop
  INC countLoByte
  LDA countLoByte
  CMP #$07
  BNE load_backgroundLoop
  JMP load_attribute
increaseHigh:
  INC adrHiByte
  JMP load_backgroundLoop

load_attribute:
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$C0
  STA PPUADDR
  LDX #$00
load_attribute_loop:
  LDA attribute,X
  STA PPUDATA
  INX
  CPX #$40
  BNE load_attribute_loop
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait
  LDA #%10010000
  STA PPUCTRL
  LDA #%00111110
  STA PPUMASK

;gameLoop start
gameLoop:
  LDA gameState
  CMP #$00
  BEQ load
  CMP #$01
  BEQ play
  CMP #$02
  BEQ score
  CMP #$03
  BEQ endgame
load:
  LDX #$00
  LDY #$00
loadPlayer:
;X increments 1 to count iteration
;Y increments 4 to count iteration + offset
  LDA paddlePosY,X
  STA $0200,Y
  STA $0200+12,Y
  LDA paddleGrph,X
  STA $0201,Y
  STA $020D,Y
  LDA paddleAtt,X
  STA $0202,Y
  LDA opnAtt,X
  STA $020E,Y
  LDA paddlePosX
  STA $0203,Y
  LDA opnPosX
  STA $020F,Y
  INX
  CPX #$03
  BEQ loadBall
  CLC
  TYA
  ADC #$04
  TAY
  JMP loadPlayer
loadBall:
  LDX #$03
  STX ballspeed
  LDX #$00
  STX ballDirX
  STX ballDirY
loadBallLoop:
  LDA ballSprite,X
  STA $0218,X
  INX
  CPX #04
  BNE loadBallLoop
;playstart

  LDA paddlePosY
  STA playerPosY
  STA oppntPosY
  LDA ballSprite
  STA ballY
  LDA ballSprite+3
  STA ballX
  LDA #$01
  STA gameState
play:
  JSR updateSprites
  JSR LatchController
  LDA playerPosY
  JSR calcPlayer
  JSR calBall
  JSR moveBall




score:
endgame:


  JMP vblankwait

;subroutines
LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016

  JSR readNextInput
  BEQ a_noPress
a_noPress:

  JSR readNextInput
  BEQ b_noPress
b_noPress:

  JSR readNextInput
  BEQ sel_noPress
sel_noPress:

  JSR readNextInput
  BEQ strt_noPress
strt_noPress:

  JSR readNextInput
  BEQ up_noPress
  JSR PmoveUp
up_noPress:

  JSR readNextInput
  BEQ dwn_noPress
  JSR PmoveDown
dwn_noPress:

  JSR readNextInput
  BEQ lft_noPress
lft_noPress:

  JSR readNextInput
  BEQ rgt_noPress
rgt_noPress:
  RTS

readNextInput:
  LDA PLAYER1
  AND #%00000001
  RTS
;end controller
PmoveUp:
  LDA playerPosY
  SEC
  SBC #$02
  CMP #$10
  BCC clampLow
  STA playerPosY
  RTS
PmoveDown:
  LDA playerPosY
  CLC
  ADC #$02
  CMP #$C8
  BCS clampHi
  STA playerPosY
  RTS
updateSprites:
  LDA playerPosY
  STA $0200
  CLC
  ADC #$08
  STA $0200+4
  ADC #$08
  STA $0200+8
  LDA oppntPosY
  STA $020C
  CLC
  ADC #$08
  STA $020C+4
  ADC #$08
  STA $020C+8
  LDA ballY
  STA $0218
  LDA ballX
  STA $021B
  RTS

;Ball subroutines
moveBall:
  LDA ballDirX
  CMP #$01
  BEQ ballLeft
  LDA ballX
  CLC
  ADC ballspeed
  STA ballX
  LDA ballDirY
  CMP #$01
  BEQ ballUp
  CMP #$02
  BEQ ballDown
  RTS
ballDown:
  LDA ballY
  CLC
  ADC ballspeed
  STA ballY
  RTS
ballLeft:
  LDA ballX
  SEC
  SBC ballspeed
  STA ballX
  RTS
ballUp:
  LDA ballY
  SEC
  SBC ballspeed
  STA ballY
  RTS

;Math stuff
clampLow:
  LDA #$10
  RTS
clampHi:
  LDA #$C8
  RTS
;bounding boxes
calcPlayer:
  LSR A
  LSR A
  LSR A
  STA playerBoxUpper
  CLC
  ADC #$01
  STA playerBoxMiddle
  ADC #$01
  STA playerBoxLower
  RTS
calBall:
  LDA ballY
  CLC
  ADC #$04
  LSR A
  LSR A
  LSR A
  STA ballBoxY
  LDA ballX
  LSR A
  LSR A
  LSR A
  STA ballBoxX
  RTS

;end math stuff

.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"

.segment "RODATA"
palettes:
.byte $0F, $00, $10, $30
.byte $0F, $01, $21, $31
.byte $0F, $06, $16, $26
.byte $0F, $09, $19, $29
.include "attribute.asm"
.include "nametable1.asm"
.include "spriteTable.asm"
