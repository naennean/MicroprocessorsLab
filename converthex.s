#include <xc.inc>

global  multiply, multiply_24

psect	udata_acs   ; named variables in access ram
LCD_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1	; reserve 1 byte for ms counter
LCD_tmp:	ds 1	; reserve 1 byte for temporary use
LCD_counter:	ds 1	; reserve 1 byte for counting through nessage
ARG1L:		ds 1	
ARG2L:		ds 1
ARG1H:		ds 1
ARG1T:		ds 1
ARG2H:		ds 1
RES0:		ds 1
RES1:		ds 1
RES2:		ds 1
RES3:		ds 1


psect	mult_code,class=CODE

multiply:
	movlw	0x0d        
	movwf	ARG1L
	movwf	ARG2L
	movwf	ARG1H
	movwf	ARG2H
	
    
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
	
	movff	RES0,0x00   ;Store results in registers
	movff	RES1,0x01
	movff	RES2,0x02
	movff	RES3,0x03
	return
	
multiply_24:
	movlw	0x0e        
	movwf	ARG1L
	
	movwf	ARG1H
	movwf	ARG1T
	movwf	ARG2L
	
    
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

	
	movff	RES0,0x00   ;Store results in registers
	movff	RES1,0x01
	movff	RES2,0x02
	movff	RES3,0x03
	return
end