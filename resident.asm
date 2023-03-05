.286
.model tiny
.code

org 100h

extrn	PrintHex:proc
extrn	InitAndTSR:proc

include stdmacro.asm
include vidmacro.asm

public ScreenDrawer, KeyboardHandler, IRQ0DfltOffs, IRQ0DfltSeg, IRQ1DfltOffs, IRQ1DfltSeg

Start:		call InitAndTSR		; noreturn

;----------------------------------------------------------------------------------------------------
; Notifies INTC that the interrupt has been successfully handled
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		None
; Destroys:	AL
;----------------------------------------------------------------------------------------------------
.handle_intr	macro

		.do_nop

		mov		al,		20h
		out		20h,		al

		.do_nop

		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Notifies PPI that key has been accepted
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		None
; Destroys:	AL
;----------------------------------------------------------------------------------------------------
.blink_ppi	macro

		.do_nop
		
		in	al,	61h
		or	al,	08h
		out	61h,	al
		and	al,	not 08h
		out	61h,	al
		
		.do_nop

		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Draws frame containing register values. Connected to IRQ0
;----------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------
DrawScreen	db 00h

ScreenDrawer	proc

		push		bp
		mov		bp,		sp		; new stack frame

		push		ax bx cx dx si di ds es

		mov		al, byte ptr	cs:[DrawScreen]
		and		al,		01h
		jnz		@@Draw
		jmp		@@DrawEnd

@@Draw:		mov		ax,		ss:[bp-2]	; restore old ax
		push		ax
		push		bx
		push		cx
		push		dx
		push		si
		push		di

		mov		ax,		ss:[bp]
		push		ax			; old bp

		mov		ax,		bp
		sub		ax,		02h
		push		ax			; old sp

		push		ds	
		push		es
		push		ss
		push		cs

		push		cs
		pop		ds		; ds = cs

		.load_vbuf_es

		xor		di,		di
		.load_xy	73d,		14d
		.get_offset

		mov		cx,		12d

@@PrintRegs:	pop		bx
		mov		ax,		7900h
		push		cx
		call		PrintHex

		sub		di,		2*80d

		pop		cx
		loop		@@PrintRegs

@@DrawEnd:	pop		es ds di si dx cx bx ax

		mov		sp,		bp			; restore stack frame
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

		mov		ax,		0200h
		int		16h

		and		al,		08h
		jnz		@@CheckKey
		jmp		@@KeybDflt

@@CheckKey:	in		al,		60h
		cmp		al,		13h	; 'R' key
		je		@@ChangeState
		jmp		@@KeybDflt

@@ChangeState:	mov		al, byte ptr	DrawScreen
		xor		al,		01h	; flip last bit
		mov byte ptr	DrawScreen,	al

		.blink_ppi
		.handle_intr

		pop		ds es di si dx cx bx ax
		iret

@@KeybDflt:	pop		ds es di si dx cx bx ax

		; jump to default interrupt
		db 0EAh		; `jmp far` instruction code
IRQ1DfltOffs	dw ?
IRQ1DfltSeg	dw ?

		endp
;----------------------------------------------------------------------------------------------------



end Start
