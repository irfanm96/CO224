
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	sub sp, sp, #100 // get space for the string
	mov r5, sp // move the address to r5

        mov r7,#0 // string length
	loop: // scan chars
	ldr	r0, =formats
	mov	r1, r5
	bl scanf // call scanf
	ldrb r6,[r5,#0]  // load the character scanned
        add r7,r7,#1 // increment length	
	cmp r6,#'\n' // check for new line
	beq return // if new line branch to print in reverse
	add r5,r5,#1 // else move the stackpointer up
	b loop // loop again


	return:
	loop2: cmp r7,#1 // check the first charcter 
        beq exit // if all charcters printed ,go to exit
	sub r5,r5,#1 // move stack downwords
        sub r7,r7,#1  // decrement the length
        ldrb r1,[r5,#0] // load the charcater
        ldr r0,=formatp1 // load the print format 
        bl printf // print
        b loop2 // loop back
         	 
    exit: add sp,sp,#100
 @   stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
formats: .asciz "%c"
formatp1: .asciz "%c"


