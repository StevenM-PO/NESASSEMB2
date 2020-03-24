spriteTable:
;Begin Paddle
paddlePosX:
.byte $18 ;Starting X-position (0)
paddleGrph:
.byte $05, $06, $05 ;graphics (1-3)
paddleAtt:
.byte $01, $01, $81
paddlePosY:
.byte $60, $68, $70
opnPosX:
.byte $E0
opnAtt:
.byte $42, $42, $C2
;End Paddle

;Ball
ballSprite:
.byte $68, $01, $03, $80
