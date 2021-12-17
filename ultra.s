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


; *** Main ultrasound routine***
ultra_main:
ultra_start:
    call ultra_pulse	; Send outgoing signal
    
    call ultra_receive 
    call ultra_convert
    ;call step_delay
    return

; *** Forward pulse ****
ultra_pulse:		; This triggers the ultrasonic sensor
    movlw   0x00	; Configure PORTE direction register as output
    movwf   TRISE, A	 
    
    movlw   0x01	; Set RE0 high
    movwf   LATE, A
    call    pulse_delay	; Delay for 5 us

    movlw   0x00	; Set RE0 low
    movwf   LATE, A

    return

; *** Measure echo ****
ultra_receive:		; This aims to receive the return echo pulse
    movlw   0xff	; Configure PORTE direction register as input
    movwf   TRISE, A
    call    wait_delay	; Fixed 750us holdoff
    call    meas_pulse_len
    call    pulse_delay ; Delay for 5 us
    return


; *** Useful delays  ****
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

; ******* ROUTINE FOR PULSE LENGTH MEASUREMENT******************
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

extract_count:	    ; return from measurement routine
	return	    

; ******* Converts distance to a decimal ******************
ultra_convert:
    ; converts LENH:LENL into a 4 digits for display use to the LCD
    call decimal 
    return 

	

    
    
    