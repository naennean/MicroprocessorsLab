#include <xc.inc>

psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay
LENH:			ds 1
LENL:			ds 1

psect	ultra_code, class=CODE 
global	ultra_main
global	LENH,LENL
extrn decimal 


ultra_main:
    call ultra_init
    
ultra_start:
    call ultra_pulse	; Send outgoing signal
    
    call ultra_receive 
    call ultra_convert
    ;call step_delay
    return
 
ultra_init:		; Initialises Echo ports
    ;movlw 0x00
    ;movwf TRISH
    ;movwf TRISJ
	
    return
    
ultra_pulse:		; This triggers the ultrasonic sensor
    movlw   0x00	; Configure PORTE direction register as output
    movwf   TRISE, A	 
    
    movlw   0x01	; Set RE0 high
    movwf   LATE, A
    call    pulse_delay	; Delay for 5 us

    movlw   0x00	; Set RE0 low
    movwf   LATE, A

    return

ultra_receive:		; This aims to receive the return echo pulse
    movlw   0xff	; Configure PORTE direction register as input
    movwf   TRISE, A
    call    wait_delay	; Fixed 750us holdoff
    call    meas_pulse_len
    call    pulse_delay ; Delay for 5 us
    return


 
pulse_delay:			; 5 us delay for the ultrasound
	movlw 0x00		; Configure the delay for the ultrasound pulse
	movwf DELAY_H, A
	movlw 0x10
	movwf DELAY_L, A
	movlw 0x00 ; W = 0
	bra Dloop
	
wait_delay:
	movlw 0x07		; Configure the delay for the waiting pulse
	movwf DELAY_H, A
	movlw 0xBC
	movwf DELAY_L, A
	movlw 0x00 ; W = 0
	bra Dloop
	
step_delay:
	movlw	0x00		; Configure the delay for the waiting pulse
	movwf	DELAY_H, A
	movlw	0x00		; CHANGE NUMBER HERE TO CONFIG CALIBRATION
	movwf	DELAY_L, A
	movlw	0x00 ; W = 0
	bra	Dloop
	
Dloop:	decf	DELAY_L, f, A	; Delay loop for 16 bit counter decrement
	subwfb	DELAY_H, f, A
	bc	Dloop		; branch if carry in high bits
	return			; otherwise return, decrement finished

meas_pulse_len:		; Counts for how long the return pulse is on for
	movlw	0x00		; sets our counter to be 0 initially
	movwf	LENH, A
	movwf	LENL, A
check_start:
	btfss	PORTE, 0
	goto	check_start
pulse_count:	
	;call step_delay
	btfss	PORTE, 0	    
	goto	extract_count  ; PORT is low, break
	incf	LENL, f, A	    ; is high, increment counter, call step delay again
	btfsc	STATUS, 0	    ; test carry bit, add to LENH
	incf	LENH, f, A
	bra	pulse_count

extract_count:	    ; branch and echo final counter value to another PORT
    	;movff LENH, 0x40, A
	;movff LENL, 0x41, A
	
	;movff LENH, PORTH
	;movff LENL, PORTJ

	return

ultra_convert:
    ; converts LENH:LENL into a 4 digits for display use to the LCD
    ;movff LENH, 0x50, A
    ;movff LENL, 0x51, A
    call decimal 
    return 

	

    
    
    