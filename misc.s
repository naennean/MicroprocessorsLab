#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay
Counter1:		ds 1
Increment:		ds 1
TIME_H:			ds 1	; high 8 bits for time change
TIME_L:			ds 1	; low 8 bits for time change

psect	misc_code, class=CODE
    
global Delay_set,delay, DelayH_set, DelayL_set, longpulse1,longpulsesetup,shortpulse1,outputcheck
global pwm_setup
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
	;movf DELAY_H, W
	;movwf 0x10,A
	;movf DELAY_L, W
	;movwf 0x11,A
	movlw 0x00 ; W = 0
	
Dloop:	decf DELAY_L, f, A ; counter decrement
	subwfb DELAY_H, f, A
	bc Dloop
	return   
		
; Delay using interrupts

pwm_setup:
    movlw 0x00
    movwf Counter1
    movlw 0x0A
    movwf Increment
    return
    
longpulsesetup: 
    clrf  TRISJ,A   ;sets as output
    clrf  LATJ,A

    movlw 10000010B
    movwf T0CON,A   
    bsf TMR0IE	    ; Enable timer0 interrupts
    bsf GIE	    ;Enable all interrupts
    return
    
outputcheck:
    btfss TMR0IF ;bit test f,skip if set  
    retfie f    ;return if not interrupt 
   
    btfss PORTJ,0
    bra shortpulse1
    bra longpulse1
    
pulselength:
    ;movff Increment, 0x06, A
    movff Counter1, 0x05, A
    incf Counter1, 1, 0 ; increment counter variable 
    movf Counter1, W
    mulwf Increment ; multiply, result in PRODH:PRODL
    
    movff Counter1, 0x50, A
    movff Increment, 0x51, A
    movff PRODH, 0x52, A
    movff PRODL, 0x53, A
    return 
    
longpulse1:
    incf LATJ,F,A  ;increments latj 
    movlw 0x6a  ;timer length settings 628E
    movwf TMR0H, A
    movlw 0x00
    movwf TMR0L, A
    
    movf PRODL, W   ;16 bit adder
    addwf TMR0L, 1
    movf  PRODH, W
    addwfc TMR0H, 1
    
    bcf TMR0IF
    retfie f
    
   
    
shortpulse1:
    incf LATJ,F,A  ;increments latj
    call pulselength ; call pulse length configurer
     
    movlw 0xF6	    ; Define Delay0
    movwf TMR0H, A  ; Delay = Delay0 - counter * increment
    movlw 0xC9
    movwf TMR0L, A
    
    movf PRODL, W   ; subtract counter*increment from delay0
    subwf TMR0L,1
    movf  PRODH, W
    subwfb TMR0H, 1
    
    
    movff TMR0L, 0x40, A
    movff TMR0H, 0x41, A
    
    
    bcf TMR0IF
    retfie f

    
    
    


