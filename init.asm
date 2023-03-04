.286
.model tiny
.code

include stdmacro.asm

include vidmacro.asm

extrn	PrintHex:proc

public	InitAndTSR

;----------------------------------------------------------------------------------------------------
; Draws frame containing register values. Connected to IRQ0
;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
ScreenDrawer	proc

		; jump to default interrupt
		db 0EAh		; `jmp far` instruction code
IRQ0DfltOffs	dw ?
IRQ0DfltSeg	dw ?

		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Reacts to keyboard events to activate/deactivate resident program
;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
KeyboardHandler	proc

		push		ax bx dx si di es ds

		push		cs
		pop		ds

		.load_vbuf_es

		xor		di,		di
		.load_xy	76d,		1d
		.get_offset

		in		al,		60h		; read symbol
		and		ax,		0FFh		; lower byte

		mov		bx,		ax
		mov		ax,		3D00h		; magenta on cyan
		call		PrintHex

		pop		ds es di si dx bx ax

		; jump to default interrupt
		db 0EAh		; `jmp far` instruction code
IRQ1DfltOffs	dw ?
IRQ1DfltSeg	dw ?

		endp
;----------------------------------------------------------------------------------------------------

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

		mov		dx, offset	ResidentEnd
		shr		dx,		4h		; / 16
		inc		dx
		mov		ax,		3100h		; TSR

		int		21h

		endp
;----------------------------------------------------------------------------------------------------



end
