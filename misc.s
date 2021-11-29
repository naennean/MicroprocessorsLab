#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE
    
global Delay_set,delay, DelayH_set, DelayL_set, longpulse1,longpulsesetup,shortpulse1,outputcheck
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
		


longpulsesetup:
    clrf  TRISJ,A   ;sets as output
    clrf  LATJ,A

    movlw 10000001B
    movwf T0CON,A   ; approx 1sec rollover
    
    bsf TMR0IE	    ; Enable timer0 interrupts
    bsf GIE	    ;Enable all interrupts
    return
    
outputcheck:
    btfss TMR0IF ;bit test f,skip if set  
    retfie f    ;return if not interrupt 
    btfss PORTJ,0
    bra shortpulse1
    bra longpulse1
    
longpulse1:
    
  
    incf LATJ,F,A  ;increments latj 
    movlw 0x62  ;timer length settings 628E
    movwf TMR0H, A
    movlw 0x8E
    movwf TMR0L, A
    bcf TMR0IF
    retfie f
    
   
    
shortpulse1:
   
    incf LATJ,F,A  ;increments latj 
    movlw 0x99  ;timer length settings 628E
    movwf TMR0H, A
    movlw 0x94
    movwf TMR0L, A
    bcf TMR0IF
    retfie f
    


