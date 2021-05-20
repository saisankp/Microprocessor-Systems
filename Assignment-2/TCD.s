; Assignment 2 : Polling
; Student Number : 19314123

	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010
	
	;Firstly, let's set the direction of the pins 23-16 as an "output".
	ldr	r0,=IO1DIR		;Make r0 point to the DATA DIRECTION register.
	ldr	r1,=0x00ff0000	;r1 contains a mask which has bits 23-16 set.
	str	r1,[r0]			;Make those equivalent pins as outputs (acting as the 8 bit number "D").
	
	;The value of pins 23-16 should be initally 0, so let's ensure that's the case.
	ldr	r0,=IO1CLR 		;Make r0 point to the CLEAR register.
	ldr r1,=0x00ff0000	;r1 contains a mask which has bits 23-16 set.
	str	r1,[r0]			;Make those equivalent pins clear.
	
	;Store the value of the PIN register into r0.
	ldr	r0,=IO1PIN		;Make r0 point to the PIN register.
	mov	r1,#0x0f000000	;A mask for bits 27-24 which are for the 4 input pins.
	
poll
	ldr	r2,[r0]			;Read all the pin values.
	and	r3,r2,r1		;Set all bits to zero except for bit 27-24.
	cmp	r3,#0x0f000000	;Compare the input with pins 27-24 being all set.
	beq	poll			;No change in the input means we keep looping.
	
	;At this point, we the input pins 27-24 have been changed.
	
	cmp	r3,#0x0e000000	;Is bit 24 set?
	bne	try1			;If not, check other bits.
	bl	button24		;If so, then go to our dedicated subroutine for button 24.
	b	wait			;Now, we wait for button 24 to be released.
try1
	cmp	r3,#0x0d000000	;Is bit 25 set?
	bne	try2			;If not, check the other bits.
	bl	button25		;If so, then go to our dedicated subroutine for button 25.
	b	wait			;Now, we wait for button 25 to be released.
try2
	cmp	r3,#0x0b000000	;Is bit 26 set?
	bne	try3			;If not, check the other bits.
	bl	button26		;If so, then go to our dedicated subroutine for button 26.
	b	wait			;Now, we wait for button 26 to be released.
try3
	cmp	r3,#0x07000000	;Is bit 27 set?
	bne	wait			;If not, then none of the 4 input bits have been set - we wait for the non-input button to be released..
	bl	button27		;If so, then go to our dedicated subroutine for button 27.
	;Now, we wait for button 26 to be released.

	;After the button has been pressed, it needs to be released.
	;Here, we keep looping until all buttons have been released back into their initial state.
wait
	ldr	r2,[r0]			;Read all the pin values
	and	r3,r2,r1		;Set all bits to zero except for bit 27-24
	cmp	r3,#0x0f000000	;Are the input bits set as they were initially? (meaning all buttons are released)
	bne	wait			;If not, then we keep looping
	b	poll			;If so, keep polling the input bits for the next input
fin	b	fin	


;Subsidary subroutine for pressing button 24
;Input:
;R2: Contains the current pin values
;Output:
;IO1PIN: The 8 bit number "D" in the output pins 23-16 will be incremented by one.
button24
	;Load registers and the Link Register onto the stack
	stmfd sp!,{r0,r2,r3,lr}	
	and	r3,r2,#0x00ff0000	;Set all pin values to zero except for bit 23-16 and store into r3.
	lsr	r3,#16				;Shift the output bits 23-16 right by 16 bit positions to do arithmetic on it.	
	add	r3,r3,#1			;Button 24 increments the output bits by 1.
	lsl	r3,#16				;Shift the output bits 23-16 left by 16 bit positions as we are done doing arithmetic on it.
	and	r2,r2,#0xff00ffff	;Make bits 23-16 all zeros in r2.
	orr	r2,r2,r3			;Combine r2 (has bits 23-16 empty) with r3 (has bits 23-16 after arithmetic).
	
	;Clear all 8 output pins
	ldr r0,=IO1CLR
	mov r3,#0x00ff0000
	str r3,[r0]
	
	;Set the pins we want to set as a new output
	ldr	r0,=IO1SET
	str	r2,[r0]
	
	;Pop registers and the program counter off the stack
	ldmfd sp!,{r0,r2,r3,pc} 
	bx	lr
	
	
;Subsidary subroutine for pressing button 25
;Input:
;R2: Contains the current pin values
;Output:
;IO1PIN: The 8 bit number "D" in the output pins 23-16 will be decremented by one.
button25
	;Load registers and the Link Register onto the stack
	stmfd sp!,{r0,r2,r3,lr}	
	and	r3,r2,#0x00ff0000	;Set all pin values to zero except for bit 23-16 and store into r3.
	lsr	r3,#16				;Shift the output bits 23-16 right by 16 bit positions to do arithmetic on it.	
	sub	r3,r3,#1			;Button 25 decrements the output bits by 1.
	lsl	r3,#16				;Shift the output bits 23-16 left by 16 bit positions as we are done doing arithmetic on it.
	and	r2,r2,#0xff00ffff 	;Make bits 23-16 all zeros in r2.
	orr	r2,r2,r3			;Combine r2 (has bits 23-16 empty) with r3 (has bits 23-16 after arithmetic).
	
	;Clear all 8 output pins
	ldr r0,=IO1CLR
	mov r3,#0x00ff0000
	str r3,[r0]
	
	;Set the pins we want to set as a new output
	ldr	r0,=IO1SET
	str	r2,[r0]
	
	;Pop registers and the program counter off the stack
	ldmfd sp!,{r0,r2,r3,pc} 
	bx	lr
	
	
;Subsidary subroutine for pressing button 26
;Input:
;R2: Contains the current pin values
;Output:
;IO1PIN: The 8 bit number "D" in the output pins 23-16 will be shifted to the left by one bit position.
button26
	;Load registers and the Link Register onto the stack
	stmfd sp!,{r0,r2,r3,lr}	
	and	r3,r2,#0x00ff0000	;Set all pin values to zero except for bit 23-16 and store into r3.
	lsr	r3,#16				;Shift the output bits 23-16 right by 16 bit positions to do arithmetic on it.	
	lsl	r3,#1				;Button 26 shifts the output bits to the left by 1 bit.
	lsl	r3,#16				;Shift the output bits 23-16 left by 16 bit positions as we are done doing arithmetic on it.
	and	r2,r2,#0xff00ffff 	;Make bits 23-16 all zeros in r2.
	orr	r2,r2,r3			;Combine r2 (has bits 23-16 empty) with r3 (has bits 23-16 after arithmetic).
	
	;Clear all 8 output pins
	ldr r0,=IO1CLR
	mov r3,#0x00ff0000
	str r3,[r0]
	
	;Set the pins we want to set as a new output
	ldr	r0,=IO1SET
	str	r2,[r0]
	
	;Pop registers and the program counter off the stack
	ldmfd sp!,{r0,r2,r3,pc} 
	bx	lr

	
	
;Subsidary subroutine for pressing button 27
;Input:
;R2: Contains the current pin values
;Output:
;IO1PIN: The 8 bit number "D" in the output pins 23-16 will be shifted to the right by one bit position.
button27
	;Load registers and the Link Register onto the stack
	stmfd sp!,{r0,r2,r3,lr}	
	and	r3,r2,#0x00ff0000	;Set all pin values to zero except for bit 23-16 and store into r3.
	lsr	r3,#16				;Shift the output bits 23-16 right by 16 bit positions to do arithmetic on it.	
	lsr	r3,#1				;Button 27 shifts the output bits to the right by 1 bit.
	lsl	r3,#16				;Shift the output bits 23-16 left by 16 bit positions as we are done doing arithmetic on it.
	and	r2,r2,#0xff00ffff 	;Make bits 23-16 all zeros in r2.
	orr	r2,r2,r3			;Combine r2 (has bits 23-16 empty) with r3 (has bits 23-16 after arithmetic).
	
	;Clear all 8 output pins
	ldr r0,=IO1CLR
	mov r3,#0x00ff0000
	str r3,[r0]
	
	;Set the pins we want to set as a new output
	ldr	r0,=IO1SET
	str	r2,[r0]
	
	;Pop registers and the program counter off the stack
	ldmfd sp!,{r0,r2,r3,pc} 
	bx	lr
	end