.286
.model tiny
.code

FrameTemplate:
db '###########'
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
db '# IP 0000 #'
db '#         #'
db '###########'

TEMPLATELEN equ $ - FrameTemplate


DrawBuffer db 2*TEMPLATELEN dup (0)
SaveBuffer db 2*TEMPLATELEN dup (0)



end
