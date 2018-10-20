@ ARM Assembly - exercise 5

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	mov r0, #0 @i is stored here
	mov r1, #0 @j is stored here

	
	@ Write YOUR CODE HERE
	
	@ j=0;
	@ for (i=0;i<10;i++)
	@ 		j+=i;	
	
	@ Put final j to r5

	@ ---------------------
	
	
	
	
	
	
	
	@ ---------------------
	
	
	@ load aguments and print
	ldr r0, =format
	mov r1, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "The Answer is %d (Expect 45 if correct)\n"

