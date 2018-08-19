; Start iNES Header
	.inesprg 1	; 16KB of program rom
	.ineschr 1	; 8KB of chr rom
	.inesmap 0	; mapper 0 = NROM, no bank swapping
	.inesmir 1	; background mirroring
; End iNES Header

	.bank 0
	.org $C000
	
RESET:
	SEI 		; disable IRQs
	CLD			; disable decimal mode
	
	LDA $2002	; read the PPU status to reset the high/low latch to high
	LDA #$3F
	STA $2006	; write the high byte of $3F10 address
	LDA #$10
	STA $2006	; write the low byte of $3F10 address
	
	; Load the palette data
	LDX #$00	; start out at 0
	
LoadPalettesLoop:
	LDA PaletteData, x	; load data from address (PaletteData + the value in x)
	STA $2007			; write to PPU
	INX
	CPX #$20			; Compare x to hex $20, decimal 32
	BNE LoadPalettesLoop
	
	; set up sprites
	LDX #$00
SpriteRenderLoop:
	LDA SpriteMetaData, x
	STA $0200, x
	INX
	CPX #$C0			; Compare x to hex $C0, decimal 12
	BNE SpriteRenderLoop

	LDA #%10000000		; enable NMI, sprites from pattern table 0
	STA $2000
	
	LDA #%00010000		; no intensify (black background), enable sprites
	STA $2001
	
	
	
Forever:
	JMP Forever
	
NMI:
	; start sprite dma. This will copy all 64 sprites (4 bytes per sprite) to the
	; PPU memory (the onboard RAM $0200-$02FF is used for this).
	LDA #$00
	STA $2003	; set the low byte (00) of the RAM address
	LDA #$02
	STA $4014	; set the high byte (02) of the RAM address, start the transfer
	
	
	
	.bank 1
	.org $E000
	
PaletteData:
	.db $0F, $31, $32, $33, $0F, $35, $36, $37, $0F, $39, $3A, $3B, $0F, $3D, $3E, $0F	; background palette data
	.db $0F, $1C, $15, $14, $0F, $02, $38, $3C, $0F, $1C, $15, $14, $0F, $02, $38, $3C	; sprite palette data
	
SpriteMetaData:
	.db $80, $32, $01, $80	; sprite 0
	.db $80, $33, $01, $88	; sprite 1
	.db $88, $42, $01, $80	; sprite 2
	.db $88, $43, $01, $88	; sprite 3

	.org $FFFA
	.dw NMI
	.dw RESET
	.dw 0
	
	.bank 2
	.org $0000
	.incbin "mario.chr"
	