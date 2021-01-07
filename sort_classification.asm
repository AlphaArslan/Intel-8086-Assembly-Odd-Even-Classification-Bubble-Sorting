;This code gets N elements of unsigned 8-bit integers from the user.
;it then classifies numbers into odd and even
;Then, it displays odd numbers in ascending order
; and even numbers in descending order.


include "emu8086.inc"

;=========================================
; *** MACROS ***  

; So much faster than the macro provided in emu8086.inc
M_PRINT    MACRO   str_
LOCAL       s, skip
            
            JMP     skip
            s       db  str_,"$"
    skip:   PUSH    AX
            PUSH    DX
            
            MOV     AH, 9
            LEA     DX, s
            INT     21H
            
            POP     DX
            POP     AX
                        
ENDM

            
;=========================================


name "sort n elements"

org     100h
            
            
            
            ;get the length from user
            M_PRINT "Enter number of elements: "
            CALL    scan_num
            MOV     length, CX
            
            ;get each element
            MOV     AX, 1                   ;ascending counter for elements
            MOV     DI, 0
            MOV     DX, CX                  ;DX will store length
            GOTOXY  0, 2
E1:         M_PRINT "Enter element #"
            CALL    print_num_uns           ;prints the counter in AX
            M_PRINT   ":  "                 ;simple spacing
            CALL    scan_num                ;gets number from user
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            MOV     values[DI], CL          ;stores the number
            CMP     AX, DX                  ;was it the last element?
            JE      E2                      ;yes, exit loop
            INC     DI                      ;no, increment counters and loop again
            INC     AX
            JMP     E1           
E2:                               
            
            
            ;seperate odd and even
            MOV     DI, 0                   ;indexing evens
            MOV     SI, 0                   ;indexing odds
            MOV     BX, 0                   ;indexing original array ( values )
S1:         MOV     AL, values[BX]          ;put it in a register for speed   
            AND     AL, 1                   ;keep only LSB
            JZ      EVEN                    ;if LSB=0, it's even
            MOV     AL, values[BX]          ;else, it's odd. retrieve original value
            MOV     odds[SI], AL            ;store a copy in odds
            INC     SI                      ;increment odds index
            JMP     COMMON
EVEN:       MOV     AL, values[BX]          ;retrieve original value
            MOV     evens[DI], AL           ;store a copy in evens
            INC     DI                      ;increment evens index
COMMON:     INC     BX                      
            CMP     BX, DX                  ;Are we finished ? (DX still holds length)    
            JNE     S1                      ;no, loop again
            
            MOV     odd_len, SI             ;store the length of odds
            MOV     even_len, DI            ;store the length of evens
            
            
            ;sort odd numbers in acsending order (Buble Sorting)
            MOV     SI, 0                   ;index i
            MOV     AX, odd_len             ;k = length - 2 ;AX              
            SUB     AX, 2
            MOV     DH, 0                   ;flag, 1 if swap happened

BASORT1:    MOV     BL, odds[SI+1]          ;right number
            MOV     DL, odds[SI]            ;left number
            CMP     DL, BL                  ;left - right
            JS      BASORT2                 ;right > left , no swap needed
            JE      BASORT2                 ;right = left , no swap needed
            MOV     odds[SI+1], DL          ;swap
            MOV     odds[SI], BL
            MOV     DH, 1                   ;set swap flag
BASORT2:    CMP     SI, AX                  ;( i == k ? )
            JE      BASORT3
            INC     SI                      ;no,    increment i
            JMP     BASORT1                 ;       loop again
BASORT3:    CMP     DH, 0                   ;yes,   check swap flag
            JE      BASORT4                 ;       no swap happened. All sorted. Exit               
            MOV     SI, 0                   ;       swap happened. Sorting not finished.
            MOV     DH, 0                   ;       reset flag
            JMP     BASORT1                 ;       loop again
BASORT4:
            
            
            ;sort even numbers in decsending order (Buble Sorting)
            MOV     SI, 0                   ;index i
            MOV     AX, even_len            ;k = length - 2 ;AX              
            SUB     AX, 2
            MOV     DH, 0                   ;flag, 1 if swap happened

BDSORT1:    MOV     BL, evens[SI+1]         ;right number
            MOV     DL, evens[SI]           ;left number
            CMP     BL, DL                  ;right - left
            JS      BDSORT2                 ;left > right , no swap needed
            JE      BDSORT2                 ;right = left , no swap needed
            MOV     evens[SI+1], DL         ;swap
            MOV     evens[SI], BL
            MOV     DH, 1                   ;set swap flag
BDSORT2:    CMP     SI, AX                  ;( i == k ? )
            JE      BDSORT3
            INC     SI                      ;no,    increment i
            JMP     BDSORT1                 ;       loop again
BDSORT3:    CMP     DH, 0                   ;yes,   check swap flag
            JE      BDSORT4                 ;       no swap happened. All sorted. Exit               
            MOV     SI, 0                   ;       swap happened. Sorting not finished.
            MOV     DH, 0                   ;       reset flag
            JMP     BDSORT1                 ;       loop again
BDSORT4:


            ;print sorted odds
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            M_PRINT "Sorted Odd Numbers: "  ;then start to loop
            MOV     AH, 0                   ;numbers will be stored in AL and printed from AX
            MOV     SI, 0                   ;index
PO:         MOV     AL, odds[SI]            ;fetch an element
            CALL    print_num_uns           ;print it
            M_PRINT "  "                    ;print seperation spaces
            INC     SI                      ;increment the index
            CMP     SI, odd_len             ;was it the last ?
            JNE     PO                      ;no loop again.
            

            ;print sorted evens
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            M_PRINT "Sorted Even Numbers: " ;then start to loop
            MOV     SI, 0                   ;index
PE:         MOV     AL, evens[SI]           ;fetch an element
            CALL    print_num_uns           ;print it
            M_PRINT "  "                    ;print seperation spaces
            INC     SI                      ;increment the index
            CMP     SI, even_len            ;was it the last ?
            JNE     PE                      ;no loop again.               
RET

;================================================
length      dw      0
values      db      255 dup(?)
odd_len     dw      0
odds        db      255 dup(?)
even_len    dw      0
evens       db      255 dup(?)


DEFINE_SCAN_NUM
DEFINE_PRINT_NUM_UNS

END