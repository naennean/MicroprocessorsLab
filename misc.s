#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay
pwm_counter:		ds 1	; variable for counting pwm duty cycle
Increment:		ds 1	; fixed time lengthener
TIME_H:			ds 1	; high 8 bits for time change
TIME_L:			ds 1	; low 8 bits for time change

psect	misc_code, class=CODE
    
global pwm_setup, pwm_main, outputcheck
global Delay_set, DelayL_set, DelayH_set, delay, pwm_counter

; STANDARD 16 BIT LOOP DELAY
Delay_set:
	movlw 0xFF
	movwf DELAY_H, A
	movlw 0xFF
	movwf DELAY_L, A
	return
	
DelayL_set:
	movwf DELAY_L, A
	return

DelayH_set:
	movwf DELAY_H, A
	return

delay:			; General 16 bit Delay function
	call Delay_set
	movlw 0x00 ; W = 0
	
Dloop:	decf DELAY_L, f, A ; counter decrement
	subwfb DELAY_H, f, A
	bc Dloop
	return   
		
; ****************The main PWM generator is below************************

pwm_main:
    ; Generates a variable PWM cycle for the operation of a servo motor
    ; Signal is outputted to PORTD
    call pwm_setup 
    
    ;goto $
    
    return


    
pwm_setup:	    ; initialises variables for looping, output and the interrupts
    movlw 0x00	    
    movwf   pwm_counter, A
    movlw   0x0f	    
    movwf   Increment, A

    ;clrf    TRISJ  ; sets PORTD as output
    ;clrf    LATJ
    movlw   0x00
    movwf   TRISJ
    ;movlw   0x00
    ;movwf   TRISH
    
    ;movlw   0xff
    ;movwf   LATJ
    ;movwf   PORTJ
   ; movwf   LATH
    ;movwf   PORTH
    movlw   10000010B ; Configure length of timer0
    movwf   T0CON,A   
    bsf	    TMR0IE	    ; Enable timer0 interrupts
    bsf	    GIE	    ; Enable all interrupts
  
    return
    
    
outputcheck:
    ; Tests signal PORT to see whether a low or high pulse is next needed
    btfss TMR0IF    ;bit test f,skip if set  
    retfie f	    ;return if not interrupt 
   
    btfss PORTJ, 0, A
    bra high_pulse
    bra low_pulse
    
    
pulselength:		; calculates counter * increment
    
    movf  pwm_counter, W
    mulwf Increment	; multiply, result in PRODH:PRODL
    return 
    
low_pulse:
    ; Generates LOW part of pulse wave, with fixed 50 Hz duty cycle
    incf    LATJ,  F,A	; increments LAT Register
    ;btg	    LATD, 0, A	; Output by toggling LAT Register
    movlw   0x66		
    movwf   TIME_H, A
    movlw   0xE9
    movwf   TIME_L, A
    
    movf    PRODL, W	; 16 bit adder
    addwf   TIME_L, 1
    movf    PRODH, W
    addwfc  TIME_H, 1
    
    movff   TIME_H, TMR0H ; Update interrupt timer control registers
    movff   TIME_L, TMR0L
    
    bcf	    TMR0IF
    retfie  f
    
high_pulse:
    ; Generates HIGH part of pulse wave, with fixed 50 Hz duty cycle
    ; Reconfigures interrupt pulse length
    
    incf    LATJ,F,A	; Output by incrementing LAT Register
    ;btg	    LATD, 0, A	; Output by toggling LAT Register
    call    pulselength	; Configure pulse width in the cycle
     
			; Delay = Delay0 - counter * increment
    movlw   0xFC	; Define Delay0
    movwf   TIME_H, A	
    movlw   0xe9
    movwf   TIME_L, A
    
    movf    PRODL, W	; Subtract counter * increment from delay0
    subwf   TIME_L,f, A	; to increase length of high pulse
    movf    PRODH, 0
    subwfb  TIME_H, f, A	
    
    movff   TIME_H, TMR0H	; Update interrupt timer control registers
    movff   TIME_L, TMR0L	; Must update TMR0L for TMR0H to register
   
    bcf	    TMR0IF		; Clear interrupt flag
    retfie  f
