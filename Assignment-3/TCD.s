; Assignment 3 -- Interrupt Handling
;(c) Prathamesh Sai, 2021.

	area	tcd,code,readonly
	export	__main
__main

;Note: any references to 'UM' are to the User Manual.

;1. We can write some equate statements to refer to later on for the timer - UM, Table 173
T0	equ	0xE0004000	;Timer 0 Base Address
IR	equ	0			;Interrupt register
TCR	equ	4			;Timer control register
MCR	equ	0x14		;Match control register
MR0	equ	0x18		;Match Register 0 (out of the 4 available)
	
;We add the values of TCR and MCR to the timer to locate the relevant register.
;i.e. the timer control register of T0 is at 0xE0004000 + 4 = 0xE0004008, the match control register of T0 is at 0xE0004000 + 14 = 0xE0004014.

;Here are some equate statements for commands for the timer.
TimerCommandReset	equ	2 			;Storing this to the timer control register resets the timer.
TimerCommandRun	equ	1				;Storing this to the timer control register runs the timer.
TimerModeResetAndInterrupt	equ	3	;Storing this to the match control register resets the timer and sends an interrupt when the match register value is reached.
TimerResetTimer0Interrupt	equ	1	;Storing this to the interrupt register resets the interrupt request from timer 0.
TimerResetAllInterrupts	equ	0xff	;Storing this to the interrupt register resets any interrupt requests that may be pending.
Timer0ChannelNumber	equ	4 			;UM, Table 63
IRQslot_en	equ	5					;We use this to make sure it actually generates a interrupt request.
Timer0Mask	equ	1<<Timer0ChannelNumber	;UM, Table 63
	
;2. We can write some equate statements to help us initialize the VIC (Vectored Interrupt Controller) - UM, Table 41
VIC	equ	0xFFFFF000		;This is the VIC Base Address.
IntEnable	equ	0x10	;We will store the Timer0Mask inside of this location.
VectAddr	equ	0x30	;Remove any pending interrupt (may not be needed).
VectAddr0	equ	0x100	;This is vector address 0.
VectCtrl0	equ	0x200	;Used to tell the VIC to recognise the interrupts coming in from timer 0.
	
;3. We can write some equate statements to help us set up and run the application
Mode_USR	equ	0x10	;This is used to transfer the program into User mode, as requested by the assignment specification.
IO1DIR	equ	0xE0028018	;The data direction Register.
IO1SET	equ	0xE0028014	;The set register.
IO1CLR	equ	0xE002801C	;The clear register.

;4. Start of the MAIN PROGRAM

;4.1: The first part of the main program is the "initialisation" part, which sets everything up for subsequent operation.

	;We can initialize the Vectored Interrupt Control (VIC) first.
	ldr	r0,=VIC					;Get the address associated with the VIC.
	ldr	r1,=irqhan				;This label irqhan is associated with the first instruction in the interrupt handler.
	str	r1,[r0,#VectAddr0]		;Associate our interrupt handler with Vectored Interrupt Controller.
	
	;With that initialization, when an interrupt comes in that is recognized as Vectored Interrupt 0, we supply our interrupt handler's address to the CPU.
	;Now that the "front-end" is set up, we can now set up the "back-end"
	
	;Now tell the VIC to recognise the interrupts requests coming in from timer 0.
	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)	;Make sure it actually generates a interrupt request.
	str	r1,[r0,#VectCtrl0]						;Make timer 0 interrupts recongised by the Vectored Interrupt Controller.
	
	;Ensure that timer 0 interrupts will be recongised by the system.
	mov	r1,#Timer0Mask		;We will use this mask to enable timer 0 interrupts to be fully recognised.
	str	r1,[r0,#IntEnable]	;Enable timer 0 interrupts to be recognised by the system.
	
	;Remove any pending interrupts (murphy's law!) - there is a chance that interrupts are happening.
	mov	r1,#0				;We want 0 interrupts at the start.
	str	r1,[r0,#VectAddr]	;Remove any pending interrupt (may not be needed).

	;Now we can initialize timer 0.
	ldr	r0,=T0					;Get the address associated with timer 0.
	mov	r1,#TimerCommandReset	;Value to reset the timer.
	str	r1,[r0,#TCR]			;Reset timer 0 at the start of our program.
	
	mov	r1,#TimerResetAllInterrupts	;Reset any interrupts that might be pending.
	str	r1,[r0,#IR]
	
	;Put the number of ticks that the match register 0 should be looking out for.
	ldr	r1,=(14745600/1)-1 		;1000000 us = 1 second.
	str	r1,[r0,#MR0]			;The match register will now look out for that value.
	
	;Now we can use this to know that 1 second has elapsed,
	;and at that point, we would want it to generate an interrupt and reset the timer back to 0.
	
	mov	r1,#TimerModeResetAndInterrupt	;Make the timer reset and generate an interrupt request.
	str	r1,[r0,#MCR]					;Store this into the match control register to follow these instructions.
	
	;Now we can initialize the "display".
	;Let's set the direction of the 32 pins as an "output".
	ldr	r0,=IO1DIR		;Make r0 point to the data direction register.
	ldr	r1,=0xffffffff	;r1 contains a mask which has all bits set.
	str	r1,[r0]			;Make those equivalent pins as outputs.
	
	;The elapsed time at the start is 0, therefore we set all 32 pins to 0.
	;We cannot assume that all the pins will be clear!
	ldr	r0,=IO1CLR 		;Make r0 point to the clear register.
	ldr r1,=0xffffffff	;r1 contains a mask which has all bits set.
	str	r1,[r0]			;Make those equivalent pins clear.

	;Now we can set the ":" between the hours, minutes, and seconds numbers.
	ldr r0,=0x00f00f00	;Mask which has the appropriate bits set for the ":" characters, which are "1111".
	ldr	r1,=IO1SET		;We want to set those bits.
	str	r0,[r1]			;Set those pins on the "display".
	
	;Initialize a binary flag for the interrupt handler.
	ldr	r6,=check ;This points to the byte stored in memory to check if an interrupt has occured.
	mov	r0,#0	  ;We want to set it to 0 at the start.
	str	r0,[r6]	  ;This stores it into memory.
	
	mov r0,#0	;This will represent the 'units' of the seconds.
	mov	r1,#0	;This will represent the 'tens' of the seconds.
	mov r2,#0	;This will represent the 'units' of the minutes.
	mov r3,#0	;This will represent the 'tens' of the minutes.
	mov	r4,#0	;This will represent the 'units' of the hours.
	mov	r5,#0	;This will represent the 'tens' of the hours.
	
	ldr	r8,=T0					;Get the address associated with timer 0.
	mov	r7,#TimerCommandRun		;This value starts the timer
	str	r7,[r8,#TCR]			;From this point onwards, it's free game - An interrupt request can happen any second.
	
	;Now all the initialisation is finished!

	;Ensure the system is in the user mode after initialisation.
	msr	CPSR_c,#Mode_USR
	
;4.2: The second part of the main program is the "application" part that actually implements the display.

app
	ldr	r7,[r6]	;Read the binary flag value from memory.
	cmp	r7,#1	;Is that binary flag set?
	bne	notYet	;If not, we a second has not elapsed yet.
	bl	secondElapsed	;If it is set, then we go to our dedicated subroutine to deal with it.
	mov	r7,#0	;Reset the binary flag value.
	str	r7,[r6]	;Store the binary flag back into memory.
notYet	
	b	app

fin	b	fin	;Infinite loop incase the program has an error and does not loop back to "app".


;This subsidiary subroutine deals with the situation that a second has elapsed on the timer.
;This means we must update the values being shown on the "display".
;Input:
;R0: representing the 'units' of the seconds.
;R1: representing the 'tens' of the seconds.
;R2: representing the 'units' of the minutes.
;R3: representing the 'tens' of the minutes.
;R4: representing the 'units' of the hours.
;R5: representing the 'tens' of the hours.
;Output:
;R0: representing the updated 'units' of the seconds.
;R1: representing the updated 'tens' of the seconds.
;R2: representing the updated 'units' of the minutes.
;R3: representing the updated 'tens' of the minutes.
;R4: representing the updated 'units' of the hours.
;R5: representing the updated 'tens' of the hours.
;IO1PIN: The display will have changed to represent an extra elapsed second.
secondElapsed
	;Load registers and the link register onto the stack.
	stmfd sp!,{r6-r8,lr}	
	
	;Add one second to the registers in charge of the timer's values (taking a carry into account).
	bl	addOneSecond

	;Now we need to shift all the register's bits into their respective bit positions.
	;R0 is in it's place already at the least significant 4 bits.
	;R1 must be shifted to the left by 4 bits.
	lsl	r1,#4
	;R2 must be shifted to the left by 12 bits
	lsl	r2,#12
	;R3 must be shifted to the left by 16 bits
	lsl	r3,#16
	;R4 must be shifted to the left by 24 bits
	lsl	r4,#24
	;R5 must be shifted to the left by 28 bits
	lsl	r5,#28

	;Now we can combine all the times into one value to store on the pins.
	bl	combineTimes
	;Now the final combined value is in r6, including the ':' characters between the hours, minutes, and seconds.

	;With the value in r6, we can now update the "display".
	bl	updateDisplay
	
	;Now we can shift all the register's bits back into their original positions.
	;R0 was never shifted left, so we don't do anything to it.
	;R1 must be shifted to the right by 4 bits.
	lsr	r1,#4
	;R2 must be shifted to the right by 12 bits.
	lsr	r2,#12
	;R3 must be shifted to the right by 16 bits.
	lsr	r3,#16
	;R4 must be shifted to the right by 24 bits.
	lsr	r4,#24
	;R5 must be shifted to the right by 28 bits.
	lsr	r5,#28
	
	;Pop registers and the program counter off the stack.
	ldmfd sp!,{r6-r8,pc} 


;This subsidiary subroutine will add one second to the timer's values (hours, minutes, and seconds).
;It also takes into account any carry from seconds to minutes, and minutes to hours. 
;Adding one second to 23:59:59 wraps to 00:00:00.
;Inputs:
;R0: representing the 'units' of the seconds.
;R1: representing the 'tens' of the seconds.
;R2: representing the 'units' of the minutes.
;R3: representing the 'tens' of the minutes.
;R4: representing the 'units' of the hours.
;R5: representing the 'tens' of the hours.
;Outputs:
;R0: representing the updated 'units' of the seconds.
;R1: representing the updated 'tens' of the seconds.
;R2: representing the updated 'units' of the minutes.
;R3: representing the updated 'tens' of the minutes.
;R4: representing the updated 'units' of the hours.
;R5: representing the updated 'tens' of the hours.
;Key: For the number '23', '3' is the 'units' of that number, and '2' is the 'tens' of that number.
addOneSecond
	stmfd sp!,{lr}	;Load link register onto the stack.
	cmp	r0,#9		;Is the 'units' of the seconds 9?
	bne	noCarry1	;If not, then we don't have to care about a carry - add as normal!
	
	;If we get here, a carry must be executed.
	mov	r0,#0		;The 'units' of the seconds turns to 0, now we bring a carry over.
	cmp r1,#5		;Is the 'tens' of the seconds 5?
	bne	noCarry2	;If not, then we don't have to care about a carry - add as normal!
	
	;If we get here, a carry must be executed.
	mov	r1,#0		;The 'tens' of the seconds turns to 0, now we bring a carry over.
	
	;If we get here, we have a carry to bring to the "minutes" value.
minutes	
	cmp	r2,#9		;Is the 'units' of the minutes 9?
	bne	noCarry3	;If not, then we don't have to care about a carry - add as normal!
	
	;If we get here, a carry must be executed.
	mov	r2,#0		;The 'units' of the minutes turns to 0, now we bring a carry over.
	cmp	r3,#5		;Is the 'tens' of the minutes 5?
	bne	noCarry4	;If not, then we don't have to care about a carry - add as normal!
	
	;If we get here, a carry must be executed.
	mov	r3,#0		;The 'tens' of the minutes turns to 0, now we bring a carry over.
	
	;If we get here, we have a carry to bring to the "hours" value.
hours
	cmp	r4,#3		;Is the 'units' of the hours 3?
	bne	noWrap		;If not, then we have not hit the hours of '23' where we have to wrap around to 0.
	cmp	r5,#2		;Is the 'tens' of the hours 2?
	bne	noWrap		;If not, then we have not hit the hours of '23' where we have to wrap around to 0.
	
	;If we get here, The clock must be at 23:59:59, meaning we want 00:00:00 so the time wraps around.
	;r0-r3 have already been set to 0 if we get to this point.
	;We just have to set r4 and r5, and we are done.
	mov	r4,#0
	mov	r5,#0
	b done
noWrap
	;If we get here, we have not hit the hours of '23', so we can add (taking a carry into account as normal).
	cmp	r4,#9		;Is the 'units' of the hours 9?
	bne	noCarry5	;If not, then we don't have to care about a carry - add as normal!
	mov	r4,#0		;The 'units' of the hours turns to 0, now we bring a carry over.
	cmp	r5,#2		;Is the 'tens' of the hours 2?
	bne	noCarry6	;If not, then we don't have to care about a carry - add as normal!
	
	;The program should never get here (The 'tens' of the hours being 2 but the 'units' of the hour being 9 - There is no hour 29)
	;But i've included an error handling mechanism to cover any case when the program malfunctions for any reason.
	mov r1,#0
	mov r2,#0
	mov	r3,#0
	mov r4,#0
	mov r5,#0
	b	done
	
	;The following six labels represent 6 situations of no carry happening.
noCarry1
    ldr r5,=23487
	add	r0,r5	;Add 1 to the 'units' of the seconds.
	b	done
noCarry2	
	add	r1,#1	;Add 1 to the 'tens' of the seconds.
	b	done	
noCarry3
	add	r2,#1	;Add 1 to the 'units' of the minutes.
	b	done
noCarry4
	add	r3,#1	;Add 1 to the 'tens' of the minutes.
	b	done
noCarry5
	add	r4,#1	;Add 1 to the 'units' of the hours.
	b	done
noCarry6
	add	r5,#1	;Add 1 to the 'tens' of the hours.
done
	ldmfd sp!,{pc}	;Pop the program counter off the stack.


;This subsidiary subroutine takes the values for hours, minutes and seconds from different registers and combines them.
;The resulting value will be 32 bits long, representing an accurate time in the format of "hours:minutes:seconds" where ':' = "1111".
;Input:
;R0: representing the 'units' of the seconds.
;R1: representing the 'tens' of the seconds.
;R2: representing the 'units' of the minutes.
;R3: representing the 'tens' of the minutes.
;R4: representing the 'units' of the hours.
;R5: representing the 'tens' of the hours.
;Outputs:
;R6: representing the combined time in the format "hours:minutes:seconds" where ':' = "1111".
combineTimes
	;Load register and the link register onto the stack.
	stmfd sp!,{r7,lr}
	mov	r6, #0
	ldr	r7,=0x00f00f00	;Mask for the ':' characters
	orr r6,r7 			;Setting the ':' values between hours, minutes, and seconds.
	orr	r6,r0
	orr	r6,r1
	orr	r6,r2
	orr	r6,r3
	orr	r6,r4
	orr	r6,r5
	;Pop register and the program counter off the stack.
	ldmfd sp!,{r7,pc} 


;This subsidiary subroutine updates the GPIO-1 pins, and therefore updates the display for the user.
;Input:
;R6: Contains the 32 bit value representing the 32 pins that want to be set or unset.
;Output:
;IO1PIN: The display will change to represent the input register R6.
updateDisplay
	stmfd sp!,{r1,r2,lr}	;Load register and the link register onto the stack.
	;Clear all 8 output pins
	ldr r1,=IO1CLR
	mov r2,#0xffffffff
	str r2,[r1]
	;Set the pins we want to set as a new output
	ldr	r1,=IO1SET
	str	r6,[r1]
	ldmfd sp!,{r1,r2,pc}	;Pop register and the program counter off the stack.


;5. The Interrupt Handler - This will tell the main program when one second has elapsed, and it's time to update the display.
;We can let the main application know that a second has elapsed by storing a "check value" in memory.
;This lets the interrupt handler be well behaved, since it does not change the registers of the main program to store the "check value",
;and it has no parameters or return values. This is because we are not meant to know when an exception happens - we can't expect it.
;It also does not work with the time count, because it is not the job of the interrupt handler to do so - The main application deals with that.
	area	InterruptHandler, code, readonly
irqhan	
	sub	lr,lr,#4	;Bring the link register back to the previous instruction.
	stmfd	sp!,{r0,r1,r6,lr}	
	;Now we stop the timer from making the interrupt request to the VIC (we 'acknowledge' the interrupt).
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]			;Remove interrupt request from timer.
	;Now we stop the VIC from making the interrupt request to the CPU.
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	;reset VIC.
	mov	r1,#1
	str	r1,[r6]
	ldmfd	sp!,{r0,r1,r6,pc}^	;return from the interrupt, restoring pc from lr and also restoring the CPSR.
			
			
	area	RandomAccessMemory, code, readwrite
check	space	1	;This 1 byte of memory is used for the interrupt handler to tell the main program one second has elapsed.
	end