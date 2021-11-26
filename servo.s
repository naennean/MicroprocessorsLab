#include <xc.inc>



psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE
    
global pulse,shortpulse,longpulse
extrn  delay, DelayH_set, DelayL_set
    
    
pulse:
    movlw 0xff
    movwf PORTE
    call longpulse
    
   ; call shortpulse
    movlw 0x00
    movwf PORTE
    ;call shortpulse
    call longpulse
    return

    
shortpulse:
    movlw high(0x07cb)
    call DelayH_set
    movlw low(0x07cb) 
    call DelayL_set
    call delay
    call delay
    return
    
longpulse:
    call calclongdelay
    movlw high(0x9c3f)
    call DelayH_set
    movlw low(0x9c3f) 
    call DelayL_set
    call delay
    call delay
    return

calclongdelay:

    movlw high(0x9c3f)
    call DelayH_set
    movlw low(0x9c3f) 
    call DelayL_set
    movlw 0x07cb
    subwf DELAY_H, 0
    
    