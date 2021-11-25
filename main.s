#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex ; external LCD subroutines
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn	multiply, multiply_24, decimal		   ; external ADC subroutines
extrn   Delay_set,delay,pulse
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
org 0x00
 
setup:
    movlw 0x00 
    movwf TRISE
    call pulse
loop:
    movlw 0xff
    movwf PORTE
    call delay
    movlw 0x00
    movwf PORTE
    call delay
    goto loop
