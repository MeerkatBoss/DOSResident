.286
.model tiny
.code

org 100h

extrn	PrintHex:proc
extrn	InitAndTSR:proc
extrn	LoadTemplate:proc
extrn	RestoreVidMem:proc
extrn	UpdSavedVidMem:proc
extrn	DrawToVidMem:proc

extrn	DrawBuffer:word

include stdmacro.asm

include vidmacro.asm

include bufconst.asm

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
; State variable
ST_CHANGED	equ 02h
ST_DRAW		equ 01h
DrawState	db  03h
;----------------------------------------------------------------------------------------------------

ScreenDrawer	proc

		push		bp
		mov		bp,		sp		; new stack frame

		push		ax bx cx dx si di ds es

		mov		al, byte ptr	cs:[DrawState]
		and		al,		ST_DRAW		; need to draw?
		jnz		@@Draw
		jmp		@@NoDraw

@@Draw:		mov		ax,		ss:[bp-2]	; restore old ax
		push		ax bx cx dx si di		; push general-usage regs

		mov		ax,		ss:[bp]
		push		ax				; old bp

		mov		ax,		bp
		sub		ax,		02h
		push		ax				; old sp (= bp-2)

		push		ds es ss cs			; push segment regs

		push		cs
		pop		ds				; ds = cs for tiny model

		mov		al, byte ptr	cs:[DrawState]
		and		al,		ST_CHANGED
		jz		@@NoUpdate

		call		LoadTemplate
		mov		al,		01h
		mov byte ptr	[DrawState],	al


@@NoUpdate:	.load_vbuf_es
		xor		di,		di
		.load_xy	68d,		1d
		.get_offset
		call		UpdSavedVidMem

		push		ds
		pop		es				; es = ds for access to DrawBuffer

		lea		di,		DrawBuffer+FIRSTNUMOFFS
		add		di,		11d*2d*ROWLEN

		mov		cx,		12d

@@PrintRegs:	pop		bx
		mov		ax,		7900h
		push		cx
		call		PrintHex

		sub		di,		2*ROWLEN

		pop		cx
		loop		@@PrintRegs

		.load_vbuf_es
		xor		di,		di
		.load_xy	68d,		1d
		.get_offset
		call		DrawToVidMem

		jmp		@@DrawEnd

@@NoDraw:	mov		al, byte ptr	cs:[DrawState]
		and		al,		ST_CHANGED
		jz		@@DrawEnd

		push		cs
		pop		ds		; ds = es for tiny model

		.load_vbuf_es
		xor		di,		di
		.load_xy	68d,		1d
		.get_offset
		call		RestoreVidMem

		xor		al,		al
		mov byte ptr	[DrawState],	al

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

@@ChangeState:	mov		al, byte ptr	DrawState
		xor		al,		ST_DRAW		; flip DRAW state bit
		or		al,		ST_CHANGED	; set CHANGED state bit
		mov byte ptr	DrawState,	al

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
