PaddleSprites_0_data:

	.byte   0,  0,$05,1
	.byte   0,  8,$06,1
	.byte   0, 16,$05,1|OAM_FLIP_V
	.byte 128

PaddleSprites_1_data:

	.byte   0,  0,$05,1|OAM_FLIP_H
	.byte   0,  8,$06,1|OAM_FLIP_H
	.byte   0, 16,$05,1|OAM_FLIP_H|OAM_FLIP_V
	.byte 128

PaddleSprites_pointers:

	.word PaddleSprites_0_data
	.word PaddleSprites_1_data
