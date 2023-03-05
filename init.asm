.286
.model tiny
.code

extrn	ScreenDrawer:proc
extrn	KeyboardHandler:proc
extrn	IRQ0DfltOffs:word
extrn	IRQ0DfltSeg:word
extrn	IRQ1DfltOffs:word
extrn	IRQ1DfltSeg:word

public	InitAndTSR

ResidentEnd:

;----------------------------------------------------------------------------------------------------
; Initializes program state and calls TSR interrupt. Never returns
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		N/A
; Destroys:	N/A
;----------------------------------------------------------------------------------------------------
InitAndTSR	proc

		xor		bx,		bx
		mov		es,		bx
		mov		bx,		8d * 4			; IRQ0/INT 8h
		mov		dx,		cs

		cli
		
		mov		ax,		es:[bx]
		mov word ptr	IRQ0DfltOffs,	ax
		mov word ptr	es:[bx],	offset ScreenDrawer	; set IRQ0 handler

		mov		ax,		es:[bx+2]
		mov word ptr	IRQ0DfltSeg,	ax
		mov word ptr	es:[bx+2],	dx			; set IRQ0 handler segment

		add		bx,		4			; IRQ1/INT 9h

		mov		ax,		es:[bx]
		mov word ptr	IRQ1DfltOffs,	ax
		mov word ptr	es:[bx],	offset KeyboardHandler	; set IRQ1 handler

		mov		ax,		es:[bx+2]
		mov word ptr	IRQ1DfltSeg,	ax
		mov word ptr	es:[bx+2],	dx			; set IRQ1 handler segment

		sti

		int		08h

		mov		dx, offset	ResidentEnd
		shr		dx,		4h		; / 16
		inc		dx
		mov		ax,		3100h		; TSR

		int		21h

		endp
;----------------------------------------------------------------------------------------------------

end
