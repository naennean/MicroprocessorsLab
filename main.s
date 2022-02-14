	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100

start:
	myLoc EQU 0x2E0
	lfsr    0,myLoc
	movlw 	0x0
;	movwf	TRISC, A	    ; Port C all outputs
	bra 	test
inc_numb:
;	movff 	0x06, PORTC
	incf 	0x06, W, A
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movff	0x06, POSTINC0 ;store new number into predetermined loc
	movlw 	0x05
	cpfsgt 	0x06, A
	bra 	inc_numb	    ; Not yet finished goto start of loop again
	;goto 	$ ;0x0		    ; Re-run program from start
start2:
    	lfsr	1,myLoc
	movlw 	0x0
	bra 	read
inc_numb2:
	incf 	0x06, W, A
read:
	movwf	0x06, A
	movff	POSTINC1,0x05
	cpfseq	0x05,A
	bra	light
	movlw	0x05
	cpfsgt	0x06, A
	bra	inc_numb2
	
light:
	NOP
	end	main
