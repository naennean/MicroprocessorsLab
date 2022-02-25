
    #include <xc.inc>

global  KP_Setup, KP_read_row, KP_read, read_keypad

psect	udata_acs   ; named variables in access ram
read_keypad:	ds 1	;reserve one byte for total keypad value
read_row:	ds 1	; reserve one byte for row values
read_col:	ds 1	; reserve one byte for row values
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through message
kp_counter:	ds 1	; reserve 1 byte to count through rows and columns

	LCD_E	EQU 5	; LCD enable bit
    	LCD_RS	EQU 4	; LCD register select bit
	

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
	
    col_length EQU 4

psect	keypad_code,class=CODE
    
KP_Setup:
	movlb	0xf		; bank 15
	bsf	PADCFG1, 6, B	 ;set REPU bit in PADCFG1 to enable pull-up resistors on PORTE
	clrf	LATE, A		; write 0s to LATE register
	movlw	0x0f		; 00001111
	movwf	TRISE, A	;configures PORTE 4-7 as outputs and PORTE 0-3 as inputs
	return
	
KP_read:
KP_read_col:	    ;read column value
	movlw	0x0f		; 00001111
	movwf	TRISE, A	;configures PORTE 4-7 as outputs and PORTE 0-3 as inputs
;	movlw	0x0f
	call	LCD_delay
	movff	PORTE, read_col , A  
KP_read_row:	    ;read row value
	movlw	0xf0		; 11110000
	movwf	TRISE, A	;configures PORTE 4-7 as inputs and PORTE 0-3 as outputs
	call	LCD_delay
	movff	PORTE, read_row , A ;
	
	movff	read_row, WREG
	addwf	read_col, W, A    ;add col and row value, store in read_keypad
	movwf	read_keypad, A
	return	    ;return to where KP_read was called
	
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
    
    ;;make at least 2 keys work
    

    
    
;	movlw	0x01 ; (binary for button 1~)
;	cpfseq PORTD, A
;	call print 1 to LCD
;	movlw binary for button 2
;	cpfseq 2
;	call print 2
;	...
;	wreg 
;	1011 1101
;	btfsc
    end


