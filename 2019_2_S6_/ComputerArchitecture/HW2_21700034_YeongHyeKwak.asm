.data
digit:   .word 10, 12, 23, 28, 7, 39, 10, 11, 23, 12, 3, 4, 5, 1, 34, 17, 0, 5, 24
length:   .word 19 # the length of the digit list
integer:   .word 1

str0: .asciiz "\n"
str1: .asciiz "s-sum x-max n-min q-end"
str2: .asciiz "Finish Program"
str3: .asciiz "\n sum is "
str4: .asciiz "\n max is "
str5: .asciiz "\n min is "

.text
main:

# HERE, implement mips code
# to get the sum(), max(39), and min(0) of the ‘digit’ list above
# and to print the results (sum, max, and min)

# the printing format should be as follows:
# sum is xxx
# max is yyy
# min is zzz

  la $s0, digit
  lw $t0, integer # digit[0] + (sum of digit[1~18])
  lw $s1, 0($s0) # sum
  lw $s2, 0($s0) # max
  lw $s3, 0($s0) # min
  lw $s4, length

Loop: beq $t0, $s4, Exit # if(integer == length) go to Exit
      sll $t1, $t0, 2 # t3 = t1 * 4
      addu $t1, $t1, $s0 # t3 = digit[t3]
      lw $t2, 0($t1) # t4 = digit[int]
      addu $s1, $s1, $t2 # s1 += t4
      addi $t0, $t0, 1 # t1 = t1 + 1
      addi $s5, $s5, 1 # t1 = t1 + 1

      sltu $t3, $s2, $t2 # max case(s2<digit[i]) t5=1(max<digit[i])
      bne $t3, $zero, Max # if(t5!=0) go to max
      sltu $t4, $t2, $s3 # min case(digit[i]<s2) t5=1(min>digit[i])
      bne $t4, $zero, Min # if(t5!=0) go to min
      j Loop

Max: addu $s2, $t2, $zero
     j Loop

Min: addu $s3, $t2, $zero
     j Loop

Exit: li $v0, 4
      la $a0, str1
      syscall

      li $v0, 4
      la $a0, str0
      syscall

LoopExit : li $v0, 12
           syscall

           beq $v0, 's', sumExit
           beq $v0, 'x', maxExit
           beq $v0, 'n', minExit
           beq $v0, 'q', realExit

           j LoopExit

sumExit : li $v0, 4
          la $a0, str3
          syscall

          li $v0, 1
          add $a0, $s1, $0 #sum
          syscall

          li $v0, 4
          la $a0, str0
          syscall

          j LoopExit

maxExit : li $v0, 4
          la $a0, str4
          syscall

          li $v0, 1
          add $a0, $s2, $0 #sum
          syscall

          li $v0, 4
          la $a0, str0
          syscall

          j LoopExit

minExit : li $v0, 4
          la $a0, str5
          syscall

          li $v0, 1
          add $a0, $s3, $0 #sum
          syscall

          li $v0, 4
          la $a0, str0
          syscall

          j LoopExit

realExit : li $v0, 4
           la $a0, str0
           syscall

           li $v0, 4
           la $a0, str2
           syscall

           li $v0, 4
           la $a0, str0
           syscall

           li $v0, 10
           syscall

.end
