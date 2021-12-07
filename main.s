 #include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Read			    ; external ADC subroutines
extrn	multiply, multiply_24, decimal		   ; external ADC subroutines

extrn	pwm_main, ultra_main, ANSH, ANSL, LENH,LENL
extrn	delay
 
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine

    
psect	code, abs
	
start:
    org 0x0000
    movlw   0x00	; Configure PORTE direction register as output 

    ;call ccp_main
    ;call pwm_setup
    bra lcd_setup
loop: 
    call	ultra_main
    call	mirror_hex
    
    movf	ANSH, W, A	; Writes to LCD
    call	LCD_Write_Hex
    movf	ANSL, W, A
    call	LCD_Write_Hex
    
    call	LCD_clear
    
    goto	loop

mirror_decimal:
    movff	ANSH, PORTH
    movff	ANSL, PORTJ
    return 
mirror_hex:
    movff	LENH, PORTH
    movff	LENL, PORTJ
    
    return 
lcd_setup:
    bcf		CFGS	; point to Flash program memory  
    bsf		EEPGD 	; access Flash program memory
    call	UART_Setup	; setup UART
    call	LCD_Setup	; setup UART
    ;call	ADC_Setup	; setup ADC
    goto	loop
	
    
    end start

    
  
