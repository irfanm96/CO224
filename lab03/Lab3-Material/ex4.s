@ ARM Assembly - exercise 4

	.text 	@ instruction memory
	
	
@ Write YOUR CODE HERE	

@ ---------------------	
 fact:
sub sp,sp,#8 // space for two items
str lr,[sp,#4] //  save the link register address
str r0, [sp,#0] // save r0


cmp r0,#1  // compare r0,#1
bge branch1 // if r0>1 go to branch 1

mov r0,#1 // base case
add sp,sp,#8 // undo the stack pointer
mov pc,lr // go to the previous call

branch1 :
 sub r0,r0,#1 // substract 1 from r0
 bl fact // recursive call

mov r1,r0
ldr r0,[sp,#0] // load the r0 from stack
ldr lr,[sp,#4] // load link register from stack
add sp,sp,#8 // reset the stack pointer

mul r0,r1,r0 // multiply old r0, new r0
mov pc,lr // move to the previous call 
@ ---------------------	

.global main	
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value n

	@ calling the fact function
	mov r0, r4 	@the arg1 load
	bl fact
	mov r5,r0
	

	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "Factorial of %d is %d\n"

