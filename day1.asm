SYS_EXIT: equ   0x2000001
SYS_READ: equ   0x2000003
SYS_WRITE: equ  0x2000004
SYS_MMAP: equ   0x20000C5
STDIN: equ      0
STDOUT: equ     1
NEWLINE: equ    10
MEM_RW: equ     0x03
MEM_FLAGS: equ  0x1001 ;; MAP_ANON | MAP_SHARED

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
    mov     rax, 0
    mov     r11, rsp
add_num:
    add     rax, [r11]
    add     r11, 8
    cmp     r11, r12
    jl      add_num
output:
    call    output_number

;; Find the repeated number!
allocate_set:
    mov     rax, SYS_MMAP
    ;; rdi, rsi, rdx, r10, r8, r9
    ;; mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset)
    mov     rdi, 0
    mov     rsi, 0x100000000  ;; lazy allocation! it's fine to ask for 4GB!
    mov     rdx, MEM_RW
    mov     r10, MEM_FLAGS
    mov     r8, -1
    mov     r9, 0
    syscall
    mov     r13, 0x080000000
    add     r13, rax

;; Repeatedly scans through the numbers, marking values in the set.
find_repeated_number:
    mov     rax, 0
    mov     byte [r13], 1
find_repeat:
    mov     r11, r12
scan:
    sub     r11, 8
    add     rax, [r11]
    ;; Stop if we find set[sum] != 0
    cmp     byte [r13 + rax], 0
    jne     found_repeated_number
    mov     byte [r13 + rax], 1
    cmp     r11, rsp
    jle     find_repeat
    jmp     scan

found_repeated_number:
    call    output_number

exit:
    mov     rax, SYS_EXIT
    mov     rdi, 0
    syscall

;; Prints the number it gets from rax to stdout
output_number:
    push    rax
    push    r10
    push    r11
    push    r14
    push    r15
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
    pop     r15
    pop     r14
    pop     r11
    pop     r10
    pop     rax
    ret
