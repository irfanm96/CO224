@ ARM Assembly - lab 2
@ 
@ Roshan Ragel - roshanr@pdn.ac.lk
@ Hasindu Gamaarachchi - hasindu@ce.pdn.ac.lk

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ Load REQUIRED VALUES HERE
	@ load i to r0
	@ load j to r1
	@load sum to r5
	
	mov r0,#1 // i=0
	mov r1,#5 //j=5
	mov r5,#0 // sum=0

	
	@ Write YOUR CODE HERE
	
	@	Sum = 0;
	@	for (i=0;i<10;i++){
	@			for(j=5;j<15;j++){
	@				if(i+j<10)
	@				sum+=i*2
	@				else 
	@				sum+=(i&j);	
	@			}	
	@	} 
	@ Put final sum to r5


	@ ---------------------

	loop1:  cmp r0,#10 // 
	        bge exit  // i>=10
	        mov r1,#5  // j=5
	loop2:	cmp r1,#15  
	        bge incrementloop1 // j>=15
	          	
		add r2,r0,r1 // i+j
		 cmp r2,#10  // i+j<10
		 bge else  // i+j >=10
 		 add r3,r0,r0 // 2*i
		 add r5,r5,r3 // sum+=(2*i)
		 b incrementloop2
	
	else : and r2,r0,r1 // i & j
	       add r5,r5,r2 // sum+= (i & j)
	       	 
		   
    incrementloop2: add r1,r1,#1 // j++
	                b loop2
	                
	  incrementloop1 :	add r0,r0,#1  //i++
					b loop1
		               

	@ ---------------------
	
	
 exit:	@ load aguments and print
    @mov r5,r0  
	ldr r0, =format
	mov r1, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "The Answer is %d (Expect 300 if correct)\n"

