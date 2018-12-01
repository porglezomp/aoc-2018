SYS_EXIT: equ   0x2000001
SYS_READ: equ   0x2000003
SYS_WRITE: equ  0x2000004
STDIN: equ      0
STDOUT: equ     1
NEWLINE: equ    10

global start

section .text
start:
    ;; We allocate space on the stack for reading the data into.
    ;; We make it 8 bytes so we can use it with full width arithmetic.
    sub     rsp, 8
    mov     r12, rsp

;; Read a number starting with +/- from stdin
read_num:
    mov     r14, 0
read_sign:
    ;; Read the sign
    mov     rax, SYS_READ
    mov     rdi, STDIN
    mov     rsi, r12
    mov     rdx, 1
    syscall
    ;; If we reached EOF, go to output
    cmp     eax, 0
    je      compute_sum
    ;; Store the sign in r13
    mov     r13, [r12]
read_digit:
    mov     rax, SYS_READ
    mov     rdi, STDIN
    mov     rsi, r12
    mov     rdx, 1
    syscall
    ;; If we see '\n', we can stop reading digits
    cmp     byte [r12], NEWLINE
    je      read_done
    ;; r14 = r14 * 10 + (digit - '0')
    imul    r14, r14, 10
    add     r14, [r12]
    sub     r14, '0'
    jmp     read_digit

;; Store the number on the stack
read_done:
    cmp     r13, '-'
    jne     skip_neg
    neg     r14
skip_neg:
    push    r14
    jmp     read_num

;; Compute the sum!
compute_sum:
    mov     r15, 0
add_num:
    pop     r14
    add     r15, r14
    cmp     rsp, r12
    jne     add_num

;; Print out the final result
output:
    mov     rax, r15
    call    output_number

exit:
    mov     rax, SYS_EXIT
    mov     rdi, 0
    syscall

;; Prints the number it gets from rax to stdout
output_number:
    ;; r14 stores the length of the output buffer
    mov     r14, 1
    mov     r15, rax
    dec     rsp
    mov     byte [rsp], NEWLINE
    cmp     rax, 0
    jge     output_digit
    ;; Ensure that rax is positive
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
    add     rsp, r14
    ret
