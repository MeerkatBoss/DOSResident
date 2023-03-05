.286
.model tiny
.code

include stdmacro.asm

include vidmacro.asm

extrn	PrintHex:proc

public	InitAndTSR

DrawScreen	db 0

;----------------------------------------------------------------------------------------------------
; Notifies INTC that the interrupt has been successfully handled
;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
.handle_intr	macro

		.do_nop

		mov		al,		20h
		out		20h,		al

		.do_nop

		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Draws frame containing register values. Connected to IRQ0
;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
ScreenDrawer	proc

		push		bp
		mov		bp,		sp

		push		ax bx cx dx si di ds es

;		mov		ax,		[bp]
;		mov		[bp-14],	ax	; Correct BP on stack
;		mov		ax,		bp
;		add		ax,		02h
;		mov		[bp-18],	ax	; Correct SP on stack

		push		ss
		pop		ds		; ds = ss
		
		push		ax
		push		bx
		push		cx
		push		dx
		push		si
		push		di

		mov		ax,		[bp]
		push		ax			; old bp

		mov		ax,		bp
		sub		ax,		02h
		push		ax			; old sp

		mov		ax,		[bp-7d*2]
		push		ax			; old ds
		
		push		es
		push		ss
		push		cs

		push		cs
		pop		ds		; ds = cs

		.load_vbuf_es

		xor		di,		di
		.load_xy	73d,		14d
		.get_offset

;		mov		ax,		7900h
;		pop		bx
;		call		PrintHex

;		jmp		@@DrawEnd

		mov		cx,		12d

@@PrintRegs:	;mov		bx,		cx
		;shl		bx,		01h
		;neg		bx
		;add		bx,		bp		; bx = bp - 2*cx

		;mov		bx, word ptr	[bx]		; bx = [bp - 2*cx]
		pop		bx
		mov		ax,		7900h
		push		cx
		call		PrintHex

		sub		di,		2*80d

		pop		cx
		loop		@@PrintRegs

		;.handle_intr

;			[IGNORE]cs ss es ds sp bp di si dx cx bx ax
@@DrawEnd:	pop		es ds di si dx cx bx ax	; [IGNORE] do not restore cs and ss

		mov		sp,		bp			; bp and sp handled separately
		pop		bp

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

		push		ax bx cx dx si di es ds

		push		cs
		pop		ds

		.load_vbuf_es

		xor		di,		di
		.load_xy	73d,		1d
		.get_offset

		in		al,		60h		; read symbol
		and		ax,		0FFh		; lower byte

		mov		bx,		ax
		mov		ax,		3D00h		; magenta on cyan
		call		PrintHex

		pop		ds es di si dx cx bx ax

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

		int		08h

		mov		dx, offset	ResidentEnd
		shr		dx,		4h		; / 16
		inc		dx
		mov		ax,		3100h		; TSR

		int		21h

		endp
;----------------------------------------------------------------------------------------------------

end
