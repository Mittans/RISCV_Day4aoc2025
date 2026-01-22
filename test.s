.global _start

.section .text
_start:
      # li a0, 1 #fd to write to. 1 is stdout
      # la a1, hello #address to write. Needs 0 terminated
      # li a2, 13 #how many bytes to write. hardcode it lole
      # li a7, 64 #syscall for write
      # ecall
      #
      # li a0, 1
      # la a1, hello2
      # li a2, 13
      # li a7, 64
      # ecall

_openfile:
        # fd = openat(AT_FDCWD, filename, O_RDONLY, 0)
        # fd <0 is bad
        li      a0, -100 # AT_FDCWD is a magic number. -100 means read from relative path
        la      a1, inputfile # pathname. Either day4sample.txt or day4.txt
        li      a2, 0               # O_RDONLY magic value is 0 (only read, what we want)
        li      a3, 0               # mode? No idea, just leave at 0
        li      a7, 56              # syscall for openat()
        ecall
        mv      s0, a0              # save the fd
        bltz    s0, _fatal           # if fd < 0 => error

_printmap:
        #mapFD must be in s0
        # n = read(fd, buf, 19000)
        mv      a0, s0  #Move s0 (fd) to a0 arg
        la      a1, buf #Use the buf as output
        li      a2, 20000 #Read 19000 bytes in. Day4.txt is 18632 chars
        li      a7, 63              # __NR_read
        ecall
        mv      t0, a0              # n
        mv      s1, a0  #Save to s1 the map length (important)
        bltz    a0, _fatal           # error

        # write(fd, buf, n)
        li      a0, 1               # stdout
        la      a1, buf
        mv      a2, t0
        li      a7, 64              # __NR_write
        ecall 

_done:
    # close(fd)
    mv      a0, s0
    li      a7, 57              # __NR_close
    ecall



        la   t1, buf        # pointer = buf
        li  s2, 0
        li t3, 10

#AT THIS POINT THE MAP IS LOADED
#THE FULL LENGTH IS SAVED IN S1
_getwidth: #we need a map width for da convolution. save in s2
        lbu  t2, 0(t1)            # load byte (unsigned char)
        beq  t2, t3, _afterWidth   # while (ptr != end)
        addi s2, s2,  1
        addi t1, t1, 1
        j _getwidth

#AT THIS POINT THE WIDTH IS KNOWN
#WIDTH IS SAVED IN S2
_afterWidth:
        addi s2, s2, 1
        li s3, 0
        li s4, 0
        la t3, buf

#S3 is our position in the buffer. Need to loop through char by char
#S4 is our counter. Holds the final answer.
#S5 is our old counter. Needed for Part B
#ASCII 10 = \n
#ASCII 64 = @
#ASCII 46 = .
#t0 = \n
#t1 = @
#t2 = .
#t3 = ptr

#t6 = curr char

  li s5, -1 
_theloop:
  la t3, buf 


_processMap:
        li t0, 10 #t0 == \n
        li t1, 64 #t1 == @
        li t2, 46 #t2 == .
        lbu t6, 0(t3) #t6 == load char
        #addi t3, t3, 1 was moved from here. Won''t it mess up the pointer too early?
        beq t6, x0, _exit #is char null terminated? then exit
        bne t6, t1, _processCleanup #is t6 != @? if nup, skip
        call _processChar #otherwise, process the @ char

_processCleanup:
        addi s3, s3, 1 #add 1 to pos
        addi t3, t3, 1 #move t3 next post
        j _processMap


_exit:
        mv a0, s4
        ebreak
        #I can~t return the actual value, cos it's mod % 256~d, lole
        li a7, 93
        ecall

_fatal:
        neg a0, a0
        li a7, 93
        ecall

_coolcall:
        add a0, a0, 56
        ret

_processChar:
#Ok chud, you're guaranateed to be on an @ character
#s1 is length
#S2 is your width
#S3 is your pos
#S4 is your result. +1 if your convolution has <4 @'s
#t3 is the currPtr

#t0 is reset. Contains the \n char, which is useless 
#t1 is reset. But contains the @ symbol, which mite be useful
#t2 is reset but contains the . symbol which mite be useful
#t3 is the currPtr, need that
#t4 is free
#t5 is free
#t6 is free

#a0 will contain number of @''s counted
#a1 is free. Store prev ra here?

        #remu t0, s3, s2
        # Eg. Width is 4 here
        #0 1 2 \n
        #@ 5 6 \n 
        #. . . \n

        mv a1, ra
        addi t0, s3, 1
        bge s2, t0, _afterCheckTop 
        call _checkTop

_afterCheckTop:
     # middle check is always valid 
  call _checkMid
    
    # after mid check, time to check the bottom 
    # pos s3, len == s1
    # s3 + width > length

    add t0, s3, s2
    addi t0, t0, +1
    blt s1, t0, _afterCheckBot
    call _checkBot


_afterCheckBot:        

  #after everything
  li t0, 4
  bge a0, t0, 1f 
  addi s4, s4, 1

1:
  li a0, 0
  mv ra, a1
  ret


_checkMid:
  #Check Left first.
  remu t0, s3, s2 #if pos % width == 0, left wall, skip 
  beqz t0, 1f #if t0 == 0, left wall = skip
 
  addi a2, t3, -1 #then subtract 1 to get topleft
  lbu a2, 0(a2) #load byte at address
  bne a2, t1, 1f #if not != '@', skip
  addi a0, a0, 1 #if == '@', add 1 to a0

 1:
  #Check Right next.

  addi t2, s3, 2
  remu t0, t2, s2 #if pos+2 % width == 0, right wall, skip 
  beqz t0, 1f #if t0 == 0, right wall = skip
  
  addi a2, t3, 1 #then add 1 to get topleft
  lbu a2, 0(a2) #load byte at address
  bne a2, t1, 1f #if not != '@', skip
  addi a0, a0, 1 #if == '@', add 1 to a0
1:
  ret



_checkTop:
 #Check top centre first. Always valid if top is valid 
  sub a2, t3, s2 #Subtract width from pos 
  lbu a2, 0(a2) #load character at (pos - width) 
  bne a2, t1, 1f #if t1 (@) != char at (pos - width), skip
  addi a0, a0, 1

1:
 #top checked. now need to check if top left is valid 
  remu t0, s3, s2 #if pos % width == 0, left wall, skip 
  beqz t0, 1f #if t0 == 0, left wall = skip
  
  sub a2, t3, s2 #otherwise move pointer. Subtract width to get row above
  addi a2, a2, -1 #then subtract 1 to get topleft
  lbu a2, 0(a2) #load byte at address
  bne a2, t1, 1f #if not != '@', skip
  addi a0, a0, 1 #if == '@', add 1 to a0
1:
  #top left checked. now need to check if topright is valid
  addi t2, s3, 2
  remu t0, t2, s2 #if pos+2 % width == 0, right wall, skip 
  beqz t0, 1f #if t0 == 0, right wall = skip
  
  sub a2, t3, s2 #otherwise move pointer. Subtract width to get row above
  addi a2, a2, 1 #then add 1 to get topleft
  lbu a2, 0(a2) #load byte at address
  bne a2, t1, 1f #if not != '@', skip
  addi a0, a0, 1 #if == '@', add 1 to a0
1:
  ret


_checkBot:
 #Check bot centre first. Always valid if bot is valid 
  add a2, t3, s2 #Subtract width from pos 
  lbu a2, 0(a2) #load character at (pos - width) 
  bne a2, t1, 1f #if t1 (@) != char at (pos - width), skip
  addi a0, a0, 1

1:
 #bot checked. now need to check if bot left is valid 
  remu t0, s3, s2 #if pos % width == 0, left wall, skip 
  beqz t0, 1f #if t0 == 0, left wall = skip
  
  add a2, t3, s2 #otherwise move pointer. Subtract width to get row above
  addi a2, a2, -1 #then subtract 1 to get botleft
  lbu a2, 0(a2) #load byte at address
  bne a2, t1, 1f #if not != '@', skip
  addi a0, a0, 1 #if == '@', add 1 to a0
1:
  #bot left checked. now need to check if top right is valid
  addi t2, s3, 2
  remu t0, t2, s2 #if pos+2 % width == 0, right wall, skip 
  beqz t0, 1f #if t0 == 0, right wall = skip
  
  add a2, t3, s2 #otherwise move pointer. Subtract width to get row above
  addi a2, a2, 1 #then add 1 to get bot left
  lbu a2, 0(a2) #load byte at address
  bne a2, t1, 1f #if not != '@', skip
  addi a0, a0, 1 #if == '@', add 1 to a0
1:
  ret
#Check top left next. Need to check if left wall

#Check top right last. Need to chek if right wall



.section .rodata
hello: .asciz "Hello World!\n"
hello2: .asciz "Hello World2\n"
inputfile: .asciz "day4sample.txt"

        .section .bss
        .align 8
buf:
        .skip 20000

