 #include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Read			    ; external ADC subroutines
extrn	multiply, multiply_24, decimal		   ; external ADC subroutines

extrn	pwm_setup, outputcheck  
extrn	ultra_main, ANSH, ANSL, LENH,LENL 
extrn	delay

extrn pwm_counter
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count: ds 1    ; reserve one byte for counter in the delay routine
joystick_H: ds 1

psect	udata_bank4 ; Reserve data in RAM
msg:	ds 0xF	    ; 16 byte message
    
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
    call    ADC_Setup
    
    movlw   0x00
    movwf   TRISH
    movwf   TRISD
   ; call test_adc

loop:
    call    test_adc
    
    call    ultra_main	    ;Send and receive ultrasound signal
    
    movf    ANSH, W, A	    ; Writes converted distance reading to LCD
    call    LCD_Write_Hex
    movf    ANSL, W, A
    call    LCD_Write_Hex
    call    LCD_clear

    call    joystick_control   ; use joystick to set new counter
   
    movff   pwm_counter, PORTD
    ;incf    pwm_counter, 1, 0	; Increment counter variable 
    call    send_message
    goto loop

    
setup:
    bcf		CFGS	; point to Flash program memory  
    bsf		EEPGD 	; access Flash program memory
    call	UART_Setup	; setup UART
    call	LCD_Setup	; setup LCD
    
    return
    

send_message:		; Output message to UART
    lfsr    0, msg 
    movff   ANSH, POSTINC0
    movff   ANSL, POSTINC0
    movff   pwm_counter, POSTINC0

    
    movlw   0x3		; Load message length into W
    lfsr    2, msg	; UART reads from FSR2	    
    call    UART_Transmit_Message
    return

joystick_control:


    ;movff ADRESH, 0x30, A
    ; If greater than, move right
    movlw   0xA	    ;
    cpfsgt joystick_H, A	;less than
    bra    js_small
    incf    pwm_counter, 1, 0	; Increment counter variable twice
    incf    pwm_counter, 1, 0	
    incf    pwm_counter, 1, 0	
    incf    pwm_counter, 1, 0	
joystick_done:
    return
    
js_small: ; If less than 1536, move left
    movlw   0x5	    ;
    cpfslt joystick_H, A
    bra joystick_done
    decf    pwm_counter, 1, 0	; Decrement counter variable twice
    decf    pwm_counter, 1, 0	
    decf    pwm_counter, 1, 0	
    decf    pwm_counter, 1, 0	
    bra joystick_done

test_adc:
    call    ADC_Read ;output in ADRESH:ADRESL, 12 bit number
    movff   ADRESH, joystick_H, A ; Store value 
    movff   joystick_H, PORTH, A
    return
    
end rst
