;====================================================================================================
; stdio.asm
;====================================================================================================
.286
.model tiny
.code
include stdmacro.asm

locals @@

public PrintHex

;----------------------------------------------------------------------------------------------------
; Prints number in hex
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- video address to print to
;		AH	- symbol attribute
;		BX	- number to print
; Exit:		None
; Destr:	AL, BX, CX, SI, DF
;----------------------------------------------------------------------------------------------------
PrintHex	proc

		add		di,		06h
		std

		mov		cx,		04h

@@PrintLoop:	mov		si,		bx	
		and		si,		0Fh

		mov		al,    byte ptr	[HexDigits+si]

		stosw
		
		shr		bx,		4h
		loop		@@PrintLoop

		add		di,		02h
		
		ret

HexDigits	db 	'0123456789ABCDEF'

		endp
;----------------------------------------------------------------------------------------------------


end
