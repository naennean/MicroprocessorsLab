#include <xc.inc>



psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE
    
global Delay_set,delay,pulse,shortpulse,longpulse
extrn  delay
    
    
pulse:
    movlw 0xff
    movwf PORTE
    call shortpulse
    movlw 0x00
    movwf PORTE
    call longpulse
    
    goto pulse
    
shortpulse:
    movlw high(0x08d0)
    movwf DELAY_H, A
    movlw low(0x08d0) 
    movwf DELAY_L, A
    call delay
    
longpulse:
    movlw high(0x9c3f)
    movwf DELAY_H, A
    movlw low(0x9c3f) 
    movwf DELAY_L, A
    call delay
    