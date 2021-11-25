#include <xc.inc>



psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE
    
global Delay_set,delay
;1ms=7d0
;20ms=9c3f
Delay_set:
	movlw high(0x7d0)
	movwf DELAY_H, A
	movlw low(0x07d0)
	movwf DELAY_L, A
	return
    

delay:			; General 16 bit Delay function
	movf DELAY_H, W
	movwf 0x10,A
	movf DELAY_L, W
	movwf 0x11,A
	movlw 0x00 ; W = 0
	
Dloop:	decf 0x11, f, A ; counter decrement
	subwfb 0x10, f, A
	bc Dloop
	return   