
    #include <xc.inc>

global  KP_Setup, KP_read_row, KP_read_col,read_row, read_col

psect	udata_acs   ; named variables in access ram
read_row:	ds 1	; reserve one byte for row values
read_col:	ds 1	; reserve one byte for row values
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through nessage

	LCD_E	EQU 5	; LCD enable bit
    	LCD_RS	EQU 4	; LCD register select bit
	

psect	data    
	; ******* myTable, data in programme memory, and its length *****
KP_numbers:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2

psect	keypad_code,class=CODE
    
KP_Setup:
	movlb	0xf		; bank 15
	bsf	PADCFG1, 6, B	 ;set REPU bit in PADCFG1 to enable pull-up resistors on PORTE
	clrf	LATE, A		; write 0s to LATE register
	movlw	0x0f		; 00001111
	movwf	TRISE, A	;configures PORTE 4-7 as outputs and PORTE 0-3 as inputs
	return
	
KP_read_col:	    ;Already switched row and col (Mel 24.02.22)
	movlw	0x0f		; 00001111
	movwf	TRISE, A	;configures PORTE 4-7 as outputs and PORTE 0-3 as inputs
;	movlw	0x0f
	call	LCD_delay
	movff	PORTE, read_col , A  
	return
	
KP_read_row:
	movlw	0xf0		; 11110000
	movwf	TRISE, A	;configures PORTE 4-7 as inputs and PORTE 0-3 as outputs
	call	LCD_delay
	movff	PORTE, read_row , A ;
	
	return
	
; ** a few delay routines below here as LCD timing can be quite critical ****
LCD_delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return


	
KP_decode:

    ;;;;; ADD 17 FUnctions to decode keypad and send ASCII to LCD display
    
    
;	movlw	0x01 ; (binary for button 1~)
;	cpfseq PORTD, A
;	call print 1 to LCD
;	movlw binary for button 2
;	cpfseq 2
;	call print 2
	...
    end


