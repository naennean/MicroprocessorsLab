 #include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I,LCD_Send_Byte_D, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Read, ADC_Read_1	    ; external ADC subroutines

extrn	pwm_setup, outputcheck  
extrn	ultra_main, ANSH, ANSL, LENH,LENL 
extrn	delay

extrn pwm_counter, pwm_counter1
	
psect	udata_acs   ; reserve data space in access ram
pwm_res:    ds 1    ; reserve one byte for a counter variable
counter:    ds 1    ; reserve one byte for counter in the delay routine
joystick_LR: ds 1
joystick_UD: ds 1

psect	udata_bank4 ; Reserve data in RAM
myArray:    ds 0x80 ; reserve 128 bytes for message data
msg:	    ds 0xF	    ; 16 byte message

psect data
myTable:	    ; Table to store message data for LCD
	db	'D','i','s','t','a','n','c','e', ' ', '(', 'm','m',')', 0x0a
					; message, plus carriage return
	myTable_l   EQU	14	; length of data
	align	2
	
psect	code, abs
rst:		; Reset vector
    org 0x0000
    goto start
    
int:		; Interrupt vector
    org 0x0008
    goto outputcheck
    
start:		 ; Initialisation of ports and processes
    bcf		CFGS	; point to Flash program memory  
    bsf		EEPGD 	; access Flash program memory
    call	UART_Setup	; setup UART
    call	LCD_Setup	; setup LCD
    
    movlw   0x1	    
    movwf   pwm_res, A
    
    call    pwm_setup
    call    ADC_Setup
    
    movlw   0x00
    movwf   TRISH, A
    movwf   TRISD, A

;*** MAIN LOOP******************
loop:
    call    ultra_main	    ;Send and receive ultrasound signal
    call    lcd_display
    call    joystick_control   ; use joystick to set new counter
    movff   pwm_counter, PORTD
    movff   pwm_counter1, PORTH, A
    call    send_message
    
    goto loop
   
    
;*** LCD MESSAGE ROUTINE******************
lcd_run_message: 	
	lfsr	0, myArray		; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
test_loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	test_loop		; keep going until finished

	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message

	return

lcd_display:
    movlw   0010000000B		; Write to first line
    call    LCD_Send_Byte_I 
    
    movlw   0x0
    call    LCD_Send_Byte_D
    call    lcd_run_message
    
    movlw   0011000000B		; Write to second line
    call    LCD_Send_Byte_I 
  
    movlw   0x0
    call    LCD_Send_Byte_D
    
    movf    ANSH, W, A	    ; Writes converted distance reading to LCD  
    call    LCD_Write_Hex
    movf    ANSL, W, A
    call    LCD_Write_Hex
    return
    
;********* UART TO COMPUTER****************************
send_message:		; Output message to UART, interface to computer
    lfsr    0, msg 
    movlw   0xAB	; Padding for start byte
    movwf   POSTINC0
    movlw   0xCD	
    movwf   POSTINC0
    movlw   0xEF	
    movwf   POSTINC0
    movff   ANSH, POSTINC0
    movff   ANSL, POSTINC0
    movff   pwm_counter, POSTINC0
    movff   pwm_counter1, POSTINC0
    
    movlw   0xAB	; Send message twice
    movwf   POSTINC0
    movlw   0xCD
    movwf   POSTINC0
    movlw   0xEF
    movwf   POSTINC0
    movff   ANSH, POSTINC0
    movff   ANSL, POSTINC0
    movff   pwm_counter, POSTINC0
    movff   pwm_counter1, POSTINC0

    
    movlw   0xE		; Load message length into W
    lfsr    2, msg	; UART reads from FSR2	    
    call    UART_Transmit_Message
    return
    
;********* Joystick *************
joystick_control:
    call    ADC_Read		    ;output in ADRESH:ADRESL, 12 bit number
    movff   ADRESH, joystick_LR, A   ; Store value so it doesn't change
    
    
    call    ADC_Read_1		    ;output in ADRESH:ADRESL, 12 bit number
    movff   ADRESH, joystick_UD, A   ; Store value so it doesn't change

control_lr:
js_right:
    movlw   0xA			    ; If greater than, move right
    cpfsgt joystick_LR, A	    ;less than
    bra    js_left
    movf    pwm_res, W, A	    ; Decrement counter variable
    subwf   pwm_counter, 1, 0
    
 
js_left: ; If less than 1536, move left
    movlw   0x5	    
    cpfslt joystick_LR, A
    bra	    control_ud
    movf    pwm_res, W, A		; Increment counter variable
    addwf   pwm_counter, 1, 0
    bra	    control_ud
    
control_ud:
js_up:
    movlw   0xA				; If greater than, move up
    cpfsgt joystick_UD, A		;less than
    bra    js_down
    movf    pwm_res, W, A		; Decrement counter variable
    subwf   pwm_counter1, 1, 0
joystick_done:
    
    return
    
js_down:
    movlw   0x5	    
    cpfslt  joystick_UD, A
    bra	    joystick_done
    movf    pwm_res, W, A		; Increment counter variable
    addwf   pwm_counter1, 1, 0
    bra	    joystick_done
end rst
