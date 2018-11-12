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


           
	@ load aguments and print
	

            
        cmp r2,r3
        bne neq 
	ldr r0, =format1
        b exit  
        neq : ldr r0, =format2
	
        exit: bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format1: .asciz "equal\n"
format2: .asciz "not equal\n"
formats: .asciz "%d %d"
