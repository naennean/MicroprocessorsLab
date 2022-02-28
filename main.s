#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear, LCD_shift ; external LCD subroutines
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
delaydelay_count:ds 1
delayCubed_count:ds 1
    
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
mySecretArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','?',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
mySecretTable:
	db	'G','o','o','d','b','y','e',0x0a
					; message, plus carriage return
	mySecretTable_l   EQU	8	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	movlw	11111111B
	movwf	TRISD, A
	movlw	0x00
	cpfsgt	PORTD, A
	goto	start
	goto	Secretstart
	
	; ******* Main programme ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_l-1	; output message to LCD
				; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	
measure_loop:
	call	ADC_Read
	movf	ADRESH, W, A
	call	LCD_Write_Hex
	movf	ADRESL, W, A
	call	LCD_Write_Hex
	call	delay
	call	delay
	call	delay
	call	delay
	call	delay
	call	delay
	call	delay
	call	delay
	call	delay
	call	delay
	goto	measure_loop		; goto current line in code

	call	LCD_shift
	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	
	call	delay
	call	LCD_clear
	goto	$		; goto current line in code

Secretstart: 	lfsr	0, mySecretArray	; Load FSR0 with address in RAM	
	movlw	low highword(mySecretTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(mySecretTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(mySecretTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	mySecretTable_l	; bytes to read
	movwf 	counter, A		; our counter register
Secretloop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	Secretloop		; keep going until finished
		
	movlw	mySecretTable_l	; output message to UART
	lfsr	2, mySecretArray
	call	UART_Transmit_Message

	movlw	mySecretTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, mySecretArray
	call	LCD_Write_Message
	
	call	LCD_shift
	movlw	mySecretTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, mySecretArray
	call	LCD_Write_Message
	
	call	delay
	call	LCD_clear
	goto	$		; goto current line in code

;	; a delay subroutine if you need one, times around loop in delay_count
;delay:	decfsz	delay_count, A	; decrement until zero
;	bra	delay
;	return
	
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
	end	rst