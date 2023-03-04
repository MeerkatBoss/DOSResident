.286
.model tiny
.code

org 100h

extrn InitAndTSR:proc

Start:		call InitAndTSR		; noreturn


end Start
