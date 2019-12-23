.data
matrixA:   .float 1.5, -1.2, 2.3, -2.8, 0.7, 3.9, 1.3, 1.3, 1.4, 1.0, 0.5, -1.2, 1.2, -2.1, 1.8
vectorX:   .float 3.2, -1.5, 1.1 # 3 dimension
vectorB:   .float 0.3, -0.5, 1.3, -2.1, 0.1 # 5 dimension
shapeA:    .word 5, 3 # matrix size is 5 x 3
str1: .asciiz "\nshape\n"  #
str2: .asciiz "\nThe value of Y = max(0, A*X+B) is\n"  #
space: .asciiz " "
linechange: .asciiz "\n"
.text

#
#   IN C code :
#     int i, j;
#     int C = 3, L =5;
#     float A[] = {1.5, -1.2, 2.3, -2.8, 0.7, 3.9, 1.3, 1.3, 1.4, 1.0, 0.5, -1.2, 1.2, -2.1, 1.8};
#     float X[] = {3.2, -1.5, 1.1};
#     float B[] = {0.3, -0.5, 1.3, -2.1, 0.1};
#     float R[5] = {}; 덧셈 계산을 위해 거쳐가는 부분
#     float M[5] = {}; 곱셈 게산을 위해 거쳐가는 부분
#     int temp; 일시적 사용을 위한 변수
#
#     for(i=0; i<L; i++){
#       for(j=0; j<C; j++){
#         temp = C*i+j;
#         M[i] += (A[temp]*X[j]);
#       }
#       R[i] = M[i] + B[i];
#     }
#
#     for(i = 0; i<L; i++){
#       if(R[i] < 0) R[i] = 0;
#     }
#
#     for(i = 0; i<L; i++){
#       printf("%f\n", R[i]);
#     }
#

main:
  la $s0, shapeA
  la $s1, matrixA
  la $s2, vectorX
  la $s3, vectorB

  # matrix 크기 불러오기
  lw $t0, 0($s0) # 5 (L)
  lw $t1, 4($s0) # 3 (C)

  # i = 0 반복문 변수
  li $s4, 0

  # max에서 값 비교를 위해 float 형으로 전환
  mtc1 $s4, $f1
  cvt.s.w $f1, $f1 # f1 = 0.0

  # 'shape' 출력
  li $v0, 4 # system call code for printing string = 4
  la $a0, str1
  syscall # call operating system to perform operation

  # printing shape (5 출력)
  li $v0, 1
  # la $s0, shapeA
  lw $a0, 0($s0)
  syscall

  # 빈칸 출력
  li $v0, 4 # system call code for printing string = 4
  la $a0, space
  syscall # call operating system to perform operation

  # printing shape (3 출력)
  li $v0, 1
  lw $a0, 4($s0)
  syscall

  # 'The value of Y = max(0, A*X+B) is' 출력
  li $v0, 4 # system call code for printing string = 4
  la $a0, str2
  syscall # call operating system to perform operation

  li $v0, 4
  la $a0, linechange # 줄바꿈(편의상 가독성을 높일려고)
  syscall

OutLoop : move $t2, $s4 # t2 = i
          sll $t2, $t2, 2 # i = i*4
          addu $t2, $s3, $t2 # t2 = B[i], vectorB
          lwc1 $f2, 0($t2)
          li $s5, 0 # j = 0 반복문 변수, InLoop의 변수

InLoop  : mul $t3, $t1, $s4 # t3 = C*i
          add $t3, $t3, $s5 # t3 = (C*i)+j
          sll $t3, $t3, 2 # t3 = t3*4
          addu $t3, $s1, $t3 # t3 = A[(C*i)+j], matrixA와 vectorX의 곱셈을 위한 준비
          lwc1 $f3, 0($t3) # f3 = matrixA의 값

          move $t4, $s5 # t4 = j (X[j]를 위한 변수)
          sll $t4, $t4, 2 # j = j*4
          addu $t4, $s2, $t4 # t4 = X[j]
          lwc1 $f4, 0($t4) # f4 = vectorX의 값

          mul.s $f3, $f3, $f4 # f3 = matrixA x vectorX
          add.s $f2, $f3, $f2 # f2 = f3 + vectorB

          addi $s5, $s5, 1 # j++
          bne $s5, $t1, InLoop # if j != 3(C) go to InLoop

          # 이 위로는 내부 반복문(InLoop)

          c.lt.s $f2, $f1 # f2의 값(결과값의 항목)이 0과 비교했을 때 작은 경우(음수)
          bc1t Change # Change로 이동(값 변환)
          swc1 $f2, 0($t3) # 나중에 더하는 vectorB의 위치에 결과값을 저장함(공간 크기 일치)

          li $v0, 2
          lwc1 $f12, 0($t3) # vectorB에 저장한 결과값 출력
          syscall

          li $v0, 4
          la $a0, linechange # 줄바꿈(편의상 가독성을 높일려고)
          syscall

          addi $s4, $s4, 1 # i++
          bne $s4, $t0, OutLoop # if i != 5(L) go to OutLoop

          li $v0, 10
          syscall

Change  : swc1 $f1, 0($t3) # 해당 항목(음수값)에 0을 저장

          li $v0, 2
          lwc1 $f12, 0($t3) # 저장한 항목 출력
          syscall

          li $v0, 4
          la $a0, linechange # 줄바꿈(편의상 가독성을 높일려고)
          syscall

          addi $s4, $s4, 1 # i++
          bne $s4, $t0, OutLoop # if i != 5(L) go to OutLoop, 다시 반복문 내로 복귀

.end
