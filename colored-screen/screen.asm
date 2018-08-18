; START of iNES Header -> giving relevant information about the game to the NES
	.inesprg 1	; 1x 16KB bank of PRG code
	.ineschr 1	; 1x 8KB bank of chr data
	.inesmap 0	; mapper 0 = NROM, no bank swapping
	.inesmir 1	; background mirroring
; END of iNES Header


	; The NES arranges everything in 8KB code and 8KB graphics banks.
	.bank 0
	.org $C000
RESET:
	SEI	; disable IRQs
	CLD	; disable decimal mode
	
	LDA #%10000000	; Write PPUMASK -> blue color
	STA $2001
	
Forever:
	JMP Forever
	
NMI:
	RTI ; just return do nothing
	
	; Sometimes the NES will interrupt the program flow when certain things happen
	; In order to tell what should happen Vectors are required
	; NMI Vector: This happens once per frame (VBlank happens) -> you can do graphic updates
	; RESET Vector: Happens when the NES starts up or the Reset button is pressed
	; IRQ Vector: Is triggered from some mapper chips or audio interrupts
	; The vectors are defined via .dw (Data Word -> 1 Word  - 2 bytes)
	.bank 1
	.org $FFFA
	.dw NMI
	.dw RESET
	.dw 0	
	

	.bank 2
	.org $0000
	
	; We need to make the .NES file size match the iNES header
	;so we need to include an 8KB graphics file
	.incbin "mario.chr"	; includes an 8KB graphics file from SMB1