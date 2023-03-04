;====================================================================================================
; vidmacro.asm
;====================================================================================================
; Provides:
;	constants:	VBUFSEGMENT
;			SCRWIDTH
;			SCRHEIGHT
;			VBUFSIZE
;			SCRMID
;	macros:		.load_vbuf_es
;			.load_xy
;			.get_offset
;====================================================================================================
; Depends:	stdmacro.asm
;====================================================================================================


VBUFSEGMENT	equ 0B800h
SCRWIDTH	equ 80d
SCRHEIGHT	equ 25d
VBUFSIZE	equ SCRHEIGHT * SCRWIDTH
SCRMID		equ VBUFSIZE/2

;----------------------------------------------------------------------------------------------------
; Stores VBUFSEGMENT into ES
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		ES = VBUFSEGMENT
; Destr:	BX			; TODO: remove dummy params, make it .load_segment_const es, VBUF...
;----------------------------------------------------------------------------------------------------
.load_vbuf_es	macro
		.do_nop
		
		mov		bx,		VBUFSEGMENT
		mov		es,		bx
		
		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Store x and y combined in AX register
;----------------------------------------------------------------------------------------------------
; Entry:	x, y
; Exit:		AH	= x
;		AL	= y
; Destroys:	None                 TODO: Make ax param of .load_xy? .load_xy ax, x, y
;----------------------------------------------------------------------------------------------------
.load_xy	macro x, y
		.do_nop

		mov		ax,		(((x) and 0FFh) shl 8) or ((y) and 0FFh)

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Offset position in video memory by x horizontally and by y vertically
;----------------------------------------------------------------------------------------------------
; Entry:	AH	- x offset 
;		AL	- y offset
;		DI	- initial offset in video memory
; Exit:		DI	- new offset in video memory
; Destroys:	AX, DX
;----------------------------------------------------------------------------------------------------
.get_offset	macro
		.do_nop

		push		ax

		shl		ax,		8h
		sar		ax,		8h		; fill sign bit

		mov		dx,		ax		; copy to dx

		shl		ax,		2h
		add		ax,		dx
		shl		ax,		5h		; ax*A0h = ax * 160 = (4*ax + ax)*32

		add		di,		ax		; adjust y-coordinate

		pop		ax

		sar		ax,		8h
		shl		ax,		1h
		add		di,		ax		; adjust x-coordinate

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------
