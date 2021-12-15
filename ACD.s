#include <xc.inc>

global  ADC_Setup, ADC_Read, ADC_Read_1
    
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	bsf	TRISA, PORTA_RA1_POSN, A  ; pin RA1==AN1 input
	movlb	0x0f	    ; Modify bank selection register for ANCON0
	bsf	ANSEL0	    ; set AN0 to analog
	bsf	ANSEL1	    ; set AN1 to analog
	
	movlb	0x00
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:		    ; READ from AN0
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
	bra	adc_loop
	
ADC_Read_1:		    ; READ from AN1
	movlb	0x00
	movlw   0x05	    ; select AN1 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
	bra	adc_loop
    
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end