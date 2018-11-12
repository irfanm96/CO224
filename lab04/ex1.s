@ ARM Assembly - exercise 4

	.text 	@ instruction memory
	
	
@ Write YOUR CODE HERE	

.global main	
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

        sub sp,sp,#4 // allocate size for two integers
        ldr r0,=formats // load %d %d
        mov r2,sp // move stack pointer
	sub sp,sp,#4 // allocate size for two integers
	mov r1,sp // move stack pointer
        bl scanf  // call scanf function

       
        ldr r2,[sp,#0] //x 
        ldr r3,[sp,#4]// y 	
        add sp,sp,#8  


        mov r6,r2// multiplication power 
        mov r5,#1 // counter
        mov r4,r2//  division  
        LSL r6,r6,r3
	LSR r4,r4,r3 	           
	@ load aguments and print  
	ldr r0, =format
        mov r1,r6
        mov r2,r4
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "%d %d\n"
formats: .asciz "%d %d"
