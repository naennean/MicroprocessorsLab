#include <xc.inc>



psect	udata_acs   ; reserve data space in access ram
DELAY_H:		ds 1    ; high 8 bits for delay
DELAY_L:		ds 1	; low 8 bits for delay

psect	misc_code, class=CODE
    
global pulse,shortpulse,longpulse
extrn  delay, DelayH_set, DelayL_set
    
ultra_init: ;initialises ultrasound ports
    return
    
ultra_pulse:
    return

ultra_receive:
    return

ultra_count:
    return