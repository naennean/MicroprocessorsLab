#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE
    
global Delay_set,delay, DelayH_set, DelayL_set, dac_int,dac_setup
;1ms=7d0
;20ms=9c3f
Delay_set:
	movlw high(0x7d0)
	movwf DELAY_H, A
	movlw low(0x07d0)
	movwf DELAY_L, A
	return
	
DelayL_set:
	movwf DELAY_L, A
	return

DelayH_set:
	movwf DELAY_H, A
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
		
dac_int:
    
    btfss TMR0IF
    retfie f
    incf LATJ,F,A
    bcf  TMR0IF	 
    movlw 0x9f
    movwf TMR0H, A
    movlw 0x0f
    movwf TMR0L, A
    
    retfie f
    
    
    ;movlw high(0xff)
    ;movwf TMR0H

    
dac_setup:
    clrf  TRISJ,A
    clrf  LATJ,A

    movlw 0x00
    movwf TMR0H, A
    movlw 0x0f
    movwf TMR0L, A
    
    movlw 10000001B
    movwf T0CON,A   ; approx 1sec rollover
    
    
    bsf TMR0IE	    ; Enable timer0 interrupts
    bsf GIE	    ;Enable all interrupts
    return
 