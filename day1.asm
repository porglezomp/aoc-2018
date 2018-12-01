SYS_EXIT: equ   0x2000001
SYS_READ: equ   0x2000003
SYS_WRITE: equ  0x2000004
STDIN: equ      0
STDOUT: equ     1
NEWLINE: equ    10

global start

section .text
start:
    ;; We allocate space on the stack for reading the data into
    sub     rsp, 8
    ;; r15 holds the total so far
    mov     r15, 0

;; Read a number starting with +/- from stdin
read_num:
    mov     r14, 0
read_sign:
    ;; Read the sign
    mov     rax, SYS_READ
    mov     rdi, STDIN
    mov     rsi, rsp
    mov     rdx, 1
    syscall
    ;; If we reached EOF, go to output
    cmp     eax, 0
    je      output
    ;; Store the sign in r13
    mov     r13, [rsp]
read_digit:
    mov     rax, SYS_READ
    mov     rdi, STDIN
    mov     rsi, rsp
    mov     rdx, 1
    syscall
    ;; If we see '\n', we can stop reading digits
    cmp     byte [rsp], NEWLINE
    je      add
    ;; r14 = r14 * 10 + (digit - '0')
    imul    r14, r14, 10
    add     r14, [rsp]
    sub     r14, '0'
    jmp     read_digit

;; Use the sign stored in r13 to maybe negate r14, then add to r15
add:
    cmp     r13, '-'
    jne     skip_neg
    neg     r14
skip_neg:
    add     r15, r14
    jmp     read_num

;; Print out the final result
output:
    ;; r14 stores the length of the output buffer
    mov     r14, 1
    mov     rax, r15
    cmp     rax, 0
    mov     byte [rsp], NEWLINE
    jl      output_negate
    jne     output_digit
    ;; If the value is 0, we need to print just 0
    dec     rsp
    mov     byte [rsp], '0'
    inc     r14
    jmp     output_write
output_negate:
    ;; We need to print a positive output
    neg     rax
output_digit:
    ;; rax, rdx = rax / 10, rax % 10
    mov     rdx, 0
    mov     r10, 10
    idiv    r10
    ;; Store the digit in the output buffer
    mov     r10, '0'
    add     r10, rdx
    dec     rsp
    mov     byte [rsp], r10b
    inc     r14
    ;; If rax = 0, then we have no more digits to print
    cmp     rax, 0
    jne     output_digit
output_sign:
    cmp     r15, 0
    ;; If we're positive, don't output a sign
    jge     output_write
    ;; But if we're negative, output a '-'
    dec     rsp
    mov     byte [rsp], '-'
    inc     r14
output_write:
    ;; Write the output buffer
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, rsp
    mov     rdx, r14
    syscall

exit:
    mov     rax, SYS_EXIT
    mov     rdi, 0
    syscall
