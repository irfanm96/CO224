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
        mov r1,sp // move stack pointer
        bl scanf  // call scanf function

       
        ldr r1,[sp,#0] //x	
        add sp,sp,#4  


           
	@ load aguments and print
	
        mov r5,#1 // counter=1
        mov r6,r1 // r3=x
loop:  cmp r5,r6
        bgt exit   //count > x
	ldr r0, =formatp
        mov r1,r5
        bl printf
        add r5,r5,#1  

 b loop

	@ stack handling (pop lr from the stack) and return
	exit:
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
formatp: .asciz "%d\n"
formats: .asciz "%d"
formatok: .asciz "ok\n"
