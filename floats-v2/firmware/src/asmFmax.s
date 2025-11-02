/*** asmFmax.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data  
.align

@ Define the globals so that the C code can access them

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Amanda Earney"  
 
.align

/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global f0,f1,fMax,signBitMax,storedExpMax,realExpMax,mantMax
.type f0,%gnu_unique_object
.type f1,%gnu_unique_object
.type fMax,%gnu_unique_object
.type sbMax,%gnu_unique_object
.type storedExpMax,%gnu_unique_object
.type realExpMax,%gnu_unique_object
.type mantMax,%gnu_unique_object

.global sb0,sb1,storedExp0,storedExp1,realExp0,realExp1,mant0,mant1
.type sb0,%gnu_unique_object
.type sb1,%gnu_unique_object
.type storedExp0,%gnu_unique_object
.type storedExp1,%gnu_unique_object
.type realExp0,%gnu_unique_object
.type realExp1,%gnu_unique_object
.type mant0,%gnu_unique_object
.type mant1,%gnu_unique_object
 
.align
@ use these locations to store f0 values
f0: .word 0
sb0: .word 0
storedExp0: .word 0  /* the unmodified 8b exp value extracted from the float */
realExp0: .word 0
mant0: .word 0
 
@ use these locations to store f1 values
f1: .word 0
sb1: .word 0
realExp1: .word 0
storedExp1: .word 0  /* the unmodified 8b exp value extracted from the float */
mant1: .word 0
 
@ use these locations to store fMax values
fMax: .word 0
sbMax: .word 0
storedExpMax: .word 0
realExpMax: .word 0
mantMax: .word 0

.global nanValue 
.type nanValue,%gnu_unique_object
nanValue: .word 0x7FFFFFFF            

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
 function name: initVariables
    input:  none
    output: initializes all f0*, f1*, and *Max varibales to 0
********************************************************************/
.global initVariables
 .type initVariables,%function
initVariables:
    /* YOUR initVariables CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR}
    
    LDR r4, =0
    
    LDR r5, =f0 
    STR r4, [r5]
    LDR r5, =sb0
    STR r4, [r5]
    LDR r5, =storedExp0
    STR r4, [r5]
    LDR r5, =realExp0
    STR r4, [r5]
    LDR r5, =mant0
    STR r4, [r5]
    
    LDR r5, =f1
    STR r4, [r5]
    LDR r5, =sb1
    STR r4, [r5]
    LDR r5, =storedExp1
    STR r4, [r5]
    LDR r5, =realExp1
    STR r4, [r5]
    LDR r5, =mant1
    STR r4, [r5]

    LDR r5, =fMax
    STR r4, [r5]
    LDR r5, =sbMax
    STR r4, [r5]
    LDR r5, =storedExpMax
    STR r4, [r5]
    LDR r5, =realExpMax
    STR r4, [r5]
    LDR r5, =mantMax
    STR r4, [r5]
    
    pop {r4-r11, LR}
    BX LR
    /* YOUR initVariables CODE ABOVE THIS LINE! Don't forget to push and pop! */

    
/********************************************************************
 function name: getSignBit
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store sign bit (bit 31).
                Store a 1 if the sign bit is negative,
                Store a 0 if the sign bit is positive
                use sb0, sb1, or signBitMax for storage, as needed
    output: [r1]: mem location given by r1 contains the sign bit
********************************************************************/
.global getSignBit
.type getSignBit,%function
getSignBit:
    /* YOUR getSignBit CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR}
    
    LDR r4, [r0] /* puts the value to be unpacked in r4 */
    LDR r5, =0
    LDR r6, =1
    TST r4, 0x80000000 /* sets z flag if value in bit 31 is 0 */
    STREQ r5, [r1] /* puts the correct value of the sign bit into the given memory address */
    STRNE r6, [r1]
    
    pop {r4-r11, LR}
    BX LR
    /* YOUR getSignBit CODE ABOVE THIS LINE! Don't forget to push and pop! */
    

    
/********************************************************************
 function name: getExponent
    input:  r0: address of mem containing 32b float to be unpacked
      
    output: r0: contains the unpacked original STORED exponent bits,
                shifted into the lower 8b of the register. Range 0-255.
            r1: always contains the REAL exponent, equal to r0 - 127.
                It is a signed 32b value. This function does NOT
                check for +/-Inf or +/-0, so r1 ALWAYS contains
                r0 - 127.
                
********************************************************************/
.global getExponent
.type getExponent,%function
getExponent:
    /* YOUR getExponent CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR}
    
    LDR r4, [r0] /* puts the value to be unpacked into r4 */
    LSL r4, r4, 1 /* removes sign bit */
    LSR r0, r4, 24 /* removes mantissa and puts stored exp in r0 for output */
    CMP r0, 0
    SUBNE r1, r0, 127 /* if stored exp isn't 0, subtracts 127 and puts into r1 */
    LDREQ r1, =-126 /* otherwise, puts -126 into r1 */
    
    pop {r4-r11, LR}
    BX LR
    /* YOUR getExponent CODE ABOVE THIS LINE! Don't forget to push and pop! */
   

    
/********************************************************************
 function name: getMantissa
    input:  r0: address of mem containing 32b float to be unpacked
      
    output: r0: contains the mantissa WITHOUT the implied 1 bit added
                to bit 23. The upper bits must all be set to 0.
            r1: contains the mantissa WITH the implied 1 bit added
                to bit 23. Upper bits are set to 0. 
********************************************************************/
.global getMantissa
.type getMantissa,%function
getMantissa:
    /* YOUR getMantissa CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR}
    
    LDR r4, [r0] /* puts the value to be unpacked into r4 */
    LDR r5, =0x007FFFFF
    AND r0, r4, r5 /* removes the sign bit and exp and puts the mantissa into r0 */
    ADD r1, r0, 0x00800000 /* puts the mantissa with the implied 1 into r1 */
    
    pop {r4-r11, LR}
    BX LR
    /* YOUR getMantissa CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
 function name: asmIsZero
    input:  r0: address of mem containing 32b float to be checked
                for +/- 0
      
    output: r0:  0 if floating point value is NOT +/- 0
                 1 if floating point value is +0
                -1 if floating point value is -0
      
********************************************************************/
.global asmIsZero
.type asmIsZero,%function
asmIsZero:
    /* YOUR asmIsZero CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR}
     
    MOV r4, r0 /* stores the given address between function calls */
    BL getExponent /* r0 stored, r1 real */
    MOV r5, r0 /* puts stored exponent into r5 */
    MOV r0, r4 /* puts given address back into r0 */
    BL getMantissa /* r0 without implied, r1 with */
    MOV r6, r0 /* puts stored mantissa into r6 */
    LDR r7, [r4] /* puts the unpacked value into r7 */
    LSR r7, r7, 31 /* puts the value of the sign bit into r7 */
    
    CMP r5, 0 
    BEQ exponentZero /* exponent is 0 if z flag set */
    B notZero
    
exponentZero:
    CMP r6, 0 
    BEQ mantissaZero /* mantissa is 0 if z flag set */
    B notZero
    
mantissaZero:
    CMP r7, 0
    LDREQ r0, =1 /* returns 1 when +0 */
    LDRNE r0, =-1 /* returns -1 when -0 */
    B exitAsmIsZero
    
notZero:
    LDR r0, =0 /* returns 0 when not zero */
    
exitAsmIsZero:
    pop {r4-r11, LR}
    BX LR
    /* YOUR asmIsZero CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
 function name: asmIsInf
    input:  r0: address of mem containing 32b float to be checked
                for +/- infinity
      
    output: r0:  0 if floating point value is NOT +/- infinity
                 1 if floating point value is +infinity
                -1 if floating point value is -infinity
      
********************************************************************/
.global asmIsInf
.type asmIsInf,%function
asmIsInf:
    /* YOUR asmIsInf CODE BELOW THIS LINE! Don't forget to push and pop! */
    push {r4-r11, LR}
    
    MOV r4, r0 /* stores the given address between function calls */
    BL getExponent /* r0 stored, r1 real */
    MOV r5, r0 /* puts stored exponent into r5 */
    MOV r0, r4 /* puts given address back into r0 */
    BL getMantissa /* r0 without implied, r1 with */
    MOV r6, r0 /* puts stored mantissa into r6 */
    LDR r7, [r4] /* puts the unpacked value into r7 */
    LSR r7, r7, 31 /* puts the value of the sign bit into r7 */
    
    CMP r5, 0xFF
    BEQ exponentInf /* z flag is set if stored exponent is 0xFF */
    B notInfinity
    
exponentInf:
    CMP r6, 0
    BEQ mantissaInf /* z flag is set if stored mantissa is 0 */
    B notInfinity
    
mantissaInf:
    CMP r7, 0
    LDREQ r0, =1 /* returns 1 when +infinity */
    LDRNE r0, =-1 /* returns -1 when -infinity */
    B exitAsmIsInf
    
notInfinity:
    LDR r0, =0 /* returns 0 when not infinity */
    
exitAsmIsInf:
    pop {r4-r11, LR}
    BX LR
    /* YOUR asmIsInf CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
function name: asmFmax
function description:
     max = asmFmax ( f0 , f1 )
     
where:
     f0, f1 are 32b floating point values passed in by the C caller
     max is the ADDRESS of fMax, where the greater of (f0,f1) must be stored
     
     if f0 equals f1, return either one
     notes:
        "greater than" means the most positive number.
        For example, -1 is greater than -200
     
     The function must also unpack the greater number and update the 
     following global variables prior to returning to the caller:
     
     signBitMax: 0 if the larger number is positive, otherwise 1
     realExpMax: The REAL exponent of the max value, adjusted for
                 (i.e. the STORED exponent - (127 o 126), see lab instructions)
                 The value must be a signed 32b number
     mantMax:    The lower 23b unpacked from the larger number.
                 If not +/-INF and not +/- 0, the mantissa MUST ALSO include
                 the implied "1" in bit 23! (So the student's code
                 must make sure to set that bit).
                 All bits above bit 23 must always be set to 0.     

********************************************************************/    
.global asmFmax
.type asmFmax,%function
asmFmax:   

    /* YOUR asmFmax CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, LR}
    BL initVariables
    
    /* store input values */
    LDR r4, =f0
    STR r0, [r4]
    LDR r5, =f1
    STR r1, [r5]
    
    /* unpack and store f0 values */
    LDR r0, =f0
    LDR r1, =sb0
    BL getSignBit /* will update sb0 within function */
    
    LDR r0, =f0
    BL getExponent /* r0 has stored, r1 has real */
    LDR r4, =storedExp0
    LDR r5, =realExp0
    STR r0, [r4] /* updates exp variables */
    STR r1, [r5]
    
    LDR r0, =f0
    BL getMantissa /* r0 without implied bit, r1 with */
    LDR r4, =storedExp0
    LDR r5, [r4] 
    CBZ r5, noHiddenBit0 /* determines whether to store mantissa with or without implied bit */
    CMP r5, 255
    BEQ noHiddenBit0
    B hiddenBit0
    
noHiddenBit0:
    LDR r4, =mant0
    STR r0, [r4] /* puts mantissa without implied bit into mant0 */
    B unpackF1
    
hiddenBit0:
    LDR r4, =mant0
    STR r1, [r4] /* puts mantissa with implied bit into mant0 */
    
unpackF1:
    /* unpack and store f1 values */
    LDR r0, =f1
    LDR r1, =sb1
    BL getSignBit /* will update sb1 within function */
    
    LDR r0, =f1
    BL getExponent /* r0 has stored, r1 has real */
    LDR r4, =storedExp1
    LDR r5, =realExp1
    STR r0, [r4] /* updates exp variables */
    STR r1, [r5]
    
    LDR r0, =f1
    BL getMantissa /* r0 without implied bit, r1 with */
    LDR r4, =storedExp1
    LDR r5, [r4] 
    CBZ r5, noHiddenBit1 /* determines whether to store mantissa with or without implied bit */
    CMP r5, 255
    BEQ noHiddenBit1
    B hiddenBit1
    
noHiddenBit1:
    LDR r4, =mant1
    STR r0, [r4] /* puts mantissa without implied bit into mant1 */
    B checkSpecialValues
    
hiddenBit1:
    LDR r4, =mant1
    STR r1, [r4] /* puts mantissa with implied bit into mant1 */
    
checkSpecialValues:
    /* check for special values */
    LDR r0, =f0
    BL asmIsInf /* returns 0 if f0 is not inf, 1 if +inf, -1 if -inf */
    CMP r0, 1
    BEQ f0Max /* if f0 is positive infinity, store it to max */
    CMP r0, -1
    BEQ f1Max /* if f0 is negative infinity, store f1 to max */
    
    LDR r0, =f1
    BL asmIsInf /* returns 0 if f1 is not inf, 1 if +inf, -1 if -inf */
    CMP r0, 1
    BEQ f1Max /* if f1 is positive infinity, store it to max */
    CMP r0, -1
    BEQ f0Max /* if f1 is negative infinity, store f0 to max */
    
    /* if not determined, compare sign bit of each */
    LDR r4, =sb0
    LDR r5, [r4]
    LDR r6, =sb1
    LDR r7, [r6]
    CMP r5, r7 /* n = 1 -> f0 greater, n = 0 -> f1 greater */
    BEQ checkExponent /* do if sign bits are equal */
    BMI f0Max
    BPL f1Max
    
checkExponent:
    /* if not determined, compare exponent of each */
    LDR r4, =realExp0
    LDR r5, [r4] 
    LDR r6, =realExp1
    LDR r7, [r6]
    CMP r5, r7 /* z = 0 -> check sign bits */
    BEQ checkMantissa /* do if exponents are equal */
    
    LDR r8, =sb0
    LDR r9, [r8] /* only need to check one sign bit, bits are same if got here */
    CMP r9, 0 /* z = 0 -> both numbers negative */
    BNE exponentWithNegatives
    CMP r5, r7 /* n = 0 -> f0 is greater */
    BPL f0Max /* z flag can't be set if got here */
    BMI f1Max
    B checkMantissa /* skip negative section */
    
exponentWithNegatives:
    CMP r5, r7 /* n = 0 -> f1 is greater */
    BPL f1Max /* z flag can't be set if got here */
    BMI f0Max
    
checkMantissa:
    /* if not determined, compare mantissa of each */
    LDR r4, =mant0
    LDR r5, [r4]
    LDR r6, =mant1
    LDR r7, [r6]
    CMP r5, r7 /* z = 0 -> check sign bits */
    BEQ f0Max /* if got here, floats are equal */
    
    LDR r8, =sb0
    LDR r9, [r8] /* only need to check one sign bit, bits are same if got here */
    CMP r9, 0 /* z = 0 -> both numbers negative */
    BNE mantissaWithNegatives
    CMP r5, r7 /* n = 0 -> f0 is greater */
    BPL f0Max /* z flag can't be set if got here */
    BMI f1Max
    B f0Max /* skip negative section */
    
mantissaWithNegatives:
    CMP r5, r7 /* n = 0 -> f1 is greater */
    BPL f1Max /* z flag can't be set if got here */
    BMI f0Max
    
f0Max:
    LDR r4, =f0
    LDR r5, [r4] /* gets value of float */
    LDR r6, =fMax
    STR r5, [r6] /* stores float into max variable */
    
    LDR r4, =sb0
    LDR r5, [r4] /* gets value of sign bit */
    LDR r6, =sbMax
    STR r5, [r6] /* stores sign bit into max variable */
    
    LDR r4, =storedExp0
    LDR r5, [r4] /* gets value of biased exponent */
    LDR r6, =storedExpMax
    STR r5, [r6] /* stores biased exponent into max variable */
    
    LDR r4, =realExp0
    LDR r5, [r4] /* gets value of real exponent */
    LDR r6, =realExpMax
    STR r5, [r6] /* stores real exponent into max variable */
    
    LDR r4, =mant0
    LDR r5, [r4] /* gets value of mantissa */
    LDR r6, =mantMax
    STR r5, [r6] /* stores mantissa into max variable */
    B returnFMax
    
f1Max:
    LDR r4, =f1
    LDR r5, [r4] /* gets value of float */
    LDR r6, =fMax
    STR r5, [r6] /* stores float into max variable */
    
    LDR r4, =sb1
    LDR r5, [r4] /* gets value of sign bit */
    LDR r6, =sbMax
    STR r5, [r6] /* stores sign bit into max variable */
    
    LDR r4, =storedExp1
    LDR r5, [r4] /* gets value of biased exponent */
    LDR r6, =storedExpMax
    STR r5, [r6] /* stores biased exponent into max variable */
    
    LDR r4, =realExp1
    LDR r5, [r4] /* gets value of exponent */
    LDR r6, =realExpMax
    STR r5, [r6] /* stores exponent into max variable */
    
    LDR r4, =mant1
    LDR r5, [r4] /* gets value of mantissa */
    LDR r6, =mantMax
    STR r5, [r6] /* stores mantissa into max variable */
    
returnFMax:
    /* return address of fMax in r0 */
    LDR r0, =fMax
    
    pop {r4-r11, LR}
    BX LR
    /* YOUR asmFmax CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           



