# Microprocessor-Systems

` "What does “well behaved” mean in the context of subroutines?" `

A subroutine is well behaved if it does not damage the context of the calling program. This means it does not unnecessarily change register values of registers or memory contents of memory from the calling program.

` "Explain how/why your subroutine is “well behaved”" `

My subroutine "fact" is well behaved because it does not damage the contents of any registers from the calling program. Any registers which are used are pushed onto/popped off the stack appropriately to avoid this; The only registers that change are the output registers.

` "How would you test that your subroutine is well behaved?" `

I would test that my subroutine is well behaved by storing values in different registers and also into memory locations before invoking my subroutine. If the registers are the same before and after (excluding the output registers) and the memory contents are unchanged, then the subroutine is well-behaved.

` "Why is using repeated addition to implement multiplication such a bad idea?" `

The use of repeated addition is not scalable to bigger numbers. For example, if you multiply by 100, you would have to add 100 times - this is costly and inefficient. Other methods such as shifting bits would be more efficient.

` "What would happen to the program if a very large number of recursive calls were made, i.e. if there was very "deep" recursion?" `

Deep recursion will result in values being continuously added to the stack until recursion finishes - as each recursive call will push/pop values on the stack. A large number of recursive calls consequently results in stack overflow.

` "What does the term "Memory Mapped" in "Memory Mapped I/O" mean?" `

"Memory Mapped" in "Memory Mapped I/O" refers to the mapping of I/O devices to small numbers of memory locations (generally seen as the memory space of the computer), allowing the address space of a computer to be filled with RAM, ROM, and I/O devices.

` "What is the difference between a byte-sized memory-mapped interface register and a regular byte of RAM?" `

A byte-sized memory-mapped interface register is a register 8 bits in size that is accessed through an address in memory and processes information, making it available as binary data to the input register or making it available to external hardware. A regular byte of RAM is 8 bits of information stored in Random Access Memory. 

` "Why is polling considered to be inefficient?" `

Polling is considered to be inefficient because the CPU must POLL frequently to ensure it does not miss anything, resulting in higher energy usage and a waste of the CPU's computational power.

` "How could you organise polling of two or more interfaces?" `

To organise polling of two or more interfaces, you would need to constantly check for changes in all the interfaces one after each other, frequently. This ensures that all interfaces get the required attention by the CPU to not miss anything.

` "Why would polling be bad for a computer's energy consumption?" `

Polling is bad for the computer's energy consumption because the CPU is generally busy on it's own, but with polling it has to spend extra energy polling frequently, constantly checking if a condition is true. However, Interrupt Driven I/O does not do this!

` "What is the difference between "system" mode and "supervisor" mode on the ARM 7?" `

On the ARM 7, the supervisor mode is a mode of operation which is privileged, meaning it can execute privileged instructions; it also has private copies of certain registers. However, the system mode is another mode of operation which is privileged but has no register bank switch. 

` "When the term "preemptive" is used in respect of a thread or process scheduler, what does it mean?" `

The term "preemptive" means to provide a fixed time for a thread or process to execute (called a quantum), with the intention of resuming it at a later time. Round Robin is an example of a preemptive scheduling algorithm.

` "why it is inadvisable to use a general-purpose operating system in a situation where real-time operation must be guaranteed?" `

When real-time operation must be guaranteed, you need to be certain that a job will complete in a certain amount of time. Using general-purpose operation systems in this situation is inadvisable because they are not designed for that purpose; the consequences of not meeting those time constraints can be for example an aircraft landing system trying to do something else (possibly from an interrupt) when it is meant to be doing something crucial such as putting the aircraft wheels down before landing.

` "What basic hardware facilities are provided to enable system builders to enforce privilege outside the CPU ("off-chip")?" `

Basic hardware facilities provided to enable system builders to enforce privilege outside the CPU include things such as the MMU (memory management unit) to offer hardware-level memory protection for separate programs, and the two "PROT" lines to allow hardware connected to the bus to tell the mode of an access attempt.

` "Overall, which is more efficient: interrupt-driven I/O or polled I/O? In your answer, explain why and roughly estimate the difference in efficiency." `

Interrupt-driven I/O is more efficient, as the CPU does not have the responsibility of detecting any I/O opportunities; the CPU can be productive doing something else. Estimating the difference in efficiency : For example, if we need to check when a second has passed on a timer, polled I/O would have to check the timer continuously for an elapsed second for however many instruction cycles it takes until it happens. However with interrupts, when the match register hits a certain time, the interrupt handler would know a second has elapsed without having to repeatedly check and use multiple instruction cycles to do so.





