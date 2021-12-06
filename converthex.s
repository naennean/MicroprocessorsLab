#include <xc.inc>

global  multiply, multiply_24, decimal
extrn LENH,LENL
global ANSH, ANSL


psect	udata_acs   ; named variables in access ram

ARG1L:		ds 1	
ARG2L:		ds 1
ARG1H:		ds 1
ARG1T:		ds 1
ARG2H:		ds 1
    
RES0:		ds 1
RES1:		ds 1
RES2:		ds 1
RES3:		ds 1
    
ANSH:		ds 1	 ; answer for the conversion
ANSL:		ds 1


psect	mult_code,class=CODE

multiply:
	        
	;movwf	ARG1L
	;movwf	ARG2L
	;movwf	ARG1H
	;movwf	ARG2H
	
    
	MOVF ARG1L, W
	MULWF ARG2L ; ARG1L * ARG2L->
	; PRODH:PRODL
	MOVFF PRODH, RES1 ;
	MOVFF PRODL, RES0 ;
	;
	MOVF ARG1H, W
	MULWF ARG2H ; ARG1H * ARG2H->
	; PRODH:PRODL
	MOVFF PRODH, RES3 ;
	MOVFF PRODL, RES2 ;
	;
	MOVF ARG1L, W
	MULWF ARG2H ; ARG1L * ARG2H->
	; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;
	;
	MOVF ARG1H, W ;
	MULWF ARG2L ; ARG1H * ARG2L->
	; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;
	
	movff	RES0,0x10   ;Store results in registers
	movff	RES1,0x11
	movff	RES2,0x12
	movff	RES3,0x13
	return
	
multiply_24:
	;movlw	0xAB        
	;movwf	ARG1L
	;movlw	0xCD  
	;movwf	ARG1H
	;movlw	0xEF
	;movwf	ARG1T
	
	;movlw	0xDD
	;movwf	ARG2L
	
	MOVF	ARG1L, W
	MULWF	ARG2L	    ; ARG1L * ARG2L->
			    ; PRODH:PRODL
	MOVFF	PRODH, RES1   ;
	MOVFF	PRODL, RES0   ;
	;
	MOVF	ARG1T, W
	MULWF	ARG2L	    ; ARG1H * ARG2L->
			    ; PRODH:PRODL
	MOVFF	PRODH, RES3 ;
	MOVFF	PRODL, RES2 ;
			    ;
	MOVF	ARG1H, W
	MULWF	ARG2L	    ; ARG1M * ARG2L->
			    ; PRODH:PRODL
	MOVF	PRODL, W    ;
	ADDWF	RES1, F	    ; Add cross
	MOVF	PRODH, W    ; products
	ADDWFC	RES2, F	    ;
	CLRF	WREG	    ;
	ADDWFC	RES3, F	    ;
			    ;

	
	;movff	RES0,0x20   ;Store results in registers
	;movff	RES1,0x21
	;movff	RES2,0x22
	;movff	RES3,0x23
	
	return

decimal:  
	; Converts 16 bit Hex number to a number in decimal based on
	; a configurable conversion factor
	; Hex input is in LENH:LENL
	; Number in k can be configured
	; The output is a 16 bit hex number where its digits is a decimal
	
	;movlw	0x07
	;movwf	LENH
	;movlw	0xD0
	;movwf	LENL
	
	movff	LENH, ARG1H	; Extract first bit
	movff	LENL, ARG1L
	
	movlw	0x00		; Multiply by our number k= 0x0300
	movwf	ARG2H
	movlw	0x30
	
	movwf	ARG2L		; Following is the conversion routine
	call	multiply 
	movff	RES3,ANSH
	rlncf	ANSH, F		; left shift 4 bits
	rlncf	ANSH, F
	rlncf	ANSH, F
	rlncf	ANSH, F

	call	extract_next	; Extract next bit, combine it with first bit
	movf	RES3,W
	addwf	0x00,1
	
	call	extract_next	; Extract next bit
	movff	RES3, ANSL
	rlncf	ANSL, F		; left shift 4 bits
	rlncf	ANSL, F
	rlncf	ANSL, F
	rlncf	ANSL, F

	call	extract_next	; Extract next bit, combine it with previous bit
	movf	RES3,W
	addwf	ANSL,1
	
	return
	
	

extract_next:
	movff	RES0, ARG1L ;Store results in registers for multiplication
	movff	RES1, ARG1H
	movff	RES2, ARG1T
	
	movlw	0x0A
	movwf	ARG2L
	
	call	multiply_24 ; multiplies remainder with dec10
	
	return
    
end