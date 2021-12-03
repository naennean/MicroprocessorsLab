#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay
LENH:			ds 1
LENL:			ds 1
US_reading:		ds 1

psect	misc_code, class=CODE 
global ultra_main, ccp_main, ultraread,writeval

ccp_main:
    ;call ccp
    goto ccp_main
    
ultra_main:
    call ultra_init
ultra_start:
    call ultra_pulse
    ;call ultra_receive 

    call step_delay
    goto ultra_start
    
ultra_init:		; CCP
    return
    
ultra_pulse:		; This pulse to RE0 triggers the ultrasonic sensor
    movlw   0x00	; Configure PORTE direction register as output
    movwf   TRISE, A	 
    
    movlw   0x01	; Set RE0 high
    movwf   LATE, A
    ;call    pulse_delay	; Delay for 5 us
    call    step_delay
    movlw   0x00	; Set RE0 low
    movwf   LATE, A

    return

ultra_receive:		; This aims to receive the return echo pulse
    movlw   0xff	; Configure PORTE direction register as input
    movwf   TRISE, A
    call    meas_pulse_len
    ;call    pulse_delay ; Delay for 5 us
    return

ultra_count:
    return
 
pulse_delay:			; 5 us delay for the ultrasound
	movlw 0x00		; Configure the delay for the ultrasound pulse
	movwf DELAY_H, A
	movlw 0x10
	movwf DELAY_L, A
	movlw 0x00 ; W = 0
	bra Dloop
	
wait_delay:
	movlw 0x01		; Configure the delay for the waiting pulse
	movwf DELAY_H, A
	movlw 0x00
	movwf DELAY_L, A
	movlw 0x00 ; W = 0
	bra Dloop
	
step_delay:
	movlw 0x00		; Configure the delay for the waiting pulse
	movwf DELAY_H, A
	movlw 0x60
	movwf DELAY_L, A
	movlw 0x00 ; W = 0
	bra Dloop
	
Dloop:	decf DELAY_L, f, A	; Delay loop for 16 bit counter decrement
	subwfb DELAY_H, f, A
	bc Dloop		; branch if carry in high bits
	return			; otherwise return, decrement finished

meas_pulse_len:
	movlw 0x00		; sets our counter to be 0
	movwf LENH, A
	movwf LENL, A
pulse_count:	
	call step_delay
	btfss PORTE, 0
	goto extract_count  ; is low
	incf LENL, f, A	    ; is high, increment counter, call step delay again
	btfsc STATUS, 0	    ; test carry bit, add to LENH
	incf LENH, f, A
	bra pulse_count

extract_count: ; branch and echo final counter value to another PORT
	movlw 0x00
	movwf TRISH
	movwf TRISJ
    	movff LENH, 0x40, A
	movff LENL, 0x41, A
	
	movff LENH, PORTH
	movff LENL, PORTJ

	return
distance_conversion:
    movlw 0xff
    mulwf LENH
    movf PRODL,W
    addwf LENL, 1
    movf PRODH,W
    
    
    movf PRODL, W   ; 16 bit adder
    addwf TIME_L, 1
    movf  PRODH, W
    addwfc TIME_H, 1
    
    movff TIME_H, TMR0H ; Update interrupt timer control registers
    movff TIME_L, TMR0L
   
    
    
    
;ccp:
	
   ; movlw 0b00000100   
    ;movwf CCP1CON, A	    ;Capture Mode, every falling edge on RC2
   ; movlw 0x00
    ;movwf CCPTMRS0	    ; 
    
   ; movlw 00110001B
   ; movwf T1CON,A   
    
   ; movlw 0x00		    ; Update interrupt timer control registers
   ; movwf CCPR1L 
   ; movwf CCPR1H
    
    ;BSF STATUS,RP0	    ;Bank 1
  ;  BSF TRISC,2		    ;Make RC2 input
   ; CLRF TRISD		    ;Make PORTD output
  
   ; bsf TMR0IE	    ; Enable timer0 interrupts
;ccp1:
   ; BTFSS CCP1IF
   ; GOTO ccp1
   ; MOVF CCPR1L,W
   ; MOVWF PORTD, A
    
ultraread:
    movlw 0xff
    movlw PORTE
    movlw 0x00
    movwf PORTH
    ;movf TRISE,US_reading
    movlw 0x00
    cpfseq US_reading
    call writeval
writeval:
    ;movf PORTE,PORTD
    
    return 
    
    
    