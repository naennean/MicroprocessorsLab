#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex ; external LCD subroutines
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn	multiply, multiply_24, decimal		   ; external ADC subroutines
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
org 0x00
 
setup:
    movlw 0xff
    movwf TRISB
    movlw 0xff
    movwf PORTB
    call Bigdelay
    movlw   0x00
    call Bigdelay
    goto setup
    
   
   
Bigdelay: 
	movlw high(0xDEAD)
	movwf 0x10,A
	movlw low(0xDEAD)
	movwf 0x11,A
	movlw 0x00 ; W = 0
Dloop:	decf 0x11, f, A ; counter decrement
	subwfb 0x10, f, A
	bc Dloop
	return   