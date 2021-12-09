 #include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Read			    ; external ADC subroutines
extrn	multiply, multiply_24, decimal		   ; external ADC subroutines

extrn	pwm_setup, outputcheck ;, pwm_main, pwm_counter 
extrn	ultra_main, ANSH, ANSL, LENH,LENL 
extrn	delay

extrn pwm_counter
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
;org 0x00
 
;setup:
    ;movlw 0x00 
    ;movwf TRISE
psect	code, abs
	
rst:
    org 0x0000
    goto start
    
int:
    org 0x0008
    goto outputcheck
    
    
start:
    call    setup
    call    pwm_setup

loop:
    call    ultra_main
    
    movf    ANSH, W, A	; Writes converted number to LCD
    call    LCD_Write_Hex
    movf    ANSL, W, A
    call    LCD_Write_Hex
    call    LCD_clear

    incf    pwm_counter, 1, 0	; Increment counter variable 
    
    goto loop

    
setup:
    bcf		CFGS	; point to Flash program memory  
    bsf		EEPGD 	; access Flash program memory
    call	UART_Setup	; setup UART
    call	LCD_Setup	; setup UART
    
    return
    

    
end rst
