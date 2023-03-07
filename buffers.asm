.286
.model tiny
.code

locals @@

public	LoadTemplate, RestoreVidMem, UpdSavedVidMem, DrawToVidMem, DrawBuffer

include bufconst.asm

;----------------------------------------------------------------------------------------------------
; Loads template into both buffers
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		None
; Destroys:	AX, CX,	SI, DI, ES, DF
;----------------------------------------------------------------------------------------------------
LoadTemplate	proc

		cld

		push		ds
		pop		es		; es = ds

		lea		di, 		DrawBuffer
		lea		si, 		FrameTemplate

		mov		cx,		TEMPLATELEN

		mov		ah,		79h

@@LoopDrawBuf:	lodsb
		stosw
		loop		@@LoopDrawBuf

		lea		di, 		SaveBuffer
		lea		si, 		FrameTemplate

		mov		cx,		TEMPLATELEN
	
@@LoopSaveBuf:	lodsb
		stosw
		loop		@@LoopSaveBuf

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Restores video memory from saved state
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	video memory address, which should be restored
; Exit:		None
; Destroys:	AX, CX, DI, SI, DF
;----------------------------------------------------------------------------------------------------
RestoreVidMem	proc

		cld

		lea		si,		SaveBuffer

;		mov		ax,		es
;		mov		cx,		ds
;		mov		es,		cx
;		mov		ds,		ax		; exchange es and ds for movsw

		mov		cx,		ROWCOUNT

@@NextRow:	push		cx

		push		di

		mov		cx,		ROWLEN
		rep		movsw				; copy row

		pop		di
		add		di,		2*80d		; next row

		pop		cx
		loop		@@NextRow

;		mov		ax,		es
;		mov		cx,		ds
;		mov		es,		cx
;		mov		ds,		ax		; restore es and ds

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Updates saved video memory by comparing it with draw buffer
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	video memory address to be saved
; Exit:		None
; Destroys:	AX, BX, CX, DX, DI, SI
;----------------------------------------------------------------------------------------------------
UpdSavedVidMem	proc

		mov		si,		di
		lea		bx,		DrawBuffer

		lea		di,		SaveBuffer

		mov		cx,		ROWCOUNT

@@NextRow:	push		cx

		push		si

		mov		cx,		ROWLEN

@@NextChar:	mov		ax,		es:[si]		; symbol in video memory
		mov		dx,		ds:[bx]		; drawn symbol

		cmp		ax,		dx		; did symbol change?
		jne		@@SaveChanges
		jmp		@@NoChanges

@@SaveChanges:	mov		ds:[di],	ax		; store in save buffer

@@NoChanges:	add		si,		02h
		add		bx,		02h
		add		di,		02h

		loop		@@NextChar

		pop		si
		add		si,		2*80d

		pop		cx
		loop		@@NextRow

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Draws the contents of draw buffer into video memory
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	draw start address
; Exit:		None
; Destroys:	AX, CX, SI, DI, DF
;----------------------------------------------------------------------------------------------------
DrawToVidMem	proc

		cld

		mov		cx,		ROWCOUNT

		lea		si,		DrawBuffer

@@NextRow:	push		cx

		push		di

		mov		cx,		ROWLEN
		rep 		movsw

		pop		di
		add		di,		2*80d

		pop		cx
		loop		@@NextRow

		ret
		endp
;----------------------------------------------------------------------------------------------------

FrameTemplate	db '###########'
		db '#         #'
		db '# AX 0000 #'
		db '# BX 0000 #'
		db '# CX 0000 #'
		db '# DX 0000 #'
		db '# SI 0000 #'
		db '# DI 0000 #'
		db '# BP 0000 #'
		db '# SP 0000 #'
		db '# DS 0000 #'
		db '# ES 0000 #'
		db '# SS 0000 #'
		db '# CS 0000 #'
		db '#         #'
		db '###########'

DrawBuffer	dw TEMPLATELEN dup (0)
SaveBuffer	dw TEMPLATELEN dup (0)

end
