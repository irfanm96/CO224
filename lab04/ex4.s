
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	ldr r0,=formatinput // load the print format 
        bl printf // print
        
	sub sp, sp, #4 // get space for the string
	mov r1,sp

	ldr	r0, =formatinputnumber
	bl scanf // call scanf
	
        ldr r8,[sp,#0]
 	add sp,sp,#4	
	sub sp, sp, #100 // get space for the string
	mov r5, sp // move the address to r5

	sub sp, sp, #1 // get space for the string
	mov r1,sp
	ldr	r0, =formats
	bl scanf // call scanf
	add sp,sp,#1

       cmp r8,#0
       ble invalid


 
	
mainloop: cmp r8,#0
          beq exit
           
scan:	
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
        beq exit1 // if all charcters printed ,go to exit
	sub r5,r5,#1 // move stack downwords
        sub r7,r7,#1  // decrement the length
        ldrb r1,[r5,#0] // load the charcater
        ldr r0,=formatp1 // load the print format 
        bl printf // print
        b loop2 // loop back
       
    exit1:
		ldr r0,=check // load the print format 
        bl printf // print
        
		sub r8,r8,#1
        b mainloop
  

invalid: ldr r0,=invalidp // load the print format 
        bl printf // print
        
	 	 
    exit: add sp,sp,#100
 @   stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
formats: .asciz "%c"
formatp1: .asciz "%c"
formatinputnumber: .asciz "%d"
check: .asciz "\n"
invalidp: .asciz "invalid Input\n"
formatinput: .asciz "enter number of strings:"

