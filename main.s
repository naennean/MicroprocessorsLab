	#include <xc.inc>
extrn	KP_Setup, KP_read, read_keypad,LCD_Setup, LCD_Write_Message, LCD_clear

psect	udata_acs   ; reserve data space in access ram
counter: ds 1
binary_bit: ds 1
delay_count:ds 1    ; reserve one byte for counter in the delay routine
delaydelay_count:ds 1
delayCubed_count:ds 1	
kp_count: ds 1
   
psect	data

col_1:
	db	'1','4','7','A'
	align 2
col_2:
	db	'2','5','8','0'
	align 2
col_3:
	db	'3','6','9','B'
	align 2
col_4:
	db	'F','E','D','C'
	align 2
	
    col_length EQU 0x04
 
    
psect	code, abs
	
main:
	org	0x0
	goto	setup

	org	0x100		    ; Main code starts here at address 0x100
setup:
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	movlw	0b11110000
	movwf	binary_bit,A
	movlw	0x04 ;set one higher than total number of elements
	movwf	kp_count,A
	goto    start
start:
	movlw	low highword(col_1)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(col_1)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(col_1)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	col_length	; bytes to read
	movwf 	counter, A		; our counter register
loop:	
	;addlw	0xff		; don't send the final carriage return to LCD
	TBLRD*+
	rlcf	binary_bit, f , A      ;dcfsnz	kp_count, A
	;goto	ending
	movff	STATUS, WREG, A
	btfsc	WREG, 0, A
	goto	loop
	call	LCD_Write_Message
	call	delay
;	decfsz	counter
	goto	loop
	call	LCD_clear
	goto 	$

ending:
	call	LCD_clear
	goto	$

	
	
	
	
delay:
	movlw	0xff
	movwf	delay_count,A	    ;store 0xff in 0x02 for delay
delayloop:
	movlw	0xff
	movwf	delaydelay_count,A	    ;store 0xff in 0x02 for delay	
	call	delaydelay
	decfsz  delay_count,A		;decrement from 0x20 down to 0
	bra	delayloop		;when line above reaches zero, will skip this line
	return
	
delaydelay:
	movlw	0xff
	movwf	delayCubed_count, A	    ;store 0xff in 0x02 for delay	
	call	delayCubed
	decfsz	delaydelay_count, A
	bra	delaydelay
	return
delayCubed:
	decfsz	delayCubed_count, A
	bra	delayCubed
	return
	
	
	
	end	main
