	#include <xc.inc>
extrn	KP_Setup, KP_read, read_keypad

psect	udata_acs   ; reserve data space in access ram
delay_count:ds 1    ; reserve one byte for counter in the delay routine
delaydelay_count:ds 1
delayCubed_count:ds 1	
    
    
psect	code, abs
	
main:
	org	0x0
	goto	setup

	org	0x100		    ; Main code starts here at address 0x100
setup:
	movlw	0x00		; 
	movwf	TRISD, A	;configures PORTD as output
	goto    start
start:
	call	KP_Setup
read:
	call	KP_read
	movff	read_keypad, PORTD, A
	goto 	read
	
	
	
	
	
	
	
delay:
	movlw	0xff
	movwf	delay_count	    ;store 0xff in 0x02 for delay
delayloop:
	movlw	0xff
	movwf	delaydelay_count	    ;store 0xff in 0x02 for delay	
	call	delaydelay
	decfsz  delay_count		;decrement from 0x20 down to 0
	bra	delayloop		;when line above reaches zero, will skip this line
	return
	
delaydelay:
	movlw	0xff
	movwf	delayCubed_count	    ;store 0xff in 0x02 for delay	
	call	delayCubed
	decfsz	delaydelay_count
	bra	delaydelay
	return
delayCubed:
	decfsz	delayCubed_count
	bra	delayCubed
	return
	
	
	
	end	main
