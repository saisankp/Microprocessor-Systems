; Assignment 1 - Microprocessor Systems
; Student Number: 19314123
	area	tcd,code,readonly
	export	__main
__main	
	;First let's set all registers to 0 at the start for good practice - we can't assume they are all 0 by default.
	mov r0,#0x00000000
	mov	r1,#0x00000000
	mov	r2,#0x00000000
	mov	r3,#0x00000000
	mov	r4,#0x00000000
	mov	r5,#0x00000000
	mov	r6,#0x00000000
	mov	r7,#0x00000000
	mov	r8,#0x00000000
	mov	r9,#0x00000000
	mov	r10,#0x00000000
	mov	r11,#0x00000000
	mov	r12,#0x00000000
	
	;We don't need to put 0 into R13, R14, and R15 as they are the Stack Pointer (SP), Link Register (LR) and Program Counter (PC) respectively.
	
	;Trial one for the subroutine "fact" - with an input of 5!
	mov	r0,#0x00000005 ;Input = 5!
	bl	fact		   ;Call the subroutine
	;The result:
	;Most Significant 32 bits (R0): 0x00000000
	;Least Significant 32 bits (R1): 0x00000078
	;Total 64 bit result: 0x0000000000000078
	;C bit set : False (the result is only 7 bits long)
	;Integer representation = 5! = 120
	
	;The result should be in R0 and R1 here, so let's store them into RAM.
	ldr		r2,=ans1
	;Store the most significant bits first at the address of ans1.
	str		r0,[r2]
	;Store the least significant bits second at the address of ans1 + 4 (4 bytes after ans1).
	str		r1,[r2,#4]
	
	;Reset the registers we changed in Trial one.
	mov	r0,#0x00000000
	mov	r1,#0x00000254 ;This is to prove that no matter what other registers contain, R0 will be the only input.
	
	;Trial two for the subroutine "fact" - with an input of 14!
	mov	r0,#0x0000000E ;Input = 14!
	bl	fact		   ;Call the subroutine
	;The result:
	;Most Significant 32 bits (R0): 0x00000014
	;Least Significant 32 bits (R1): 0x4C3B2800
	;Total 64 bit result: 0x000000144C3B2800
	;C bit set : False (the result is only 37 bits long)
	;Integer representation = 14! = 87178291200
	
	;The result should be in R0 and R1 here, so let's store them into RAM.
	ldr		r2,=ans2
	;Store the most significant bits first at the address of ans2.
	str		r0,[r2]
	;Store the least significant bits second at the address of ans2 + 4 (4 bytes after ans2).
	str		r1,[r2,#4]
	
	;Reset the registers we changed in Trial two.
	mov	r0,#0x00000000
	mov	r1,#0x00000000
	
	;Trial three for the subroutine "fact" - with an input of 20!
	mov	r0,#0x00000014 ;Input = 20!
	bl	fact		   ;Call the subroutine
	;Result:
	;Most Significant 32 bits (R0): 0x21C3677C
	;Least Significant 32 bits (R1): 0x82B40000
	;Total 64 bit result: 0x21C3677C82B40000
	;C bit set : False (the result is only 62 bits long)
	;Integer representation = 20! = 2432902008176640000
	
	;The result should be in R0 and R1 here, so let's store them into RAM.
	ldr		r2,=ans3
	;Store the most significant bits first at the address of ans3.
	str		r0,[r2]
	;Store the least significant bits second at the address of ans3 + 4 (4 bytes after ans3).
	str		r1,[r2,#4]
	
	;Reset the registers we changed in Trial three.
	mov	r0,#0x00000000
	mov	r1,#0x00000000
	
	;Trial four for the subroutine "fact" - with an input of 30!
	mov	r0,#0x0000001E ;Input = 30!
	bl	fact		   ;Call the subroutine
	;Result:
	;Most Significant 32 bits (R0): 0x00000000
	;Least Significant 32 bits (R1): 0x00000000
	;Total 64 bit result: 0x0000000000000000
	;C bit set : True (the result is 108 bits - this is too many bits for us to represent in two registers)
	;Integer representation = 30! = 265252859812191058636308480000000 (108 bits long in binary - too long!)
	
	;The result should be in R0 and R1 here, so let's store them into RAM.
	ldr		r2,=ans4
	;Store the most significant bits first at the address of ans4.
	str		r0,[r2]
	;Store the least significant bits second at the address of ans4 + 4 (4 bytes after ans4).
	str		r1,[r2,#4]
	
	;Reset the registers we changed in Trial four.
	mov	r0,#0x00000000
	mov	r1,#0x00000000
	
	;Reset R2 which we used to transfer our answers into RAM.
	mov r2,#0x00000000

	;End of the main program
fin	b	fin


;Subroutine 'fact' calculates the factorial of the number passed to it in R0.
;Input parameters: 
;R0: factorial number to be calculated (i.e. for calculating 5!, R0 must be equal to 5).

;Output parameters:
;R0: The most significant 32 bits of the result.
;R1: The least significant 32 bits of the result.
fact
	;Push the registers we are going to use onto the stack.
	stmfd sp!,{r10,r11,r12,lr}
	
	;The input as a 64 bit value can be visualized as so:
    ;We can treat R0 as the Input from the user - acting as the lower 32 least significant bits of the input.
	;We can treat R1 as the upper 32 most significant bits for the input - by setting it all to 0.
	mov	r1,#0x00000000
 
	cmp r0,#1		;if (R0 != 1)
	beq done 		;
	mov r12,r0 		;Move R0 (lower end of input) into R12 to set up recursion.
	mov	r10,r1 		;Move R1 (upper end of input) into R10 to set up recursion.
	
	;Subtract 1 from the input - This is tricky because we have a 64 bit value over two registers.
	subs r0,r0,#0x00000001 	;Subtract the lower part and "s" will update the CSPR.

	;Subtract the higher part + the negation of the carry from the lower subtraction.
	sbc	r1,r1,#0x00000000	;This statement serves little purpose but follows the convention of 64 bit subtraction.
	
	bl fact		 	;With the help of recursion, the subroutine can call itself.
	
	;At this point, {R1,R0} is 64 bits and {R10,R12} is also 64 bits. Let's multiply them.
	;I have a separate subroutine for 64 bit multiplication!
pt	bl	mul64
	
	;Now the result is in {R1,R0} - R0 has the least significant bits, R1 has the most significant bits.
	
	;Restore the original contents of the registers.
	ldmfd sp!,{r10,r11,r12,lr} 

	;We need to make sure that R0 & R1 is not equal to 0. If they are zero, then an error has occured.
	;Generally, this error means that we multiplied two 64 bit numbers and the result overflowed 64 bits.
	cmp	r0,#0x00000000
	bne	there
	cmp	r1,#0x00000000
	bne	there
	
	;At this point, we know we have encountered an error, as both R0 and R1 are both 0.
	;We need to start the process of setting the C bit and ensuring R0 & R1 stay as 0 for the output.
	
	;Get the CPSR into R0.
	mrs	r0,cpsr
	
	;Load a bit mask into R1 - This is where the C bit is in the CPSR.
	;The bit mask of 0x20000000 has 0010 in it's most significant 4 bytes. Referring to the NZCV flags, 0010 sets the C bit.
	ldr	r1,=0x20000000
	
	;Turn on the equivalent of the C bit in R0.
	;By using the logical operation of "OR", we set the C bit if it isn't set already.
	orr	r0,r1 
	
	;Put R0 back into the CPSR.
	msr cpsr_f,r0 
	
	;Ensure both registers R0 and R1 are 0 to represent an error.
	mov r0,#0x00000000
	mov r1,#0x00000000
	
	;We are done with the program - an error has occured and the C bit is set, along with R0 & R1 set to 0.
	b	final
	
there	
	;We get here if R0 and R1 are not 0 - an error has not occured (so far).
	;Since the assignment specification requires the most significant 32 bits in R0 and the least significant 32 bits in R1,
	;We have to swap the registers R0 & R1 at the end as they are in the wrong order at this point in the program.
	
	;Push the register 9 onto the stack, to check if we're done with looping.
	stmfd sp!,{r9}
	;Load the address of the start of the loop - i.e. at the label "pt".
	ldr r9,=pt
	
	;If R14 (Link Register) doesn't have the address of R9 (the 'back to loop label' "pt"), then we are done with our calculations.
	;At that point, we can swap the registers to match the assignment specification.
	
	cmp	r14,r9	;If(Link Register = address of looping label)
	beq noswap	;We are in the process of calculating the answer - we plan on looping back and we don
	
	;At this point, the link register does not have the address of the looping label,
	;This means we are done with the calculations, and we can swap R0 & R1.
	stmfd sp!,{lr}
	bl	swap
	ldmfd sp!,{lr}
noswap
	;Pop off register 9, which we used to check if we're done with looping.
	ldmfd sp!,{r9}
final	
	;If we are finished with our calculations we can return to the main program - else we loop back to "pt".
	bx	lr
done		   ; if (R0 == 1)
	mov r0,#1  ;With recursion, if R0 is 1, we have reached the end of recursion.
	;Restore the original contents of the registers.
	ldmfd sp!,{r10,r11,r12,lr} 
	bx	lr


;Subsidiary subroutine 'swap' swaps the contents of two registers.
;Input parameters: 
;R0: Register one to swap.
;R1: Register two to swap.

;Output parameters:
;R0: Will contain the contents of R1 previously.
;R1: Will contain the contents of R0 previously.
swap
	stmfd sp!,{r8, lr}
	mov	r8,r1
	mov	r1,r0
	mov r0,r8
	ldmfd sp!,{r8, lr}
	bx lr


;Subsidiary subroutine 'mul64' takes in two 64 bit values and multiplies them, giving a 64 bit result.
;Input parameters: 
;R0: Least significant bits of operand 1.
;R1: Most significant bits of operand 1.
;R12: Least significant bits of operand 2.
;R10: Most significant bits of operand 2.

;Output parameters:
;R0: The least significant 32 bits of the result.
;R1: The most significant 32 bits of the result.
mul64
	;Save registers before we use them.
	stmfd sp!,{r8,r9,r10,r11,r12,lr}
	
	;Multiply both the upper and lower bits separately for operand1 and operand 2.
	umull	r8,r9,r0,r12
	umull	r10,r11,r1,r12
	
	;Store the lower part of the result into r0 - the answer is computed.
	mov	r0,r8
	;Add r9 to r10, and add it to r1.
	add	r1,r9,r10
	
	;If r11 is equal to 0, then no error has occured. 
	;If r11 is not equal to 0, then an error has occured.
	cmp	r11,#0x00000000
	beq	fine
	;At this point, an error has occured, such as multiplying two 64 bit values and getting a result bigger than 64 bits.
	;Set both registers R0 and R1 to 0 to represent an error.
	mov r0,#0x00000000
	mov r1,#0x00000000
fine

	;Now that we have completed the calculation, we can set the C flag to 0.
	;Get the CPSR into r8.
	mrs	r8,cpsr
	
	;Load a bit mask into R1 - This is where the C bit is in the CPSR.
	;The bit mask of 0xDFFFFFFF has 1101 in it's most significant 4 bytes. Referring to the NZCV flags, 1101 sets the C bit to 0.
	ldr	r9,=0xDFFFFFFF
	
	;Turn off the equivalent of the C bit in R0.
	;By using the logical operation of "OR", we set the C bit to 0 if it isn't set already.
	and	r8,r9
	
	;Put R0 back into the CPSR.
	msr cpsr_f,r8
	
	ldmfd sp!,{r8,r9,r10,r11,r12,lr}
	bx lr  

	area	MyResults,code,readwrite
;Reserving four 8-byte spaces at the start of the read-write area.
;This will allow me to store the results of my trials in the main program.

;ans1 -> Upper part stored at 0x40000000
;ans1 -> Lower part stored at 0x40000004
ans1	space	8
	
;ans2 -> Upper part stored at 0x40000008
;ans2 -> Lower part stored at 0x4000000C
ans2	space	8	

;ans3 -> Upper part stored at 0x40000010
;ans3 -> Lower part stored at 0x40000014
ans3	space	8	

;ans4 -> Upper part stored at 0x40000018
;ans4 -> Lower part stored at 0x4000001C
ans4	space	8
	end