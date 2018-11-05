@ ARM Assembly - exercise 6
@ 
@ Roshan Ragel - roshanr@pdn.ac.lk
@ Hasindu Gamaarachchi - hasindu@ce.pdn.ac.lk

	.text 	@ instruction memory

	
@ Write YOUR CODE HERE	

@ ---------------------	
@Implement gcd subroutine to find gcd of arg1 and arg2
 gcd:

mov r3,r0

loop1 : sub r3,r3,r1 // a-b
        cmp r3,#0 // check whether reminder is zero
        blt goloop1  // go to find the reminder
        b loop1 
goloop1 : add r3,r3,r1 // get the reminder to r3
          cmp r3,#0  // compare the reminder with zero
          beq exit  // if equal go to exit
          mov r7,r3 // t=a
          mov r3,r1// a=b
          mov r1,r7 // b=t
          b loop1   

exit : mov r0,r1 // load the result to r0
       mov pc,lr  // back to the main fun    
@ ---------------------	

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #64 	@the value a
	mov r5, #24 	@the value b
	

	@ calling the mypow function
	mov r0, r4 	@the arg1 load
	mov r1, r5 	@the arg2 load
	bl gcd
	mov r6,r0
	

	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	mov r3, r6
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "gcd(%d,%d) = %d\n"

