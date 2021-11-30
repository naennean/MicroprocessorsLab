#include <xc.inc>



psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE 
global ultra_main

ultra_main:
    call ultra_init
ultra_start:
    call ultra_pulse
    goto ultra_start
    
ultra_init:		; Initialises ultrasound ports, CCP
    movlw 0x02		; 00000010b
    movwf TRISE,A	; Configure PORTE direction register
    movlw 0x04
    movwf CCP4CON, A
    return
    
ultra_pulse:		; This pulse to RE0 triggers the ultrasonic sensor
    movlw   0x01	; Set RE0 high
    movwf   LATE, A
    call    pulse_delay	; Delay for 5 us
    movlw   0x00	; Set RE0 high
    movwf   LATE, A
    call    pulse_delay	; Delay for 5 us\
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    call    pulse_delay	; Delay for 5 us
    
    
    
    return

ultra_receive:		; This aims to receive the return echo pulse
    movlw   0x00	; Set RE0 low
    movwf   LATE, A
    call    pulse_delay ; Delay for 5 us
    return

ultra_count:
    return
 
pulse_delay:			; 5 us delay for the ultrasound
	movlw 0x00		; Configure the delay for the ultrasound pulse
	movwf DELAY_H, A
	movlw 0x10
	movwf DELAY_L, A
	movlw 0x00 ; W = 0
	
Dloop:	decf DELAY_L, f, A	; Delay loop for 16 bit counter decrement
	subwfb DELAY_H, f, A
	bc Dloop		; branch if carry in high bits
	return			; otherwise return, decrement finished