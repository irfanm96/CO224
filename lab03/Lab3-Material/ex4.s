@ ARM Assembly - exercise 4

	.text 	@ instruction memory
	
	
@ Write YOUR CODE HERE	

@ ---------------------	
 fact:
sub sp,sp,#8 // space for two items
str lr,[sp,#4]
str r0, [sp,#0]


cmp r0,#1
bge l1

mov r0,#1
add sp,sp,#8
mov pc,lr

l1 :
 sub r0,r0,#1
 bl fact

mov r1,r0
ldr r0,[sp,#0]
ldr lr,[sp,#4]
add sp,sp,#8

mul r0,r1,r0
mov pc,lr
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

