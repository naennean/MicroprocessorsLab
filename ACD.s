#include <xc.inc>

global  ADC_Setup, ADC_Read, multiply, multiply_uneven
global	RES0, RES1, RES2, RES3, ARG1H, ARG2H, ARG1L, ARG2L
global	L1, M1, H1, ARG2
    
psect udata_acs
RES0:	ds  1
RES1:	ds  1
RES2:	ds  1
RES3:	ds  1
ARG1H:	ds  1
ARG2H:	ds  1
ARG1L:	ds  1
ARG2L:	ds  1
L1:	ds  1
H1:	ds  1
M1:	ds  1
ARG2:	ds 1
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return
	
multiply:
	MOVF ARG1L, W, A
	MULWF ARG2L, A ; ARG1L * ARG2L-> 
		    ; PRODH:PRODL 
	MOVFF PRODH, RES1, A ; 
	MOVFF PRODL, RES0, A ; 
	; 
	MOVF ARG1H, W, A 
	MULWF ARG2H, A ; ARG1H * ARG2H-> 
		    ; PRODH:PRODL 
	MOVFF PRODH, RES3, A ; 
	MOVFF PRODL, RES2, A ; 
	; 
	MOVF ARG1L, W, A 
	MULWF ARG2H, A ; ARG1L * ARG2H-> 
		    ; PRODH:PRODL 
	MOVF PRODL, W, A ; 
	ADDWF RES1, F, A ; Add cross 
	MOVF PRODH, W, A ; products 
	ADDWFC RES2, F, A ; 
	CLRF WREG, A ; 
	ADDWFC RES3, F, A ; 
	; 
	MOVF ARG1H, W, A ; 
	MULWF ARG2L, A ; ARG1H * ARG2L-> 
		    ; PRODH:PRODL 
	MOVF PRODL, W, A ; 
	ADDWF RES1, F, A ; Add cross 
	MOVF PRODH, W, A ; products 
	ADDWFC RES2, F, A ; 
	CLRF WREG, A ; 
	ADDWFC RES3, F, A ; 
	return
	
multiply_uneven:
	MOVF L1, W, A
	MULWF ARG2, A ; ARG1L * ARG2L-> 
		    ; PRODH:PRODL 
	MOVFF PRODH, RES1, A ; 
	MOVFF PRODL, RES0, A ; 
	; 
	MOVF H1, W, A 
	MULWF ARG2, A ; ARG1H * ARG2H-> 
		    ; PRODH:PRODL 
	MOVFF PRODH, RES3, A ; 
	MOVFF PRODL, RES2, A ; 
	; 
	MOVF M1, W, A 
	MULWF ARG2, A ; ARG1L * ARG2H-> 
		    ; PRODH:PRODL 
	MOVF PRODL, W, A ; 
	ADDWF RES1, F, A ; Add cross 
	MOVF PRODH, W, A ; products 
	ADDWFC RES2, F, A ; 
	CLRF WREG, A ; 
	ADDWFC RES3, F, A ; 

	return
end