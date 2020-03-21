.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
lowbyte: .res 1
hibyte:  .res 1

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
  LDX #$00
  LDY #$00
  LDA #.lobyte(nametable1)
  STA lowbyte
  LDA #.hibyte(nametable1)
  STA hibyte
load_backgroundLoop:
  LDA (lowbyte),Y
  STA $2007
  INY
  CPY #$FF
  BNE load_backgroundLoop
  LDA hibyte
  CLC
  ADC #$01
  STA hibyte
  INX
  CPX #$04
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
.byte $65, $19, $09, $0f
.byte $23, $01, $05, $35
.byte $23, $01, $05, $35
.byte $23, $01, $05, $35

attribute:
.byte %00000000, %00010000, %0010000, %00010000, %00000000, %00000000, %00000000, %00110000
.include "nametable1.asm"
.include "attributes.asm"
