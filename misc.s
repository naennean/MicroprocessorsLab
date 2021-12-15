#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay
pwm_counter:		ds 1	; variable for counting pwm duty cycle
Increment:		ds 1	; fixed time lengthener
TIME_H:			ds 1	; high 8 bits for time change
TIME_L:			ds 1	; low 8 bits for time change
    
T_CHANGE_H:		ds 1
T_CHANGE_L:		ds 1
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
    movlw   0x0E
    ;movlw   0x00
    movwf   Increment, A

    ;clrf    TRISJ  ; sets PORTD as output
    
    movlw   0x00
    movwf   TRISJ
    clrf    LATJ
    movwf   T_CHANGE_H
    movwf   T_CHANGE_L
    ;movlw   0x00
    ;movwf   TRISH
    
    ;movlw   0xff
    ;movwf   LATJ
    ;movwf   PORTJ
   ; movwf   LATH
    ;movwf   PORTH
    movlw   10000010B	; Configure length of timer0
    movwf   T0CON,A   
    bsf	    TMR0IE	; Enable timer0 interrupts
    
    movlw   00110001B	    ; Enable timer1 interrupts and configure length
    movwf   T1CON, A
    bcf	    TMR1IE
    ;bsf	    PEIE
    
    bsf	    GIE	    ; Enable all interrupts
  
    return
    
    
outputcheck: ; Tests signal PORTS to see whether a low or high pulse is next needed
check_int0:
    btfss  TMR0IF    ; Service interrupt 0
    bra	   check_int1    
    
    btfss PORTJ, 0, A
    bra high_pulse
    bra low_pulse
  
check_int1:
    btfss   TMR1IF  
    retfie  f	    ;return if not interrupt 

    bcf	    LATJ,  6,A	
    retfie  f	    ;return if not interrupt 
    ;btg	    LATJ,  4,A	
    
    ;retfie  f
    
pulselength:		; calculates counter * increment
    
    movf  pwm_counter, W
    mulwf Increment	; multiply, result in PRODH:PRODL
    movff   PRODL, T_CHANGE_L
    movff   PRODH, T_CHANGE_H
    return 
    
low_pulse:
    ; Generates LOW part of pulse wave, with fixed 50 Hz duty cycle
    btg    LATJ,  0,A	; increments LAT Register
    ;btg	    LATD, 0, A	; Output by toggling LAT Register
    movlw   0x69		
    movwf   TIME_H, A
    movlw   0xE6
    movwf   TIME_L, A
    
    movf    T_CHANGE_L, W	; 16 bit adder
    addwf   TIME_L, 1
    movf    T_CHANGE_H, W
    addwfc  TIME_H, 1
    
    movff   TIME_H, TMR0H ; Update interrupt timer control registers
    movff   TIME_L, TMR0L
    
    bcf	    TMR0IF
    goto    check_int1
    
high_pulse:
    ; Generates HIGH part of pulse wave, with fixed 50 Hz duty cycle
    ; Reconfigures interrupt pulse length
    
    btg    LATJ,0,A	; Output by incrementing LAT Register
    bsf    LATJ, 6,A
    call    pulselength	; Configure pulse width in the cycle
     
			; Delay = Delay0 - counter * increment
    movlw   0xF9	; Define Delay0
    movwf   TIME_H, A	
    movlw   0xEC
    movwf   TIME_L, A
    
    movf    T_CHANGE_L, W	; Subtract counter * increment from delay0
    subwf   TIME_L,f, A	; to increase length of high pulse
    movf    T_CHANGE_H, 0
    subwfb  TIME_H, f, A	
    
    movff   TIME_H, TMR0H	; Update interrupt timer control registers
    movff   TIME_L, TMR0L	; Must update TMR0L for TMR0H to register
    
    movff   TIME_H, TMR1H
    movff   TIME_L, TMR1L
   
    bcf	    TMR0IF		; Clear interrupt flag
    bcf	    TMR1IF		; Clear interrupt flag
    goto    check_int1
