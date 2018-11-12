
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]
	
    ldr r0, =formatps       @Enter the number of strings :
	bl printf

    sub sp, sp, #4
	ldr r0, =formatsint
	mov r1, sp
    bl scanf
	ldr r11, [sp,#0]		@number of strings
	add sp, sp, #4

    cmp r11,#0              @
    blt exit1               @ no of str < 0 -> invalid input
    beq exit2               @ no of str = 0 -> no input
    mov r10,#0              @ r10 itr for no of string loop

    loopMain:
        
        cmp r10,r11
        beq exit

        ldr r0, =formatp3   @Enter input String :
        mov r1,r10
        bl printf

        sub sp, sp, #100
        ldr r0, =formats
        mov r1, sp
        bl scanf
        mov r6, sp      @Address of Orginal String
        mov r7,#0       @length

        loop1:
        ldrb r8, [r6, #0]   @loading what was in stack
        cmp	r8, #0
        beq	endLoop1
        add	r6, r6, #1      @add of next char
        add r7, r7, #1      @length++
        b loop1
        
        endLoop1:
        mov r8,r6       @add of null character
        sub r6,r6,#1    @add of last elelement
        sub sp,sp,#100  @add of new string
        mov r9,sp       @add of new string in r8

        loop2:
        cmp r7,#0
        beq exit3

        LDRB r5,[r6, #0]    @load char from orginal
        STRB r5,[r9, #0]   @store char in new string
        ADD r9,r9,#1
        SUB r6,r6,#1
        SUB r7,r7,#1
        b loop2

        exit3:
        LDRB r5,[r8, #0]
        STRB r5,[r9, #0]

        ldr r0, =formatp4
        mov r1,r10
        bl printf

        mov r1,sp
        ldr r0, =formatp
        bl printf
        add sp, sp, #200
        ADD r10,r10,#1
        b loopMain

    exit1:
    ldr r0, =formatp1
	bl printf
    b exit

    exit2:
    ldr r0, =formatp2
	bl printf
    b exit

    exit:
	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
formatsint: .asciz "%d"
formats: .asciz "%s"

formatps: .asciz "Enter the number of strings :\n" 
formatp1: .asciz "Invalid number\n"
formatp2: .asciz "No input\n"
formatp3: .asciz "Enter input String %d :\n"
formatp4: .asciz "Output string %d is :\n"
formatp: .asciz "%s\n"

