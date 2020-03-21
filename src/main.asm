.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
adrLowByte:   .res 1
adrHiByte:    .res 1
countLoByte:  .res 1
countHiByte:  .res 1

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
  LDX #$04
  STX countHiByte
  LDY #$00
  STY countLoByte
load_backgroundLoop:
  LDA (adrLowByte),Y
  STA $2007
  CLC
  LDA adrLowByte
  ADC #$01
  STA adrLowByte
  LDA adrHiByte
  ADC #$00
  STA adrHiByte

  LDA countLoByte
  SEC
  SBC #$01
  STA countLoByte
  LDA countHiByte
  SBC #$00
  STA countHiByte

  LDA countLoByte
  CMP #$00
  BNE load_backgroundLoop
  LDA countHiByte
  CMP #$00
  BNE load_backgroundLoop



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

  JMP vblankwait
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
